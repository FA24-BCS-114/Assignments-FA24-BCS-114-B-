class PersonRecord {
  final int? id;
  final String fullName;
  final String email;
  final int age;
  final String gender;
  final String roleTag;
  final String? photoBase64;
  final int badgeColor;

  const PersonRecord({
    this.id,
    required this.fullName,
    required this.email,
    required this.age,
    required this.gender,
    required this.roleTag,
    this.photoBase64,
    this.badgeColor = 0xFF059669,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'fullName': fullName,
      'email': email,
      'age': age,
      'gender': gender,
      'roleTag': roleTag,
      'photoBase64': photoBase64,
      'badgeColor': badgeColor,
    };
  }

  factory PersonRecord.fromMap(Map<String, dynamic> map) {
    return PersonRecord(
      id: map['id'] as int?,
      fullName: (map['fullName'] ?? '') as String,
      email: (map['email'] ?? '') as String,
      age: map['age'] is int
          ? map['age'] as int
          : int.tryParse('${map['age']}') ?? 20,
      gender: (map['gender'] ?? 'Male') as String,
      roleTag: (map['roleTag'] ?? 'CS Scholar') as String,
      photoBase64: map['photoBase64'] as String?,
      badgeColor: (map['badgeColor'] as int?) ?? 0xFF059669,
    );
  }

  PersonRecord copyWith({
    int? id,
    String? fullName,
    String? email,
    int? age,
    String? gender,
    String? roleTag,
    String? photoBase64,
    int? badgeColor,
  }) {
    return PersonRecord(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      roleTag: roleTag ?? this.roleTag,
      photoBase64: photoBase64 ?? this.photoBase64,
      badgeColor: badgeColor ?? this.badgeColor,
    );
  }
}
