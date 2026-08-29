import { IsEnum } from 'class-validator';

import { OrderStatus } from '@prisma/client';

export class UpdateSupplierOrderStatusDto {
  @IsEnum(OrderStatus)
  status!: OrderStatus;
}