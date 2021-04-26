import { Expose } from 'class-transformer';

export class EpisodeDto {
  @Expose()
  showId: string;
  @Expose()
  date: string;
  @Expose()
  size: number;
  @Expose()
  url: string;

  constructor(data: Partial<EpisodeDto>) {
    Object.assign(this, data);
  }
}
