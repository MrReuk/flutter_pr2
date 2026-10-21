import 'json_helpers.dart';

class Publisher {
  final int id;
  final String name;
  final String country;
  final int foundedYear;
  final String email;
  final DateTime? deletedAt;

  const Publisher({
    required this.id,
    required this.name,
    required this.country,
    required this.foundedYear,
    required this.email,
    this.deletedAt,
  });

  factory Publisher.fromJson(Map<String, dynamic> json) {
    return Publisher(
      id: jsonInt(json['id']),
      name: jsonString(json['name']),
      country: jsonString(json['country']),
      foundedYear: jsonInt(json['foundedYear']),
      email: jsonString(json['email']),
      deletedAt: jsonDate(json['deletedAt']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'country': country,
        'foundedYear': foundedYear,
        'email': email,
        'deletedAt': deletedAt?.toIso8601String(),
      };

  bool get isDeleted => deletedAt != null;

  Publisher copyWith({
    int? id,
    String? name,
    String? country,
    int? foundedYear,
    String? email,
    DateTime? deletedAt,
    bool clearDeletedAt = false,
  }) {
    return Publisher(
      id: id ?? this.id,
      name: name ?? this.name,
      country: country ?? this.country,
      foundedYear: foundedYear ?? this.foundedYear,
      email: email ?? this.email,
      deletedAt: clearDeletedAt ? null : (deletedAt ?? this.deletedAt),
    );
  }
}
