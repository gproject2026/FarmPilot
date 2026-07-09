import {
  BadRequestException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

import { CreateOrderDto } from './dto/create-order.dto';

@Injectable()
export class OrdersService {
  constructor(private readonly prisma: PrismaService) {}

  async create(createOrderDto: CreateOrderDto, customerId: string) {
    return this.prisma.$transaction(async (tx) => {
      let totalPrice = 0;

      const orderItemsData: {
  productId: string;
  quantity: number;
  price: any;
}[] = [];

      for (const item of createOrderDto.items) {
        const product = await tx.product.findUnique({
          where: { id: item.productId },
        });

        if (!product) {
          throw new NotFoundException('Product not found');
        }

        if (product.quantity < item.quantity) {
          throw new BadRequestException(
            `Not enough quantity for product: ${product.name}`,
          );
        }

        totalPrice += Number(product.price) * item.quantity;

        orderItemsData.push({
          productId: product.id,
          quantity: item.quantity,
          price: product.price,
        });
      }

      const order = await tx.order.create({
        data: {
          customerId,
          totalPrice,
          orderItems: {
            create: orderItemsData,
          },
        },
        include: {
          orderItems: {
            include: {
              product: true,
            },
          },
        },
      });

      for (const item of createOrderDto.items) {
        await tx.product.update({
          where: { id: item.productId },
          data: {
            quantity: {
              decrement: item.quantity,
            },
          },
        });
      }

      return order;
    });
  }

  findAll() {
    return this.prisma.order.findMany({
      include: {
        customer: {
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
        orderItems: {
          include: {
            product: true,
          },
        },
      },
    });
  }

  findOne(id: string) {
    return this.prisma.order.findUnique({
      where: { id },
      include: {
        customer: {
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
        orderItems: {
          include: {
            product: true,
          },
        },
      },
    });
  }
}