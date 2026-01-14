import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:player/services/new_api/dto/show_dto.dart';
import 'package:player/services/on_demand_api.dart';
import 'package:player/store/app_state.dart';
import 'package:player/store/shows/shows_selectors.dart';
import 'package:redux_entity/redux_entity.dart';

RemoteEntityState<OnDemandProgram> getOnDemandProgramState(AppState s) =>
    s.onDemandPrograms;

Map<String, OnDemandProgram> getOnDemandEntities(AppState s) =>
    getOnDemandProgramState(s).entities;

List<ShowDto> getShowsForOnDemandStreaming(AppState s) {
  final onDemand = getOnDemandEntities(s);
  final shows = getShowEntities(s).values;

  final List<ShowDto> sorted = shows.where((s) {
    final onDemandKey = s.onDemandShowId;
    return onDemand[onDemandKey] != null;
  }).toList();

  sorted.sort((a, b) => a.sortKey.compareTo(b.sortKey));

  return sorted;
}

int getWeekOfMonth(DateTime date) {
  return (date.day / 7.0).ceil();
}

bool isOddWeek(DateTime date) {
  final weekNumber = getWeekOfMonth(date);
  return weekNumber % 2 == 1;
}

/// Returns the week number for the date, in the range (0,1).
int weekNumber(DateTime? date) {
  date ??= DateTime.now();

  // Unix Epoch was Thursday, January 1, 1970
  // we are treating the start of the first full week
  // since epoch as week 0
  // This hard coded timestamp is
  // Mon Jan 05 1970 00:00:00 GMT+0930 (Australian Central Standard Time)
  const threeDEpoch = 311400;

  // so we are subtracting this epoch from the current time, and then
  // converting to weeks
  final elapsedSeconds = (date.millisecondsSinceEpoch / 1000) - threeDEpoch;
  final weekNumber = elapsedSeconds / 60 / 60 / 24 / 7;

  // finally, we modulus with 2 then add 1 to get a number in the range (1, 2)
  // which is what the wordpress schedule requires
  return (weekNumber.toInt() % 2);
}

String oddOrEvenWeek(DateTime date) {
  return weekNumber(date) == 0 ? 'even' : 'odd';
}

ShowDto? getCurrentShow(AppState s) {
  final now = DateTime.now();
  final day = DateFormat.EEEE().format(now);
  final time = TimeOfDay.fromDateTime(now);

  try {
    return s.shows.entities.values.firstWhere((show) {
      return show.acf?.shows_schedule.any(
            (schedule) =>
                schedule.week_of_the_day == day &&
                schedule.start_time.isBefore(time) &&
                schedule.end_time.isAfter(time),
          ) ??
          false;
    });
  } catch (err) {
    return null;
  }
}

List<OnDemandEpisode> getEpisodesForShow(AppState state, ShowDto show) {
  final possibleEpisodes =
      state.onDemandEpisodes.entities[show.onDemandShowId]?.reversed.toList() ??
      <OnDemandEpisode>[];

  final validWeeks =
      show.acf?.shows_schedule
          .map((schedule) => schedule.week_option)
          .toSet() ??
      {};

  return possibleEpisodes.where((episode) {
    final parsedDate = DateFormat('y-M-d').parse(episode.date);
    final episodeWeek = oddOrEvenWeek(parsedDate);
    return validWeeks.contains(episodeWeek);
  }).toList();
}
