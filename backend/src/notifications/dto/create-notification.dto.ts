import {
  IsOptional,
  IsString,
  IsUUID,
} from 'class-validator';

export class CreateNotificationDto {
  @IsUUID()
  userId!: string;

  @IsOptional()
  @IsUUID()
  diagnosisId?: string;

  @IsString()
  title!: string;

  @IsString()
  message!: string;

  @IsOptional()
  @IsString()
  titleEn?: string;

  @IsOptional()
  @IsString()
  titleAr?: string;

  @IsOptional()
  @IsString()
  messageEn?: string;

  @IsOptional()
  @IsString()
  messageAr?: string;

  @IsOptional()
  @IsString()
  type?: string;
}