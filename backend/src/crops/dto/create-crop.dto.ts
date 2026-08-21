import {
  IsDateString,
  IsNotEmpty,
  IsOptional,
  IsString,
} from 'class-validator';

export class CreateCropDto {
  @IsString()
  @IsNotEmpty()
  cropName!: string;

  @IsOptional()
  @IsString()
  cropType?: string;

  @IsOptional()
  @IsString()
  cropNameEn?: string;

  @IsOptional()
  @IsString()
  cropNameAr?: string;

  @IsOptional()
  @IsString()
  cropTypeEn?: string;

  @IsOptional()
  @IsString()
  cropTypeAr?: string;

  @IsOptional()
  @IsDateString()
  plantingDate?: string;

  @IsOptional()
  @IsString()
  irrigationSchedule?: string;

  @IsOptional()
  @IsString()
  irrigationScheduleEn?: string;

  @IsOptional()
  @IsString()
  irrigationScheduleAr?: string;

  @IsOptional()
  @IsString()
  fertilizationSchedule?: string;

  @IsOptional()
  @IsString()
  fertilizationScheduleEn?: string;

  @IsOptional()
  @IsString()
  fertilizationScheduleAr?: string;

  @IsOptional()
  @IsString()
  notes?: string;

  @IsOptional()
  @IsString()
  notesEn?: string;

  @IsOptional()
  @IsString()
  notesAr?: string;
}