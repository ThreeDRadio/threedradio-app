import { CACHE_MANAGER } from '@nestjs/common';
import { Test, TestingModule } from '@nestjs/testing';
import { ShowsController } from './shows.controller';
import { ShowsService } from './shows.service';

describe('ShowsController', () => {
  let controller: ShowsController;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [ShowsController],
      providers: [
        {
          provide: ShowsService,
          useValue: {
            getShows: jest.fn(),
            getEpisodesForShow: jest.fn(),
          },
        },
        {
          provide: CACHE_MANAGER,
          useValue: {
            get: jest.fn(),
            set: jest.fn(),
          },
        },
      ],
    }).compile();

    controller = module.get<ShowsController>(ShowsController);
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });
});
