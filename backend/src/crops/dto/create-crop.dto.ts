import {
  IsDateString,
  IsIn,
  IsNotEmpty,
  IsNumber,
  IsOptional,
  IsPositive,
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
  @IsNumber()
  @IsPositive()
  area?: number;

  @IsOptional()
  @IsString()
  areaUnit?: string;

  @IsOptional()
  @IsNumber()
  @IsPositive()
  expectedYieldMin?: number;

  @IsOptional()
  @IsNumber()
  @IsPositive()
  expectedYieldMax?: number;

  @IsOptional()
  @IsString()
  yieldUnit?: string;

  @IsOptional()
  @IsString()
  @IsIn([
    'LOW',
    'MEDIUM',
    'HIGH',
  ])
  yieldConfidence?: string;

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
  sprayingSchedule?: string;

  @IsOptional()
  @IsString()
  sprayingScheduleEn?: string;

  @IsOptional()
  @IsString()
  sprayingScheduleAr?: string;

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