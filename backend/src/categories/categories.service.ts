import {
  BadRequestException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';

import { PrismaService } from '../prisma/prisma.service';

import { CreateCategoryDto } from './dto/create-category.dto';
import { UpdateCategoryDto } from './dto/update-category.dto';

@Injectable()
export class CategoriesService {
  constructor(
    private readonly prisma: PrismaService,
  ) {}

  create(
    createCategoryDto: CreateCategoryDto,
  ) {
    return this.prisma.category.create({
      data: createCategoryDto,
    });
  }

  findAll() {
    return this.prisma.category.findMany({
      include: {
        _count: {
          select: {
            products: true,
          },
        },
      },
      orderBy: {
        name: 'asc',
      },
    });
  }

  async findOne(
    id: string,
  ) {
    const category =
      await this.prisma.category.findUnique({
        where: {
          id,
        },
        include: {
          _count: {
            select: {
              products: true,
            },
          },
        },
      });

    if (!category) {
      throw new NotFoundException(
        'Category not found',
      );
    }

    return category;
  }

  async update(
    id: string,
    updateCategoryDto: UpdateCategoryDto,
  ) {
    await this.findOne(
      id,
    );

    return this.prisma.category.update({
      where: {
        id,
      },
      data: updateCategoryDto,
      include: {
        _count: {
          select: {
            products: true,
          },
        },
      },
    });
  }

  async remove(
    id: string,
  ) {
    const category =
      await this.prisma.category.findUnique({
        where: {
          id,
        },
        include: {
          _count: {
            select: {
              products: true,
            },
          },
        },
      });

    if (!category) {
      throw new NotFoundException(
        'Category not found',
      );
    }

    if (
      category._count.products > 0
    ) {
      throw new BadRequestException(
        'Cannot delete a category that contains products',
      );
    }

    return this.prisma.category.delete({
      where: {
        id,
      },
    });
  }
}