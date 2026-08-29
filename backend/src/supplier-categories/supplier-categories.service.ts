
import {
  BadRequestException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';

import { PrismaService } from '../prisma/prisma.service';

interface CreateSupplierCategoryInput {
  name: string;
  description?: string;
  nameEn?: string;
  nameAr?: string;
  descriptionEn?: string;
  descriptionAr?: string;
}

interface UpdateSupplierCategoryInput {
  name?: string;
  description?: string | null;
  nameEn?: string | null;
  nameAr?: string | null;
  descriptionEn?: string | null;
  descriptionAr?: string | null;
}

@Injectable()
export class SupplierCategoriesService {
  constructor(
    private readonly prisma: PrismaService,
  ) {}

  create(
    input: CreateSupplierCategoryInput,
  ) {
    const name = input.name.trim();

    if (!name) {
      throw new BadRequestException(
        'Category name is required',
      );
    }

    const description =
      this.cleanOptionalText(
        input.description,
      );

    const nameEn =
      this.cleanOptionalText(
        input.nameEn,
      ) ?? name;

    const nameAr =
      this.cleanOptionalText(
        input.nameAr,
      );

    const descriptionEn =
      this.cleanOptionalText(
        input.descriptionEn,
      ) ?? description;

    const descriptionAr =
      this.cleanOptionalText(
        input.descriptionAr,
      );

    return this.prisma.supplierCategory.create({
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
    return this.prisma.supplierCategory.findMany({
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
      await this.prisma.supplierCategory.findUnique({
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
        'Supplier category not found',
      );
    }

    return category;
  }

  async update(
    id: string,
    input: UpdateSupplierCategoryInput,
  ) {
    const currentCategory =
      await this.findOne(id);

    const name =
      input.name !== undefined
        ? input.name.trim()
        : undefined;

    if (
      input.name !== undefined &&
      !name
    ) {
      throw new BadRequestException(
        'Category name cannot be empty',
      );
    }

    const data = {
      name,

      description:
        input.description !== undefined
          ? this.cleanOptionalText(
              input.description,
            )
          : undefined,

      nameEn:
        input.nameEn !== undefined
          ? this.cleanOptionalText(
              input.nameEn,
            )
          : undefined,

      nameAr:
        input.nameAr !== undefined
          ? this.cleanOptionalText(
              input.nameAr,
            )
          : undefined,

      descriptionEn:
        input.descriptionEn !== undefined
          ? this.cleanOptionalText(
              input.descriptionEn,
            )
          : undefined,

      descriptionAr:
        input.descriptionAr !== undefined
          ? this.cleanOptionalText(
              input.descriptionAr,
            )
          : undefined,
    };

    if (
      input.name !== undefined &&
      input.nameEn === undefined &&
      currentCategory.nameEn == null
    ) {
      data.nameEn = name;
    }

    return this.prisma.supplierCategory.update({
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
      await this.prisma.supplierCategory.findUnique({
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
        'Supplier category not found',
      );
    }

    if (
      category._count.products > 0
    ) {
      throw new BadRequestException(
        'Cannot delete a supplier category that contains products',
      );
    }

    return this.prisma.supplierCategory.delete({
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

    const cleaned = value.trim();

    return cleaned.length === 0
      ? null
      : cleaned;
  }
}