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

import { CreateCropDto } from './dto/create-crop.dto';
import { UpdateCropDto } from './dto/update-crop.dto';
import { CropsService } from './crops.service';

@Controller('crops')
export class CropsController {
  constructor(private readonly cropsService: CropsService) {}

  @Post()
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.FARMER)
  create(@Body() createCropDto: CreateCropDto, @CurrentUser() user: any) {
    return this.cropsService.create(createCropDto, user.id);
  }

  @Get()
  findAll() {
    return this.cropsService.findAll();
  }

  @Get(':id')
  findOne(@Param('id') id: string) {
    return this.cropsService.findOne(id);
  }

  @Patch(':id')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.FARMER)
  update(
    @Param('id') id: string,
    @Body() updateCropDto: UpdateCropDto,
    @CurrentUser() user: any,
  ) {
    return this.cropsService.update(id, updateCropDto, user.id);
  }

  @Delete(':id')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.FARMER)
  remove(@Param('id') id: string, @CurrentUser() user: any) {
    return this.cropsService.remove(id, user.id);
  }
}