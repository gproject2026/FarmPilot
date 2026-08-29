
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

import { Roles } from '../auth/decorators/roles.decorator';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../auth/guards/roles.guard';

import { SupplierCategoriesService } from './supplier-categories.service';

@Controller('supplier-categories')
export class SupplierCategoriesController {
  constructor(
    private readonly supplierCategoriesService: SupplierCategoriesService,
  ) {}

  @Post()
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.ADMIN)
  create(
    @Body()
    body: {
      name: string;
      description?: string;
      nameEn?: string;
      nameAr?: string;
      descriptionEn?: string;
      descriptionAr?: string;
    },
  ) {
    return this.supplierCategoriesService.create(body);
  }

  @Get()
  findAll() {
    return this.supplierCategoriesService.findAll();
  }

  @Get(':id')
  findOne(
    @Param('id')
    id: string,
  ) {
    return this.supplierCategoriesService.findOne(id);
  }

  @Patch(':id')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.ADMIN)
  update(
    @Param('id')
    id: string,
    @Body()
    body: {
      name?: string;
      description?: string | null;
      nameEn?: string | null;
      nameAr?: string | null;
      descriptionEn?: string | null;
      descriptionAr?: string | null;
    },
  ) {
    return this.supplierCategoriesService.update(id, body);
  }

  @Delete(':id')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.ADMIN)
  remove(
    @Param('id')
    id: string,
  ) {
    return this.supplierCategoriesService.remove(id);
  }
} 