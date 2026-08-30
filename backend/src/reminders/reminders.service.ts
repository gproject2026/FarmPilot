import {
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';

import { GeminiService } from '../ai/gemini.service';
import { PrismaService } from '../prisma/prisma.service';

import { CreateReminderDto } from './dto/create-reminder.dto';
import { UpdateReminderDto } from './dto/update-reminder.dto';

@Injectable()
export class RemindersService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly geminiService: GeminiService,
  ) {}

  async create(
    createReminderDto: CreateReminderDto,
    farmerId: string,
  ) {
    if (createReminderDto.cropId) {
      await this.validateCropOwnership(
        createReminderDto.cropId,
        farmerId,
      );
    }

    const title =
      createReminderDto.title?.trim() ?? '';

    const cropName =
      createReminderDto.cropName?.trim() ?? '';

    let titleEn: string | null = null;
    let titleAr: string | null = null;

    let cropNameEn: string | null = null;
    let cropNameAr: string | null = null;

    if (title.length > 0) {
      const isArabic =
        this.containsArabic(title);

      if (isArabic) {
        titleAr = title;

        cropNameAr =
          cropName.length > 0
            ? cropName
            : null;

        const translation =
          await this.geminiService
              .translateReminderContent({
            title,
            cropName,
            targetLanguage: 'en',
          });

        titleEn =
          translation.title.trim();

        cropNameEn =
          translation.cropName.trim().length > 0
            ? translation.cropName.trim()
            : null;
      } else {
        titleEn = title;

        cropNameEn =
          cropName.length > 0
            ? cropName
            : null;

        const translation =
          await this.geminiService
              .translateReminderContent({
            title,
            cropName,
            targetLanguage: 'ar',
          });

        titleAr =
          translation.title.trim();

        cropNameAr =
          translation.cropName.trim().length > 0
            ? translation.cropName.trim()
            : null;
      }
    }

    return this.prisma.reminder.create({
      data: {
        farmerId,

        title:
          title.length > 0
            ? title
            : null,

        titleEn,
        titleAr,

        cropName:
          cropName.length > 0
            ? cropName
            : null,

        cropNameEn,
        cropNameAr,

        cropId:
          createReminderDto.cropId,

        type:
          createReminderDto.type,

        reminderDate: new Date(
          createReminderDto.reminderDate,
        ),

        repeatDays:
          createReminderDto.repeatDays ?? [],
      },
      include: {
        crop: true,
      },
    });
  }

  findAll(
    farmerId: string,
  ) {
    return this.prisma.reminder.findMany({
      where: {
        farmerId,
      },
      include: {
        crop: true,
      },
      orderBy: {
        reminderDate: 'asc',
      },
    });
  }

  async findOne(
    id: string,
    farmerId: string,
  ) {
    const reminder =
      await this.prisma.reminder.findUnique({
        where: {
          id,
        },
        include: {
          crop: true,
        },
      });

    if (!reminder) {
      throw new NotFoundException(
        'Reminder not found',
      );
    }

    if (
      reminder.farmerId !== farmerId
    ) {
      throw new ForbiddenException(
        'You are not allowed to access this reminder',
      );
    }

    return reminder;
  }

  async update(
    id: string,
    updateReminderDto: UpdateReminderDto,
    farmerId: string,
  ) {
    const reminder =
      await this.prisma.reminder.findUnique({
        where: {
          id,
        },
      });

    if (!reminder) {
      throw new NotFoundException(
        'Reminder not found',
      );
    }

    if (
      reminder.farmerId !== farmerId
    ) {
      throw new ForbiddenException(
        'You are not allowed to update this reminder',
      );
    }

    if (updateReminderDto.cropId) {
      await this.validateCropOwnership(
        updateReminderDto.cropId,
        farmerId,
      );
    }

    let title:
      | string
      | null
      | undefined;

    let titleEn:
      | string
      | null
      | undefined;

    let titleAr:
      | string
      | null
      | undefined;

    let cropName:
      | string
      | null
      | undefined;

    let cropNameEn:
      | string
      | null
      | undefined;

    let cropNameAr:
      | string
      | null
      | undefined;

    const shouldTranslate =
      updateReminderDto.title !== undefined ||
      updateReminderDto.cropName !== undefined;

    if (shouldTranslate) {
      title =
        updateReminderDto.title !== undefined
          ? updateReminderDto.title.trim() ||
            null
          : reminder.title;

      cropName =
        updateReminderDto.cropName !== undefined
          ? updateReminderDto.cropName.trim() ||
            null
          : reminder.cropName;

      if (title) {
        const isArabic =
          this.containsArabic(title);

        if (isArabic) {
          titleAr = title;
          cropNameAr = cropName;

          const translation =
            await this.geminiService
                .translateReminderContent({
              title,
              cropName:
                cropName ?? '',
              targetLanguage: 'en',
            });

          titleEn =
            translation.title.trim();

          cropNameEn =
            translation.cropName
                    .trim()
                    .length >
                0
              ? translation.cropName.trim()
              : null;
        } else {
          titleEn = title;
          cropNameEn = cropName;

          const translation =
            await this.geminiService
                .translateReminderContent({
              title,
              cropName:
                cropName ?? '',
              targetLanguage: 'ar',
            });

          titleAr =
            translation.title.trim();

          cropNameAr =
            translation.cropName
                    .trim()
                    .length >
                0
              ? translation.cropName.trim()
              : null;
        }
      } else {
        titleEn = null;
        titleAr = null;

        cropNameEn = cropName;
        cropNameAr = cropName;
      }
    }

    const reminderDateChanged =
      updateReminderDto.reminderDate !== undefined;

    const repeatDaysChanged =
      updateReminderDto.repeatDays !== undefined;

    return this.prisma.reminder.update({
      where: {
        id,
      },
      data: {
        title,
        titleEn,
        titleAr,

        cropName,
        cropNameEn,
        cropNameAr,

        cropId:
          updateReminderDto.cropId,

        type:
          updateReminderDto.type,

        reminderDate:
          updateReminderDto.reminderDate
            ? new Date(
                updateReminderDto.reminderDate,
              )
            : undefined,

        repeatDays:
          updateReminderDto.repeatDays,

        status:
          updateReminderDto.status,

        notificationSentAt:
          reminderDateChanged ||
          repeatDaysChanged
            ? null
            : undefined,
      },
      include: {
        crop: true,
      },
    });
  }

  async remove(
    id: string,
    farmerId: string,
  ) {
    const reminder =
      await this.prisma.reminder.findUnique({
        where: {
          id,
        },
      });

    if (!reminder) {
      throw new NotFoundException(
        'Reminder not found',
      );
    }

    if (
      reminder.farmerId !== farmerId
    ) {
      throw new ForbiddenException(
        'You are not allowed to delete this reminder',
      );
    }

    return this.prisma.reminder.delete({
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
        'You cannot use this crop',
      );
    }
  }

  private containsArabic(
    value: string,
  ): boolean {
    return /[\u0600-\u06FF]/.test(
      value,
    );
  }
}