import {
  BadRequestException,
  Injectable,
} from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

import { CreateFavoriteDto } from './dto/create-favorite.dto';

@Injectable()
export class FavoritesService {
  constructor(private readonly prisma: PrismaService) {}

  async create(
    createFavoriteDto: CreateFavoriteDto,
    customerId: string,
  ) {
    const product = await this.prisma.product.findUnique({
      where: { id: createFavoriteDto.productId },
    });

    if (!product) {
      throw new BadRequestException('Product not found');
    }

    const exists = await this.prisma.favorite.findFirst({
      where: {
        customerId,
        productId: createFavoriteDto.productId,
      },
    });

    if (exists) {
      throw new BadRequestException(
        'Product already exists in favorites',
      );
    }

    return this.prisma.favorite.create({
      data: {
        customerId,
        productId: createFavoriteDto.productId,
      },
      include: {
        product: true,
      },
    });
  }

  findAll(customerId: string) {
    return this.prisma.favorite.findMany({
      where: {
        customerId,
      },
      include: {
        product: true,
      },
    });
  }

  remove(productId: string, customerId: string) {
    return this.prisma.favorite.deleteMany({
      where: {
        customerId,
        productId,
      },
    });
  }
}