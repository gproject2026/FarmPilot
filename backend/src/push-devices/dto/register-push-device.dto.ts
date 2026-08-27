import {
  IsIn,
  IsNotEmpty,
  IsString,
} from 'class-validator';

export class RegisterPushDeviceDto {
  @IsString()
  @IsNotEmpty()
  token!: string;

  @IsString()
  @IsIn([
    'android',
    'ios',
    'web',
  ])
  platform!: string;
}