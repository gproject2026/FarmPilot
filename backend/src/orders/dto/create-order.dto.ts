import { Type } from 'class-transformer';

import {
  ArrayMinSize,
  IsArray,
  IsEnum,
  IsInt,
  IsOptional,
  IsString,
  IsUUID,
  MaxLength,
  Min,
  ValidateNested,
} from 'class-validator';

import {
  DeliveryMethod,
  PaymentMethod,
} from '@prisma/client';

export class CreateOrderItemDto {
  @IsUUID()
  productId!: string;

  @Type(() => Number)
  @IsInt()
  @Min(1)
  quantity!: number;
}

export class CreateOrderDto {
  @IsArray()
  @ArrayMinSize(1)
  @ValidateNested({ each: true })
  @Type(() => CreateOrderItemDto)
  items!: CreateOrderItemDto[];

  @IsEnum(DeliveryMethod)
  deliveryMethod!: DeliveryMethod;

  @IsOptional()
  @IsString()
  @MaxLength(500)
  deliveryAddress?: string;

  @IsOptional()
  @IsString()
  @MaxLength(500)
  pickupLocation?: string;

  @IsOptional()
  @IsEnum(PaymentMethod)
  paymentMethod?: PaymentMethod;
}