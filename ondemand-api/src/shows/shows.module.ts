import { CacheModule, Module } from '@nestjs/common';
import { S3_BUCKET_NAME, ShowsService } from './shows.service';
import { ShowsController } from './shows.controller';
import { S3 } from 'aws-sdk';

@Module({
  imports: [
    CacheModule.register({
      ttl: 30 * 60,
    }),
  ],
  controllers: [ShowsController],
  providers: [
    ShowsService,
    {
      provide: S3,
      useValue: new S3({}),
    },
    {
      provide: S3_BUCKET_NAME,
      useValue: 'threedradio-podcasts-production',
    },
  ],
})
export class ShowsModule {}
