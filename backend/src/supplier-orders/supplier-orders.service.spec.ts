import {
  Test,
  TestingModule,
} from '@nestjs/testing';

import { PrismaService } from '../prisma/prisma.service';
import { SupplierOrdersService } from './supplier-orders.service';

describe(
  'SupplierOrdersService',
  () => {
    let service:
      SupplierOrdersService;

    const prismaServiceMock = {
      supplierOrder: {
        create: jest.fn(),
        findMany: jest.fn(),
        findUnique: jest.fn(),
        update: jest.fn(),
      },

      supplierProduct: {
        findMany: jest.fn(),
        findUnique: jest.fn(),
        updateMany: jest.fn(),
        update: jest.fn(),
      },

      user: {
        findUnique: jest.fn(),
      },

      notification: {
        create: jest.fn(),
      },

      $transaction: jest.fn(),
    };

    beforeEach(async () => {
      const module: TestingModule =
        await Test.createTestingModule({
          providers: [
            SupplierOrdersService,

            {
              provide:
                PrismaService,
              useValue:
                prismaServiceMock,
            },
          ],
        }).compile();

      service =
        module.get<SupplierOrdersService>(
          SupplierOrdersService,
        );
    });

    it('should be defined', () => {
      expect(service).toBeDefined();
    });
  },
);