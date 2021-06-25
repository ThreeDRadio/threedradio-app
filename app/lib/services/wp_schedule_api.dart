import 'package:dio/dio.dart';
import 'package:html_unescape/html_unescape.dart';

import 'package:json_annotation/json_annotation.dart';

part 'wp_schedule_api.g.dart';

// ignore_for_file: non_constant_identifier_names

@JsonSerializable()
class WpMeta {
  const WpMeta({
    this.show_incipit,
    this.subtitle2,
  });
  final List<String>? show_incipit;
  final List<String>? subtitle2;

  factory WpMeta.fromJson(Map<String, dynamic> json) => _$WpMetaFromJson(json);
  Map<String, dynamic> toJson() => _$WpMetaToJson(this);
}

@JsonSerializable()
class WpText {
  const WpText(this.rendered);
  final String rendered;

  String get text => HtmlUnescape().convert(rendered);

  factory WpText.fromJson(Map<String, dynamic> json) => _$WpTextFromJson(json);
  Map<String, dynamic> toJson() => _$WpTextToJson(this);
}

@JsonSerializable()
class ScheduledShowInfo {
  const ScheduledShowInfo({
    required this.show_id,
    required this.show_time,
    required this.show_time_end,
  });
  final List<String> show_id;
  final String show_time;
  final String show_time_end;

  factory ScheduledShowInfo.fromJson(Map<String, dynamic> json) =>
      _$ScheduledShowInfoFromJson(json);
  Map<String, dynamic> toJson() => _$ScheduledShowInfoToJson(this);
}

@JsonSerializable()
class Schedule {
  const Schedule({
    required this.id,
    required this.slug,
    required this.status,
    required this.title,
    required this.shows,
  });

  final int id;
  final String slug;
  final String status;
  final WpText title;

  final List<ScheduledShowInfo> shows;

  factory Schedule.fromJson(Map<String, dynamic> json) =>
      _$ScheduleFromJson(json);
  Map<String, dynamic> toJson() => _$ScheduleToJson(this);
}

@JsonSerializable()
class Show {
  const Show({
    required this.id,
    required this.status,
    required this.slug,
    required this.title,
    required this.content,
    required this.excerpt,
    required this.featured_media,
    this.on_demand,
    required this.thumbnail,
    required this.meta,
  });

  String get onDemandShowId {
    if (on_demand?.isNotEmpty ?? false) {
      return on_demand!.replaceAll('-', '+');
    }

    return (slug).replaceAll('-', '+');
  }

  final int id;
  final String status;
  final String slug;
  final String? on_demand;
  final WpText title;
  final WpText content;
  final WpText excerpt;
  final int featured_media;
  final dynamic thumbnail;
  final WpMeta meta;

  factory Show.fromJson(Map<String, dynamic> json) => _$ShowFromJson(json);
  Map<String, dynamic> toJson() => _$ShowToJson(this);
}

class WpScheduleApiService {
  WpScheduleApiService({
    required this.http,
  });
  final Dio http;

  Future<List<Schedule>> getSchedules() async {
    final response = await http.get<List<dynamic>>(
      'https://www.threedradio.com/wp-json/wp/v2/schedule?_embed&per_page=100',
    );
    return response.data!.map((entry) => Schedule.fromJson(entry)).toList();
  }

  Future<List<Show>> getShows() async {
    List<Show> shows = [];
    for (int page = 1;; page++) {
      final response = await _getPageOfShows(page);
      shows = [
        ...shows,
        ...response.data!.map((entry) => Show.fromJson(entry)).toList()
      ];
      final count =
          int.parse(response.headers['x-wp-totalpages']?.first as String);
      if (page == count) {
        break;
      }
    }
    return shows;
  }

  Future<Response<List<dynamic>>> _getPageOfShows(int page) async {
    final response = await http.get<List<dynamic>>(
        'https://www.threedradio.com/wp-json/wp/v2/shows/?_embed&page=${page}&per_page=100');

    return response;
  }

  Future<Show> getShow(int id) async {
    final response = await http.get<Map<String, dynamic>>(
        'https://www.threedradio.com/wp-json/wp/v2/shows/$id?_embed');
    return Show.fromJson(response.data!);
  }
}
