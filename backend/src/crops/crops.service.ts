import {
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

import { CreateCropDto } from './dto/create-crop.dto';
import { UpdateCropDto } from './dto/update-crop.dto';

@Injectable()
export class CropsService {
  constructor(private readonly prisma: PrismaService) {}

  async create(createCropDto: CreateCropDto, farmerId: string) {
    return this.prisma.crop.create({
      data: {
        ...createCropDto,
        farmerId,
        plantingDate: createCropDto.plantingDate
          ? new Date(createCropDto.plantingDate)
          : undefined,
      },
    });
  }

  findAll() {
    return this.prisma.crop.findMany({
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
      },
    });
  }

  findOne(id: string) {
    return this.prisma.crop.findUnique({
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
      },
    });
  }

  async update(id: string, updateCropDto: UpdateCropDto, farmerId: string) {
    const crop = await this.prisma.crop.findUnique({
      where: { id },
    });

    if (!crop) {
      throw new NotFoundException('Crop not found');
    }

    if (crop.farmerId !== farmerId) {
      throw new ForbiddenException('You are not allowed to update this crop');
    }

    return this.prisma.crop.update({
      where: { id },
      data: {
        ...updateCropDto,
        plantingDate: updateCropDto.plantingDate
          ? new Date(updateCropDto.plantingDate)
          : undefined,
      },
    });
  }

  async remove(id: string, farmerId: string) {
    const crop = await this.prisma.crop.findUnique({
      where: { id },
    });

    if (!crop) {
      throw new NotFoundException('Crop not found');
    }

    if (crop.farmerId !== farmerId) {
      throw new ForbiddenException('You are not allowed to delete this crop');
    }

    return this.prisma.crop.delete({
      where: { id },
    });
  }
}