import 'package:flutter/material.dart';

import '../state/reference_notifier.dart';

class IdDropdown extends StatelessWidget {
  const IdDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
    this.width = 220,
  });

  final String label;
  final int? value;
  final List<NamedOption> options;
  final ValueChanged<int?> onChanged;
  final double width;

  @override
  Widget build(BuildContext context) {
    final current = options.any((o) => o.id == value) ? value : null;
    return SizedBox(
      width: width,
      child: DropdownButtonFormField<int?>(
        key: ValueKey('$label-$current-${options.length}'),
        initialValue: current,
        isExpanded: true,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          isDense: true,
        ),
        items: [
          const DropdownMenuItem<int?>(value: null, child: Text('Все')),
          for (final option in options)
            DropdownMenuItem<int?>(value: option.id, child: Text(option.name)),
        ],
        onChanged: onChanged,
      ),
    );
  }
}
