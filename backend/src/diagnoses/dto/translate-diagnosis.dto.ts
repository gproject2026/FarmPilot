import {
  IsArray,
  IsOptional,
  IsString,
} from 'class-validator';

export class TranslateDiagnosisDto {
  @IsString()
  plantName!: string;

  @IsString()
  diseaseName!: string;

  @IsOptional()
  @IsArray()
  @IsString({
    each: true,
  })
  visibleSymptoms?: string[];

  @IsString()
  description!: string;

  @IsString()
  causes!: string;

  @IsString()
  treatment!: string;

  @IsString()
  prevention!: string;
}