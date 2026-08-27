import { Module } from '@nestjs/common';

import { AiModule } from '../ai/ai.module';
import { FirebaseModule } from '../firebase/firebase.module';
import { PushDevicesModule } from '../push-devices/push-devices.module';

import { ReminderNotificationScheduler } from './reminder-notification.scheduler';
import { RemindersController } from './reminders.controller';
import { RemindersService } from './reminders.service';

@Module({
  imports: [AiModule, FirebaseModule, PushDevicesModule],

  controllers: [RemindersController],

  providers: [RemindersService, ReminderNotificationScheduler],
})
export class RemindersModule {}
