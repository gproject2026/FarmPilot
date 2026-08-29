import {
  IsInt,
  IsNotEmpty,
  IsNumber,
  IsOptional,
  IsString,
  IsUrl,
  IsUUID,
  Min,
} from 'class-validator';
import { Type } from 'class-transformer';

export class CreateSupplierProductDto {
  @IsUUID()
  categoryId!: string;

  @IsString()
  @IsNotEmpty()
  name!: string;

  @IsOptional()
  @IsString()
  description?: string;

  @IsOptional()
  @IsString()
  nameEn?: string;

  @IsOptional()
  @IsString()
  nameAr?: string;

  @IsOptional()
  @IsString()
  descriptionEn?: string;

  @IsOptional()
  @IsString()
  descriptionAr?: string;

  @IsOptional()
  @IsString()
  plantingInstructions?: string;

  @IsOptional()
  @IsString()
  plantingInstructionsEn?: string;

  @IsOptional()
  @IsString()
  plantingInstructionsAr?: string;

  @IsOptional()
  @IsString()
  irrigationInstructions?: string;

  @IsOptional()
  @IsString()
  irrigationInstructionsEn?: string;

  @IsOptional()
  @IsString()
  irrigationInstructionsAr?: string;

  @IsOptional()
  @IsString()
  usageInstructions?: string;

  @IsOptional()
  @IsString()
  usageInstructionsEn?: string;

  @IsOptional()
  @IsString()
  usageInstructionsAr?: string;

  @Type(() => Number)
  @IsNumber()
  @Min(0)
  price!: number;

  @Type(() => Number)
  @IsInt()
  @Min(0)
  quantity!: number;

  @IsString()
  @IsNotEmpty()
  unit!: string;

  @IsOptional()
  @IsString()
  imageUrl?: string;
}