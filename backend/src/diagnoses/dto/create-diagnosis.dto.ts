import {
  IsNumber,
  IsOptional,
  IsString,
  IsUUID,
  Max,
  Min,
} from 'class-validator';

export class CreateDiagnosisDto {
  @IsOptional()
  @IsUUID()
  cropId?: string;

  @IsString()
  imageUrl!: string;

  @IsOptional()
  @IsString()
  diseaseName?: string;

  @IsOptional()
  @IsNumber()
  @Min(0)
  @Max(100)
  confidence?: number;

  @IsOptional()
  @IsString()
  description?: string;

  @IsOptional()
  @IsString()
  causes?: string;

  @IsOptional()
  @IsString()
  treatment?: string;

  @IsOptional()
  @IsString()
  prevention?: string;
}