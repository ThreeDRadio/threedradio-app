import { Expose } from 'class-transformer';

export class ShowDto {
  @Expose()
  name: string;
  @Expose()
  id: string;
  @Expose()
  updatedAt: Date;
  @Expose()
  createdAt: Date;

  constructor(data: Partial<ShowDto>) {
    Object.assign(this, data);
  }
}
