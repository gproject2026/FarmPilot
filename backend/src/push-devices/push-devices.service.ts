import { Injectable } from '@nestjs/common';

import { PrismaService } from '../prisma/prisma.service';
import { RegisterPushDeviceDto } from './dto/register-push-device.dto';

@Injectable()
export class PushDevicesService {
  constructor(
    private readonly prisma: PrismaService,
  ) {}

  async register(
    userId: string,
    dto: RegisterPushDeviceDto,
  ) {
    return this.prisma.pushDevice.upsert({
      where: {
        token: dto.token,
      },
      update: {
        userId,
        platform: dto.platform,
      },
      create: {
        userId,
        token: dto.token,
        platform: dto.platform,
      },
    });
  }

  async unregister(
    userId: string,
    token: string,
  ) {
    await this.prisma.pushDevice.deleteMany({
      where: {
        userId,
        token,
      },
    });

    return {
      message: 'Push device unregistered successfully',
    };
  }

  findAllForUser(userId: string) {
    return this.prisma.pushDevice.findMany({
      where: {
        userId,
      },
      orderBy: {
        updatedAt: 'desc',
      },
    });
  }
}