import {
  IsIn,
  IsNotEmpty,
  IsOptional,
  IsString,
} from 'class-validator';

export class CropCareSuggestionDto {
  @IsString()
  @IsNotEmpty()
  cropName!: string;

  @IsString()
  @IsNotEmpty()
  cropType!: string;

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