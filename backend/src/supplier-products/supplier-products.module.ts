import { Module } from '@nestjs/common';

import { PrismaModule } from '../prisma/prisma.module';

import { SupplierProductsController } from './supplier-products.controller';
import { SupplierProductsService } from './supplier-products.service';

@Module({
  imports: [PrismaModule],
  controllers: [SupplierProductsController],
  providers: [SupplierProductsService],
  exports: [SupplierProductsService],
})
export class SupplierProductsModule {}