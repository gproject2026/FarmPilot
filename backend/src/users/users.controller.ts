import {
  Body,
  Controller,
  Get,
  Param,
  Patch,
  UseGuards,
} from '@nestjs/common';
import { UserRole } from '@prisma/client';

import { UsersService } from './users.service';
import { UpdateUserDto } from './dto/update-user.dto';
import { UpdateUserRoleDto } from './dto/update-user-role.dto';

import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../auth/guards/roles.guard';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { Roles } from '../auth/decorators/roles.decorator';

interface AuthenticatedUser {
  id: string;
  role: UserRole;
}

@Controller('users')
@UseGuards(JwtAuthGuard)
export class UsersController {
  constructor(
    private readonly usersService: UsersService,
  ) {}

  @Get('profile')
  getProfile(
    @CurrentUser() user: AuthenticatedUser,
  ) {
    return this.usersService.findById(user.id);
  }

  @Patch('profile')
  updateProfile(
    @CurrentUser() user: AuthenticatedUser,
    @Body() updateUserDto: UpdateUserDto,
  ) {
    return this.usersService.updateProfile(
      user.id,
      updateUserDto,
    );
  }

  @Get('admin/all')
  @UseGuards(RolesGuard)
  @Roles(UserRole.ADMIN)
  getAllUsers() {
    return this.usersService.findAll();
  }

  @Get('admin/:id')
  @UseGuards(RolesGuard)
  @Roles(UserRole.ADMIN)
  getUserById(
    @Param('id') userId: string,
  ) {
    return this.usersService.findByIdOrThrow(
      userId,
    );
  }

  @Patch('admin/:id/role')
  @UseGuards(RolesGuard)
  @Roles(UserRole.ADMIN)
  updateUserRole(
    @CurrentUser() admin: AuthenticatedUser,
    @Param('id') userId: string,
    @Body()
    updateUserRoleDto: UpdateUserRoleDto,
  ) {
    return this.usersService.updateUserRole(
      admin.id,
      userId,
      updateUserRoleDto.role,
    );
  }
}