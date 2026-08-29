import {
  Test,
  TestingModule,
} from '@nestjs/testing';

import { SupplierProductsController } from './supplier-products.controller';
import { SupplierProductsService } from './supplier-products.service';

describe(
  'SupplierProductsController',
  () => {
    let controller:
      SupplierProductsController;

    const supplierProductsServiceMock = {
      create: jest.fn(),
      findAll: jest.fn(),
      findMyProducts: jest.fn(),
      findOne: jest.fn(),
      update: jest.fn(),
      remove: jest.fn(),
    };

    beforeEach(async () => {
      const module: TestingModule =
        await Test.createTestingModule({
          controllers: [
            SupplierProductsController,
          ],

          providers: [
            {
              provide:
                SupplierProductsService,
              useValue:
                supplierProductsServiceMock,
            },
          ],
        }).compile();

      controller =
        module.get<SupplierProductsController>(
          SupplierProductsController,
        );
    });

    it('should be defined', () => {
      expect(controller).toBeDefined();
    });
  },
);