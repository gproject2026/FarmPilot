import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { UserRole } from '@prisma/client';

@Injectable()
export class UsersService {
  constructor(private readonly prisma: PrismaService) {}

  findByEmail(email: string) {
    return this.prisma.user.findUnique({
      where: { email },
    });
  }

  createUser(data: {
    fullName: string;
    email: string;
    password: string;
    phone?: string;
    role: UserRole;
    address?: string;
  }) {
    return this.prisma.user.create({
      data,
    });
  }
}