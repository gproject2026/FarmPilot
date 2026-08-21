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
import { TranslateDiagnosisDto } from './dto/translate-diagnosis.dto';
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

    const visibleSymptomsEn =
      analysis.visibleSymptoms ?? [];

    const arabicTranslation =
      await this.geminiService
          .translateDiagnosisToArabic({
        plantName:
          detectedPlantName,
        diseaseName,
        visibleSymptoms:
          visibleSymptomsEn,
        description:
          analysis.description,
        causes:
          analysis.causes,
        treatment:
          analysis.treatment,
        prevention:
          analysis.prevention,
      });

    const diagnosis =
      await this.prisma.diagnosis.create({
        data: {
          farmerId,
          cropId,

          plantName:
            detectedPlantName,
          plantNameEn:
            detectedPlantName,
          plantNameAr:
            arabicTranslation.plantName,

          imageUrl,

          diseaseName,
          diseaseNameEn:
            diseaseName,
          diseaseNameAr:
            arabicTranslation.diseaseName,

          confidence:
            analysis.confidence,

          isPlant:
            analysis.isPlant,

          isImageClear:
            analysis.isImageClear,

          isHealthy:
            analysis.isHealthy,

          severity:
            analysis.severity,

          visibleSymptoms:
            JSON.stringify(
              visibleSymptomsEn,
            ),

          visibleSymptomsEn:
            JSON.stringify(
              visibleSymptomsEn,
            ),

          visibleSymptomsAr:
            JSON.stringify(
              arabicTranslation.visibleSymptoms ??
                [],
            ),

          needsExpertReview:
            analysis.needsExpertReview,

          description:
            analysis.description,

          descriptionEn:
            analysis.description,

          descriptionAr:
            arabicTranslation.description,

          causes:
            analysis.causes,

          causesEn:
            analysis.causes,

          causesAr:
            arabicTranslation.causes,

          treatment:
            analysis.treatment,

          treatmentEn:
            analysis.treatment,

          treatmentAr:
            arabicTranslation.treatment,

          prevention:
            analysis.prevention,

          preventionEn:
            analysis.prevention,

          preventionAr:
            arabicTranslation.prevention,
        },
        include: {
          crop: true,
        },
      });

    await this.createDiagnosisNotification({
      farmerId,
      diagnosisId: diagnosis.id,
      plantName: detectedPlantName,
      diseaseName,
      analysis,
    });

    return {
      message:
        'Plant image analyzed successfully',

      diagnosis,

      analysis: {
        isPlant:
          analysis.isPlant,

        isImageClear:
          analysis.isImageClear,

        isHealthy:
          analysis.isHealthy,

        plantName:
          detectedPlantName,

        plantNameEn:
          detectedPlantName,

        plantNameAr:
          arabicTranslation.plantName,

        diseaseName:
          diagnosis.diseaseName,

        diseaseNameEn:
          diseaseName,

        diseaseNameAr:
          arabicTranslation.diseaseName,

        confidence:
          analysis.confidence,

        severity:
          analysis.severity,

        visibleSymptoms:
          visibleSymptomsEn,

        visibleSymptomsEn:
          visibleSymptomsEn,

        visibleSymptomsAr:
          arabicTranslation.visibleSymptoms ??
            [],

        description:
          analysis.description,

        descriptionEn:
          analysis.description,

        descriptionAr:
          arabicTranslation.description,

        causes:
          analysis.causes,

        causesEn:
          analysis.causes,

        causesAr:
          arabicTranslation.causes,

        treatment:
          analysis.treatment,

        treatmentEn:
          analysis.treatment,

        treatmentAr:
          arabicTranslation.treatment,

        prevention:
          analysis.prevention,

        preventionEn:
          analysis.prevention,

        preventionAr:
          arabicTranslation.prevention,

        needsExpertReview:
          analysis.needsExpertReview,
      },

      disclaimer:
        'This is a preliminary AI-assisted assessment and not a laboratory diagnosis. Consult an agricultural specialist before applying hazardous chemicals.',
    };
  }

  async translateToArabic(
    translateDiagnosisDto: TranslateDiagnosisDto,
  ) {
    const translation =
      await this.geminiService
          .translateDiagnosisToArabic({
        plantName:
          translateDiagnosisDto
              .plantName,

        diseaseName:
          translateDiagnosisDto
              .diseaseName,

        visibleSymptoms:
          translateDiagnosisDto
                  .visibleSymptoms ??
              [],

        description:
          translateDiagnosisDto
              .description,

        causes:
          translateDiagnosisDto
              .causes,

        treatment:
          translateDiagnosisDto
              .treatment,

        prevention:
          translateDiagnosisDto
              .prevention,
      });

    return {
      message:
        'Diagnosis translated successfully',

      language:
        'ar',

      translation,
    };
  }

  async create(
    createDiagnosisDto: CreateDiagnosisDto,
    farmerId: string,
  ) {
    if (
      createDiagnosisDto.cropId
    ) {
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
        createdAt:
          'desc',
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
        createdAt:
          'desc',
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
      await this.prisma.diagnosis
          .findUnique({
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
      await this.prisma.diagnosis
          .findUnique({
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

    if (
      updateDiagnosisDto.cropId
    ) {
      await this.validateCropOwnership(
        updateDiagnosisDto.cropId,
        farmerId,
      );
    }

    return this.prisma.diagnosis.update({
      where: {
        id,
      },
      data:
        updateDiagnosisDto,
    });
  }

  async backfillArabic(
    farmerId: string,
  ) {
    const diagnoses =
      await this.prisma.diagnosis.findMany({
        where: {
          farmerId,
        },
        orderBy: {
          createdAt: 'desc',
        },
      });

    let updated = 0;
    let skipped = 0;
    const failed: string[] = [];

    for (const diagnosis of diagnoses) {
      const hasArabicTranslation =
        diagnosis.plantNameAr?.trim() &&
        diagnosis.diseaseNameAr?.trim() &&
        diagnosis.descriptionAr?.trim() &&
        diagnosis.causesAr?.trim() &&
        diagnosis.treatmentAr?.trim() &&
        diagnosis.preventionAr?.trim();

      if (hasArabicTranslation) {
        skipped++;
        continue;
      }

      try {
        let visibleSymptoms: string[] = [];

        if (
          diagnosis.visibleSymptoms &&
          diagnosis.visibleSymptoms.trim()
        ) {
          try {
            const parsedSymptoms =
              JSON.parse(
                diagnosis.visibleSymptoms,
              );

            if (Array.isArray(parsedSymptoms)) {
              visibleSymptoms =
                parsedSymptoms.map(
                  (item) =>
                    item.toString(),
                );
            } else {
              visibleSymptoms = [
                diagnosis.visibleSymptoms,
              ];
            }
          } catch (_) {
            visibleSymptoms = [
              diagnosis.visibleSymptoms,
            ];
          }
        }

        const plantName =
          diagnosis.plantName?.trim() ||
          'Unknown plant';

        const diseaseName =
          diagnosis.diseaseName?.trim() ||
          'Unknown diagnosis';

        const description =
          diagnosis.description?.trim() ||
          '';

        const causes =
          diagnosis.causes?.trim() ||
          '';

        const treatment =
          diagnosis.treatment?.trim() ||
          '';

        const prevention =
          diagnosis.prevention?.trim() ||
          '';

        const translation =
          await this.geminiService
              .translateDiagnosisToArabic({
            plantName,
            diseaseName,
            visibleSymptoms,
            description,
            causes,
            treatment,
            prevention,
          });

        await this.prisma.diagnosis.update({
          where: {
            id: diagnosis.id,
          },
          data: {
            plantNameEn:
              diagnosis.plantName ??
              plantName,

            plantNameAr:
              translation.plantName,

            diseaseNameEn:
              diagnosis.diseaseName ??
              diseaseName,

            diseaseNameAr:
              translation.diseaseName,

            visibleSymptomsEn:
              JSON.stringify(
                visibleSymptoms,
              ),

            visibleSymptomsAr:
              JSON.stringify(
                translation.visibleSymptoms ??
                  [],
              ),

            descriptionEn:
              diagnosis.description ??
              description,

            descriptionAr:
              translation.description,

            causesEn:
              diagnosis.causes ??
              causes,

            causesAr:
              translation.causes,

            treatmentEn:
              diagnosis.treatment ??
              treatment,

            treatmentAr:
              translation.treatment,

            preventionEn:
              diagnosis.prevention ??
              prevention,

            preventionAr:
              translation.prevention,
          },
        });

        updated++;
      } catch (error) {
        console.error(
          `Failed to backfill Arabic diagnosis ${diagnosis.id}:`,
          error,
        );

        failed.push(
          diagnosis.id,
        );
      }
    }

    return {
      message:
        'Arabic diagnosis backfill completed',
      totalFound:
        diagnoses.length,
      updated,
      skipped,
      failed,
    };
  }

  async remove(
    id: string,
    farmerId: string,
  ) {
    const diagnosis =
      await this.prisma.diagnosis
          .findUnique({
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
      diagnosisId: string;
      plantName: string;
      diseaseName: string;
      analysis: PlantDiagnosisResult;
    },
  ) {
    const {
      farmerId,
      diagnosisId,
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
      await this.notificationsService
          .create({
        userId:
          farmerId,

        diagnosisId,

        title:
          notification.title,

        message:
          notification.message,

        type:
          notification.type,
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

    if (
      !analysis.isPlant
    ) {
      return {
        title:
          'No Plant Detected',

        message:
          'The uploaded image does not appear to contain a plant. Please upload a clear plant image and try again.',

        type:
          'DIAGNOSIS_WARNING',
      };
    }

    if (
      !analysis.isImageClear
    ) {
      return {
        title:
          'Image Needs Retake',

        message:
          `The image of ${plantName} was not clear enough for a reliable assessment. Please take a clearer, well-lit photo.`,

        type:
          'DIAGNOSIS_WARNING',
      };
    }

    if (
      analysis.isHealthy
    ) {
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
          id:
            cropId,
        },
        select: {
          id:
            true,

          farmerId:
            true,
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
    if (
      !analysis.isPlant
    ) {
      return 'No plant detected';
    }

    if (
      !analysis.isImageClear
    ) {
      return 'Image unclear';
    }

    if (
      analysis.isHealthy
    ) {
      return 'No clear disease detected';
    }

    return (
      analysis.diseaseName.trim() ||
      'Possible plant disease'
    );
  }
}