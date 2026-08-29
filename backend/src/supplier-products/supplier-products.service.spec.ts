import {
  Test,
  TestingModule,
} from '@nestjs/testing';

import { PrismaService } from '../prisma/prisma.service';
import { SupplierProductsService } from './supplier-products.service';

describe(
  'SupplierProductsService',
  () => {
    let service:
      SupplierProductsService;

    const prismaServiceMock = {
      supplierProduct: {
        create: jest.fn(),
        findMany: jest.fn(),
        findUnique: jest.fn(),
        update: jest.fn(),
        delete: jest.fn(),
      },

      supplierCategory: {
        findUnique: jest.fn(),
      },

      user: {
        findUnique: jest.fn(),
      },
    };

    beforeEach(async () => {
      const module: TestingModule =
        await Test.createTestingModule({
          providers: [
            SupplierProductsService,

            {
              provide:
                PrismaService,
              useValue:
                prismaServiceMock,
            },
          ],
        }).compile();

      service =
        module.get<SupplierProductsService>(
          SupplierProductsService,
        );
    });

    it('should be defined', () => {
      expect(service).toBeDefined();
    });
  },
);