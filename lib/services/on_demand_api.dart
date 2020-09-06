import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

part 'on_demand_api.g.dart';

@JsonSerializable()
class OnDemandProgram {
  const OnDemandProgram({
    this.id,
    this.createdAt,
    this.name,
    this.updatedAt,
    this.showSlug,
  });

  final String createdAt;
  final String id;
  final String name;
  final String updatedAt;
  final String showSlug;

  factory OnDemandProgram.fromJson(Map<String, dynamic> json) =>
      _$OnDemandProgramFromJson(json);
  Map<String, dynamic> toJson() => _$OnDemandProgramToJson(this);
}

@JsonSerializable()
class OnDemandEpisode {
  const OnDemandEpisode({
    this.id,
    this.showId,
    this.date,
    this.size,
    this.url,
    this.showSlug,
  });
  final String id;
  final int showId;
  final String date;
  final int size;
  final String url;
  final String showSlug;

  factory OnDemandEpisode.fromJson(Map<String, dynamic> json) =>
      _$OnDemandEpisodeFromJson(json);
  Map<String, dynamic> toJson() => _$OnDemandEpisodeToJson(this);
}

class OnDemandApiService {
  OnDemandApiService({
    @required this.http,
    this.apiKey,
  });
  final Dio http;
  final String apiKey;

  Future<List<OnDemandProgram>> getOnDemandPrograms() async {
    final response = await http.get<List<Map<String, dynamic>>>(
      'https://e5yf0dn2f7.execute-api.ap-southeast-2.amazonaws.com/production/shows',
      options: Options(
        headers: {'x-api-key': apiKey},
      ),
    );

    return response.data.map((e) => OnDemandProgram.fromJson(e));
  }

  Future<List<OnDemandEpisode>> getEpisodes(String showId) async {
    final response = await http.get<List<Map<String, dynamic>>>(
      'https://e5yf0dn2f7.execute-api.ap-southeast-2.amazonaws.com/production/shows/$showId/episodes',
      options: Options(
        headers: {'x-api-key': apiKey},
      ),
    );
    return response.data.map((e) => OnDemandEpisode.fromJson(e));
  }
}
