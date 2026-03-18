import 'package:flutter/material.dart';
import 'package:flutter_application_1/features/domain/entities/health_profile.dart';
import 'package:flutter_application_1/features/presentation/cubits/profile_cubit.dart';
import 'package:flutter_application_1/features/presentation/cubits/profile_state.dart';
import 'package:flutter_application_1/features/presentation/pages/home_page.dart';
import 'package:flutter_application_1/features/presentation/widgets/modern_loading.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfileSetupPage extends StatefulWidget {
  final String userId;
  final bool isInitialSetup;

  const ProfileSetupPage({
    super.key,
    required this.userId,
    this.isInitialSetup = true,
  });

  @override
  State<ProfileSetupPage> createState() => _ProfileSetupPageState();
}

class _ProfileSetupPageState extends State<ProfileSetupPage> {
  final _ageController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _conditionsController = TextEditingController();
  final _allergiesController = TextEditingController();
  final _medicationsController = TextEditingController();

  final List<String> _genders = const [
    'Kadın',
    'Erkek',
    'Belirtmek istemiyorum',
  ];
  String _selectedGender = 'Belirtmek istemiyorum';

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

  Future<void> _saveProfile() async {
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
      userId: widget.userId,
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
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: const Color(0xFFF2F6FC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocConsumer<ProfileCubit, ProfileState>(
      listener: (context, state) {
        if (state is ProfileSaved) {
          if (widget.isInitialSetup) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const HomePage()),
            );
          } else {
            Navigator.of(context).pop(true);
          }
        }

        if (state is ProfileError) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profil kaydedilirken bir hata olustu.')),
          );
        }
      },
      builder: (context, state) {
        final isSaving = state is ProfileSaving;

        return Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF10224F), Color(0xFF1D4E89), Color(0xFF2A9D8F)],
              ),
            ),
            child: SafeArea(
              child: Stack(
                children: [
                  Positioned(
                    top: -70,
                    left: -50,
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 460),
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.94),
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x33000000),
                                blurRadius: 28,
                                offset: Offset(0, 12),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                'Temel Saglik Bilgileri',
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF112A46),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Sana daha uygun yanitlar verebilmek icin bu bilgileri bir kez doldur.',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: const Color(0xFF4F5D75),
                                ),
                              ),
                              const SizedBox(height: 20),
                              _buildTextField(
                                controller: _ageController,
                                hint: 'Yas',
                                icon: Icons.cake_outlined,
                                keyboardType: TextInputType.number,
                              ),
                              const SizedBox(height: 12),
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
                                  prefixIcon: const Icon(Icons.wc_outlined),
                                  filled: true,
                                  fillColor: const Color(0xFFF2F6FC),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              _buildTextField(
                                controller: _heightController,
                                hint: 'Boy (cm)',
                                icon: Icons.height,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              ),
                              const SizedBox(height: 12),
                              _buildTextField(
                                controller: _weightController,
                                hint: 'Kilo (kg)',
                                icon: Icons.monitor_weight_outlined,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              ),
                              const SizedBox(height: 12),
                              _buildTextField(
                                controller: _conditionsController,
                                hint: 'Kronik hastaliklar (opsiyonel)',
                                icon: Icons.health_and_safety_outlined,
                              ),
                              const SizedBox(height: 12),
                              _buildTextField(
                                controller: _allergiesController,
                                hint: 'Alerjiler (opsiyonel)',
                                icon: Icons.warning_amber_outlined,
                              ),
                              const SizedBox(height: 12),
                              _buildTextField(
                                controller: _medicationsController,
                                hint: 'Duzenli ilaclar (opsiyonel)',
                                icon: Icons.medication_outlined,
                              ),
                              const SizedBox(height: 20),
                              SizedBox(
                                height: 52,
                                child: ElevatedButton(
                                  onPressed: isSaving ? null : _saveProfile,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF1D4E89),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  child: isSaving
                                      ? const SizedBox(
                                          height: 22,
                                          child: ModernInlineLoader(
                                            label: 'Kaydediliyor',
                                            color: Colors.white,
                                            size: 16,
                                          ),
                                        )
                                      : const Text(
                                          'Profili Kaydet',
                                          style: TextStyle(fontWeight: FontWeight.w700),
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
