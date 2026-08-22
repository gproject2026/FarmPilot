import {
  Injectable,
  NotFoundException,
} from '@nestjs/common';

import { PrismaService } from '../prisma/prisma.service';

import { CreateNotificationDto } from './dto/create-notification.dto';
import { UpdateNotificationDto } from './dto/update-notification.dto';

@Injectable()
export class NotificationsService {
  constructor(
    private readonly prisma: PrismaService,
  ) {}

  create(
    createNotificationDto: CreateNotificationDto,
  ) {
    return this.prisma.notification.create({
      data: {
        ...createNotificationDto,
      },
    });
  }

  findAll() {
    return this.prisma.notification.findMany({
      include: {
        user: {
          select: {
            id: true,
            fullName: true,
            email: true,
            role: true,
          },
        },
      },
      orderBy: {
        createdAt: 'desc',
      },
    });
  }

  async findOne(
    id: string,
    userId: string,
  ) {
    const notification =
      await this.prisma.notification.findFirst({
        where: {
          id,
          userId,
        },
        include: {
          user: {
            select: {
              id: true,
              fullName: true,
              email: true,
              role: true,
            },
          },
        },
      });

    if (!notification) {
      throw new NotFoundException(
        'Notification not found',
      );
    }

    return notification;
  }

  update(
    id: string,
    updateNotificationDto: UpdateNotificationDto,
  ) {
    return this.prisma.notification.update({
      where: {
        id,
      },
      data: updateNotificationDto,
    });
  }

  remove(
    id: string,
  ) {
    return this.prisma.notification.delete({
      where: {
        id,
      },
    });
  }

  findMyNotifications(
    userId: string,
  ) {
    return this.prisma.notification.findMany({
      where: {
        userId,
      },
      orderBy: {
        createdAt: 'desc',
      },
    });
  }

  async markAsRead(
    id: string,
    userId: string,
  ) {
    const notification =
      await this.prisma.notification.findFirst({
        where: {
          id,
          userId,
        },
      });

    if (!notification) {
      throw new NotFoundException(
        'Notification not found',
      );
    }

    if (notification.isRead) {
      return notification;
    }

    return this.prisma.notification.update({
      where: {
        id,
      },
      data: {
        isRead: true,
      },
    });
  }

