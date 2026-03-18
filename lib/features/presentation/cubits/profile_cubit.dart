import 'package:flutter_application_1/features/data/health_profile_service.dart';
import 'package:flutter_application_1/features/domain/entities/health_profile.dart';
import 'package:flutter_application_1/features/presentation/cubits/profile_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final HealthProfileService healthProfileService;

  ProfileCubit({required this.healthProfileService}) : super(ProfileInitial());

  Future<void> checkProfileStatus(String userId) async {
    emit(ProfileLoading(profile: state.profile));
    try {
      final hasProfile = await healthProfileService.hasProfile(userId);
      emit(ProfileStatusChecked(hasProfile: hasProfile, profile: state.profile));
    } catch (e) {
      emit(ProfileError(message: e.toString(), profile: state.profile));
    }
  }

  Future<void> loadProfile(String userId) async {
    emit(ProfileLoading(profile: state.profile));
    try {
      final profile = await healthProfileService.getProfile(userId);
      if (profile == null) {
        emit(ProfileStatusChecked(hasProfile: false, profile: state.profile));
      } else {
        emit(ProfileLoaded(profile: profile));
      }
    } catch (e) {
      emit(ProfileError(message: e.toString(), profile: state.profile));
    }
  }

  Future<void> saveProfile(HealthProfile profile) async {
    emit(ProfileSaving(profile: state.profile));
    try {
      await healthProfileService.upsertProfile(profile);
      emit(ProfileSaved(profile: profile));
    } catch (e) {
      emit(ProfileError(message: e.toString(), profile: state.profile));
    }
  }
}
