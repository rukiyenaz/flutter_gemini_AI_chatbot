import 'package:flutter_application_1/features/auth/domain/entities/app_user.dart';

abstract class AuthState {}

//initial state
class AuthInitial extends AuthState {}

//loading state
class AuthLoading extends AuthState {}

//authenticated state
class AuthAuthenticated extends AuthState {
  final AppUser user;
  AuthAuthenticated(this.user);
}

//unauthenticated state
class AuthUnauthenticated extends AuthState {}

//error state
class AuthError extends AuthState {
  final String message;

  AuthError({required this.message});
}