import {
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';

import {
  GeminiService,
  PlantDiagnosisResult,
} from '../ai/gemini.service';
import { PrismaService } from '../prisma/prisma.service';

import { AnalyzeDiagnosisDto } from './dto/analyze-diagnosis.dto';
import { CreateDiagnosisDto } from './dto/create-diagnosis.dto';
import { UpdateDiagnosisDto } from './dto/update-diagnosis.dto';

@Injectable()
export class DiagnosesService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly geminiService: GeminiService,
  ) {}

  async analyze(
    analyzeDiagnosisDto: AnalyzeDiagnosisDto,
    farmerId: string,
  ) {
    const {
      cropId,
      imageUrl,
      plantName,
      symptoms,
    } = analyzeDiagnosisDto;

    if (cropId) {
      await this.validateCropOwnership(
        cropId,
        farmerId,
      );
    }

    const analysis =
      await this.geminiService.analyzePlantImage({
        imageUrl,
        plantName,
        symptoms,
      });

    const detectedPlantName =
      analysis.plantName.trim() ||
      plantName?.trim() ||
      'Unknown plant';

    const diagnosis =
      await this.prisma.diagnosis.create({
        data: {
          farmerId,
          cropId,
          plantName: detectedPlantName,
          imageUrl,
          diseaseName:
            this.resolveDiseaseName(analysis),
          confidence: analysis.confidence,
          description: analysis.description,
          causes: analysis.causes,
          treatment: analysis.treatment,
          prevention: analysis.prevention,
        },
        include: {
          crop: true,
        },
      });

    return {
      message:
        'Plant image analyzed successfully',
      diagnosis,
      analysis: {
        isPlant: analysis.isPlant,
        isImageClear: analysis.isImageClear,
        isHealthy: analysis.isHealthy,
        plantName: detectedPlantName,
        diseaseName: diagnosis.diseaseName,
        confidence: analysis.confidence,
        severity: analysis.severity,
        visibleSymptoms:
          analysis.visibleSymptoms,
        description: analysis.description,
        causes: analysis.causes,
        treatment: analysis.treatment,
        prevention: analysis.prevention,
        needsExpertReview:
          analysis.needsExpertReview,
      },
      disclaimer:
        'This is a preliminary AI-assisted assessment and not a laboratory diagnosis. Consult an agricultural specialist before applying hazardous chemicals.',
    };
  }

  async create(
    createDiagnosisDto: CreateDiagnosisDto,
    farmerId: string,
  ) {
    if (createDiagnosisDto.cropId) {
      await this.validateCropOwnership(
        createDiagnosisDto.cropId,
        farmerId,
      );
    }

    return this.prisma.diagnosis.create({
      data: {
        ...createDiagnosisDto,
        farmerId,
      },
    });
  }

  findAll() {
    return this.prisma.diagnosis.findMany({
      orderBy: {
        createdAt: 'desc',
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
        crop: true,
      },
    });
  }

  findMyDiagnoses(
    farmerId: string,
  ) {
    return this.prisma.diagnosis.findMany({
      where: {
        farmerId,
      },
      orderBy: {
        createdAt: 'desc',
      },
      include: {
        crop: true,
      },
    });
  }

  async findOne(
    id: string,
  ) {
    const diagnosis =
      await this.prisma.diagnosis.findUnique({
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
          crop: true,
        },
      });

    if (!diagnosis) {
      throw new NotFoundException(
        'Diagnosis not found',
      );
    }

    return diagnosis;
  }

  async update(
    id: string,
    updateDiagnosisDto: UpdateDiagnosisDto,
    farmerId: string,
  ) {
    const diagnosis =
      await this.prisma.diagnosis.findUnique({
        where: {
          id,
        },
      });

    if (!diagnosis) {
      throw new NotFoundException(
        'Diagnosis not found',
      );
    }

    if (diagnosis.farmerId !== farmerId) {
      throw new ForbiddenException(
        'You are not allowed to update this diagnosis',
      );
    }

    if (updateDiagnosisDto.cropId) {
      await this.validateCropOwnership(
        updateDiagnosisDto.cropId,
        farmerId,
      );
    }

    return this.prisma.diagnosis.update({
      where: {
        id,
      },
      data: updateDiagnosisDto,
    });
  }

  async remove(
    id: string,
    farmerId: string,
  ) {
    const diagnosis =
      await this.prisma.diagnosis.findUnique({
        where: {
          id,
        },
      });

    if (!diagnosis) {
      throw new NotFoundException(
        'Diagnosis not found',
      );
    }

    if (diagnosis.farmerId !== farmerId) {
      throw new ForbiddenException(
        'You are not allowed to delete this diagnosis',
      );
    }

    return this.prisma.diagnosis.delete({
      where: {
        id,
      },
    });
  }

  private async validateCropOwnership(
    cropId: string,
    farmerId: string,
  ) {
    const crop =
      await this.prisma.crop.findUnique({
        where: {
          id: cropId,
        },
        select: {
          id: true,
          farmerId: true,
        },
      });

    if (!crop) {
      throw new NotFoundException(
        'Crop not found',
      );
    }

    if (crop.farmerId !== farmerId) {
      throw new ForbiddenException(
        'You are not allowed to diagnose this crop',
      );
    }
  }

  private resolveDiseaseName(
    analysis: PlantDiagnosisResult,
  ) {
    if (!analysis.isPlant) {
      return 'No plant detected';
    }

    if (!analysis.isImageClear) {
      return 'Image unclear';
    }

    if (analysis.isHealthy) {
      return 'No clear disease detected';
    }

    return (
      analysis.diseaseName.trim() ||
      'Possible plant disease'
    );
  }
}