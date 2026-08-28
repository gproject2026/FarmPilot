import {
  BadRequestException,
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';

import {
  DeliveryMethod,
  OrderStatus,
  PaymentMethod,
  Prisma,
  ProductStatus,
  UserRole,
} from '@prisma/client';

import { PrismaService } from '../prisma/prisma.service';
import { CreateOrderDto } from './dto/create-order.dto';

@Injectable()
export class OrdersService {
  constructor(
    private readonly prisma: PrismaService,
  ) {}

  private readonly orderInclude = {
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
        product: {
          include: {
            farmer: {
              select: {
                id: true,
                fullName: true,
                email: true,
                phone: true,
                address: true,
              },
            },
            category: true,
          },
        },
      },
    },
  } satisfies Prisma.OrderInclude;

  async create(
    createOrderDto: CreateOrderDto,
    customerId: string,
  ) {
    const productIds =
      createOrderDto.items.map(
        (item) => item.productId,
      );

    const uniqueProductIds =
      new Set(productIds);

    if (
      uniqueProductIds.size !==
      productIds.length
    ) {
      throw new BadRequestException(
        'The same product cannot be added more than once',
      );
    }

    return this.prisma.$transaction(
      async (tx) => {
        const products =
          await tx.product.findMany({
            where: {
              id: {
                in: productIds,
              },
            },
          });

        if (
          products.length !==
          productIds.length
        ) {
          throw new NotFoundException(
            'One or more products were not found',
          );
        }

        const farmerIds =
          new Set(
            products.map(
              (product) =>
                product.farmerId,
            ),
          );

        if (farmerIds.size > 1) {
          throw new BadRequestException(
            'All products in one order must belong to the same farmer',
          );
        }

        const farmerId =
          products[0].farmerId;

        const deliveryMethod =
          createOrderDto.deliveryMethod;

        const paymentMethod =
          createOrderDto.paymentMethod ??
          PaymentMethod.CASH;

        let deliveryAddress:
          string | null = null;

        let pickupLocation:
          string | null = null;

        if (
          deliveryMethod ===
          DeliveryMethod.DELIVERY
        ) {
          const normalizedAddress =
            createOrderDto.deliveryAddress
              ?.trim();

          if (!normalizedAddress) {
            throw new BadRequestException(
              'Delivery address is required for delivery orders',
            );
          }

          deliveryAddress =
            normalizedAddress;
        } else if (
          deliveryMethod ===
          DeliveryMethod.PICKUP
        ) {
          const farmer =
            await tx.user.findUnique({
              where: {
                id: farmerId,
              },
              select: {
                address: true,
              },
            });

          const normalizedPickupLocation =
            farmer?.address?.trim();

          if (
            !normalizedPickupLocation
          ) {
            throw new BadRequestException(
              'The farmer has not set a pickup location yet',
            );
          }

          pickupLocation =
            normalizedPickupLocation;
        }

        let totalPrice =
          new Prisma.Decimal(0);

        const orderItemsData:
          Prisma.OrderItemCreateWithoutOrderInput[] =
            [];

        for (
          const item of
          createOrderDto.items
        ) {
          const product =
            products.find(
              (currentProduct) =>
                currentProduct.id ===
                item.productId,
            );

          if (!product) {
            throw new NotFoundException(
              'Product not found',
            );
          }

          if (
            product.status !==
            ProductStatus.AVAILABLE
          ) {
            throw new BadRequestException(
              `Product is not available: ${product.name}`,
            );
          }

          if (
            product.quantity <
            item.quantity
          ) {
            throw new BadRequestException(
              `Not enough quantity for product: ${product.name}`,
            );
          }

          totalPrice =
            totalPrice.plus(
              product.price.mul(
                item.quantity,
              ),
            );

          orderItemsData.push({
            product: {
              connect: {
                id: product.id,
              },
            },
            quantity:
              item.quantity,
            price:
              product.price,
          });
        }

        for (
          const item of
          createOrderDto.items
        ) {
          const updatedResult =
            await tx.product.updateMany({
              where: {
                id:
                  item.productId,
                status:
                  ProductStatus.AVAILABLE,
                quantity: {
                  gte:
                    item.quantity,
                },
              },
              data: {
                quantity: {
                  decrement:
                    item.quantity,
                },
              },
            });

          if (
            updatedResult.count === 0
          ) {
            throw new BadRequestException(
              'The requested product quantity is no longer available',
            );
          }

          const updatedProduct =
            await tx.product.findUnique({
              where: {
                id:
                  item.productId,
              },
              select: {
                quantity: true,
              },
            });

          if (
            updatedProduct
              ?.quantity === 0
          ) {
            await tx.product.update({
              where: {
                id:
                  item.productId,
              },
              data: {
                status:
                  ProductStatus
                    .OUT_OF_STOCK,
              },
            });
          }
        }

        const createdOrder =
          await tx.order.create({
            data: {
              customerId,
              totalPrice,
              deliveryMethod,
              paymentMethod,
              deliveryAddress,
              pickupLocation,
              orderItems: {
                create:
                  orderItemsData,
              },
            },
            include:
              this.orderInclude,
          });

        await tx.notification.create({
          data: {
            userId:
              farmerId,

            title:
              'New Order',

            message:
              'You have received a new order.',

            titleEn:
              'New Order',

            titleAr:
              'طلب جديد',

            messageEn:
              'You have received a new order.',

            messageAr:
              'لقد استلمت طلبًا جديدًا.',

            type:
              'ORDER',

            isRead:
              false,
          },
        });

        return createdOrder;
      },
    );
  }

  findCustomerOrders(
    customerId: string,
  ) {
    return this.prisma.order.findMany({
      where: {
        customerId,
      },
      include:
        this.orderInclude,
      orderBy: {
        createdAt:
          'desc',
      },
    });
  }

  findFarmerOrders(
    farmerId: string,
  ) {
    return this.prisma.order.findMany({
      where: {
        orderItems: {
          some: {
            product: {
              farmerId,
            },
          },
        },
      },
      include:
        this.orderInclude,
      orderBy: {
        createdAt:
          'desc',
      },
    });
  }

  findAll() {
    return this.prisma.order.findMany({
      include:
        this.orderInclude,
      orderBy: {
        createdAt:
          'desc',
      },
    });
  }

  async findOne(
    id: string,
    userId: string,
    userRole: UserRole,
  ) {
    const order =
      await this.prisma.order.findUnique({
        where: {
          id,
        },
        include:
          this.orderInclude,
      });

    if (!order) {
      throw new NotFoundException(
        'Order not found',
      );
    }

    if (
      userRole ===
      UserRole.ADMIN
    ) {
      return order;
    }

    if (
      userRole ===
        UserRole.CUSTOMER &&
      order.customerId !==
        userId
    ) {
      throw new ForbiddenException(
        'You are not allowed to view this order',
      );
    }

    if (
      userRole ===
      UserRole.FARMER
    ) {
      const belongsToFarmer =
        order.orderItems.some(
          (item) =>
            item.product
              .farmerId ===
            userId,
        );

      if (!belongsToFarmer) {
        throw new ForbiddenException(
          'You are not allowed to view this order',
        );
      }
    }

    return order;
  }

  async updateStatus(
    id: string,
    newStatus: OrderStatus,
    userId: string,
    userRole: UserRole,
  ) {
    return this.prisma.$transaction(
      async (tx) => {
        const order =
          await tx.order.findUnique({
            where: {
              id,
            },
            include: {
              orderItems: {
                include: {
                  product: true,
                },
              },
            },
          });

        if (!order) {
          throw new NotFoundException(
            'Order not found',
          );
        }

        if (
          userRole ===
          UserRole.CUSTOMER
        ) {
          if (
            order.customerId !==
            userId
          ) {
            throw new ForbiddenException(
              'You are not allowed to cancel this order',
            );
          }

          if (
            newStatus !==
            OrderStatus.CANCELLED
          ) {
            throw new ForbiddenException(
              'Customers can only cancel their orders',
            );
          }

          if (
            order.status !==
            OrderStatus.PENDING
          ) {
            throw new BadRequestException(
              'Only pending orders can be cancelled by the customer',
            );
          }
        } else if (
          userRole ===
          UserRole.FARMER
        ) {
          const belongsToFarmer =
            order.orderItems.every(
              (item) =>
                item.product
                  .farmerId ===
                userId,
            );

          if (!belongsToFarmer) {
            throw new ForbiddenException(
              'You are not allowed to update this order',
            );
          }
        } else {
          throw new ForbiddenException(
            'You are not allowed to update this order',
          );
        }

        if (
          order.status ===
          newStatus
        ) {
          throw new BadRequestException(
            `Order status is already ${newStatus}`,
          );
        }

        const farmerTransitions:
          Record<
            OrderStatus,
            OrderStatus[]
          > = {
            [OrderStatus.PENDING]:
              [
                OrderStatus
                  .CONFIRMED,
                OrderStatus
                  .CANCELLED,
              ],

            [OrderStatus.CONFIRMED]:
              [
                OrderStatus
                  .COMPLETED,
                OrderStatus
                  .CANCELLED,
              ],

            [OrderStatus.CANCELLED]:
              [],

            [OrderStatus.COMPLETED]:
              [],
          };

        if (
          userRole ===
            UserRole.FARMER &&
          !farmerTransitions[
            order.status
          ].includes(
            newStatus,
          )
        ) {
          throw new BadRequestException(
            `Cannot change order status from ${order.status} to ${newStatus}`,
          );
        }

        if (
          newStatus ===
          OrderStatus.CANCELLED
        ) {
          for (
            const item of
            order.orderItems
          ) {
            await tx.product.update({
              where: {
                id:
                  item.productId,
              },
              data: {
                quantity: {
                  increment:
                    item.quantity,
                },
                status:
                  item.product
                      .status ===
                    ProductStatus
                      .OUT_OF_STOCK
                    ? ProductStatus
                        .AVAILABLE
                    : item.product
                        .status,
              },
            });
          }
        }

        const updatedOrder =
          await tx.order.update({
            where: {
              id,
            },
            data: {
              status:
                newStatus,
            },
            include:
              this.orderInclude,
          });

        let notificationTitleEn:
          string;

        let notificationTitleAr:
          string;

        let notificationMessageEn:
          string;

        let notificationMessageAr:
          string;

        switch (newStatus) {
          case OrderStatus.CONFIRMED:
            notificationTitleEn =
              'Order Confirmed';

            notificationTitleAr =
              'تم تأكيد الطلب';

            notificationMessageEn =
              'Your order has been confirmed by the farmer.';

            notificationMessageAr =
              'تم تأكيد طلبك من قبل المزارع.';

            break;

          case OrderStatus.COMPLETED:
            notificationTitleEn =
              'Order Completed';

            notificationTitleAr =
              'تم إكمال الطلب';

            notificationMessageEn =
              'Your order has been completed successfully.';

            notificationMessageAr =
              'تم إكمال طلبك بنجاح.';

            break;

          case OrderStatus.CANCELLED:
            notificationTitleEn =
              'Order Cancelled';

            notificationTitleAr =
              'تم إلغاء الطلب';

            if (
              userRole ===
              UserRole.CUSTOMER
            ) {
              notificationMessageEn =
                'Your order has been cancelled successfully.';

              notificationMessageAr =
                'تم إلغاء طلبك بنجاح.';
            } else {
              notificationMessageEn =
                'Your order has been cancelled by the farmer.';

              notificationMessageAr =
                'تم إلغاء طلبك من قبل المزارع.';
            }

            break;

          default:
            notificationTitleEn =
              'Order Updated';

            notificationTitleAr =
              'تم تحديث الطلب';

            notificationMessageEn =
              `Your order status has been updated to ${newStatus}.`;

            notificationMessageAr =
              `تم تحديث حالة طلبك إلى ${this.translateOrderStatusToArabic(
                newStatus,
              )}.`;
        }

        await tx.notification.create({
          data: {
            userId:
              order.customerId,

            // Keep old fields for
            // backwards compatibility.
            title:
              notificationTitleEn,

            message:
              notificationMessageEn,

            titleEn:
              notificationTitleEn,

            titleAr:
              notificationTitleAr,

            messageEn:
              notificationMessageEn,

            messageAr:
              notificationMessageAr,

            type:
              'ORDER',

            isRead:
              false,
          },
        });

        return updatedOrder;
      },
    );
  }

  private translateOrderStatusToArabic(
    status: OrderStatus,
  ): string {
    switch (status) {
      case OrderStatus.PENDING:
        return 'قيد الانتظار';

      case OrderStatus.CONFIRMED:
        return 'مؤكد';

      case OrderStatus.CANCELLED:
        return 'ملغي';

      case OrderStatus.COMPLETED:
        return 'مكتمل';

      default:
        return status;
    }
  }
}