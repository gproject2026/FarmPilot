import { Module } from '@nestjs/common';

import { AiModule } from '../ai/ai.module';
import { NotificationsModule } from '../notifications/notifications.module';

import { DiagnosesController } from './diagnoses.controller';
import { DiagnosesService } from './diagnoses.service';

@Module({
  imports: [
    AiModule,
    NotificationsModule,
  ],
  controllers: [
    DiagnosesController,
  ],
  providers: [
    DiagnosesService,
  ],
})
export class DiagnosesModule {}