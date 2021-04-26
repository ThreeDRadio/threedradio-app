import { CacheModule, Module } from '@nestjs/common';
import { ShowsModule } from './shows/shows.module';

@Module({
  imports: [ShowsModule, CacheModule.register()],
  controllers: [],
  providers: [],
})
export class AppModule {}
