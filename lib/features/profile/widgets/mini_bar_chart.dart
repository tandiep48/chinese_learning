/// Profile module — the three-day bar chart.
///
/// Ported from `profile/MiniBarChart.tsx`: a handful of bars (the web dropped
/// Chart.js for plain divs), so this is Containers, not a chart dependency.
library;

import 'package:flutter/material.dart';

import '../styles/profile_styles.dart';

const List<String> _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', //
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

/// "2026-09-17" → "Sep 17"; anything that isn't a y-m-d triple passes through.
String formatChartDate(String iso) {
  final parts = iso.split('-');
  if (parts.length != 3) return iso;
  final month = int.tryParse(parts[1]);
  if (month == null || month < 1 || month > 12) return iso;
  return '${_months[month - 1]} ${parts[2]}';
}

class MiniBarChart extends StatelessWidget {
  const MiniBarChart({
    super.key,
    required this.values,
    required this.labels,
    this.suffix = '',
  });

  final List<int> values;
  final List<String> labels;
  final String suffix;

  @override
  Widget build(BuildContext context) {
    final max = values.isEmpty
        ? 1
        : values.reduce((a, b) => a > b ? a : b).clamp(1, 1 << 31);
    return SizedBox(
      height: ProfileStyles.chartHeight + 40,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (var i = 0; i < values.length; i++)
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    '${values[i]}$suffix',
                    style: ProfileStyles.chartValueStyle,
                  ),
                  ProfileStyles.gap8,
                  Container(
                    width: 36,
                    height: (4 + (values[i] / max) * ProfileStyles.chartHeight)
                        .clamp(4, ProfileStyles.chartHeight)
                        .toDouble(),
                    decoration: const BoxDecoration(
                      color: ProfileStyles.barColor,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(6),
                      ),
                    ),
                  ),
                  ProfileStyles.gap8,
                  Text(
                    labels[i],
                    style: ProfileStyles.chartLabelStyle,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
