import {
  Test,
  TestingModule,
} from '@nestjs/testing';

import { SupplierOrdersController } from './supplier-orders.controller';
import { SupplierOrdersService } from './supplier-orders.service';

describe(
  'SupplierOrdersController',
  () => {
    let controller:
      SupplierOrdersController;

    const supplierOrdersServiceMock = {
      create: jest.fn(),
      findFarmerOrders: jest.fn(),
      findSupplierOrders: jest.fn(),
      findAll: jest.fn(),
      findOne: jest.fn(),
      updateStatus: jest.fn(),
    };

    beforeEach(async () => {
      const module: TestingModule =
        await Test.createTestingModule({
          controllers: [
            SupplierOrdersController,
          ],

          providers: [
            {
              provide:
                SupplierOrdersService,
              useValue:
                supplierOrdersServiceMock,
            },
          ],
        }).compile();

      controller =
        module.get<SupplierOrdersController>(
          SupplierOrdersController,
        );
    });

    it('should be defined', () => {
      expect(controller).toBeDefined();
    });
  },
);