import {
  Injectable,
  NotFoundException,
} from '@nestjs/common';

import { PrismaService } from '../prisma/prisma.service';

import { CreateNotificationDto } from './dto/create-notification.dto';
import { UpdateNotificationDto } from './dto/update-notification.dto';


@Injectable()
export class NotificationsService {

  constructor(
    private readonly prisma: PrismaService,
  ) {}


  create(
    createNotificationDto: CreateNotificationDto,
  ) {

    return this.prisma.notification.create({
      data: {
        ...createNotificationDto,
      },
    });

  }



  findAll() {

    return this.prisma.notification.findMany({
      include:{
        user:{
          select:{
            id:true,
            fullName:true,
            email:true,
            role:true,
          }
        }
      }
    });

  }



  async findOne(id: string) {

  console.log('SEARCHING NOTIFICATION ID:', id);

  const notification =
    await this.prisma.notification.findUnique({
      where: {
        id,
      },
      include: {
        user: {
          select: {
            id: true,
            fullName: true,
            email: true,
            role: true,
          },
        },
      },
    });


  if (!notification) {
    throw new NotFoundException('Notification not found');
  }


  return notification;
}

  update(
    id:string,
    updateNotificationDto:UpdateNotificationDto,
  ){

    return this.prisma.notification.update({
      where:{id},
      data:updateNotificationDto,
    });

  }




  remove(id:string){

    return this.prisma.notification.delete({
      where:{id},
    });

  }

  async findMyNotifications(userId:string){

  return this.prisma.notification.findMany({

    where:{
      userId,
    },

    orderBy:{
      createdAt:'desc',
    },

  });

}

async markAsRead(id: string) {

  const notification =
    await this.prisma.notification.findUnique({
      where: {
        id,
      },
    });


  if (!notification) {
    throw new NotFoundException(
      'Notification not found'
    );
  }


  return this.prisma.notification.update({
    where: {
      id,
    },
    data: {
      isRead: true,
    },
  });

}
}