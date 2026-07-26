import {
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';

import { PrismaService } from '../prisma/prisma.service';

import { CreateReminderDto } from './dto/create-reminder.dto';
import { UpdateReminderDto } from './dto/update-reminder.dto';

@Injectable()
export class RemindersService {
  constructor(
    private readonly prisma: PrismaService,
  ) {}

  async create(
    createReminderDto: CreateReminderDto,
    farmerId: string,
  ) {
    if (createReminderDto.cropId) {
      await this.validateCropOwnership(
        createReminderDto.cropId,
        farmerId,
      );
    }

    return this.prisma.reminder.create({
      data: {
        farmerId,
        cropId: createReminderDto.cropId,
        type: createReminderDto.type,
        reminderDate: new Date(
          createReminderDto.reminderDate,
        ),
      },
      include: {
        crop: true,
      },
    });
  }

  findAll(farmerId: string) {
    return this.prisma.reminder.findMany({
      where: {
        farmerId,
      },
      include: {
        crop: true,
      },
      orderBy: {
        reminderDate: 'asc',
      },
    });
  }

  async findOne(
    id: string,
    farmerId: string,
  ) {
    const reminder =
      await this.prisma.reminder.findUnique({
        where: {
          id,
        },
        include: {
          crop: true,
        },
      });

    if (!reminder) {
      throw new NotFoundException(
        'Reminder not found',
      );
    }

    if (reminder.farmerId !== farmerId) {
      throw new ForbiddenException(
        'You are not allowed to access this reminder',
      );
    }

    return reminder;
  }

  async update(
    id: string,
    updateReminderDto: UpdateReminderDto,
    farmerId: string,
  ) {
    const reminder =
      await this.prisma.reminder.findUnique({
        where: {
          id,
        },
      });

    if (!reminder) {
      throw new NotFoundException(
        'Reminder not found',
      );
    }

    if (reminder.farmerId !== farmerId) {
      throw new ForbiddenException(
        'You are not allowed to update this reminder',
      );
    }

    if (updateReminderDto.cropId) {
      await this.validateCropOwnership(
        updateReminderDto.cropId,
        farmerId,
      );
    }

    return this.prisma.reminder.update({
      where: {
        id,
      },
      data: {
        cropId: updateReminderDto.cropId,
        type: updateReminderDto.type,
        reminderDate:
          updateReminderDto.reminderDate
            ? new Date(
                updateReminderDto.reminderDate,
              )
            : undefined,
        status: updateReminderDto.status,
      },
      include: {
        crop: true,
      },
    });
  }

  async remove(
    id: string,
    farmerId: string,
  ) {
    const reminder =
      await this.prisma.reminder.findUnique({
        where: {
          id,
        },
      });

    if (!reminder) {
      throw new NotFoundException(
        'Reminder not found',
      );
    }

    if (reminder.farmerId !== farmerId) {
      throw new ForbiddenException(
        'You are not allowed to delete this reminder',
      );
    }

    return this.prisma.reminder.delete({
      where: {
        id,
      },
    });
  }

  private async validateCropOwnership(
    cropId: string,
    farmerId: string,
  ) {
    const crop =
      await this.prisma.crop.findUnique({
        where: {
          id: cropId,
        },
      });

    if (!crop) {
      throw new NotFoundException(
        'Crop not found',
      );
    }

    if (crop.farmerId !== farmerId) {
      throw new ForbiddenException(
        'You cannot use this crop',
      );
    }
  }
}