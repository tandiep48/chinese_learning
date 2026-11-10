/// Competition — a grouped multi-select field.
///
/// Flutter stand-in for the web `MultiSelect` used on the setup screen: a tap
/// opens a bottom sheet of checkboxes (grouped under their [PickerOption.group]
/// headers) with a Select-all toggle; selections apply live. The field shows the
/// placeholder when empty, else "{n} selected".
library;

import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../data/room_logic.dart';
import '../styles/competition_styles.dart';

class CompetitionMultiSelect extends StatelessWidget {
  const CompetitionMultiSelect({
    super.key,
    required this.options,
    required this.values,
    required this.onChanged,
    required this.placeholder,
    required this.selectAllLabel,
    required this.countLabel,
    required this.doneLabel,
  });

  final List<PickerOption> options;
  final List<String> values;
  final ValueChanged<List<String>> onChanged;
  final String placeholder;
  final String selectAllLabel;
  final String Function(int) countLabel;
  final String doneLabel;

  @override
  Widget build(BuildContext context) {
    final enabled = options.isNotEmpty;
    final text = values.isEmpty ? placeholder : countLabel(values.length);
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: enabled ? () => _open(context) : null,
      child: InputDecorator(
        decoration: CompetitionStyles.inputDecoration(null),
        child: Row(
          children: [
            Expanded(
              child: Text(
                text,
                style: values.isEmpty
                    ? CompetitionStyles.muted
                    : CompetitionStyles.body,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(Icons.arrow_drop_down, color: BrandColors.mutedText),
          ],
        ),
      ),
    );
  }

  Future<void> _open(BuildContext context) async {
    final selected = {...values};
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: BrandColors.card,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheet) {
            final allValues = options.map((o) => o.value).toList();
            final allSelected =
                allValues.isNotEmpty && allValues.every(selected.contains);

            void emit() =>
                onChanged(allValues.where(selected.contains).toList());

            // Build grouped sections preserving option order.
            final groups = <String?, List<PickerOption>>{};
            for (final o in options) {
              (groups[o.group] ??= []).add(o);
            }

            return SafeArea(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(ctx).size.height * 0.7,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CheckboxListTile(
                      dense: true,
                      activeColor: BrandColors.navTeal,
                      controlAffinity: ListTileControlAffinity.leading,
                      value: allSelected,
                      title: Text(
                        selectAllLabel,
                        style: CompetitionStyles.label,
                      ),
                      onChanged: (v) {
                        setSheet(() {
                          selected.clear();
                          if (v == true) selected.addAll(allValues);
                        });
                        emit();
                      },
                    ),
                    const Divider(height: 1),
                    Flexible(
                      child: ListView(
                        shrinkWrap: true,
                        children: [
                          for (final entry in groups.entries) ...[
                            if (entry.key != null)
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  12,
                                  16,
                                  4,
                                ),
                                child: Text(
                                  entry.key!,
                                  style: CompetitionStyles.muted,
                                ),
                              ),
                            for (final o in entry.value)
                              CheckboxListTile(
                                dense: true,
                                activeColor: BrandColors.navTeal,
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                                value: selected.contains(o.value),
                                title: Text(
                                  o.label,
                                  style: CompetitionStyles.chipLabel,
                                ),
                                onChanged: (v) {
                                  setSheet(() {
                                    if (v == true) {
                                      selected.add(o.value);
                                    } else {
                                      selected.remove(o.value);
                                    }
                                  });
                                  emit();
                                },
                              ),
                          ],
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          style: CompetitionStyles.primaryButton,
                          onPressed: () => Navigator.of(ctx).pop(),
                          child: Text(doneLabel),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
