import { Injectable } from '@nestjs/common';
import { UserRole } from '@prisma/client';

import { PrismaService } from '../prisma/prisma.service';
import { UpdateUserDto } from './dto/update-user.dto';

@Injectable()
export class UsersService {
  constructor(
    private readonly prisma: PrismaService,
  ) {}

  findByEmail(email: string) {
    return this.prisma.user.findUnique({
      where: {
        email,
      },
    });
  }

  findById(id: string) {
    return this.prisma.user.findUnique({
      where: {
        id,
      },
      select: {
        id: true,
        fullName: true,
        email: true,
        phone: true,
        role: true,
        address: true,
        profileImage: true,
        createdAt: true,
        updatedAt: true,
      },
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

  updateProfile(
    id: string,
    data: UpdateUserDto,
  ) {
    return this.prisma.user.update({
      where: {
        id,
      },
      data,
      select: {
        id: true,
        fullName: true,
        email: true,
        phone: true,
        role: true,
        address: true,
        profileImage: true,
        createdAt: true,
        updatedAt: true,
      },
    });
  }
}