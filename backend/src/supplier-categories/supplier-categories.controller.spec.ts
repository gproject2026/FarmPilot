import {
  Test,
  TestingModule,
} from '@nestjs/testing';

import { SupplierCategoriesController } from './supplier-categories.controller';
import { SupplierCategoriesService } from './supplier-categories.service';

describe(
  'SupplierCategoriesController',
  () => {
    let controller:
      SupplierCategoriesController;

    const supplierCategoriesServiceMock = {
      create: jest.fn(),
      findAll: jest.fn(),
      findOne: jest.fn(),
      update: jest.fn(),
      remove: jest.fn(),
    };

    beforeEach(async () => {
      const module: TestingModule =
        await Test.createTestingModule({
          controllers: [
            SupplierCategoriesController,
          ],

          providers: [
            {
              provide:
                SupplierCategoriesService,
              useValue:
                supplierCategoriesServiceMock,
            },
          ],
        }).compile();

      controller =
        module.get<SupplierCategoriesController>(
          SupplierCategoriesController,
        );
    });

    it('should be defined', () => {
      expect(controller).toBeDefined();
    });
  },
);