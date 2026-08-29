import {
  Test,
  TestingModule,
} from '@nestjs/testing';

import { PrismaService } from '../prisma/prisma.service';
import { SupplierCategoriesService } from './supplier-categories.service';

describe(
  'SupplierCategoriesService',
  () => {
    let service:
      SupplierCategoriesService;

    const prismaServiceMock = {
      supplierCategory: {
        create: jest.fn(),
        findMany: jest.fn(),
        findUnique: jest.fn(),
        update: jest.fn(),
        delete: jest.fn(),
      },
    };

    beforeEach(async () => {
      const module: TestingModule =
        await Test.createTestingModule({
          providers: [
            SupplierCategoriesService,

            {
              provide:
                PrismaService,
              useValue:
                prismaServiceMock,
            },
          ],
        }).compile();

      service =
        module.get<SupplierCategoriesService>(
          SupplierCategoriesService,
        );
    });

    it('should be defined', () => {
      expect(service).toBeDefined();
    });
  },
);