import {
  Controller,
  Get,
  UseGuards,
} from '@nestjs/common';

import { DashboardService } from './dashboard.service';

import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CurrentUser } from '../auth/decorators/current-user.decorator';


@Controller('dashboard')
export class DashboardController {

  constructor(
    private readonly dashboardService: DashboardService,
  ) {}



  @Get('farmer')
  @UseGuards(JwtAuthGuard)
  farmerDashboard(
    @CurrentUser() user:any,
  ){

    return this.dashboardService.getFarmerDashboard(
      user.id
    );

  }



  @Get('admin')
  @UseGuards(JwtAuthGuard)
  adminDashboard(){

    return this.dashboardService.getAdminDashboard();

  }

}