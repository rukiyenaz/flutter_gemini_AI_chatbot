import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/features/domain/entities/health_profile.dart';

class HealthProfileService {
  final CollectionReference<Map<String, dynamic>> _users =
      FirebaseFirestore.instance.collection('users');

  Future<HealthProfile?> getProfile(String userId) async {
    final doc = await _users.doc(userId).get();
    if (!doc.exists) {
      return null;
    }

    final data = doc.data();
    if (data == null) {
      return null;
    }

    final isCompleted = (data['profileCompleted'] as bool?) ?? false;
    if (!isCompleted) {
      return null;
    }

    return HealthProfile.fromMap(data);
  }

  Future<bool> hasProfile(String userId) async {
    final doc = await _users.doc(userId).get();
    if (!doc.exists) {
      return false;
    }

    final data = doc.data();
    if (data == null) {
      return false;
    }

    return (data['profileCompleted'] as bool?) ?? false;
  }

  Future<void> upsertProfile(HealthProfile profile) async {
    await _users.doc(profile.userId).set(profile.toMap(), SetOptions(merge: true));
  }
}
