import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class DashboardService {

  constructor(
    private readonly prisma: PrismaService,
  ) {}


  async getFarmerDashboard(farmerId: string) {

    const [
      productsCount,
      cropsCount,
      diagnosesCount,
      ordersCount,
      sales,
    ] = await Promise.all([

      this.prisma.product.count({
        where:{
          farmerId,
        },
      }),


      this.prisma.crop.count({
        where:{
          farmerId,
        },
      }),


      this.prisma.diagnosis.count({
        where:{
          farmerId,
        },
      }),


      this.prisma.order.count({
        where:{
          orderItems:{
            some:{
              product:{
                farmerId,
              },
            },
          },
        },
      }),


      this.prisma.order.aggregate({
        _sum:{
          totalPrice:true,
        },
        where:{
          orderItems:{
            some:{
              product:{
                farmerId,
              },
            },
          },
        },
      }),

    ]);


    return {

      productsCount,

      cropsCount,

      diagnosesCount,

      ordersCount,

      totalSales:
        sales._sum.totalPrice ?? 0,

    };

  }



  async getAdminDashboard(){

    const [
      totalUsers,
      totalFarmers,
      totalCustomers,
      totalProducts,
      totalOrders,
      totalDiagnoses,

    ] = await Promise.all([


      this.prisma.user.count(),


      this.prisma.user.count({
        where:{
          role:'FARMER',
        },
      }),


      this.prisma.user.count({
        where:{
          role:'CUSTOMER',
        },
      }),


      this.prisma.product.count(),


      this.prisma.order.count(),


      this.prisma.diagnosis.count(),

    ]);


    return {

      totalUsers,

      totalFarmers,

      totalCustomers,

      totalProducts,

      totalOrders,

      totalDiagnoses,

    };

  }

}