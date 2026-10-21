import 'json_helpers.dart';

class LibraryCard {
  final String number;
  final DateTime issuedAt;
  final DateTime expiresAt;

  const LibraryCard({
    required this.number,
    required this.issuedAt,
    required this.expiresAt,
  });

  factory LibraryCard.fromJson(Map<String, dynamic> json) {
    return LibraryCard(
      number: jsonString(json['number']),
      issuedAt: jsonDate(json['issuedAt']) ?? DateTime(1970),
      expiresAt: jsonDate(json['expiresAt']) ?? DateTime(1970),
    );
  }

  Map<String, dynamic> toJson() => {
        'number': number,
        'issuedAt': issuedAt.toIso8601String(),
        'expiresAt': expiresAt.toIso8601String(),
      };

  bool isExpiredAt(DateTime moment) => expiresAt.isBefore(moment);

  LibraryCard copyWith({
    String? number,
    DateTime? issuedAt,
    DateTime? expiresAt,
  }) {
    return LibraryCard(
      number: number ?? this.number,
      issuedAt: issuedAt ?? this.issuedAt,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }
}

class Reader {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final LibraryCard card;
  final DateTime? deletedAt;

  const Reader({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.card,
    this.deletedAt,
  });

  factory Reader.fromJson(Map<String, dynamic> json) {
    return Reader(
      id: jsonInt(json['id']),
      firstName: jsonString(json['firstName']),
      lastName: jsonString(json['lastName']),
      email: jsonString(json['email']),
      phone: jsonString(json['phone']),
      card: LibraryCard.fromJson(jsonMap(json['card'])),
      deletedAt: jsonDate(json['deletedAt']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'phone': phone,
        'card': card.toJson(),
        'deletedAt': deletedAt?.toIso8601String(),
      };

  bool get isDeleted => deletedAt != null;

  String get fullName => '$lastName $firstName';

  Reader copyWith({
    int? id,
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    LibraryCard? card,
    DateTime? deletedAt,
    bool clearDeletedAt = false,
  }) {
    return Reader(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      card: card ?? this.card,
      deletedAt: clearDeletedAt ? null : (deletedAt ?? this.deletedAt),
    );
  }
}
