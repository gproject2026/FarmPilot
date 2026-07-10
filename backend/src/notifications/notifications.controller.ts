import {
  Body,
  Controller,
  Get,
  Param,
  Patch,
  Post,
  UseGuards,
} from '@nestjs/common';

import { NotificationsService } from './notifications.service';
import { CreateNotificationDto } from './dto/create-notification.dto';

import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CurrentUser } from '../auth/decorators/current-user.decorator';


@Controller('notifications')
export class NotificationsController {

  constructor(
    private readonly notificationsService: NotificationsService,
  ) {}


  // إنشاء إشعار (نخليه داخلي حالياً)
  @Post()
  create(
    @Body() createNotificationDto: CreateNotificationDto,
  ) {
    return this.notificationsService.create(
      createNotificationDto,
    );
  }



  // إشعارات المستخدم الحالي فقط
  @Get('my')
  @UseGuards(JwtAuthGuard)
  findMyNotifications(
    @CurrentUser() user:any,
  ){
    return this.notificationsService.findMyNotifications(
      user.id,
    );
  }



  // جلب إشعار واحد
  @Get(':id')
  findOne(
    @Param('id') id:string,
  ){
    return this.notificationsService.findOne(id);
  }



  // تحديث حالة القراءة
  @Patch(':id/read')
  @UseGuards(JwtAuthGuard)
  markAsRead(
    @Param('id') id:string,
  ){
    return this.notificationsService.markAsRead(id);
  }

}