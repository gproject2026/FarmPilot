import { Injectable, Logger } from '@nestjs/common';
import { Cron, CronExpression } from '@nestjs/schedule';

import { FirebaseService } from '../firebase/firebase.service';
import { PrismaService } from '../prisma/prisma.service';
import { PushDevicesService } from '../push-devices/push-devices.service';

@Injectable()
export class ReminderNotificationScheduler {
  private readonly logger = new Logger(
    ReminderNotificationScheduler.name,
  );

  constructor(
    private readonly prisma: PrismaService,
    private readonly firebaseService: FirebaseService,
    private readonly pushDevicesService: PushDevicesService,
  ) {}

  @Cron(CronExpression.EVERY_MINUTE)
  async sendDueReminders() {
    const now = new Date();

    this.logger.log(
      `Checking due reminders at ${now.toISOString()}`,
    );

    const reminders =
      await this.prisma.reminder.findMany({
        where: {
          reminderDate: {
            lte: now,
          },
          status: false,
          notificationSentAt: null,
        },
        orderBy: {
          reminderDate: 'asc',
        },
      });

    this.logger.log(
      `Found ${reminders.length} due reminder(s)`,
    );

    for (const reminder of reminders) {
      try {
        this.logger.log(
          `Processing reminder ${reminder.id} for farmer ${reminder.farmerId}`,
        );

        const title =
          reminder.title ??
          reminder.titleEn ??
          reminder.titleAr ??
          'FarmPilot Reminder';

        const titleEn =
          reminder.titleEn ??
          reminder.title ??
          'FarmPilot Reminder';

        const titleAr =
          reminder.titleAr ??
          reminder.title ??
          'تذكير FarmPilot';

        const bodyParts: string[] = [];

        if (
          reminder.cropName &&
          reminder.cropName.trim().length > 0
        ) {
          bodyParts.push(
            reminder.cropName,
          );
        }

        bodyParts.push(
          this.getReminderTypeLabel(
            reminder.type,
          ),
        );

        const body =
          bodyParts.join(' • ');

        const bodyEnParts: string[] = [];

        if (
          reminder.cropNameEn &&
          reminder.cropNameEn.trim().length > 0
        ) {
          bodyEnParts.push(
            reminder.cropNameEn,
          );
        }

        bodyEnParts.push(
          this.getReminderTypeLabel(
            reminder.type,
          ),
        );

        const bodyEn =
          bodyEnParts.join(' • ');

        const bodyArParts: string[] = [];

        if (
          reminder.cropNameAr &&
          reminder.cropNameAr.trim().length > 0
        ) {
          bodyArParts.push(
            reminder.cropNameAr,
          );
        }

        bodyArParts.push(
          this.getReminderTypeLabelAr(
            reminder.type,
          ),
        );

        const bodyAr =
          bodyArParts.join(' • ');

        await this.prisma.notification.create({
          data: {
            userId:
              reminder.farmerId,

            title,
            message: body,

            titleEn,
            titleAr,

            messageEn: bodyEn,
            messageAr: bodyAr,

            type: 'REMINDER',
          },
        });

        this.logger.log(
          `Notification record created for reminder ${reminder.id}`,
        );

        const devices =
          await this.pushDevicesService.findAllForUser(
            reminder.farmerId,
          );

        this.logger.log(
          `Found ${devices.length} registered device(s) for farmer ${reminder.farmerId}`,
        );

        for (const device of devices) {
          try {
            const tokenPreview =
              device.token.length > 18
                ? `${device.token.substring(
                    0,
                    12,
                  )}...${device.token.substring(
                    device.token.length - 6,
                  )}`
                : device.token;

            this.logger.log(
              `Sending reminder ${reminder.id} to device ${device.id} (${device.platform}) token=${tokenPreview}`,
            );

            const messageId =
              await this.firebaseService.sendNotification({
                token:
                  device.token,
                title,
                body,
              });

            this.logger.log(
              `Firebase push sent successfully. Reminder=${reminder.id}, device=${device.id}, messageId=${messageId}`,
            );
          } catch (error) {
            this.logger.error(
              `Failed to send reminder ${reminder.id} to device ${device.id}`,
              error instanceof Error
                ? error.stack
                : String(error),
            );
          }
        }

        const repeatDays =
          reminder.repeatDays ?? [];

        if (repeatDays.length === 0) {
          await this.prisma.reminder.update({
            where: {
              id: reminder.id,
            },
            data: {
              notificationSentAt:
                new Date(),
            },
          });

          this.logger.log(
            `One-time reminder ${reminder.id} marked as notification sent`,
          );

          continue;
        }

        const nextReminderDate =
          this.calculateNextReminderDate(
            reminder.reminderDate,
            repeatDays,
            now,
          );

        await this.prisma.reminder.update({
          where: {
            id: reminder.id,
          },
          data: {
            reminderDate:
              nextReminderDate,

            notificationSentAt:
              null,
          },
        });

        this.logger.log(
          `Recurring reminder ${reminder.id} rescheduled to ${nextReminderDate.toISOString()}`,
        );
      } catch (error) {
        this.logger.error(
          `Failed to process reminder ${reminder.id}`,
          error instanceof Error
            ? error.stack
            : String(error),
        );
      }
    }
  }

  private calculateNextReminderDate(
    currentReminderDate: Date,
    repeatDays: number[],
    now: Date,
  ): Date {
    const uniqueRepeatDays =
      [...new Set(repeatDays)]
        .filter(
          (day) =>
            day >= 0 &&
            day <= 6,
        )
        .sort(
          (a, b) => a - b,
        );

    if (uniqueRepeatDays.length === 0) {
      const fallback =
        new Date(
          currentReminderDate,
        );

      fallback.setDate(
        fallback.getDate() + 7,
      );

      return fallback;
    }

    const baseDate =
      new Date(
        Math.max(
          currentReminderDate.getTime(),
          now.getTime(),
        ),
      );

    for (
      let daysAhead = 0;
      daysAhead <= 7;
      daysAhead++
    ) {
      const candidate =
        new Date(baseDate);

      candidate.setDate(
        baseDate.getDate() +
          daysAhead,
      );

      candidate.setHours(
        currentReminderDate.getHours(),
        currentReminderDate.getMinutes(),
        0,
        0,
      );

      const candidateDay =
        candidate.getDay();

      const isSelectedDay =
        uniqueRepeatDays.includes(
          candidateDay,
        );

      const isFuture =
        candidate.getTime() >
        now.getTime();

      if (
        isSelectedDay &&
        isFuture
      ) {
        return candidate;
      }
    }

    const fallback =
      new Date(
        currentReminderDate,
      );

    fallback.setDate(
      fallback.getDate() + 7,
    );

    return fallback;
  }

  private getReminderTypeLabel(
    type: string,
  ) {
    switch (type) {
      case 'IRRIGATION':
        return 'Irrigation';

      case 'FERTILIZATION':
        return 'Fertilization';

      default:
        return 'Farm task';
    }
  }

  private getReminderTypeLabelAr(
    type: string,
  ) {
    switch (type) {
      case 'IRRIGATION':
        return 'ري';

      case 'FERTILIZATION':
        return 'تسميد';

      default:
        return 'مهمة زراعية';
    }
  }
}