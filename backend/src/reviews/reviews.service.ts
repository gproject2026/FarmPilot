import {
  BadRequestException,
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { OrderStatus } from '@prisma/client';

import { NotificationsService } from '../notifications/notifications.service';
import { PrismaService } from '../prisma/prisma.service';

import { CreateReviewDto } from './dto/create-review.dto';

@Injectable()
export class ReviewsService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly notificationsService: NotificationsService,
  ) {}

  async create(
    createReviewDto: CreateReviewDto,
    customerId: string,
  ) {
    const product = await this.prisma.product.findUnique({
      where: {
        id: createReviewDto.productId,
      },
      select: {
        id: true,
        name: true,
        farmerId: true,
      },
    });

    if (!product) {
      throw new NotFoundException('Product not found');
    }

    const existingReview = await this.prisma.review.findFirst({
      where: {
        customerId,
        productId: createReviewDto.productId,
      },
    });

    if (existingReview) {
      throw new BadRequestException(
        'You have already reviewed this product',
      );
    }

    const completedOrder = await this.prisma.order.findFirst({
      where: {
        customerId,
        status: OrderStatus.COMPLETED,
        orderItems: {
          some: {
            productId: createReviewDto.productId,
          },
        },
      },
      select: {
        id: true,
      },
    });

    if (!completedOrder) {
      throw new BadRequestException(
        'You can only review products from completed orders',
      );
    }

    const review = await this.prisma.review.create({
      data: {
        customerId,
        productId: createReviewDto.productId,
        rating: createReviewDto.rating,
        comment: createReviewDto.comment,
      },
      include: {
        customer: {
          select: {
            id: true,
            fullName: true,
            profileImage: true,
          },
        },
        product: true,
      },
    });

    await this.notificationsService.create({
      userId: product.farmerId,
      title: 'New Review',
      message: `Your product "${product.name}" received a new ${createReviewDto.rating}-star review.`,
      type: 'REVIEW',
    });

    return review;
  }

  findByProduct(productId: string) {
    return this.prisma.review.findMany({
      where: {
        productId,
      },
      include: {
        customer: {
          select: {
            id: true,
            fullName: true,
            profileImage: true,
          },
        },
      },
      orderBy: {
        createdAt: 'desc',
      },
    });
  }

  async remove(
    reviewId: string,
    customerId: string,
  ) {
    const review = await this.prisma.review.findUnique({
      where: {
        id: reviewId,
      },
    });

    if (!review) {
      throw new NotFoundException('Review not found');
    }

    if (review.customerId !== customerId) {
      throw new ForbiddenException(
        'You are not allowed to delete this review',
      );
    }

    return this.prisma.review.delete({
      where: {
        id: reviewId,
      },
    });
  }
}