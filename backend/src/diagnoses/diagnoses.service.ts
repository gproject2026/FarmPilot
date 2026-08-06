import {
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';

import {
  GeminiService,
  PlantDiagnosisResult,
} from '../ai/gemini.service';
import { NotificationsService } from '../notifications/notifications.service';
import { PrismaService } from '../prisma/prisma.service';

import { AnalyzeDiagnosisDto } from './dto/analyze-diagnosis.dto';
import { CreateDiagnosisDto } from './dto/create-diagnosis.dto';
import { UpdateDiagnosisDto } from './dto/update-diagnosis.dto';

@Injectable()
export class DiagnosesService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly geminiService: GeminiService,
    private readonly notificationsService: NotificationsService,
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

    const diseaseName =
      this.resolveDiseaseName(
        analysis,
      );

    const diagnosis =
      await this.prisma.diagnosis.create({
        data: {
          farmerId,
          cropId,
          plantName: detectedPlantName,
          imageUrl,
          diseaseName,
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

    await this.createDiagnosisNotification({
      farmerId,
      plantName: detectedPlantName,
      diseaseName,
      analysis,
    });

    return {
      message:
        'Plant image analyzed successfully',
      diagnosis,
      analysis: {
        isPlant: analysis.isPlant,
        isImageClear:
          analysis.isImageClear,
        isHealthy: analysis.isHealthy,
        plantName: detectedPlantName,
        diseaseName:
          diagnosis.diseaseName,
        confidence:
          analysis.confidence,
        severity: analysis.severity,
        visibleSymptoms:
          analysis.visibleSymptoms,
        description:
          analysis.description,
        causes: analysis.causes,
        treatment:
          analysis.treatment,
        prevention:
          analysis.prevention,
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

    if (
      diagnosis.farmerId !==
      farmerId
    ) {
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

    if (
      diagnosis.farmerId !==
      farmerId
    ) {
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

  private async createDiagnosisNotification(
    params: {
      farmerId: string;
      plantName: string;
      diseaseName: string;
      analysis: PlantDiagnosisResult;
    },
  ) {
    const {
      farmerId,
      plantName,
      diseaseName,
      analysis,
    } = params;

    const notification =
      this.buildNotificationData({
        plantName,
        diseaseName,
        analysis,
      });

    try {
      await this.notificationsService.create({
        userId: farmerId,
        title: notification.title,
        message: notification.message,
        type: notification.type,
      });
    } catch (error) {
      console.error(
        'Failed to create diagnosis notification:',
        error,
      );
    }
  }

  private buildNotificationData(
    params: {
      plantName: string;
      diseaseName: string;
      analysis: PlantDiagnosisResult;
    },
  ) {
    const {
      plantName,
      diseaseName,
      analysis,
    } = params;

    if (!analysis.isPlant) {
      return {
        title:
          'No Plant Detected',
        message:
          'The uploaded image does not appear to contain a plant. Please upload a clear plant image and try again.',
        type:
          'DIAGNOSIS_WARNING',
      };
    }

    if (!analysis.isImageClear) {
      return {
        title:
          'Image Needs Retake',
        message:
          `The image of ${plantName} was not clear enough for a reliable assessment. Please take a clearer, well-lit photo.`,
        type:
          'DIAGNOSIS_WARNING',
      };
    }

    if (analysis.isHealthy) {
      return {
        title:
          'Plant Appears Healthy',
        message:
          `${plantName} appears healthy. No clear disease was detected. Continue regular monitoring and preventive care.`,
        type:
          'DIAGNOSIS_HEALTHY',
      };
    }

    if (
      analysis.severity ===
      'high'
    ) {
      return {
        title:
          'High-Risk Plant Diagnosis',
        message:
          `${diseaseName} was detected in ${plantName} with ${analysis.confidence}% confidence. Immediate action and consultation with an agricultural specialist are recommended.`,
        type:
          'DIAGNOSIS_HIGH_RISK',
      };
    }

    if (
      analysis.severity ===
      'moderate'
    ) {
      return {
        title:
          'Plant Disease Detected',
        message:
          `${diseaseName} was detected in ${plantName} with ${analysis.confidence}% confidence. Follow the recommended treatment and monitor the plant closely.`,
        type:
          'DIAGNOSIS_MODERATE_RISK',
      };
    }

    if (
      analysis.needsExpertReview
    ) {
      return {
        title:
          'Expert Review Recommended',
        message:
          `${diseaseName} may be affecting ${plantName}. An agricultural specialist should review this case before chemical treatment is applied.`,
        type:
          'DIAGNOSIS_EXPERT_REVIEW',
      };
    }

    return {
      title:
        'Plant Diagnosis Completed',
      message:
        `${diseaseName} was detected in ${plantName} with ${analysis.confidence}% confidence. Review the diagnosis details for treatment and prevention guidance.`,
      type:
        'DIAGNOSIS_RESULT',
    };
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

    if (
      crop.farmerId !==
      farmerId
    ) {
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