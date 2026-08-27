import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { ScheduleModule } from '@nestjs/schedule';

import { AppController } from './app.controller';
import { AppService } from './app.service';

import { AiModule } from './ai/ai.module';
import { AuthModule } from './auth/auth.module';
import { CategoriesModule } from './categories/categories.module';
import { CropsModule } from './crops/crops.module';
import { DashboardModule } from './dashboard/dashboard.module';
import { DiagnosesModule } from './diagnoses/diagnoses.module';
import { FavoritesModule } from './favorites/favorites.module';
import { NotificationsModule } from './notifications/notifications.module';
import { OrdersModule } from './orders/orders.module';
import { PrismaModule } from './prisma/prisma.module';
import { ProductsModule } from './products/products.module';
import { PushDevicesModule } from './push-devices/push-devices.module';
import { RemindersModule } from './reminders/reminders.module';
import { ReviewsModule } from './reviews/reviews.module';
import { UploadsModule } from './uploads/uploads.module';
import { UsersModule } from './users/users.module';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
    }),

    ScheduleModule.forRoot(),

    PrismaModule,
    UsersModule,
    AuthModule,
    ProductsModule,
    CropsModule,
    DiagnosesModule,
    OrdersModule,
    FavoritesModule,
    ReviewsModule,
    UploadsModule,
    RemindersModule,
    NotificationsModule,
    CategoriesModule,
    DashboardModule,
    AiModule,
    PushDevicesModule,
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}
