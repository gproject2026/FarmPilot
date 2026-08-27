import {
  Body,
  Controller,
  Delete,
  Get,
  Post,
  UseGuards,
} from '@nestjs/common';

import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

import { RegisterPushDeviceDto } from './dto/register-push-device.dto';
import { PushDevicesService } from './push-devices.service';

@Controller('push-devices')
@UseGuards(JwtAuthGuard)
export class PushDevicesController {
  constructor(
    private readonly pushDevicesService: PushDevicesService,
  ) {}

  @Post('register')
  register(
    @CurrentUser()
    user: {
      id: string;
    },
    @Body()
    dto: RegisterPushDeviceDto,
  ) {
    return this.pushDevicesService.register(
      user.id,
      dto,
    );
  }

  @Delete('unregister')
  unregister(
    @CurrentUser()
    user: {
      id: string;
    },
    @Body()
    dto: RegisterPushDeviceDto,
  ) {
    return this.pushDevicesService.unregister(
      user.id,
      dto.token,
    );
  }

  @Get()
  findAll(
    @CurrentUser()
    user: {
      id: string;
    },
  ) {
    return this.pushDevicesService.findAllForUser(
      user.id,
    );
  }
}