import 'package:cloud_firestore/cloud_firestore.dart';

class HealthProfile {
  final String userId;
  final int age;
  final String gender;
  final double heightCm;
  final double weightKg;
  final String chronicConditions;
  final String allergies;
  final String medications;
  final DateTime updatedAt;

  const HealthProfile({
    required this.userId,
    required this.age,
    required this.gender,
    required this.heightCm,
    required this.weightKg,
    required this.chronicConditions,
    required this.allergies,
    required this.medications,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'age': age,
      'gender': gender,
      'heightCm': heightCm,
      'weightKg': weightKg,
      'chronicConditions': chronicConditions,
      'allergies': allergies,
      'medications': medications,
      'updatedAt': Timestamp.fromDate(updatedAt),
      'profileCompleted': true,
    };
  }

  factory HealthProfile.fromMap(Map<String, dynamic> map) {
    final updatedAtRaw = map['updatedAt'];
    DateTime updatedAt = DateTime.now();
    if (updatedAtRaw is Timestamp) {
      updatedAt = updatedAtRaw.toDate();
    } else if (updatedAtRaw is DateTime) {
      updatedAt = updatedAtRaw;
    }

    return HealthProfile(
      userId: (map['userId'] as String?) ?? '',
      age: ((map['age'] as num?) ?? 0).toInt(),
      gender: (map['gender'] as String?) ?? 'Belirtmek istemiyorum',
      heightCm: ((map['heightCm'] as num?) ?? 0).toDouble(),
      weightKg: ((map['weightKg'] as num?) ?? 0).toDouble(),
      chronicConditions: (map['chronicConditions'] as String?) ?? '',
      allergies: (map['allergies'] as String?) ?? '',
      medications: (map['medications'] as String?) ?? '',
      updatedAt: updatedAt,
    );
  }
}
