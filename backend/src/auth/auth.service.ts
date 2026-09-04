import {
  BadRequestException,
  Injectable,
  UnauthorizedException,
} from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import * as bcrypt from 'bcrypt';
import {
  createHash,
  randomInt,
} from 'crypto';

import { UsersService } from '../users/users.service';

import { ForgotPasswordDto } from './dto/forgot-password.dto';
import { LoginDto } from './dto/login.dto';
import { MailService } from './mail.service';
import { RegisterDto } from './dto/register.dto';
import { ResetPasswordDto } from './dto/reset-password.dto';

@Injectable()
export class AuthService {
  constructor(
    private readonly usersService: UsersService,
    private readonly jwtService: JwtService,
    private readonly mailService: MailService,
  ) {}

  async register(
    registerDto: RegisterDto,
  ) {
    const existingUser =
      await this.usersService.findByEmail(
        registerDto.email,
      );

    if (existingUser) {
      throw new BadRequestException(
        'Email is already registered',
      );
    }

    const hashedPassword =
      await bcrypt.hash(
        registerDto.password,
        10,
      );

    const user =
      await this.usersService.createUser({
        fullName: registerDto.fullName,
        email: registerDto.email,
        password: hashedPassword,
        phone: registerDto.phone,
        role: registerDto.role,
        address: registerDto.address,
      });

    const {
      password,
      resetPasswordToken,
      resetPasswordExpiresAt,
      ...userWithoutSensitiveData
    } = user;

    return {
      message:
        'User registered successfully',
      user: userWithoutSensitiveData,
    };
  }

  async login(
    loginDto: LoginDto,
  ) {
    const user =
      await this.usersService.findByEmail(
        loginDto.email,
      );

    if (!user) {
      throw new UnauthorizedException(
        'Invalid email or password',
      );
    }

    if (!user.isActive) {
      throw new UnauthorizedException(
        'Your account has been blocked by the administrator',
      );
    }

    const isPasswordValid =
      await bcrypt.compare(
        loginDto.password,
        user.password,
      );

    if (!isPasswordValid) {
      throw new UnauthorizedException(
        'Invalid email or password',
      );
    }

    const payload = {
      sub: user.id,
      email: user.email,
      role: user.role,
    };

    const accessToken =
      await this.jwtService.signAsync(
        payload,
      );

    const {
      password,
      resetPasswordToken,
      resetPasswordExpiresAt,
      ...userWithoutSensitiveData
    } = user;

    return {
      message: 'Login successful',
      accessToken,
      user: userWithoutSensitiveData,
    };
  }

  async forgotPassword(
    forgotPasswordDto: ForgotPasswordDto,
  ) {
    const email =
      forgotPasswordDto.email
        .trim()
        .toLowerCase();

    const user =
      await this.usersService.findByEmail(
        email,
      );

    const responseMessage =
      'If this email is registered, a password reset code has been sent';

    if (!user) {
      return {
        message: responseMessage,
      };
    }

    const resetCode =
      randomInt(0, 1000000)
        .toString()
        .padStart(6, '0');

    const hashedResetCode =
      this.hashResetToken(
        resetCode,
      );

    const expiresAt = new Date(
      Date.now() + 15 * 60 * 1000,
    );

    await this.usersService
      .saveResetPasswordToken(
        user.id,
        hashedResetCode,
        expiresAt,
      );

    await this.mailService
      .sendPasswordResetCode(
        user.email,
        resetCode,
      );

    return {
      message: responseMessage,
    };
  }

  async resetPassword(
    resetPasswordDto: ResetPasswordDto,
  ) {
    const hashedResetToken =
      this.hashResetToken(
        resetPasswordDto.token.trim(),
      );

    const user =
      await this.usersService
        .findByValidResetPasswordToken(
          hashedResetToken,
          new Date(),
        );

    if (!user) {
      throw new BadRequestException(
        'Invalid or expired reset code',
      );
    }

    const isSamePassword =
      await bcrypt.compare(
        resetPasswordDto.password,
        user.password,
      );

    if (isSamePassword) {
      throw new BadRequestException(
        'New password must be different from the current password',
      );
    }

    const hashedPassword =
      await bcrypt.hash(
        resetPasswordDto.password,
        10,
      );

    await this.usersService
      .updatePasswordAndClearResetToken(
        user.id,
        hashedPassword,
      );

    return {
      message:
        'Password reset successfully',
    };
  }

  private hashResetToken(
    token: string,
  ) {
    return createHash('sha256')
      .update(token)
      .digest('hex');
  }
}