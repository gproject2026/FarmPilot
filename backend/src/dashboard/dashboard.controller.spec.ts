import { Test, TestingModule } from '@nestjs/testing';

import { DashboardController } from './dashboard.controller';
import { DashboardService } from './dashboard.service';

describe('DashboardController', () => {
  let controller: DashboardController;

  const dashboardServiceMock = {
    getFarmerDashboard: jest.fn(),
    getCustomerDashboard: jest.fn(),
    getAdminDashboard: jest.fn(),
  };

  beforeEach(async () => {
    const module: TestingModule =
      await Test.createTestingModule({
        controllers: [
          DashboardController,
        ],
        providers: [
          {
            provide: DashboardService,
            useValue: dashboardServiceMock,
          },
        ],
      }).compile();

    controller =
      module.get<DashboardController>(
        DashboardController,
      );
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });
});