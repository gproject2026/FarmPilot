import {
  Body,
  Controller,
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

import { CreateOrderDto } from './dto/create-order.dto';
import { UpdateOrderDto } from './dto/update-order.dto';
import { OrdersService } from './orders.service';

interface AuthenticatedUser {
  id: string;
  role: UserRole;
}

@Controller('orders')
@UseGuards(JwtAuthGuard, RolesGuard)
export class OrdersController {
  constructor(
    private readonly ordersService: OrdersService,
  ) {}

  @Post()
  @Roles(UserRole.CUSTOMER)
  create(
    @Body() createOrderDto: CreateOrderDto,
    @CurrentUser() user: AuthenticatedUser,
  ) {
    return this.ordersService.create(
      createOrderDto,
      user.id,
    );
  }

  @Get('my')
  @Roles(UserRole.CUSTOMER)
  findCustomerOrders(
    @CurrentUser() user: AuthenticatedUser,
  ) {
    return this.ordersService.findCustomerOrders(
      user.id,
    );
  }

  @Get('farmer')
  @Roles(UserRole.FARMER)
  findFarmerOrders(
    @CurrentUser() user: AuthenticatedUser,
  ) {
    return this.ordersService.findFarmerOrders(
      user.id,
    );
  }

  @Get('admin')
  @Roles(UserRole.ADMIN)
  findAll() {
    return this.ordersService.findAll();
  }

  @Get(':id')
  @Roles(
    UserRole.CUSTOMER,
    UserRole.FARMER,
    UserRole.ADMIN,
  )
  findOne(
    @Param('id') id: string,
    @CurrentUser() user: AuthenticatedUser,
  ) {
    return this.ordersService.findOne(
      id,
      user.id,
      user.role,
    );
  }

  @Patch(':id/status')
  @Roles(
    UserRole.CUSTOMER,
    UserRole.FARMER,
  )
  updateStatus(
    @Param('id') id: string,
    @Body() updateOrderDto: UpdateOrderDto,
    @CurrentUser() user: AuthenticatedUser,
  ) {
    return this.ordersService.updateStatus(
      id,
      updateOrderDto.status,
      user.id,
      user.role,
    );
  }
}