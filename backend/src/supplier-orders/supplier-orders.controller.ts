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

import { CreateSupplierOrderDto } from './dto/create-supplier-order.dto';
import { UpdateSupplierOrderStatusDto } from './dto/update-supplier-order-status.dto';
import { SupplierOrdersService } from './supplier-orders.service';

interface AuthenticatedUser {
  id: string;
  role: UserRole;
}

@Controller('supplier-orders')
@UseGuards(JwtAuthGuard, RolesGuard)
export class SupplierOrdersController {
  constructor(
    private readonly supplierOrdersService: SupplierOrdersService,
  ) {}

  @Post()
  @Roles(UserRole.FARMER)
  create(
    @Body()
    createSupplierOrderDto: CreateSupplierOrderDto,
    @CurrentUser()
    user: AuthenticatedUser,
  ) {
    return this.supplierOrdersService.create(
      createSupplierOrderDto,
      user.id,
    );
  }

  @Get('farmer/my')
  @Roles(UserRole.FARMER)
  findFarmerOrders(
    @CurrentUser()
    user: AuthenticatedUser,
  ) {
    return this.supplierOrdersService.findFarmerOrders(
      user.id,
    );
  }

  @Get('supplier/my')
  @Roles(UserRole.SUPPLIER)
  findSupplierOrders(
    @CurrentUser()
    user: AuthenticatedUser,
  ) {
    return this.supplierOrdersService.findSupplierOrders(
      user.id,
    );
  }

  @Get('admin')
  @Roles(UserRole.ADMIN)
  findAll() {
    return this.supplierOrdersService.findAll();
  }

  @Get(':id')
  @Roles(
    UserRole.FARMER,
    UserRole.SUPPLIER,
    UserRole.ADMIN,
  )
  findOne(
    @Param('id')
    id: string,
    @CurrentUser()
    user: AuthenticatedUser,
  ) {
    return this.supplierOrdersService.findOne(
      id,
      user.id,
      user.role,
    );
  }

  @Patch(':id/status')
  @Roles(
    UserRole.FARMER,
    UserRole.SUPPLIER,
  )
  updateStatus(
    @Param('id')
    id: string,
    @Body()
    updateSupplierOrderStatusDto: UpdateSupplierOrderStatusDto,
    @CurrentUser()
    user: AuthenticatedUser,
  ) {
    return this.supplierOrdersService.updateStatus(
      id,
      updateSupplierOrderStatusDto.status,
      user.id,
      user.role,
    );
  }
}