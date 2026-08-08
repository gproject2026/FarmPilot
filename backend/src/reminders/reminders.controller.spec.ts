import { Test, TestingModule } from '@nestjs/testing';

import { RemindersController } from './reminders.controller';
import { RemindersService } from './reminders.service';

describe('RemindersController', () => {
  let controller: RemindersController;

  const remindersServiceMock = {
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
          RemindersController,
        ],
        providers: [
          {
            provide: RemindersService,
            useValue: remindersServiceMock,
          },
        ],
      }).compile();

    controller =
      module.get<RemindersController>(
        RemindersController,
      );
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });
});