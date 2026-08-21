import {
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { ProductStatus } from '@prisma/client';

import { GeminiService } from '../ai/gemini.service';
import { PrismaService } from '../prisma/prisma.service';
import { UploadsService } from '../uploads/uploads.service';

import { CreateProductDto } from './dto/create-product.dto';
import { UpdateProductDto } from './dto/update-product.dto';

@Injectable()
export class ProductsService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly uploadsService: UploadsService,
    private readonly geminiService: GeminiService,
  ) {}

  async create(
    createProductDto: CreateProductDto,
    farmerId: string,
  ) {
    const legacyName =
      createProductDto.name.trim();

    const legacyDescription =
      this.cleanOptionalText(
        createProductDto.description,
      );

    let nameEn =
      this.cleanOptionalText(
        createProductDto.nameEn,
      );

    let nameAr =
      this.cleanOptionalText(
        createProductDto.nameAr,
      );

    let descriptionEn =
      this.cleanOptionalText(
        createProductDto.descriptionEn,
      );

    let descriptionAr =
      this.cleanOptionalText(
        createProductDto.descriptionAr,
      );

    if (!nameEn && !nameAr) {
      if (
        this.containsArabic(
          legacyName,
        )
      ) {
        nameAr =
          legacyName;

        descriptionAr =
          legacyDescription;

        const translation =
          await this.geminiService
              .translateProductContent({
            productName:
              legacyName,
            description:
              legacyDescription ?? '',
            targetLanguage:
              'en',
          });

        nameEn =
          translation.productName;

        descriptionEn =
          this.cleanOptionalText(
            translation.description,
          );
      } else {
        nameEn =
          legacyName;

        descriptionEn =
          legacyDescription;

        const translation =
          await this.geminiService
              .translateProductContent({
            productName:
              legacyName,
            description:
              legacyDescription ?? '',
            targetLanguage:
              'ar',
          });

        nameAr =
          translation.productName;

        descriptionAr =
          this.cleanOptionalText(
            translation.description,
          );
      }
    } else if (
      nameAr &&
      !nameEn
    ) {
      const translation =
        await this.geminiService
            .translateProductContent({
          productName:
            nameAr,
          description:
            descriptionAr ?? '',
          targetLanguage:
            'en',
        });

      nameEn =
        translation.productName;

      descriptionEn =
        this.cleanOptionalText(
          translation.description,
        );
    } else if (
      nameEn &&
      !nameAr
    ) {
      const translation =
        await this.geminiService
            .translateProductContent({
          productName:
            nameEn,
          description:
            descriptionEn ?? '',
          targetLanguage:
            'ar',
        });

      nameAr =
        translation.productName;

      descriptionAr =
        this.cleanOptionalText(
          translation.description,
        );
    }

    const legacyNameToSave =
      nameEn ??
      nameAr ??
      legacyName;

    const legacyDescriptionToSave =
      descriptionEn ??
      descriptionAr ??
      legacyDescription;

    return this.prisma.product.create({
      data: {
        farmerId,

        categoryId:
          createProductDto.categoryId,

        name:
          legacyNameToSave,

        description:
          legacyDescriptionToSave,

        nameEn,
        nameAr,
        descriptionEn,
        descriptionAr,

        price:
          createProductDto.price,

        quantity:
          createProductDto.quantity,

        unit:
          createProductDto.unit.trim(),

        imageUrl:
          createProductDto.imageUrl,
      },
      include: {
        category: true,
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
      await this.uploadsService
          .removeImage(
        product.imageUrl,
      );
    }

    let nameEn =
      updateProductDto.nameEn !==
      undefined
        ? this.cleanOptionalText(
            updateProductDto.nameEn,
          )
        : product.nameEn;

    let nameAr =
      updateProductDto.nameAr !==
      undefined
        ? this.cleanOptionalText(
            updateProductDto.nameAr,
          )
        : product.nameAr;

    let descriptionEn =
      updateProductDto.descriptionEn !==
      undefined
        ? this.cleanOptionalText(
            updateProductDto.descriptionEn,
          )
        : product.descriptionEn;

    let descriptionAr =
      updateProductDto.descriptionAr !==
      undefined
        ? this.cleanOptionalText(
            updateProductDto.descriptionAr,
          )
        : product.descriptionAr;

    const incomingName =
      updateProductDto.name
        ?.trim();

    const incomingDescription =
      updateProductDto.description !==
      undefined
        ? this.cleanOptionalText(
            updateProductDto.description,
          )
        : undefined;

    if (
      updateProductDto.nameAr !==
        undefined &&
      nameAr
    ) {
      const translation =
        await this.geminiService
            .translateProductContent({
          productName:
            nameAr,
          description:
            descriptionAr ?? '',
          targetLanguage:
            'en',
        });

      nameEn =
        translation.productName;

      descriptionEn =
        this.cleanOptionalText(
          translation.description,
        );
    } else if (
      updateProductDto.nameEn !==
        undefined &&
      nameEn
    ) {
      const translation =
        await this.geminiService
            .translateProductContent({
          productName:
            nameEn,
          description:
            descriptionEn ?? '',
          targetLanguage:
            'ar',
        });

      nameAr =
        translation.productName;

      descriptionAr =
        this.cleanOptionalText(
          translation.description,
        );
    } else if (
      incomingName &&
      updateProductDto.nameAr ===
        undefined &&
      updateProductDto.nameEn ===
        undefined
    ) {
      if (
        this.containsArabic(
          incomingName,
        )
      ) {
        nameAr =
          incomingName;

        descriptionAr =
          incomingDescription ??
          descriptionAr;

        const translation =
          await this.geminiService
              .translateProductContent({
            productName:
              incomingName,
            description:
              incomingDescription ?? '',
            targetLanguage:
              'en',
          });

        nameEn =
          translation.productName;

        descriptionEn =
          this.cleanOptionalText(
            translation.description,
          );
      } else {
        nameEn =
          incomingName;

        descriptionEn =
          incomingDescription ??
          descriptionEn;

        const translation =
          await this.geminiService
              .translateProductContent({
            productName:
              incomingName,
            description:
              incomingDescription ?? '',
            targetLanguage:
              'ar',
          });

        nameAr =
          translation.productName;

        descriptionAr =
          this.cleanOptionalText(
            translation.description,
          );
      }
    }

    const legacyName =
      nameEn ??
      nameAr ??
      incomingName ??
      product.name;

    const legacyDescription =
      descriptionEn ??
      descriptionAr ??
      incomingDescription ??
      product.description;

    return this.prisma.product.update({
      where: {
        id,
      },
      data: {
        categoryId:
          updateProductDto.categoryId,

        name:
          legacyName,

        description:
          legacyDescription,

        nameEn,
        nameAr,
        descriptionEn,
        descriptionAr,

        price:
          updateProductDto.price,

        quantity:
          updateProductDto.quantity,

        unit:
          updateProductDto.unit !==
          undefined
            ? updateProductDto.unit
                .trim()
            : undefined,

        imageUrl:
          updateProductDto.imageUrl,
      },
      include: {
        category: true,
      },
    });
  }

  async backfillProductTranslations() {
    const products =
        await this.prisma.product.findMany({
          where: {
            OR: [
              { nameEn: null },
              { nameAr: null },
            ],
          },
          orderBy: {
            createdAt: 'asc',
          },
        });

    let updated = 0;
    let skipped = 0;
    const failed: Array<{
      id: string;
      name: string;
      error: string;
    }> = [];

    for (const product of products) {
      try {
        let nameEn =
            this.cleanOptionalText(
              product.nameEn,
            );

        let nameAr =
            this.cleanOptionalText(
              product.nameAr,
            );

        let descriptionEn =
            this.cleanOptionalText(
              product.descriptionEn,
            );

        let descriptionAr =
            this.cleanOptionalText(
              product.descriptionAr,
            );

        const legacyName =
            product.name.trim();

        const legacyDescription =
            this.cleanOptionalText(
              product.description,
            );

        if (!nameEn && !nameAr) {
          if (
            this.containsArabic(
              legacyName,
            )
          ) {
            nameAr = legacyName;
            descriptionAr =
                legacyDescription;

            const translation =
                await this.geminiService
                    .translateProductContent({
              productName: legacyName,
              description:
                  legacyDescription ?? '',
              targetLanguage: 'en',
            });

            nameEn =
                translation.productName;

            descriptionEn =
                this.cleanOptionalText(
                  translation.description,
                );
          } else {
            nameEn = legacyName;
            descriptionEn =
                legacyDescription;

            const translation =
                await this.geminiService
                    .translateProductContent({
              productName: legacyName,
              description:
                  legacyDescription ?? '',
              targetLanguage: 'ar',
            });

            nameAr =
                translation.productName;

            descriptionAr =
                this.cleanOptionalText(
                  translation.description,
                );
          }
        } else if (!nameEn && nameAr) {
          const translation =
              await this.geminiService
                  .translateProductContent({
            productName: nameAr,
            description:
                descriptionAr ??
                legacyDescription ??
                '',
            targetLanguage: 'en',
          });

          nameEn =
              translation.productName;

          descriptionEn =
              this.cleanOptionalText(
                translation.description,
              );
        } else if (!nameAr && nameEn) {
          const translation =
              await this.geminiService
                  .translateProductContent({
            productName: nameEn,
            description:
                descriptionEn ??
                legacyDescription ??
                '',
            targetLanguage: 'ar',
          });

          nameAr =
              translation.productName;

          descriptionAr =
              this.cleanOptionalText(
                translation.description,
              );
        }

        if (!nameEn || !nameAr) {
          skipped++;
          continue;
        }

        await this.prisma.product.update({
          where: {
            id: product.id,
          },
          data: {
            nameEn,
            nameAr,
            descriptionEn,
            descriptionAr,
            name: nameEn,
            description:
                descriptionEn ??
                descriptionAr ??
                legacyDescription,
          },
        });

        updated++;
      } catch (error) {
        failed.push({
          id: product.id,
          name: product.name,
          error:
              error instanceof Error
                  ? error.message
                  : 'Unknown error',
        });
      }
    }

    return {
      totalFound: products.length,
      updated,
      skipped,
      failed,
    };
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
      await this.uploadsService
          .removeImage(
        product.imageUrl,
      );
    }

    return this.prisma.product.delete({
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

  private containsArabic(
    value: string,
  ) {
    return /[\u0600-\u06FF]/.test(
      value,
    );
  }
}