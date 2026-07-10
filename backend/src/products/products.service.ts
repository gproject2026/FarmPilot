import {
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

import { CreateProductDto } from './dto/create-product.dto';
import { UpdateProductDto } from './dto/update-product.dto';
import { UploadsService } from '../uploads/uploads.service';

@Injectable()
export class ProductsService {
  constructor(
  private readonly prisma: PrismaService,
  private readonly uploadsService: UploadsService,
) {}

  async create(createProductDto: CreateProductDto, farmerId: string) {
    return this.prisma.product.create({
      data: {
        ...createProductDto,
        farmerId,
      },
    });
  }

  async findMyProducts(farmerId: string) {

  return this.prisma.product.findMany({

    where: {
      farmerId,
    },

    include: {

      category: true,

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
    });
  }

  findOne(id: string) {
    return this.prisma.product.findUnique({
      where: { id },
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

  async update(
  id: string,
  updateProductDto: UpdateProductDto,
  farmerId: string,
) {
  const product = await this.prisma.product.findUnique({
    where: { id },
  });

  if (!product) {
    throw new NotFoundException('Product not found');
  }

  if (product.farmerId !== farmerId) {
    throw new ForbiddenException(
      'You are not allowed to update this product',
    );
  }

  if (
    updateProductDto.imageUrl &&
    product.imageUrl &&
    updateProductDto.imageUrl !== product.imageUrl
  ) {
    await this.uploadsService.removeImage(product.imageUrl);
  }

  return this.prisma.product.update({
    where: { id },
    data: updateProductDto,
  });
}

 async remove(id: string, farmerId: string) {
  const product = await this.prisma.product.findUnique({
    where: { id },
  });

  if (!product) {
    throw new NotFoundException('Product not found');
  }

  if (product.farmerId !== farmerId) {
    throw new ForbiddenException(
      'You are not allowed to delete this product',
    );
  }

  if (product.imageUrl) {
    await this.uploadsService.removeImage(product.imageUrl);
  }

  return this.prisma.product.delete({
    where: { id },
  });
}
}