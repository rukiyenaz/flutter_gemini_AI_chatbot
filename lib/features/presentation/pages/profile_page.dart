import 'package:flutter/material.dart';
import 'package:flutter_application_1/features/auth/presenatiton/cubits/auth_cubit.dart';
import 'package:flutter_application_1/features/auth/presenatiton/cubits/auth_state.dart';
import 'package:flutter_application_1/features/domain/entities/health_profile.dart';
import 'package:flutter_application_1/features/presentation/cubits/profile_cubit.dart';
import 'package:flutter_application_1/features/presentation/cubits/profile_state.dart';
import 'package:flutter_application_1/features/presentation/pages/home_page.dart';
import 'package:flutter_application_1/features/presentation/widgets/modern_loading.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _ageController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _conditionsController = TextEditingController();
  final _allergiesController = TextEditingController();
  final _medicationsController = TextEditingController();

  final List<String> _genders = const ['Kadın', 'Erkek', 'Belirtmek istemiyorum'];
  String _selectedGender = 'Belirtmek istemiyorum';

  bool _formInitialized = false;

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthAuthenticated) {
      context.read<ProfileCubit>().loadProfile(authState.user.id);
    }
  }

  @override
  void dispose() {
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _conditionsController.dispose();
    _allergiesController.dispose();
    _medicationsController.dispose();
    super.dispose();
  }

  void _fillForm(HealthProfile profile) {
    _ageController.text = profile.age > 0 ? profile.age.toString() : '';
    _heightController.text = profile.heightCm > 0 ? profile.heightCm.toString() : '';
    _weightController.text = profile.weightKg > 0 ? profile.weightKg.toString() : '';
    _conditionsController.text = profile.chronicConditions;
    _allergiesController.text = profile.allergies;
    _medicationsController.text = profile.medications;
    _selectedGender = _genders.contains(profile.gender) ? profile.gender : 'Belirtmek istemiyorum';
  }

  Future<void> _saveProfile(String userId) async {
    final authState = context.read<AuthCubit>().state;
    if (authState is! AuthAuthenticated) {
      return;
    }

    final age = int.tryParse(_ageController.text.trim());
    final height = double.tryParse(_heightController.text.trim());
    final weight = double.tryParse(_weightController.text.trim());

    if (age == null || age <= 0 || height == null || height <= 0 || weight == null || weight <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lutfen yas, boy ve kilo alanlarini dogru doldurun.')),
      );
      return;
    }

    final profile = HealthProfile(
      userId: userId,
      age: age,
      gender: _selectedGender,
      heightCm: height,
      weightKg: weight,
      chronicConditions: _conditionsController.text.trim(),
      allergies: _allergiesController.text.trim(),
      medications: _medicationsController.text.trim(),
      updatedAt: DateTime.now(),
    );

    await context.read<ProfileCubit>().saveProfile(profile);
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 10),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1D4E89),
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: const Color(0xFF1D4E89)),
        hintStyle: const TextStyle(color: Color(0xFFA0A0A0)),
        filled: true,
        fillColor: const Color(0xFFF8FAFB),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE8EBF0), width: 1.2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE8EBF0), width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF1D4E89), width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = context.watch<AuthCubit>().state;
    String email = '';
    String userId = '';
    if (authState is AuthAuthenticated) {
      email = authState.user.email;
      userId = authState.user.id;
    }
    return BlocConsumer<ProfileCubit, ProfileState>(
      listener: (context, state) {
        if (state is ProfileLoaded && state.profile != null) {
          setState(() {
            _fillForm(state.profile!);
            _formInitialized = true;
          });
        }

        if (state is ProfileSaved && state.profile != null) {
          setState(() {
            _fillForm(state.profile!);
            _formInitialized = true;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profil guncellendi.')),
          );
        }

        if (state is ProfileError) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profil guncellenirken hata olustu.')),
          );
        }
      },
      builder: (context, state) {
        final isSaving = state is ProfileSaving;
        final isLoading =
            (state is ProfileInitial || state is ProfileLoading) &&
            !_formInitialized;

        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'Profil',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            elevation: 0,
            backgroundColor: Colors.transparent,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const HomePage()),
                );
              },
            ),
            centerTitle: false,
            actions: [
              IconButton(
                tooltip: 'Cikis',
                icon: const Icon(Icons.logout_rounded, color: Colors.white),
                onPressed: () {
                  context.read<AuthCubit>().signOut();
                },
              ),
              const SizedBox(width: 8),
            ],
          ),
          extendBodyBehindAppBar: true,
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF10224F), Color(0xFF1D4E89), Color(0xFF2A9D8F)],
              ),
            ),
            child: SafeArea(
              child: isLoading
                  ? const ModernLoadingScreen(
                      title: 'Profil Yukleniyor',
                      subtitle: 'Saglik bilgileriniz getiriliyor',
                      useScaffold: false,
                    )
                  : Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 520),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF000000).withValues(alpha: 0.12),
                              blurRadius: 16,
                              offset: const Offset(0, 8),
                            )
                          ],
                        ),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Header Section
                              Text(
                                'Profil Bilgileri',
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  color: const Color(0xFF112A46),
                                  fontWeight: FontWeight.w800,
                                  fontSize: 22,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                email,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: const Color(0xFF7A8BA8),
                                  fontSize: 14,
                                ),
                              ),
                              const Divider(
                                color: Color(0xFFE8EBF0),
                                height: 18,
                                thickness: 1,
                              ),
                        
                              // Temel Bilgiler Section
                              _buildSectionTitle('Temel Bilgiler'),
                              _buildTextField(
                                controller: _ageController,
                                hint: 'Yas',
                                icon: Icons.cake_outlined,
                                keyboardType: TextInputType.number,
                              ),
                              const SizedBox(height: 10),
                              DropdownButtonFormField<String>(
                                key: ValueKey(_selectedGender),
                                initialValue: _selectedGender,
                                items: _genders
                                    .map((gender) => DropdownMenuItem<String>(
                                          value: gender,
                                          child: Text(gender),
                                        ))
                                    .toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() {
                                      _selectedGender = value;
                                    });
                                  }
                                },
                                decoration: InputDecoration(
                                  hintText: 'Cinsiyet',
                                  prefixIcon: const Icon(Icons.wc_outlined, color: Color(0xFF1D4E89)),
                                  hintStyle: const TextStyle(color: Color(0xFFA0A0A0)),
                                  filled: true,
                                  fillColor: const Color(0xFFF8FAFB),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: const BorderSide(color: Color(0xFFE8EBF0), width: 1.2),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: const BorderSide(color: Color(0xFFE8EBF0), width: 1.2),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: const BorderSide(color: Color(0xFF1D4E89), width: 2),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                ),
                              ),
                        
                              // Boyut Bilgileri Section
                              _buildSectionTitle('Boyut Bilgileri'),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildTextField(
                                      controller: _heightController,
                                      hint: 'Boy (cm)',
                                      icon: Icons.height,
                                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: _buildTextField(
                                      controller: _weightController,
                                      hint: 'Kilo (kg)',
                                      icon: Icons.monitor_weight_outlined,
                                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                    ),
                                  ),
                                ],
                              ),
                        
                              // Saglik Durumu Section
                              _buildSectionTitle('Saglik Durumu'),
                              _buildTextField(
                                controller: _conditionsController,
                                hint: 'Kronik hastaliklar (opsiyonel)',
                                icon: Icons.health_and_safety_outlined,
                              ),
                              const SizedBox(height: 10),
                              _buildTextField(
                                controller: _allergiesController,
                                hint: 'Alerjiler (opsiyonel)',
                                icon: Icons.warning_amber_outlined,
                              ),
                              const SizedBox(height: 10),
                              _buildTextField(
                                controller: _medicationsController,
                                hint: 'Duzenli ilaclar (opsiyonel)',
                                icon: Icons.medication_outlined,
                              ),
                        
                              const SizedBox(height: 20),
                              SizedBox(
                                width: double.infinity,
                                height: 56,
                                child: ElevatedButton(
                                  onPressed: isSaving ? null : () => _saveProfile(userId),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF1D4E89),
                                    foregroundColor: Colors.white,
                                    disabledBackgroundColor: const Color(0xFFBDBDBD),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    elevation: 3,
                                  ),
                                  child: isSaving
                                      ? const SizedBox(
                                          height: 24,
                                          child: ModernInlineLoader(
                                            color: Colors.white,
                                            label: 'Kaydediliyor',
                                            size: 18,
                                          ),
                                        )
                                      : const Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.check_circle_outline, size: 20),
                                            SizedBox(width: 8),
                                            Text(
                                              'Profili Guncelle',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w700,
                                                fontSize: 16,
                                                letterSpacing: 0.3,
                                              ),
                                            ),
                                          ],
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
            ),
          ),
        );
      },
    );
  }
}
