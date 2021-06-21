import {
  CacheInterceptor,
  ClassSerializerInterceptor,
  Controller,
  Get,
  Param,
  SerializeOptions,
  UseInterceptors,
} from '@nestjs/common';
import { ApiOperation } from '@nestjs/swagger';
import { EpisodeDto } from './models/episode.dto';
import { ShowDto } from './models/show.dto';
import { ShowsService } from './shows.service';

@Controller('shows')
export class ShowsController {
  constructor(private service: ShowsService) {}

  @Get()
  @UseInterceptors(ClassSerializerInterceptor, CacheInterceptor)
  @SerializeOptions({
    excludeExtraneousValues: true,
  })
  @ApiOperation({
    description: 'Returns the list of shows available for on demand streaming.',
  })
  public async getShows(): Promise<ShowDto[]> {
    return await this.service.getShows();
  }

  @Get(':showId/episodes')
  @ApiOperation({
    description: 'Returns the list of episodes available for a show.',
  })
  @SerializeOptions({
    excludeExtraneousValues: true,
  })
  @UseInterceptors(ClassSerializerInterceptor, CacheInterceptor)
  public async getEpisodes(
    @Param('showId') showId: string,
  ): Promise<EpisodeDto[]> {
    return await this.service.getEpisodesForShow(showId);
  }
}
