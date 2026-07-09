import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';

import { AppController } from './app.controller';
import { AppService } from './app.service';

import { PrismaModule } from './prisma/prisma.module';
import { UsersModule } from './users/users.module';
import { AuthModule } from './auth/auth.module';
import { ProductsModule } from './products/products.module';
import { CropsModule } from './crops/crops.module';
import { DiagnosesModule } from './diagnoses/diagnoses.module';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
    }),

    PrismaModule,
    UsersModule,
    AuthModule,
    ProductsModule,
    CropsModule,
    DiagnosesModule,
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}