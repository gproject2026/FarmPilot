import { Module } from '@nestjs/common';

import { AiModule } from '../ai/ai.module';

import { DiagnosesController } from './diagnoses.controller';
import { DiagnosesService } from './diagnoses.service';

@Module({
  imports: [
    AiModule,
  ],
  controllers: [
    DiagnosesController,
  ],
  providers: [
    DiagnosesService,
  ],
})
export class DiagnosesModule {}