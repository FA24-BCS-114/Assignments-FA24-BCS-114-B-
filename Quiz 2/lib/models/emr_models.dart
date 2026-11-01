class EmrDocument {
  final int? id;
  final int patientId;
  final String title;
  final String docFormat; // 'IMG' or 'PDF/DOC'
  final String tag; // 'Radiology', 'Pathology', 'Rx Sheet'
  final String fileSize;
  final String dateAdded;
  final String? encodedBytes;

  const EmrDocument({
    this.id,
    required this.patientId,
    required this.title,
    required this.docFormat,
    required this.tag,
    required this.fileSize,
    required this.dateAdded,
    this.encodedBytes,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'patientId': patientId,
      'title': title,
      'docFormat': docFormat,
      'tag': tag,
      'fileSize': fileSize,
      'dateAdded': dateAdded,
      'encodedBytes': encodedBytes,
    };
  }

  factory EmrDocument.fromMap(Map<String, dynamic> map) {
    return EmrDocument(
      id: map['id'] as int?,
      patientId: (map['patientId'] as int?) ?? 1,
      title: (map['title'] ?? 'Attachment') as String,
      docFormat: (map['docFormat'] ?? 'PDF/DOC') as String,
      tag: (map['tag'] ?? 'Pathology') as String,
      fileSize: (map['fileSize'] ?? '300 KB') as String,
      dateAdded: (map['dateAdded'] ?? 'Oct 2026') as String,
      encodedBytes: map['encodedBytes'] as String?,
    );
  }
}

class EmrPatient {
  final int? id;
  final String mrnCode;
  final String fullName;
  final int age;
  final String gender;
  final String bloodType;
  final String phone;
  final String condition;
  final String priority; // 'Urgent', 'Observation', 'Routine'
  final String vitals; // e.g. 'BP 128/82 • HR 76 • SpO2 98%'
  final String clinicalSummary;
  final String? photoBase64;

  const EmrPatient({
    this.id,
    required this.mrnCode,
    required this.fullName,
    required this.age,
    required this.gender,
    required this.bloodType,
    required this.phone,
    required this.condition,
    required this.priority,
    required this.vitals,
    required this.clinicalSummary,
    this.photoBase64,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'mrnCode': mrnCode,
      'fullName': fullName,
      'age': age,
      'gender': gender,
      'bloodType': bloodType,
      'phone': phone,
      'condition': condition,
      'priority': priority,
      'vitals': vitals,
      'clinicalSummary': clinicalSummary,
      'photoBase64': photoBase64,
    };
  }

  factory EmrPatient.fromMap(Map<String, dynamic> map) {
    return EmrPatient(
      id: map['id'] as int?,
      mrnCode: (map['mrnCode'] ?? 'MRN-100') as String,
      fullName: (map['fullName'] ?? '') as String,
      age: map['age'] is int
          ? map['age'] as int
          : int.tryParse('${map['age']}') ?? 30,
      gender: (map['gender'] ?? 'Male') as String,
      bloodType: (map['bloodType'] ?? 'O+') as String,
      phone: (map['phone'] ?? '') as String,
      condition: (map['condition'] ?? '') as String,
      priority: (map['priority'] ?? 'Routine') as String,
      vitals: (map['vitals'] ?? 'BP 120/80 • HR 74 • SpO2 99%') as String,
      clinicalSummary: (map['clinicalSummary'] ?? '') as String,
      photoBase64: map['photoBase64'] as String?,
    );
  }

  EmrPatient copyWith({
    int? id,
    String? mrnCode,
    String? fullName,
    int? age,
    String? gender,
    String? bloodType,
    String? phone,
    String? condition,
    String? priority,
    String? vitals,
    String? clinicalSummary,
    String? photoBase64,
  }) {
    return EmrPatient(
      id: id ?? this.id,
      mrnCode: mrnCode ?? this.mrnCode,
      fullName: fullName ?? this.fullName,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      bloodType: bloodType ?? this.bloodType,
      phone: phone ?? this.phone,
      condition: condition ?? this.condition,
      priority: priority ?? this.priority,
      vitals: vitals ?? this.vitals,
      clinicalSummary: clinicalSummary ?? this.clinicalSummary,
      photoBase64: photoBase64 ?? this.photoBase64,
    );
  }
}
