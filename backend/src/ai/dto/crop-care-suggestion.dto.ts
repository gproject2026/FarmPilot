import {
  IsIn,
  IsNotEmpty,
  IsNumber,
  IsOptional,
  IsPositive,
  IsString,
} from 'class-validator';

export class CropCareSuggestionDto {
  @IsString()
  @IsNotEmpty()
  cropName!: string;

  @IsString()
  @IsNotEmpty()
  cropType!: string;

  @IsNumber()
  @IsPositive()
  area!: number;

  @IsString()
  @IsNotEmpty()
  areaUnit!: string;

  @IsOptional()
  @IsString()
  plantingDate?: string;

  @IsOptional()
  @IsString()
  notes?: string;

  @IsOptional()
  @IsString()
  @IsIn(['ar', 'en'])
  language?: 'ar' | 'en';
}