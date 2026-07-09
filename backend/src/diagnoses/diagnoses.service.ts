import {
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

import { CreateDiagnosisDto } from './dto/create-diagnosis.dto';
import { UpdateDiagnosisDto } from './dto/update-diagnosis.dto';

@Injectable()
export class DiagnosesService {
  constructor(private readonly prisma: PrismaService) {}

  async create(
    createDiagnosisDto: CreateDiagnosisDto,
    farmerId: string,
  ) {
    return this.prisma.diagnosis.create({
      data: {
        ...createDiagnosisDto,
        farmerId,
      },
    });
  }

  findAll() {
    return this.prisma.diagnosis.findMany({
      include: {
        farmer: {
          select: {
            id: true,
            fullName: true,
            email: true,
            phone: true,
            role: true,
            address: true,
            profileImage: true,
          },
        },
        crop: true,
      },
    });
  }

  findOne(id: string) {
    return this.prisma.diagnosis.findUnique({
      where: { id },
      include: {
        farmer: {
          select: {
            id: true,
            fullName: true,
            email: true,
            phone: true,
            role: true,
            address: true,
            profileImage: true,
          },
        },
        crop: true,
      },
    });
  }

  async update(
    id: string,
    updateDiagnosisDto: UpdateDiagnosisDto,
    farmerId: string,
  ) {
    const diagnosis = await this.prisma.diagnosis.findUnique({
      where: { id },
    });

    if (!diagnosis) {
      throw new NotFoundException('Diagnosis not found');
    }

    if (diagnosis.farmerId !== farmerId) {
      throw new ForbiddenException(
        'You are not allowed to update this diagnosis',
      );
    }

    return this.prisma.diagnosis.update({
      where: { id },
      data: updateDiagnosisDto,
    });
  }

  async remove(id: string, farmerId: string) {
    const diagnosis = await this.prisma.diagnosis.findUnique({
      where: { id },
    });

    if (!diagnosis) {
      throw new NotFoundException('Diagnosis not found');
    }

    if (diagnosis.farmerId !== farmerId) {
      throw new ForbiddenException(
        'You are not allowed to delete this diagnosis',
      );
    }

    return this.prisma.diagnosis.delete({
      where: { id },
    });
  }
}