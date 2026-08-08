import { Test, TestingModule } from '@nestjs/testing';

import { PrismaService } from '../prisma/prisma.service';
import { DashboardService } from './dashboard.service';

describe('DashboardService', () => {
  let service: DashboardService;

  const prismaMock = {
    product: {
      count: jest.fn(),
      findMany: jest.fn(),
    },
    crop: {
      count: jest.fn(),
      findMany: jest.fn(),
    },
    order: {
      count: jest.fn(),
      findMany: jest.fn(),
      aggregate: jest.fn(),
    },
    reminder: {
      count: jest.fn(),
      findMany: jest.fn(),
    },
    user: {
      count: jest.fn(),
      findMany: jest.fn(),
    },
    category: {
      count: jest.fn(),
    },
    diagnosis: {
      count: jest.fn(),
      findMany: jest.fn(),
    },
    notification: {
      count: jest.fn(),
      findMany: jest.fn(),
    },
    review: {
      count: jest.fn(),
    },
    favorite: {
      count: jest.fn(),
    },
  };

  beforeEach(async () => {
    const module: TestingModule =
      await Test.createTestingModule({
        providers: [
          DashboardService,
          {
            provide: PrismaService,
            useValue: prismaMock,
          },
        ],
      }).compile();

    service =
      module.get<DashboardService>(
        DashboardService,
      );
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });
});