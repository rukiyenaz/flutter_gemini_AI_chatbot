import 'package:flutter_application_1/features/domain/entities/health_profile.dart';

abstract class ProfileState {
  final HealthProfile? profile;

  ProfileState({this.profile});
}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {
  ProfileLoading({super.profile});
}

class ProfileStatusChecked extends ProfileState {
  final bool hasProfile;

  ProfileStatusChecked({required this.hasProfile, super.profile});
}

class ProfileLoaded extends ProfileState {
  ProfileLoaded({required HealthProfile profile}) : super(profile: profile);
}

class ProfileSaving extends ProfileState {
  ProfileSaving({super.profile});
}

class ProfileSaved extends ProfileState {
  ProfileSaved({required HealthProfile profile}) : super(profile: profile);
}

class ProfileError extends ProfileState {
  final String message;

  ProfileError({required this.message, super.profile});
}
