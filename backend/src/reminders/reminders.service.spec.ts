import { Test, TestingModule } from '@nestjs/testing';

import { GeminiService } from '../ai/gemini.service';
import { PrismaService } from '../prisma/prisma.service';
import { RemindersService } from './reminders.service';

describe('RemindersService', () => {
  let service: RemindersService;

  const prismaMock = {
    reminder: {
      create: jest.fn(),
      findMany: jest.fn(),
      findUnique: jest.fn(),
      update: jest.fn(),
      delete: jest.fn(),
    },
    crop: {
      findUnique: jest.fn(),
    },
  };

  const geminiServiceMock = {
    translateReminderContent: jest.fn(),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        RemindersService,
        {
          provide: PrismaService,
          useValue: prismaMock,
        },
        {
          provide: GeminiService,
          useValue: geminiServiceMock,
        },
      ],
    }).compile();

    service = module.get<RemindersService>(RemindersService);
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });
});
