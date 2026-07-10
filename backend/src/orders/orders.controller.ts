import { Body, Controller, Get, Param, Post, UseGuards } from '@nestjs/common';
import { UserRole } from '@prisma/client';

import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { Roles } from '../auth/decorators/roles.decorator';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../auth/guards/roles.guard';

import { CreateOrderDto } from './dto/create-order.dto';
import { OrdersService } from './orders.service';

import { OrderStatus } from '@prisma/client'; import { Patch } from '@nestjs/common';
@Controller('orders')
export class OrdersController {
  constructor(private readonly ordersService: OrdersService) {}

  @Post()
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.CUSTOMER)
  create(@Body() createOrderDto: CreateOrderDto, @CurrentUser() user: any) {
    return this.ordersService.create(createOrderDto, user.id);
  }

  @Get()
  findAll() {
    return this.ordersService.findAll();
  }

  @Get(':id')
  findOne(@Param('id') id: string) {
    return this.ordersService.findOne(id);
  }

  @Patch(':id/status')
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles(UserRole.FARMER)
updateStatus(
  @Param('id') id: string,
  @Body('status') status: OrderStatus,
) {
  return this.ordersService.updateStatus(id, status);
}
}