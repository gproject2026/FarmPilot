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
  @IsDateString()
  plantingDate?: string;

  @IsOptional()
  @IsString()
  irrigationSchedule?: string;

  @IsOptional()
  @IsString()
  fertilizationSchedule?: string;

  @IsOptional()
  @IsString()
  notes?: string;
}