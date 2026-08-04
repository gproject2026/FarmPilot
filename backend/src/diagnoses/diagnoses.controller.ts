import {
  Body,
  Controller,
  Delete,
  Get,
  Param,
  Patch,
  Post,
  UseGuards,
} from '@nestjs/common';
import { UserRole } from '@prisma/client';

import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { Roles } from '../auth/decorators/roles.decorator';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../auth/guards/roles.guard';

import { AnalyzeDiagnosisDto } from './dto/analyze-diagnosis.dto';
import { CreateDiagnosisDto } from './dto/create-diagnosis.dto';
import { UpdateDiagnosisDto } from './dto/update-diagnosis.dto';
import { DiagnosesService } from './diagnoses.service';

interface AuthenticatedUser {
  id: string;
  email: string;
  role: UserRole;
}

@Controller('diagnoses')
export class DiagnosesController {
  constructor(
    private readonly diagnosesService: DiagnosesService,
  ) {}

  @Post('analyze')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.FARMER)
  analyze(
    @Body()
    analyzeDiagnosisDto: AnalyzeDiagnosisDto,
    @CurrentUser()
    user: AuthenticatedUser,
  ) {
    return this.diagnosesService.analyze(
      analyzeDiagnosisDto,
      user.id,
    );
  }

  @Post()
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.FARMER)
  create(
    @Body()
    createDiagnosisDto: CreateDiagnosisDto,
    @CurrentUser()
    user: AuthenticatedUser,
  ) {
    return this.diagnosesService.create(
      createDiagnosisDto,
      user.id,
    );
  }

  @Get()
  findAll() {
    return this.diagnosesService.findAll();
  }

  @Get(':id')
  findOne(
    @Param('id')
    id: string,
  ) {
    return this.diagnosesService.findOne(
      id,
    );
  }

  @Patch(':id')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.FARMER)
  update(
    @Param('id')
    id: string,
    @Body()
    updateDiagnosisDto: UpdateDiagnosisDto,
    @CurrentUser()
    user: AuthenticatedUser,
  ) {
    return this.diagnosesService.update(
      id,
      updateDiagnosisDto,
      user.id,
    );
  }

  @Delete(':id')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.FARMER)
  remove(
    @Param('id')
    id: string,
    @CurrentUser()
    user: AuthenticatedUser,
  ) {
    return this.diagnosesService.remove(
      id,
      user.id,
    );
  }
}