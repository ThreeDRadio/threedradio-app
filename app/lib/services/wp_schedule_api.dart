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
    this.show_category,
  });
  final List<String>? show_incipit;
  final List<String>? subtitle2;
  final List<String>? show_category;

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
class Category {
  const Category(this.slug, this.id);
  final int id;
  final String slug;
  factory Category.fromJson(Map<String, dynamic> json) =>
      _$CategoryFromJson(json);
  Map<String, dynamic> toJson() => _$CategoryToJson(this);
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

  String? get playlistCategory => meta.show_category?.first;

  String get sortKey {
    final lower = title.text.toLowerCase();
    if (lower.indexOf('the ') == 0) {
      return lower.replaceFirst('the ', '');
    } else if (lower.indexOf('a ') == 0) {
      return lower.replaceFirst('a ', '');
    }
    return lower;
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

@JsonSerializable()
class WpPost {
  const WpPost({
    required this.id,
    required this.status,
    required this.slug,
    required this.title,
    required this.content,
    required this.excerpt,
    required this.featured_media,
    required this.thumbnail,
    required this.meta,
  });

  final int id;
  final String status;
  final String slug;
  final WpText title;
  final WpText content;
  final WpText excerpt;
  final int featured_media;
  final dynamic thumbnail;
  final WpMeta meta;

  factory WpPost.fromJson(Map<String, dynamic> json) => _$WpPostFromJson(json);
  Map<String, dynamic> toJson() => _$WpPostToJson(this);
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

  Future<Category?> getCategoryBySlug(String slug) async {
    final response = await http.get<List<dynamic>>(
        'https://www.threedradio.com/wp-json/wp/v2/categories?slug=$slug');

    if (response.data!.isNotEmpty) {
      return Category.fromJson(response.data![0]);
    }
    return null;
  }

  Future<List<WpPost>> findPosts(Map<String, dynamic> query) async {
    final response = await http.get<List<dynamic>>(
        'https://www.threedradio.com/wp-json/wp/v2/posts',
        queryParameters: query);

    return response.data?.map((e) => WpPost.fromJson(e)).toList() ?? [];
  }
}
