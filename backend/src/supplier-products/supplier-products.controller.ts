import {
  BadRequestException,
  Body,
  Controller,
  Delete,
  Get,
  Param,
  Patch,
  Post,
  Query,
  UploadedFile,
  UseGuards,
  UseInterceptors,
} from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { UserRole } from '@prisma/client';
import { diskStorage } from 'multer';
import { extname } from 'path';

import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { Roles } from '../auth/decorators/roles.decorator';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../auth/guards/roles.guard';

import { CreateSupplierProductDto } from './dto/create-supplier-product.dto';
import { UpdateSupplierProductDto } from './dto/update-supplier-product.dto';
import { SupplierProductsService } from './supplier-products.service';

interface AuthenticatedUser {
  id: string;
  email: string;
  role: UserRole;
}

@Controller('supplier-products')
export class SupplierProductsController {
  constructor(
    private readonly supplierProductsService: SupplierProductsService,
  ) {}

  @Post()
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.SUPPLIER)
  create(
    @Body()
    createSupplierProductDto: CreateSupplierProductDto,
    @CurrentUser()
    user: AuthenticatedUser,
  ) {
    return this.supplierProductsService.create(
      createSupplierProductDto,
      user.id,
    );
  }

  @Post('upload-image')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.SUPPLIER)
  @UseInterceptors(
    FileInterceptor('image', {
      storage: diskStorage({
        destination: './uploads',

        filename: (
          request,
          file,
          callback,
        ) => {
          const uniqueName =
            Date.now() +
            '-' +
            Math.round(
              Math.random() * 1e9,
            );

          const fileExtension =
            extname(
              file.originalname,
            ).toLowerCase();

          callback(
            null,
            `supplier-product-${uniqueName}${fileExtension}`,
          );
        },
      }),

      fileFilter: (
        request,
        file,
        callback,
      ) => {
        const allowedImageTypes = [
          'image/jpeg',
          'image/jpg',
          'image/png',
          'image/webp',
        ];

        if (
          !allowedImageTypes.includes(
            file.mimetype,
          )
        ) {
          return callback(
            new BadRequestException(
              'Only JPG, JPEG, PNG, and WEBP images are allowed',
            ),
            false,
          );
        }

        callback(
          null,
          true,
        );
      },

      limits: {
        fileSize:
          5 * 1024 * 1024,
      },
    }),
  )
  uploadProductImage(
    @UploadedFile()
    file?: Express.Multer.File,
  ) {
    if (!file) {
      throw new BadRequestException(
        'Product image is required',
      );
    }

    return {
      message:
        'Image uploaded successfully',

      imageUrl:
        `/uploads/${file.filename}`,

      filename:
        file.filename,
    };
  }

  @Get()
  findAll(
    @Query('categoryId')
    categoryId?: string,
  ) {
    return this.supplierProductsService.findAll(
      categoryId,
    );
  }

  @Get('my')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.SUPPLIER)
  findMyProducts(
    @CurrentUser()
    user: AuthenticatedUser,
  ) {
    return this.supplierProductsService.findMyProducts(
      user.id,
    );
  }

  @Get(':id')
  findOne(
    @Param('id')
    id: string,
  ) {
    return this.supplierProductsService.findOne(
      id,
    );
  }

  @Patch(':id')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.SUPPLIER)
  update(
    @Param('id')
    id: string,

    @Body()
    updateSupplierProductDto: UpdateSupplierProductDto,

    @CurrentUser()
    user: AuthenticatedUser,
  ) {
    return this.supplierProductsService.update(
      id,
      updateSupplierProductDto,
      user.id,
    );
  }

  @Delete(':id')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.SUPPLIER)
  remove(
    @Param('id')
    id: string,

    @CurrentUser()
    user: AuthenticatedUser,
  ) {
    return this.supplierProductsService.remove(
      id,
      user.id,
    );
  }
}