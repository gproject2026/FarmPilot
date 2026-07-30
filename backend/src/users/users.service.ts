import {
  BadRequestException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
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

  async findByIdOrThrow(id: string) {
    const user = await this.findById(id);

    if (!user) {
      throw new NotFoundException(
        'User not found',
      );
    }

    return user;
  }

 findAll() {
  return this.prisma.user.findMany({
    orderBy: {
      createdAt: 'desc',
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

  async updateUserRole(
    adminId: string,
    userId: string,
    role: UserRole,
  ) {
    if (adminId === userId) {
      throw new BadRequestException(
        'You cannot change your own role',
      );
    }

    await this.findByIdOrThrow(userId);

    return this.prisma.user.update({
      where: {
        id: userId,
      },
      data: {
        role,
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
}
