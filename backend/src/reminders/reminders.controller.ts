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
import { UserRole } from '@prisma/client';

import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { Roles } from '../auth/decorators/roles.decorator';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../auth/guards/roles.guard';

import { CreateReminderDto } from './dto/create-reminder.dto';
import { UpdateReminderDto } from './dto/update-reminder.dto';
import { RemindersService } from './reminders.service';

@Controller('reminders')
export class RemindersController {
  constructor(private readonly remindersService: RemindersService) {}

  @Post()
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.FARMER)
  create(
    @Body() createReminderDto: CreateReminderDto,
    @CurrentUser() user: any,
  ) {
    return this.remindersService.create(
      createReminderDto,
      user.id,
    );
  }


  @Get()
  @UseGuards(JwtAuthGuard)
  findAll(@CurrentUser() user: any) {
    return this.remindersService.findAll(user.id);
  }


  @Get(':id')
  @UseGuards(JwtAuthGuard)
  findOne(@Param('id') id: string) {
    return this.remindersService.findOne(id);
  }


  @Patch(':id')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.FARMER)
  update(
    @Param('id') id: string,
    @Body() updateReminderDto: UpdateReminderDto,
    @CurrentUser() user: any,
  ) {
    return this.remindersService.update(
      id,
      updateReminderDto,
      user.id,
    );
  }


  @Delete(':id')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.FARMER)
  remove(
    @Param('id') id: string,
    @CurrentUser() user: any,
  ) {
    return this.remindersService.remove(
      id,
      user.id,
    );
  }
}