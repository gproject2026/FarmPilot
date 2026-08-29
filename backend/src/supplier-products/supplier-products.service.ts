import {
  BadRequestException,
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';

import { PrismaService } from '../prisma/prisma.service';

import { CreateSupplierProductDto } from './dto/create-supplier-product.dto';
import { UpdateSupplierProductDto } from './dto/update-supplier-product.dto';

@Injectable()
export class SupplierProductsService {
  constructor(
    private readonly prisma: PrismaService,
  ) {}

  async create(
    createSupplierProductDto: CreateSupplierProductDto,
    supplierId: string,
  ) {
    const supplier =
      await this.prisma.user.findUnique({
        where: {
          id: supplierId,
        },
      });

    if (!supplier) {
      throw new NotFoundException(
        'Supplier not found',
      );
    }

    const category =
      await this.prisma.supplierCategory.findUnique({
        where: {
          id:
            createSupplierProductDto.categoryId,
        },
      });

    if (!category) {
      throw new NotFoundException(
        'Supplier category not found',
      );
    }

    const name =
      createSupplierProductDto.name.trim();

    if (!name) {
      throw new BadRequestException(
        'Product name is required',
      );
    }

    const unit =
      createSupplierProductDto.unit.trim();

    if (!unit) {
      throw new BadRequestException(
        'Product unit is required',
      );
    }

    return this.prisma.supplierProduct.create({
      data: {
        supplierId,

        categoryId:
          createSupplierProductDto.categoryId,

        name,

        description:
          this.cleanOptionalText(
            createSupplierProductDto.description,
          ),

        nameEn:
          this.cleanOptionalText(
            createSupplierProductDto.nameEn,
          ),

        nameAr:
          this.cleanOptionalText(
            createSupplierProductDto.nameAr,
          ),

        descriptionEn:
          this.cleanOptionalText(
            createSupplierProductDto.descriptionEn,
          ),

        descriptionAr:
          this.cleanOptionalText(
            createSupplierProductDto.descriptionAr,
          ),

        plantingInstructions:
          this.cleanOptionalText(
            createSupplierProductDto.plantingInstructions,
          ),

        plantingInstructionsEn:
          this.cleanOptionalText(
            createSupplierProductDto.plantingInstructionsEn,
          ),

        plantingInstructionsAr:
          this.cleanOptionalText(
            createSupplierProductDto.plantingInstructionsAr,
          ),

        irrigationInstructions:
          this.cleanOptionalText(
            createSupplierProductDto.irrigationInstructions,
          ),

        irrigationInstructionsEn:
          this.cleanOptionalText(
            createSupplierProductDto.irrigationInstructionsEn,
          ),

        irrigationInstructionsAr:
          this.cleanOptionalText(
            createSupplierProductDto.irrigationInstructionsAr,
          ),

        usageInstructions:
          this.cleanOptionalText(
            createSupplierProductDto.usageInstructions,
          ),

        usageInstructionsEn:
          this.cleanOptionalText(
            createSupplierProductDto.usageInstructionsEn,
          ),

        usageInstructionsAr:
          this.cleanOptionalText(
            createSupplierProductDto.usageInstructionsAr,
          ),

        price:
          createSupplierProductDto.price,

        quantity:
          createSupplierProductDto.quantity,

        unit,

        imageUrl:
          this.cleanOptionalText(
            createSupplierProductDto.imageUrl,
          ),
      },

      include: {
        category: true,

        supplier: {
          select: {
            id: true,
            fullName: true,
            email: true,
            phone: true,
            address: true,
            profileImage: true,
          },
        },
      },
    });
  }

  findMyProducts(
    supplierId: string,
  ) {
    return this.prisma.supplierProduct.findMany({
      where: {
        supplierId,
      },

      include: {
        category: true,
      },

      orderBy: {
        createdAt: 'desc',
      },
    });
  }

  findAll(
    categoryId?: string,
  ) {
    return this.prisma.supplierProduct.findMany({
      where: {
        ...(categoryId
          ? {
              categoryId,
            }
          : {}),
      },

      include: {
        category: true,

        supplier: {
          select: {
            id: true,
            fullName: true,
            phone: true,
            address: true,
            profileImage: true,
          },
        },
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
      await this.prisma.supplierProduct.findUnique({
        where: {
          id,
        },

        include: {
          category: true,

          supplier: {
            select: {
              id: true,
              fullName: true,
              phone: true,
              address: true,
              profileImage: true,
            },
          },
        },
      });

    if (!product) {
      throw new NotFoundException(
        'Supplier product not found',
      );
    }

    return product;
  }

  async update(
    id: string,
    updateSupplierProductDto: UpdateSupplierProductDto,
    supplierId: string,
  ) {
    const product =
      await this.prisma.supplierProduct.findUnique({
        where: {
          id,
        },
      });

    if (!product) {
      throw new NotFoundException(
        'Supplier product not found',
      );
    }

    if (
      product.supplierId !==
      supplierId
    ) {
      throw new ForbiddenException(
        'You are not allowed to update this product',
      );
    }

    if (
      updateSupplierProductDto.categoryId !==
      undefined
    ) {
      const category =
        await this.prisma.supplierCategory.findUnique({
          where: {
            id:
              updateSupplierProductDto.categoryId,
          },
        });

      if (!category) {
        throw new NotFoundException(
          'Supplier category not found',
        );
      }
    }

    let name: string | undefined;

    if (
      updateSupplierProductDto.name !==
      undefined
    ) {
      name =
        updateSupplierProductDto.name.trim();

      if (!name) {
        throw new BadRequestException(
          'Product name cannot be empty',
        );
      }
    }

    let unit: string | undefined;

    if (
      updateSupplierProductDto.unit !==
      undefined
    ) {
      unit =
        updateSupplierProductDto.unit.trim();

      if (!unit) {
        throw new BadRequestException(
          'Product unit cannot be empty',
        );
      }
    }

    return this.prisma.supplierProduct.update({
      where: {
        id,
      },

      data: {
        categoryId:
          updateSupplierProductDto.categoryId,

        name,

        description:
          updateSupplierProductDto.description !==
          undefined
            ? this.cleanOptionalText(
                updateSupplierProductDto.description,
              )
            : undefined,

        nameEn:
          updateSupplierProductDto.nameEn !==
          undefined
            ? this.cleanOptionalText(
                updateSupplierProductDto.nameEn,
              )
            : undefined,

        nameAr:
          updateSupplierProductDto.nameAr !==
          undefined
            ? this.cleanOptionalText(
                updateSupplierProductDto.nameAr,
              )
            : undefined,

        descriptionEn:
          updateSupplierProductDto.descriptionEn !==
          undefined
            ? this.cleanOptionalText(
                updateSupplierProductDto.descriptionEn,
              )
            : undefined,

        descriptionAr:
          updateSupplierProductDto.descriptionAr !==
          undefined
            ? this.cleanOptionalText(
                updateSupplierProductDto.descriptionAr,
              )
            : undefined,

        plantingInstructions:
          updateSupplierProductDto.plantingInstructions !==
          undefined
            ? this.cleanOptionalText(
                updateSupplierProductDto.plantingInstructions,
              )
            : undefined,

        plantingInstructionsEn:
          updateSupplierProductDto.plantingInstructionsEn !==
          undefined
            ? this.cleanOptionalText(
                updateSupplierProductDto.plantingInstructionsEn,
              )
            : undefined,

        plantingInstructionsAr:
          updateSupplierProductDto.plantingInstructionsAr !==
          undefined
            ? this.cleanOptionalText(
                updateSupplierProductDto.plantingInstructionsAr,
              )
            : undefined,

        irrigationInstructions:
          updateSupplierProductDto.irrigationInstructions !==
          undefined
            ? this.cleanOptionalText(
                updateSupplierProductDto.irrigationInstructions,
              )
            : undefined,

        irrigationInstructionsEn:
          updateSupplierProductDto.irrigationInstructionsEn !==
          undefined
            ? this.cleanOptionalText(
                updateSupplierProductDto.irrigationInstructionsEn,
              )
            : undefined,

        irrigationInstructionsAr:
          updateSupplierProductDto.irrigationInstructionsAr !==
          undefined
            ? this.cleanOptionalText(
                updateSupplierProductDto.irrigationInstructionsAr,
              )
            : undefined,

        usageInstructions:
          updateSupplierProductDto.usageInstructions !==
          undefined
            ? this.cleanOptionalText(
                updateSupplierProductDto.usageInstructions,
              )
            : undefined,

        usageInstructionsEn:
          updateSupplierProductDto.usageInstructionsEn !==
          undefined
            ? this.cleanOptionalText(
                updateSupplierProductDto.usageInstructionsEn,
              )
            : undefined,

        usageInstructionsAr:
          updateSupplierProductDto.usageInstructionsAr !==
          undefined
            ? this.cleanOptionalText(
                updateSupplierProductDto.usageInstructionsAr,
              )
            : undefined,

        price:
          updateSupplierProductDto.price,

        quantity:
          updateSupplierProductDto.quantity,

        unit,

        imageUrl:
          updateSupplierProductDto.imageUrl !==
          undefined
            ? this.cleanOptionalText(
                updateSupplierProductDto.imageUrl,
              )
            : undefined,

        status:
          updateSupplierProductDto.status,
      },

      include: {
        category: true,

        supplier: {
          select: {
            id: true,
            fullName: true,
            email: true,
            phone: true,
            address: true,
            profileImage: true,
          },
        },
      },
    });
  }

  async remove(
    id: string,
    supplierId: string,
  ) {
    const product =
      await this.prisma.supplierProduct.findUnique({
        where: {
          id,
        },

        include: {
          _count: {
            select: {
              orderItems: true,
            },
          },
        },
      });

    if (!product) {
      throw new NotFoundException(
        'Supplier product not found',
      );
    }

    if (
      product.supplierId !==
      supplierId
    ) {
      throw new ForbiddenException(
        'You are not allowed to delete this product',
      );
    }

    if (
      product._count.orderItems > 0
    ) {
      throw new BadRequestException(
        'Cannot delete a product that is already used in an order',
      );
    }

    return this.prisma.supplierProduct.delete({
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