import 'package:dio/dio.dart';
import 'package:json_annotation/json_annotation.dart';

part 'on_demand_api.g.dart';

@JsonSerializable()
class OnDemandProgram {
  const OnDemandProgram({
    required this.id,
    required this.createdAt,
    required this.name,
    required this.updatedAt,
  });

  final String createdAt;
  final String id;
  final String name;
  final String updatedAt;

  String get slug => id.replaceAll('+', '-').toLowerCase();

  factory OnDemandProgram.fromJson(Map<String, dynamic> json) =>
      _$OnDemandProgramFromJson(json);
  Map<String, dynamic> toJson() => _$OnDemandProgramToJson(this);
}

@JsonSerializable()
class OnDemandEpisode {
  const OnDemandEpisode({
    required this.showId,
    required this.date,
    required this.size,
    required this.url,
    this.showSlug,
  });
  final String showId;
  final String date;
  final int size;
  final String url;
  final String? showSlug;

  String get id => '$showId::$date';

  factory OnDemandEpisode.fromJson(Map<String, dynamic> json) =>
      _$OnDemandEpisodeFromJson(json);
  Map<String, dynamic> toJson() => _$OnDemandEpisodeToJson(this);
}

class OnDemandApiService {
  OnDemandApiService({
    required this.http,
    required this.apiKey,
    required this.baseUrl,
  });
  final Dio http;
  final String apiKey;
  final String baseUrl;

  Future<List<OnDemandProgram>> getOnDemandPrograms() async {
    final response = await http.get<List<dynamic>>(
      '$baseUrl/shows',
      options: Options(
        headers: {'x-api-key': apiKey},
      ),
    );

    return response.data!.map((e) => OnDemandProgram.fromJson(e)).toList();
  }

  Future<List<OnDemandEpisode>> getEpisodes(String showId) async {
    final response = await http.get<List<dynamic>>(
      '$baseUrl/shows/$showId/episodes',
      options: Options(
        headers: {'x-api-key': apiKey},
      ),
    );
    return response.data!
        .map((e) => OnDemandEpisode.fromJson({...e, 'showId': showId}))
        .toList();
  }
}
