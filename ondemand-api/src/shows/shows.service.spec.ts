import { Test, TestingModule } from '@nestjs/testing';
import { ShowsService } from './shows.service';

describe('ShowsService', () => {
  let service: ShowsService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [ShowsService],
    }).compile();

    service = module.get<ShowsService>(ShowsService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });
});
