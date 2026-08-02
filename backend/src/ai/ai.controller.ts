import {
  Body,
  Controller,
  Post,
  UseGuards,
} from '@nestjs/common';
import { UserRole } from '@prisma/client';

import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { Roles } from '../auth/decorators/roles.decorator';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../auth/guards/roles.guard';

import { AiService } from './ai.service';
import { MarketingDescriptionDto } from './dto/marketing-description.dto';

interface AuthenticatedUser {
  id: string;
  email: string;
  role: UserRole;
}

@Controller('ai')
@UseGuards(JwtAuthGuard, RolesGuard)
export class AiController {
  constructor(
    private readonly aiService: AiService,
  ) {}

  @Post('marketing-description')
  @Roles(UserRole.FARMER)
  generateMarketingDescription( 
    @CurrentUser() user: AuthenticatedUser,
    @Body()
    marketingDescriptionDto: MarketingDescriptionDto,
  ) {
    return this.aiService.generateMarketingDescription(
      user.id,
      marketingDescriptionDto,
    );
  }
}