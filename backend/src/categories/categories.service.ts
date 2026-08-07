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
    const name =
      createCategoryDto.name.trim();

    const description =
      this.cleanOptionalText(
        createCategoryDto.description,
      );

    const nameEn =
      this.cleanOptionalText(
        createCategoryDto.nameEn,
      ) ?? name;

    const nameAr =
      this.cleanOptionalText(
        createCategoryDto.nameAr,
      );

    const descriptionEn =
      this.cleanOptionalText(
        createCategoryDto.descriptionEn,
      ) ?? description;

    const descriptionAr =
      this.cleanOptionalText(
        createCategoryDto.descriptionAr,
      );

    return this.prisma.category.create({
      data: {
        name,
        description,
        nameEn,
        nameAr,
        descriptionEn,
        descriptionAr,
      },
      include: {
        _count: {
          select: {
            products: true,
          },
        },
      },
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
    const currentCategory =
      await this.findOne(
        id,
      );

    const data = {
      name:
          updateCategoryDto.name !==
                  undefined
              ? updateCategoryDto.name.trim()
              : undefined,

      description:
          updateCategoryDto.description !==
                  undefined
              ? this.cleanOptionalText(
                  updateCategoryDto.description,
                )
              : undefined,

      nameEn:
          updateCategoryDto.nameEn !==
                  undefined
              ? this.cleanOptionalText(
                  updateCategoryDto.nameEn,
                )
              : undefined,

      nameAr:
          updateCategoryDto.nameAr !==
                  undefined
              ? this.cleanOptionalText(
                  updateCategoryDto.nameAr,
                )
              : undefined,

      descriptionEn:
          updateCategoryDto.descriptionEn !==
                  undefined
              ? this.cleanOptionalText(
                  updateCategoryDto.descriptionEn,
                )
              : undefined,

      descriptionAr:
          updateCategoryDto.descriptionAr !==
                  undefined
              ? this.cleanOptionalText(
                  updateCategoryDto.descriptionAr,
                )
              : undefined,
    };

    if (
      updateCategoryDto.name !==
        undefined &&
      updateCategoryDto.nameEn ===
        undefined &&
      currentCategory.nameEn == null
    ) {
      data.nameEn =
          updateCategoryDto.name.trim();
    }

    return this.prisma.category.update({
      where: {
        id,
      },
      data,
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

  private cleanOptionalText(
    value?: string | null,
  ) {
    if (value == null) {
      return null;
    }

    const cleaned =
        value.trim();

    return cleaned.length === 0
        ? null
        : cleaned;
  }
}