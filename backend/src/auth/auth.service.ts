import {
  BadRequestException,
  Injectable,
  UnauthorizedException,
} from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import * as bcrypt from 'bcrypt';
import {
  createHash, 
  randomBytes, 
} from 'crypto'; 

import { UsersService } from '../users/users.service';

import { ForgotPasswordDto } from './dto/forgot-password.dto';
import { LoginDto } from './dto/login.dto';
import { RegisterDto } from './dto/register.dto';
import { ResetPasswordDto } from './dto/reset-password.dto';

@Injectable()
export class AuthService {
  constructor(
    private readonly usersService: UsersService,
    private readonly jwtService: JwtService,
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

    /*
     * نرجع رسالة عامة إذا لم يوجد الحساب،
     * حتى لا يستطيع أحد معرفة الإيميلات
     * المسجلة داخل النظام.
     */
    if (!user) {
      return {
        message:
            'If this email is registered, a password reset token has been generated',
      };
    }

    const resetToken =
        randomBytes(32).toString('hex');

    const hashedResetToken =
        this.hashResetToken(
      resetToken,
    );

    const expiresAt = new Date(
      Date.now() + 15 * 60 * 1000,
    );

    await this.usersService
        .saveResetPasswordToken(
      user.id,
      hashedResetToken,
      expiresAt,
    );

    /*
     * نرجع الرمز حاليًا فقط لتجربة المشروع.
     * لاحقًا سيتم إرساله إلى البريد الإلكتروني
     * بدل إظهاره في الاستجابة.
     */
    return {
      message:
          'Password reset token generated successfully',
      resetToken,
      expiresAt,
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
        'Invalid or expired reset token',
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