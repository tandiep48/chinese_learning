/// Profile module — one day in the three-day activity charts.
///
/// Ported from `LearnedWordsDay` / `TimeLearnedDay` in
/// `yi-chinese-manage/lib/types/dashboard.ts`. Raw JSON under `{ days: [...] }`
/// from `GET /api/user/{learned-words,time-learned}-last-3-days`.
library;

import '../../../../core/api/validators.dart';

/// Words mastered on [date] (ISO `y-m-d`).
class LearnedWordsDay {
  const LearnedWordsDay({required this.date, required this.count});

  final String date;
  final int count;

  factory LearnedWordsDay.fromJson(Map<String, dynamic> json) {
    return LearnedWordsDay(
      date: optString(json, 'date') ?? '',
      count: optInt(json, 'count') ?? 0,
    );
  }
}

/// Minutes learned on [date] (ISO `y-m-d`).
class TimeLearnedDay {
  const TimeLearnedDay({required this.date, required this.minutes});

  final String date;
  final int minutes;

  factory TimeLearnedDay.fromJson(Map<String, dynamic> json) {
    return TimeLearnedDay(
      date: optString(json, 'date') ?? '',
      minutes: optInt(json, 'minutes') ?? 0,
    );
  }
}
