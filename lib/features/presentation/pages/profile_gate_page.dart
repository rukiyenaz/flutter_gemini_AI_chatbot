import 'package:flutter/material.dart';
import 'package:flutter_application_1/features/auth/domain/entities/app_user.dart';
import 'package:flutter_application_1/features/presentation/cubits/profile_cubit.dart';
import 'package:flutter_application_1/features/presentation/cubits/profile_state.dart';
import 'package:flutter_application_1/features/presentation/pages/home_page.dart';
import 'package:flutter_application_1/features/presentation/pages/profile_setup_page.dart';
import 'package:flutter_application_1/features/presentation/widgets/modern_loading.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfileGatePage extends StatefulWidget {
  final AppUser user;

  const ProfileGatePage({super.key, required this.user});

  @override
  State<ProfileGatePage> createState() => _ProfileGatePageState();
}

class _ProfileGatePageState extends State<ProfileGatePage> {
  bool _statusChecked = false;

  @override
  void initState() {
    super.initState();
    if (!_statusChecked) {
      context.read<ProfileCubit>().checkProfileStatus(widget.user.id);
      _statusChecked = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        if (state is ProfileLoading || state is ProfileInitial) {
          return const ModernLoadingScreen(
            title: 'Profil Hazirlaniyor',
            subtitle: 'Bilgileriniz kontrol ediliyor',
          );
        }

        if (state is ProfileStatusChecked && state.hasProfile) {
          return const HomePage();
        }

        if (state is ProfileError) {
          return Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Profil bilgileri kontrol edilirken bir hata olustu.'),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () {
                        _statusChecked = false;
                        context.read<ProfileCubit>().checkProfileStatus(widget.user.id);
                        _statusChecked = true;
                      },
                      child: const Text('Tekrar Dene'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return ProfileSetupPage(userId: widget.user.id, isInitialSetup: true);
      },
    );
  }
}
