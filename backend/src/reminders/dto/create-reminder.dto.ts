import {
  IsDateString,
  IsEnum,
  IsOptional,
  IsString,
  IsUUID,
  MaxLength,
} from 'class-validator';

import { ReminderType } from '@prisma/client';

export class CreateReminderDto {
  @IsOptional()
  @IsString()
  @MaxLength(100)
  title?: string;

  @IsOptional()
  @IsString()
  @MaxLength(100)
  titleEn?: string;

  @IsOptional()
  @IsString()
  @MaxLength(100)
  titleAr?: string;

  @IsOptional()
  @IsString()
  @MaxLength(100)
  cropName?: string;

  @IsOptional()
  @IsString()
  @MaxLength(100)
  cropNameEn?: string;

  @IsOptional()
  @IsString()
  @MaxLength(100)
  cropNameAr?: string;

  @IsOptional()
  @IsUUID()
  cropId?: string;

  @IsOptional()
  @IsEnum(ReminderType)
  type?: ReminderType;

  @IsDateString()
  reminderDate!: string;
}