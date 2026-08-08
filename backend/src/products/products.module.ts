import { Module } from '@nestjs/common';

import { AiModule } from '../ai/ai.module';
import { UploadsModule } from '../uploads/uploads.module';

import { ProductsController } from './products.controller';
import { ProductsService } from './products.service';

@Module({
  imports: [
    UploadsModule,
    AiModule,
  ],
  controllers: [
    ProductsController,
  ],
  providers: [
    ProductsService,
  ],
})
export class ProductsModule {}