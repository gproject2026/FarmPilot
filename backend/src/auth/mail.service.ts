import {
  Injectable,
  InternalServerErrorException,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import * as nodemailer from 'nodemailer';

@Injectable()
export class MailService {
  private readonly transporter;

  constructor(
    private readonly configService: ConfigService,
  ) {
    const mailUser =
      this.configService.getOrThrow<string>(
        'MAIL_USER',
      );

    const mailPass =
      this.configService.getOrThrow<string>(
        'MAIL_PASS',
      );

    this.transporter =
      nodemailer.createTransport({
        service: 'gmail',
        auth: {
          user: mailUser,
          pass: mailPass,
        },
      });
  }

  async sendPasswordResetCode(
    email: string,
    code: string,
  ) {
    const mailUser =
      this.configService.getOrThrow<string>(
        'MAIL_USER',
      );

    try {
      await this.transporter.sendMail({
        from: `"FarmPilot" <${mailUser}>`,
        to: email,
        subject: 'FarmPilot Password Reset Code',
        text: `
Your FarmPilot password reset code is:

${code}

This code will expire in 15 minutes.

If you did not request a password reset, you can ignore this email.
        `.trim(),
      });
    } catch {
      throw new InternalServerErrorException(
        'Failed to send password reset email',
      );
    }
  }
}