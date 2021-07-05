import { CacheModule, Module } from '@nestjs/common';
import {
  S3_BUCKET_NAME,
  S3_HOSTING_ENDPOINT,
  ShowsService,
} from './shows.service';
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
      useValue: new S3({
        endpoint: 'https://sfo3.digitaloceanspaces.com',
      }),
    },
    {
      provide: S3_BUCKET_NAME,
      useValue: 'threedradio-ondemand-files',
    },
    {
      provide: S3_HOSTING_ENDPOINT,
      useValue:
        'https://threedradio-ondemand-files.sfo3.cdn.digitaloceanspaces.com',
    },
  ],
})
export class ShowsModule {}