  async backfillTranslations(
    userId: string,
  ) {
    const notifications =
      await this.prisma.notification.findMany({
        where: {
          userId,
        },
        include: {
          diagnosis: {
            select: {
              plantName: true,
              plantNameEn: true,
              plantNameAr: true,

              diseaseName: true,
              diseaseNameEn: true,
              diseaseNameAr: true,

              confidence: true,

              isPlant: true,
              isImageClear: true,
              isHealthy: true,
              severity: true,
              needsExpertReview: true,
            },
          },
        },
        orderBy: {
          createdAt: 'desc',
        },
      });

    let updated = 0;
    let skipped = 0;

    const failed: string[] = [];

    for (
      const notification of notifications
    ) {
      const hasEnglish =
        notification.titleEn?.trim() &&
        notification.messageEn?.trim();

      const hasArabic =
        notification.titleAr?.trim() &&
        notification.messageAr?.trim();

      if (
        hasEnglish &&
        hasArabic
      ) {
        skipped++;
        continue;
      }

      try {
        const type =
          notification.type
            ?.trim()
            .toUpperCase() ??
          '';

        let titleEn =
          notification.titleEn?.trim() ||
          notification.title.trim();

        let messageEn =
          notification.messageEn?.trim() ||
          notification.message.trim();

        let titleAr =
          notification.titleAr?.trim() ||
          '';

        let messageAr =
          notification.messageAr?.trim() ||
          '';

        if (
          type.includes('ORDER')
        ) {
          finalOrderTranslation:
          switch (titleEn) {
            case 'New Order':
              titleAr =
                'طلب جديد';

              messageAr =
                'لقد استلمت طلبًا جديدًا.';

              break finalOrderTranslation;

            case 'Order Confirmed':
              titleAr =
                'تم تأكيد الطلب';

              messageAr =
                'تم تأكيد طلبك من قبل المزارع.';

              break finalOrderTranslation;

            case 'Order Completed':
              titleAr =
                'تم إكمال الطلب';

              messageAr =
                'تم إكمال طلبك بنجاح.';

              break finalOrderTranslation;

            case 'Order Cancelled':
              titleAr =
                'تم إلغاء الطلب';

              if (
                messageEn
                    .toLowerCase()
                    .includes(
                      'by the farmer',
                    )
              ) {
                messageAr =
                  'تم إلغاء طلبك من قبل المزارع.';
              } else {
                messageAr =
                  'تم إلغاء طلبك بنجاح.';
              }

              break finalOrderTranslation;

            case 'Order Updated':
              titleAr =
                'تم تحديث الطلب';

              messageAr =
                'تم تحديث حالة طلبك.';

              break finalOrderTranslation;

            default:
              titleAr =
                'إشعار طلب';

              messageAr =
                'يوجد تحديث جديد متعلق بطلبك.';
          }
        } else if (
          type.includes('DIAGNOSIS')
        ) {
          const diagnosis =
            notification.diagnosis;

          const plantNameEn =
            diagnosis?.plantNameEn?.trim() ??
            diagnosis?.plantName?.trim() ??
            'plant';

          const plantNameAr =
            diagnosis?.plantNameAr?.trim() ??
            'النبات';

          const diseaseNameEn =
            diagnosis?.diseaseNameEn?.trim() ??
            diagnosis?.diseaseName?.trim() ??
            'plant disease';

          const diseaseNameAr =
            diagnosis?.diseaseNameAr?.trim() ??
            'مرض نباتي';

          const confidence =
            diagnosis?.confidence
                ?.toString() ??
            '';

          if (
            type.includes(
              'DIAGNOSIS_HIGH_RISK',
            )
          ) {
            titleEn =
              'High-Risk Plant Diagnosis';

            titleAr =
              'تشخيص نباتي عالي الخطورة';

            messageEn =
              `${diseaseNameEn} was detected in ${plantNameEn}` +
              `${confidence.length > 0 ? ` with ${confidence}% confidence` : ''}. ` +
              'Immediate action and consultation with an agricultural specialist are recommended.';

            messageAr =
              `تم اكتشاف ${diseaseNameAr} في ${plantNameAr}` +
              `${confidence.length > 0 ? ` بنسبة ثقة ${confidence}%` : ''}. ` +
              'يُنصح باتخاذ إجراء فوري واستشارة مختص زراعي.';
          } else if (
            type.includes(
              'DIAGNOSIS_MODERATE_RISK',
            )
          ) {
            titleEn =
              'Plant Disease Detected';

            titleAr =
              'تم اكتشاف مرض نباتي';

            messageEn =
              `${diseaseNameEn} was detected in ${plantNameEn}` +
              `${confidence.length > 0 ? ` with ${confidence}% confidence` : ''}. ` +
              'Follow the recommended treatment and monitor the plant closely.';

            messageAr =
              `تم اكتشاف ${diseaseNameAr} في ${plantNameAr}` +
              `${confidence.length > 0 ? ` بنسبة ثقة ${confidence}%` : ''}. ` +
              'اتبع العلاج الموصى به وراقب النبات بعناية.';
          } else if (
            type.includes(
              'DIAGNOSIS_HEALTHY',
            )
          ) {
            titleEn =
              'Plant Appears Healthy';

            titleAr =
              'النبات يبدو سليمًا';

            messageEn =
              `${plantNameEn} appears healthy. ` +
              'No clear disease was detected. ' +
              'Continue regular monitoring and preventive care.';

            messageAr =
              `يبدو أن ${plantNameAr} سليم. ` +
              'لم يتم اكتشاف مرض واضح. ' +
              'استمر في المراقبة المنتظمة والعناية الوقائية.';
          } else if (
            type.includes(
              'DIAGNOSIS_EXPERT_REVIEW',
            )
          ) {
            titleEn =
              'Expert Review Recommended';

            titleAr =
              'يوصى بمراجعة مختص';

            messageEn =
              `${diseaseNameEn} may be affecting ${plantNameEn}. ` +
              'An agricultural specialist should review this case before chemical treatment is applied.';

            messageAr =
              `قد يكون ${diseaseNameAr} مؤثرًا على ${plantNameAr}. ` +
              'يُنصح بأن يراجع مختص زراعي هذه الحالة قبل استخدام أي علاج كيميائي.';
          } else if (
            type.includes(
              'DIAGNOSIS_WARNING',
            )
          ) {
            if (
              diagnosis?.isPlant ==
              false
            ) {
              titleEn =
                'No Plant Detected';

              titleAr =
                'لم يتم اكتشاف نبات';

              messageEn =
                'The uploaded image does not appear to contain a plant. '
                'Please upload a clear plant image and try again.';

              messageAr =
                'لا يبدو أن الصورة المرفوعة تحتوي على نبات. '
                'يرجى رفع صورة واضحة للنبات والمحاولة مرة أخرى.';
            } else {
              titleEn =
                'Image Needs Retake';

              titleAr =
                'يجب إعادة التقاط الصورة';

              messageEn =
                `The image of ${plantNameEn} was not clear enough for a reliable assessment. ` +
                'Please take a clearer, well-lit photo.';

              messageAr =
                `لم تكن صورة ${plantNameAr} واضحة بما يكفي لإجراء تقييم موثوق. ` +
                'يرجى التقاط صورة أوضح وبإضاءة جيدة.';
            }
          } else {
            titleEn =
              'Plant Diagnosis Completed';

            titleAr =
              'اكتمل تشخيص النبات';

            messageEn =
              `${diseaseNameEn} was detected in ${plantNameEn}` +
              `${confidence.length > 0 ? ` with ${confidence}% confidence` : ''}. ` +
              'Review the diagnosis details for treatment and prevention guidance.';

            messageAr =
              `تم اكتشاف ${diseaseNameAr} في ${plantNameAr}` +
              `${confidence.length > 0 ? ` بنسبة ثقة ${confidence}%` : ''}. ` +
              'راجع تفاصيل التشخيص للحصول على إرشادات العلاج والوقاية.';
          }
        } else {
          if (titleAr.length === 0) {
            titleAr =
              this.translateKnownTitle(
                titleEn,
              );
          }

          if (messageAr.length === 0) {
            messageAr =
              this.translateKnownMessage(
                messageEn,
              );
          }
        }

        await this.prisma.notification.update({
          where: {
            id:
              notification.id,
          },
          data: {
            titleEn,
            titleAr,
            messageEn,
            messageAr,
          },
        });

        updated++;
      } catch (error) {
        console.error(
          `Failed to backfill notification ${notification.id}:`,
          error,
        );

        failed.push(
          notification.id,
        );
      }
    }

    return {
      message:
        'Notification translation backfill completed',

      totalFound:
        notifications.length,

      updated,

      skipped,

      failed,
    };
  }

