import {
  IsOptional,
  IsString,
  IsUUID,
  MaxLength,
  MinLength,
} from 'class-validator';

export class AnalyzeDiagnosisDto {
  @IsOptional()
  @IsUUID()
  cropId?: string;

  @IsString()
  @MinLength(1)
  imageUrl!: string;

  @IsOptional()
  @IsString()
  @MaxLength(100)
  plantName?: string;

  @IsOptional()
  @IsString()
  @MaxLength(1000)
  symptoms?: string;
}