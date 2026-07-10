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

    const crop = await this.prisma.crop.findUnique({
      where: {
        id: createReminderDto.cropId,
      },
    });


    if (!crop) {
      throw new NotFoundException(
        'Crop not found',
      );
    }


    if (crop.farmerId !== farmerId) {
      throw new ForbiddenException(
        'You cannot create reminder for this crop',
      );
    }

  }


  return this.prisma.reminder.create({
    data: {
      ...createReminderDto,
      farmerId,
      reminderDate: new Date(
        createReminderDto.reminderDate,
      ),
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
    });

  }



  findOne(id: string) {

    return this.prisma.reminder.findUnique({
      where: {
        id,
      },
      include: {
        crop: true,
      },
    });

  }



  async update(
    id: string,
    updateReminderDto: UpdateReminderDto,
    farmerId: string,
  ) {

    const reminder =
      await this.prisma.reminder.findUnique({
        where: { id },
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


    return this.prisma.reminder.update({
      where: {
        id,
      },
      data: {
        ...updateReminderDto,
        reminderDate:
          updateReminderDto.reminderDate
            ? new Date(updateReminderDto.reminderDate)
            : undefined,
      },
    });

  }




  async remove(
    id: string,
    farmerId: string,
  ) {

    const reminder =
      await this.prisma.reminder.findUnique({
        where: { id },
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
      where:{
        id,
      },
    });

  }

}