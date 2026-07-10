import {
  Body,
  Controller,
  Get,
  Patch,
  UseGuards,
} from '@nestjs/common';

import { UsersService } from './users.service';
import { UpdateUserDto } from './dto/update-user.dto';

import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CurrentUser } from '../auth/decorators/current-user.decorator';


@Controller('users')
export class UsersController {

  constructor(
    private readonly usersService: UsersService,
  ) {}


  @Get('profile')
  @UseGuards(JwtAuthGuard)
  async getProfile(
    @CurrentUser() user: any,
  ) {
    return this.usersService.findById(user.id);
  }

  @Patch('profile')
@UseGuards(JwtAuthGuard)
async updateProfile(
  @CurrentUser() user: any,
  @Body() updateUserDto: UpdateUserDto,
) {
  return this.usersService.updateProfile(
    user.id,
    updateUserDto,
  );
}

}