  private translateKnownTitle(
    title: string,
  ): string {
    switch (title.trim()) {
      case 'New Order':
        return 'طلب جديد';

      case 'Order Confirmed':
        return 'تم تأكيد الطلب';

      case 'Order Completed':
        return 'تم إكمال الطلب';

      case 'Order Cancelled':
        return 'تم إلغاء الطلب';

      case 'Order Updated':
        return 'تم تحديث الطلب';

      case 'High-Risk Plant Diagnosis':
        return 'تشخيص نباتي عالي الخطورة';

      case 'Plant Disease Detected':
        return 'تم اكتشاف مرض نباتي';

      case 'Plant Appears Healthy':
        return 'النبات يبدو سليمًا';

      case 'Expert Review Recommended':
        return 'يوصى بمراجعة مختص';

      case 'Plant Diagnosis Completed':
        return 'اكتمل تشخيص النبات';

      case 'No Plant Detected':
        return 'لم يتم اكتشاف نبات';

      case 'Image Needs Retake':
        return 'يجب إعادة التقاط الصورة';

      default:
        return title;
    }
  }

  private translateKnownMessage(
    message: string,
  ): string {
    switch (message.trim()) {
      case 'You have received a new order.':
        return 'لقد استلمت طلبًا جديدًا.';

      case 'Your order has been confirmed by the farmer.':
        return 'تم تأكيد طلبك من قبل المزارع.';

      case 'Your order has been completed successfully.':
        return 'تم إكمال طلبك بنجاح.';

      case 'Your order has been cancelled successfully.':
        return 'تم إلغاء طلبك بنجاح.';

      case 'Your order has been cancelled by the farmer.':
        return 'تم إلغاء طلبك من قبل المزارع.';

      default:
        return message;
    }
  }
}