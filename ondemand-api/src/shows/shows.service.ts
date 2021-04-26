import { CACHE_MANAGER, Inject, Injectable } from '@nestjs/common';
import { S3 } from 'aws-sdk';
import { Cache } from 'cache-manager';
import { EpisodeDto } from './models/episode.dto';
import { Episode } from './models/episode.entity';
import { ShowDto } from './models/show.dto';

export const S3_BUCKET_NAME = Symbol('S3 bucket name');

const CACHE_KEY = 'S3_CACHE_DATA';

const ONE_HOUR_S = 60 * 60;

@Injectable()
export class ShowsService {
  constructor(
    private s3: S3,
    @Inject(S3_BUCKET_NAME) private bucketName: string,
    @Inject(CACHE_MANAGER) private cache: Cache,
  ) {}

  public async getShows(): Promise<ShowDto[]> {
    const data = await this.getAndCache();
    const episodes: Episode[] = data.map((item) => ({
      ...this.parsePodcastKey(item.Key),
      updatedAt: item.LastModified,
      key: item.Key,
      size: item.Size,
    }));

    const shows: { [id: string]: Episode[] } = {};

    for (let episode of episodes) {
      if (shows[episode.id]) {
        shows[episode.id] = [...shows[episode.id], episode];
      } else {
        shows[episode.id] = [episode];
      }
    }

    let showIds = Object.keys(shows);
    return showIds.map(
      (id) =>
        new ShowDto({
          id,
          name: shows[id][shows[id].length - 1].name,
          updatedAt: new Date(shows[id][shows[id].length - 1].updatedAt),
          createdAt: new Date(shows[id][shows[id].length - 1].updatedAt),
        }),
    );
  }

  public async getEpisodesForShow(showId: string): Promise<EpisodeDto[]> {
    const data = await this.getAndCache();
    const episodes: Episode[] = data.map((item) => ({
      ...this.parsePodcastKey(item.Key),
      updatedAt: item.LastModified,
      key: item.Key,
      size: item.Size,
    }));

    const shows: { [id: string]: EpisodeDto[] } = {};

    for (let episode of episodes) {
      const episodeDto: EpisodeDto = new EpisodeDto({
        ...episode,
        url: `https://${this.bucketName}.s3.amazonaws.com/${episode.key.replace(
          ' ',
          '+',
        )}`,
        showId: showId,
      });
      if (shows[episode.id]) {
        shows[episode.id] = [...shows[episode.id], episodeDto];
      } else {
        shows[episode.id] = [episodeDto];
      }
    }

    return shows[showId];
  }

  private async getAndCache(): Promise<S3.ObjectList> {
    let data: S3.ObjectList;
    try {
      data = await this.cache.get(CACHE_KEY);
      if (!data) {
        throw new Error();
      }
      console.log('Obtained from cache');
    } catch (exception) {
      data = await this.getDataFromS3();
      this.cache.set(CACHE_KEY, data, {
        ttl: ONE_HOUR_S,
      });
      console.log('Put into cache');
    }
    return data;
  }

  private async getDataFromS3(): Promise<S3.ObjectList> {
    const items = [];
    let response = await this.s3
      .listObjectsV2({ Bucket: this.bucketName })
      .promise();

    items.push(...response.Contents);

    while (response.IsTruncated) {
      response = await this.s3
        .listObjectsV2({
          Bucket: this.bucketName,
          ContinuationToken: response.NextContinuationToken,
        })
        .promise();

      items.push(...response.Contents);
    }
    return items;
  }

  private parsePodcastKey(
    key: string,
  ): Omit<Episode, 'updatedAt' | 'key' | 'size'> {
    const pathParts = key.split('/');
    const filename = pathParts[pathParts.length - 1];
    const parts = filename.split(
      /([a-zA-Z0-9\+\% ]+)-(\d\d\d\d-\d\d-\d\d)-([A-Za-z]+).mp3/,
    );
    return {
      id: decodeURIComponent(parts[1].toLowerCase())
        .replace(/\+\&\+/g, '+')
        .replace(/ /g, '+'),
      name: decodeURIComponent(parts[1].replace(/\+/g, ' ')),
      date: parts[2],
    };
  }
}
