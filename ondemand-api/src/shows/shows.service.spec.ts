import { Test, TestingModule } from '@nestjs/testing';
import { S3 } from 'aws-sdk';
import { S3_BUCKET_NAME, ShowsService } from './shows.service';
import { Cache } from 'cache-manager';
import { CACHE_MANAGER } from '@nestjs/common';

describe('ShowsService', () => {
  let service: ShowsService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        ShowsService,
        {
          provide: S3,
          useValue: {
            listObjectsV2: jest.fn(),
          },
        },
        {
          provide: CACHE_MANAGER,
          useValue: {
            get: jest.fn(),
            set: jest.fn(),
          },
        },
        {
          provide: S3_BUCKET_NAME,
          useValue: 'test-bucket',
        },
      ],
    }).compile();

    service = module.get<ShowsService>(ShowsService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });
});
