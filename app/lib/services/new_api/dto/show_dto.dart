import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:json_annotation/json_annotation.dart';

part 'show_dto.g.dart';

@JsonSerializable()
class ShowDto {
  const ShowDto({
    required this.id,
    required this.name,
    required this.slug,
    required this.description,
    required this.link,
    this.acf,
  });

  factory ShowDto.fromJson(Map<String, dynamic> json) =>
      _$ShowDtoFromJson(json);
  Map<String, dynamic> toJson() => _$ShowDtoToJson(this);

  final int id;
  final String name;
  final String slug;
  final String description;
  final String link;
  final ShowAcf? acf;

  String get onDemandShowId {
    if (acf?.on_demand_slug_override?.isNotEmpty ?? false) {
      return acf!.on_demand_slug_override!.replaceAll('-', '+');
    }

    return (slug).replaceAll('-', '+');
  }

  String get sortKey {
    final lower = name.toLowerCase();
    if (lower.indexOf('the ') == 0) {
      return lower.replaceFirst('the ', '');
    } else if (lower.indexOf('a ') == 0) {
      return lower.replaceFirst('a ', '');
    }
    return lower;
  }
}

@JsonSerializable()
class ShowAcf {
  const ShowAcf({
    this.shows_schedule = const [],
    this.on_demand_slug_override,
    this.show_excerpt,
    this.hosted_by = const [],
    this.program_featured_image,
  });

  factory ShowAcf.fromJson(Map<String, dynamic> json) =>
      _$ShowAcfFromJson(json);
  Map<String, dynamic> toJson() => _$ShowAcfToJson(this);

  @JsonKey(fromJson: scheduleCanBeFalseForSomeReason)
  final List<ScheduleEntry> shows_schedule;
  final String? on_demand_slug_override;
  final String? show_excerpt;
  @JsonKey(fromJson: hostedByCanBeAListOrStringForSomeReason)
  final List<Presenter>? hosted_by;

  @JsonKey(fromJson: featuredImageCanBeFalseForSomeReason)
  final ShowFeaturedImage? program_featured_image;
}

@JsonSerializable()
class ScheduleEntry {
  const ScheduleEntry({
    required this.week_of_the_day,
    required this.week_option,
    required this.start_time,
    required this.end_time,
  });

  factory ScheduleEntry.fromJson(Map<String, dynamic> json) =>
      _$ScheduleEntryFromJson(json);
  Map<String, dynamic> toJson() => _$ScheduleEntryToJson(this);

  final String week_of_the_day;
  final String week_option;

  @JsonKey(fromJson: timeStringToTimeOfDay, toJson: timeOfDayToJson)
  final TimeOfDay start_time;
  @JsonKey(fromJson: timeStringToTimeOfDay, toJson: timeOfDayToJson)
  final TimeOfDay end_time;
}

@JsonSerializable()
class Presenter {
  const Presenter({required this.ID, required this.post_title});

  factory Presenter.fromJson(Map<String, dynamic> json) =>
      _$PresenterFromJson(json);
  Map<String, dynamic> toJson() => _$PresenterToJson(this);
  final int ID;
  final String post_title;
}

class ShowFeaturedImage {
  const ShowFeaturedImage({
    required this.id,
    this.thumbnail,
    this.medium,
    this.large,
  });

  factory ShowFeaturedImage.fromJson(Map<String, dynamic> json) =>
      ShowFeaturedImage(
        id: json['id'],
        thumbnail: json['sizes']['thumbnail'],
        medium: json['sizes']['medium'],
        large: json['sizes']['large'],
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'sizes': {'thumbnail': thumbnail, 'medium': medium, 'large': large},
  };

  final int id;
  final String? thumbnail;
  final String? medium;
  final String? large;
}

TimeOfDay timeStringToTimeOfDay(String value) {
  try {
    final date = DateFormat('jm').parse(value.toUpperCase());
    return TimeOfDay.fromDateTime(date);
  } catch (err) {
    return TimeOfDay(hour: 0, minute: 0);
  }
}

String timeOfDayToJson(TimeOfDay value) {
  final now = DateTime.now();
  final dateTime = DateTime(
    now.year,
    now.month,
    now.day,
    value.hour,
    value.minute,
  );
  return DateFormat('jm').format(dateTime);
}

List<Presenter> hostedByCanBeAListOrStringForSomeReason(dynamic value) {
  if (value is List) {
    return value.map((v) => Presenter.fromJson(v)).toList();
  } else {
    return const [];
  }
}

ShowFeaturedImage? featuredImageCanBeFalseForSomeReason(dynamic value) {
  if (value is Map) {
    return ShowFeaturedImage.fromJson(value as Map<String, dynamic>);
  } else {
    return null;
  }
}

List<ScheduleEntry> scheduleCanBeFalseForSomeReason(dynamic value) {
  if (value is List) {
    return value.map((v) => ScheduleEntry.fromJson(v)).toList();
  } else {
    return const [];
  }
}
