import 'package:flutter_application_1/features/auth/domain/entities/app_user.dart';

abstract class AuthRepository {
  Future<AppUser?> signInWithEmailAndPassword(String email, String password);
  Future<AppUser?> signUpWithEmailAndPassword(String name,String email, String password);
  Future<void> signOut();
  Future<void> resetPassword(String email);
  Future<AppUser?> getCurrentUser();

}