import {
  Body,
  Controller,
  Delete,
  Get,
  Param,
  Patch,
  Post,
  UseGuards,
} from '@nestjs/common';

import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

import { CreateNotificationDto } from './dto/create-notification.dto';
import { NotificationsService } from './notifications.service';

@Controller('notifications')
export class NotificationsController {
  constructor(
    private readonly notificationsService: NotificationsService,
  ) {}

  @Post()
  @UseGuards(JwtAuthGuard)
  create(
    @Body()
    createNotificationDto: CreateNotificationDto,
  ) {
    return this.notificationsService.create(
      createNotificationDto,
    );
  }

  @Post('backfill-translations')
  @UseGuards(JwtAuthGuard)
  backfillTranslations(
    @CurrentUser()
    user: any,
  ) {
    return this.notificationsService.backfillTranslations(
      user.id,
    );
  }

  @Get('my')
  @UseGuards(JwtAuthGuard)
  findMyNotifications(
    @CurrentUser()
    user: any,
  ) {
    return this.notificationsService.findMyNotifications(
      user.id,
    );
  }

  @Get(':id')
  @UseGuards(JwtAuthGuard)
  findOne(
    @Param('id')
    id: string,

    @CurrentUser()
    user: any,
  ) {
    return this.notificationsService.findOne(
      id,
      user.id,
    );
  }

  @Patch(':id/read')
  @UseGuards(JwtAuthGuard)
  markAsRead(
    @Param('id')
    id: string,

    @CurrentUser()
    user: any,
  ) {
    return this.notificationsService.markAsRead(
      id,
      user.id,
    );
  }

  @Delete(':id')
  @UseGuards(JwtAuthGuard)
  remove(
    @Param('id')
    id: string,
  ) {
    return this.notificationsService.remove(
      id,
    );
  }
}