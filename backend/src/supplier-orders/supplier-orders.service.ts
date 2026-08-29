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

import { CreateSupplierOrderDto } from './dto/create-supplier-order.dto';

@Injectable()
export class SupplierOrdersService {
  constructor(
    private readonly prisma: PrismaService,
  ) {}

  private readonly supplierOrderInclude = {
    farmer: {
      select: {
        id: true,
        fullName: true,
        email: true,
        phone: true,
        address: true,
        profileImage: true,
      },
    },

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

    orderItems: {
      include: {
        product: {
          include: {
            category: true,

            supplier: {
              select: {
                id: true,
                fullName: true,
                phone: true,
                address: true,
              },
            },
          },
        },
      },
    },
  } satisfies Prisma.SupplierOrderInclude;

  async create(
    createSupplierOrderDto: CreateSupplierOrderDto,
    farmerId: string,
  ) {
    const productIds =
      createSupplierOrderDto.items.map(
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
          await tx.supplierProduct.findMany({
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
            'One or more supplier products were not found',
          );
        }

        const supplierIds =
          new Set(
            products.map(
              (product) =>
                product.supplierId,
            ),
          );

        if (supplierIds.size > 1) {
          throw new BadRequestException(
            'All products in one order must belong to the same supplier',
          );
        }

        const supplierId =
          products[0].supplierId;

        const deliveryMethod =
          createSupplierOrderDto.deliveryMethod;

        const paymentMethod =
          createSupplierOrderDto.paymentMethod ??
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
            createSupplierOrderDto.deliveryAddress
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
          const supplier =
            await tx.user.findUnique({
              where: {
                id: supplierId,
              },
              select: {
                address: true,
              },
            });

          const normalizedPickupLocation =
            supplier?.address?.trim();

          if (
            !normalizedPickupLocation
          ) {
            throw new BadRequestException(
              'The supplier has not set a pickup location yet',
            );
          }

          pickupLocation =
            normalizedPickupLocation;
        }

        let totalPrice =
          new Prisma.Decimal(0);

        const orderItemsData:
          Prisma.SupplierOrderItemCreateWithoutOrderInput[] =
            [];

        for (
          const item of
          createSupplierOrderDto.items
        ) {
          const product =
            products.find(
              (currentProduct) =>
                currentProduct.id ===
                item.productId,
            );

          if (!product) {
            throw new NotFoundException(
              'Supplier product not found',
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
          createSupplierOrderDto.items
        ) {
          const updatedResult =
            await tx.supplierProduct.updateMany({
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
            await tx.supplierProduct.findUnique({
              where: {
                id:
                  item.productId,
              },

              select: {
                quantity: true,
              },
            });

          if (
            updatedProduct?.quantity === 0
          ) {
            await tx.supplierProduct.update({
              where: {
                id:
                  item.productId,
              },

              data: {
                status:
                  ProductStatus.OUT_OF_STOCK,
              },
            });
          }
        }

        const createdOrder =
          await tx.supplierOrder.create({
            data: {
              farmerId,
              supplierId,
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
              this.supplierOrderInclude,
          });

        await tx.notification.create({
          data: {
            userId:
              supplierId,

            title:
              'New Supply Order',

            message:
              'You have received a new supply order from a farmer.',

            titleEn:
              'New Supply Order',

            titleAr:
              'طلب مستلزمات جديد',

            messageEn:
              'You have received a new supply order from a farmer.',

            messageAr:
              'لقد استلمت طلب مستلزمات جديدًا من مزارع.',

            type:
              'SUPPLIER_ORDER',

            isRead:
              false,
          },
        });

        return createdOrder;
      },
    );
  }

  findFarmerOrders(
    farmerId: string,
  ) {
    return this.prisma.supplierOrder.findMany({
      where: {
        farmerId,
      },

      include:
        this.supplierOrderInclude,

      orderBy: {
        createdAt:
          'desc',
      },
    });
  }

  findSupplierOrders(
    supplierId: string,
  ) {
    return this.prisma.supplierOrder.findMany({
      where: {
        supplierId,
      },

      include:
        this.supplierOrderInclude,

      orderBy: {
        createdAt:
          'desc',
      },
    });
  }

  findAll() {
    return this.prisma.supplierOrder.findMany({
      include:
        this.supplierOrderInclude,

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
      await this.prisma.supplierOrder.findUnique({
        where: {
          id,
        },

        include:
          this.supplierOrderInclude,
      });

    if (!order) {
      throw new NotFoundException(
        'Supplier order not found',
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
        UserRole.FARMER &&
      order.farmerId !==
        userId
    ) {
      throw new ForbiddenException(
        'You are not allowed to view this supplier order',
      );
    }

    if (
      userRole ===
        UserRole.SUPPLIER &&
      order.supplierId !==
        userId
    ) {
      throw new ForbiddenException(
        'You are not allowed to view this supplier order',
      );
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
          await tx.supplierOrder.findUnique({
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
            'Supplier order not found',
          );
        }

        if (
          userRole ===
          UserRole.FARMER
        ) {
          if (
            order.farmerId !==
            userId
          ) {
            throw new ForbiddenException(
              'You are not allowed to cancel this supplier order',
            );
          }

          if (
            newStatus !==
            OrderStatus.CANCELLED
          ) {
            throw new ForbiddenException(
              'Farmers can only cancel their supply orders',
            );
          }

          if (
            order.status !==
            OrderStatus.PENDING
          ) {
            throw new BadRequestException(
              'Only pending supplier orders can be cancelled by the farmer',
            );
          }
        } else if (
          userRole ===
          UserRole.SUPPLIER
        ) {
          if (
            order.supplierId !==
            userId
          ) {
            throw new ForbiddenException(
              'You are not allowed to update this supplier order',
            );
          }
        } else {
          throw new ForbiddenException(
            'You are not allowed to update this supplier order',
          );
        }

        if (
          order.status ===
          newStatus
        ) {
          throw new BadRequestException(
            `Supplier order status is already ${newStatus}`,
          );
        }

        const supplierTransitions:
          Record<
            OrderStatus,
            OrderStatus[]
          > = {
            [OrderStatus.PENDING]:
              [
                OrderStatus.CONFIRMED,
                OrderStatus.CANCELLED,
              ],

            [OrderStatus.CONFIRMED]:
              [
                OrderStatus.COMPLETED,
                OrderStatus.CANCELLED,
              ],

            [OrderStatus.CANCELLED]:
              [],

            [OrderStatus.COMPLETED]:
              [],
          };

        if (
          userRole ===
            UserRole.SUPPLIER &&
          !supplierTransitions[
            order.status
          ].includes(
            newStatus,
          )
        ) {
          throw new BadRequestException(
            `Cannot change supplier order status from ${order.status} to ${newStatus}`,
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
            await tx.supplierProduct.update({
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
                  item.product.status ===
                  ProductStatus.OUT_OF_STOCK
                    ? ProductStatus.AVAILABLE
                    : item.product.status,
              },
            });
          }
        }

        const updatedOrder =
          await tx.supplierOrder.update({
            where: {
              id,
            },

            data: {
              status:
                newStatus,
            },

            include:
              this.supplierOrderInclude,
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
              'Supply Order Confirmed';

            notificationTitleAr =
              'تم تأكيد طلب المستلزمات';

            notificationMessageEn =
              'Your supply order has been confirmed by the supplier.';

            notificationMessageAr =
              'تم تأكيد طلب المستلزمات من قبل المورد.';

            break;

          case OrderStatus.COMPLETED:
            notificationTitleEn =
              'Supply Order Completed';

            notificationTitleAr =
              'تم إكمال طلب المستلزمات';

            notificationMessageEn =
              'Your supply order has been completed successfully.';

            notificationMessageAr =
              'تم إكمال طلب المستلزمات بنجاح.';

            break;

          case OrderStatus.CANCELLED:
            notificationTitleEn =
              'Supply Order Cancelled';

            notificationTitleAr =
              'تم إلغاء طلب المستلزمات';

            if (
              userRole ===
              UserRole.FARMER
            ) {
              notificationMessageEn =
                'Your supply order has been cancelled successfully.';

              notificationMessageAr =
                'تم إلغاء طلب المستلزمات بنجاح.';
            } else {
              notificationMessageEn =
                'Your supply order has been cancelled by the supplier.';

              notificationMessageAr =
                'تم إلغاء طلب المستلزمات من قبل المورد.';
            }

            break;

          default:
            notificationTitleEn =
              'Supply Order Updated';

            notificationTitleAr =
              'تم تحديث طلب المستلزمات';

            notificationMessageEn =
              `Your supply order status has been updated to ${newStatus}.`;

            notificationMessageAr =
              `تم تحديث حالة طلب المستلزمات إلى ${this.translateOrderStatusToArabic(
                newStatus,
              )}.`;
        }

        await tx.notification.create({
          data: {
            userId:
              order.farmerId,

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
              'SUPPLIER_ORDER',

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