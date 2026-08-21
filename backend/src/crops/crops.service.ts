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
  constructor(
    private readonly prisma: PrismaService,
  ) {}

  async create(
    createCropDto: CreateCropDto,
    farmerId: string,
  ) {
    const {
      plantingDate,
      ...cropData
    } = createCropDto;

    return this.prisma.crop.create({
      data: {
        ...cropData,
        farmerId,
        plantingDate: plantingDate
          ? new Date(plantingDate)
          : undefined,
      },
    });
  }

  async findAll() {
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
      orderBy: {
        createdAt: 'desc',
      },
    });
  }

  async findMyCrops(
    farmerId: string,
  ) {
    return this.prisma.crop.findMany({
      where: {
        farmerId,
      },
      orderBy: {
        createdAt: 'desc',
      },
    });
  }

  async findOne(
    id: string,
  ) {
    const crop =
        await this.prisma.crop.findUnique({
      where: {
        id,
      },
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

    if (!crop) {
      throw new NotFoundException(
        'Crop not found',
      );
    }

    return crop;
  }

  async update(
    id: string,
    updateCropDto: UpdateCropDto,
    farmerId: string,
  ) {
    const crop =
        await this.prisma.crop.findUnique({
      where: {
        id,
      },
    });

    if (!crop) {
      throw new NotFoundException(
        'Crop not found',
      );
    }

    if (
      crop.farmerId !== farmerId
    ) {
      throw new ForbiddenException(
        'You are not allowed to update this crop',
      );
    }

    const {
      plantingDate,
      ...cropData
    } = updateCropDto;

    return this.prisma.crop.update({
      where: {
        id,
      },
      data: {
        ...cropData,
        plantingDate:
            plantingDate !== undefined
                ? new Date(
                    plantingDate,
                  )
                : undefined,
      },
    });
  }

  async remove(
    id: string,
    farmerId: string,
  ) {
    const crop =
        await this.prisma.crop.findUnique({
      where: {
        id,
      },
    });

    if (!crop) {
      throw new NotFoundException(
        'Crop not found',
      );
    }

    if (
      crop.farmerId !== farmerId
    ) {
      throw new ForbiddenException(
        'You are not allowed to delete this crop',
      );
    }

    return this.prisma.crop.delete({
      where: {
        id,
      },
    });
  }
}