import { Module } from '@nestjs/common';

import { AiModule } from '../ai/ai.module';

import { RemindersController } from './reminders.controller';
import { RemindersService } from './reminders.service';

@Module({
  imports: [
    AiModule,
  ],

  controllers: [
    RemindersController,
  ],

  providers: [
    RemindersService,
  ],
})
export class RemindersModule {}