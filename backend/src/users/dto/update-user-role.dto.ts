import { IsEnum } from 'class-validator';
import { UserRole } from '@prisma/client';

export class UpdateUserRoleDto {
  @IsEnum(UserRole, {
    message:
      'Role must be ADMIN, FARMER, or CUSTOMER',
  })
  role!: UserRole;
}