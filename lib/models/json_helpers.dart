int jsonInt(Object? value, [int fallback = 0]) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value.trim()) ?? fallback;
  return fallback;
}

String jsonString(Object? value, [String fallback = '']) {
  if (value is String) return value;
  if (value == null) return fallback;
  return '$value';
}

List<int> jsonIntList(Object? value) {
  if (value is! List) return <int>[];
  return <int>[
    for (final element in value)
      if (element is int) element else if (element is num) element.toInt(),
  ];
}

DateTime? jsonDate(Object? value) {
  if (value is! String) return null;
  return DateTime.tryParse(value);
}

Map<String, dynamic> jsonMap(Object? value) {
  if (value is Map) return Map<String, dynamic>.from(value);
  return <String, dynamic>{};
}
