import {
  IsDateString,
  IsEnum,
  IsOptional,
  IsUUID,
} from 'class-validator';
import { ReminderType } from '@prisma/client';

export class CreateReminderDto {
  @IsOptional()
  @IsUUID()
  cropId?: string;

  @IsEnum(ReminderType)
  type!: ReminderType;

  @IsDateString()
  reminderDate!: string;
}