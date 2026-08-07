import {
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { ProductStatus } from '@prisma/client';

import { PrismaService } from '../prisma/prisma.service';
import { UploadsService } from '../uploads/uploads.service';

import { CreateProductDto } from './dto/create-product.dto';
import { UpdateProductDto } from './dto/update-product.dto';

@Injectable()
export class ProductsService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly uploadsService: UploadsService,
  ) {}

  async create(
    createProductDto: CreateProductDto,
    farmerId: string,
  ) {
    return this.prisma.product.create({
      data: {
        ...createProductDto,
        farmerId,
      },
    });
  }

  async findMyProducts(
    farmerId: string,
  ) {
    return this.prisma.product.findMany({
      where: {
        farmerId,
      },
      include: {
        category: true,
      },
      orderBy: {
        createdAt: 'desc',
      },
    });
  }

  findAll() {
    return this.prisma.product.findMany({
      include: {
        farmer: {
          select: {
            id: true,
            fullName: true,
            email: true,
            phone: true,
            role: true,
            address: true,
            profileImage: true,
          },
        },
        category: true,
      },
      orderBy: {
        createdAt: 'desc',
      },
    });
  }

  async findOne(
    id: string,
  ) {
    const product =
      await this.prisma.product.findUnique({
        where: {
          id,
        },
        include: {
          farmer: {
            select: {
              id: true,
              fullName: true,
              email: true,
              phone: true,
              role: true,
              address: true,
              profileImage: true,
            },
          },
          category: true,
        },
      });

    if (!product) {
      throw new NotFoundException(
        'Product not found',
      );
    }

    return product;
  }

  async update(
    id: string,
    updateProductDto: UpdateProductDto,
    farmerId: string,
  ) {
    const product =
      await this.prisma.product.findUnique({
        where: {
          id,
        },
      });

    if (!product) {
      throw new NotFoundException(
        'Product not found',
      );
    }

    if (
      product.farmerId !==
      farmerId
    ) {
      throw new ForbiddenException(
        'You are not allowed to update this product',
      );
    }

    if (
      updateProductDto.imageUrl &&
      product.imageUrl &&
      updateProductDto.imageUrl !==
        product.imageUrl
    ) {
      await this.uploadsService.removeImage(
        product.imageUrl,
      );
    }

    return this.prisma.product.update({
      where: {
        id,
      },
      data: updateProductDto,
      include: {
        category: true,
      },
    });
  }

  async updateProductStatus(
    id: string,
    status: ProductStatus,
  ) {
    const product =
      await this.prisma.product.findUnique({
        where: {
          id,
        },
      });

    if (!product) {
      throw new NotFoundException(
        'Product not found',
      );
    }

    return this.prisma.product.update({
      where: {
        id,
      },
      data: {
        status,
      },
      include: {
        farmer: {
          select: {
            id: true,
            fullName: true,
            email: true,
            phone: true,
            role: true,
            address: true,
            profileImage: true,
          },
        },
        category: true,
      },
    });
  }

  async remove(
    id: string,
    farmerId: string,
  ) {
    const product =
      await this.prisma.product.findUnique({
        where: {
          id,
        },
      });

    if (!product) {
      throw new NotFoundException(
        'Product not found',
      );
    }

    if (
      product.farmerId !==
      farmerId
    ) {
      throw new ForbiddenException(
        'You are not allowed to delete this product',
      );
    }

    if (product.imageUrl) {
      await this.uploadsService.removeImage(
        product.imageUrl,
      );
    }

    return this.prisma.product.delete({
      where: {
        id,
      },
    });
  }
}