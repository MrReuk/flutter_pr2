import 'package:flutter/material.dart';

typedef Choice = ({String value, String label});

class ChoiceDropdown extends StatelessWidget {
  const ChoiceDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.choices,
    required this.onChanged,
    this.width = 220,
  });

  final String label;
  final String value;
  final List<Choice> choices;
  final ValueChanged<String> onChanged;
  final double width;

  @override
  Widget build(BuildContext context) {
    final current = choices.any((c) => c.value == value) ? value : '';
    return SizedBox(
      width: width,
      child: DropdownButtonFormField<String>(
        key: ValueKey('$label-$current-${choices.length}'),
        initialValue: current,
        isExpanded: true,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          isDense: true,
        ),
        items: [
          const DropdownMenuItem<String>(value: '', child: Text('Все')),
          for (final choice in choices)
            DropdownMenuItem<String>(value: choice.value, child: Text(choice.label)),
        ],
        onChanged: (next) => onChanged(next ?? ''),
      ),
    );
  }
}
