// lib/presentation/screens/profile_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../domain/entities/condition_entity.dart';
import '../../domain/entities/health_profile_entity.dart';
import '../../domain/entities/user_entity.dart';
import '../../core/utils/result.dart';
import '../providers/health_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/repository_providers.dart';
import '../widgets/loading_widget.dart';
import '../widgets/app_button.dart';
import '../widgets/custom_text_field.dart';
import '../../theme/app_colors.dart';
import '../../core/utils/permission_helper.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // User Profile Controllers
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _ageController;
  late TextEditingController _phoneController;
  late TextEditingController _emergencyContactController;
  String? _selectedGender;

  // Health Profile Controllers
  late TextEditingController _weightController;
  late TextEditingController _heightController;
  late TextEditingController _allergiesController;
  String? _selectedBloodType;

  final Set<String> _selectedConditionIds = {};
  bool _isSaving = false;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _ageController = TextEditingController();
    _phoneController = TextEditingController();
    _emergencyContactController = TextEditingController();
    _weightController = TextEditingController();
    _heightController = TextEditingController();
    _allergiesController = TextEditingController();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _ageController.dispose();
    _phoneController.dispose();
    _emergencyContactController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _allergiesController.dispose();
    super.dispose();
  }

  void _initializeData(UserEntity? user, HealthProfileEntity? healthProfile, List<ConditionEntity> userConditions) {
    if (_initialized) return;
    
    if (user != null) {
      _firstNameController.text = user.firstName;
      _lastNameController.text = user.lastName;
      _ageController.text = user.age.toString();
      _phoneController.text = user.phone ?? '';
      _emergencyContactController.text = user.emergencyContact ?? '';
      _selectedGender = user.gender;
    }

    if (healthProfile != null) {
      _weightController.text = healthProfile.weightKg.toString();
      _heightController.text = healthProfile.heightCm.toString();
      _allergiesController.text = healthProfile.allergies ?? '';
      _selectedBloodType = healthProfile.bloodType;
    }

    _selectedConditionIds.clear();
    for (var condition in userConditions) {
      _selectedConditionIds.add(condition.id);
    }
    
    _initialized = true;
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final authRepository = ref.read(authRepositoryProvider);
      final healthRepository = ref.read(healthRepositoryProvider);
      
      final authState = ref.read(authStateProvider);
      final user = authState.value;

      if (user == null) throw Exception('User not authenticated');

      // 1. Update User Profile
      final userResult = await authRepository.updateUserProfile(
        userId: user.id,
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        age: int.tryParse(_ageController.text.trim()) ?? 60,
        phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
        gender: _selectedGender,
        emergencyContact: _emergencyContactController.text.trim().isEmpty ? null : _emergencyContactController.text.trim(),
      );

      if (userResult is Failure) throw Exception((userResult as Failure).userMessage);

      // 2. Update/Create Health Profile
      final healthProfileAsync = ref.read(userHealthProfileProvider);
      final hasProfile = healthProfileAsync.value != null;

      double weight = double.tryParse(_weightController.text.trim()) ?? 70.0;
      if (weight <= 0) weight = 70.0;

      int height = double.tryParse(_heightController.text.trim())?.toInt() ?? 170;
      if (height <= 0) height = 170;

      Result<HealthProfileEntity> healthResult;
      if (hasProfile) {
        healthResult = await healthRepository.updateHealthProfile(
          userId: user.id,
          weightKg: weight,
          heightCm: height,
          bloodType: _selectedBloodType,
          allergies: _allergiesController.text.trim().isEmpty ? null : _allergiesController.text.trim(),
        );
      } else {
        healthResult = await healthRepository.createHealthProfile(
          userId: user.id,
          weightKg: weight,
          heightCm: height,
          bloodType: _selectedBloodType,
          allergies: _allergiesController.text.trim().isEmpty ? null : _allergiesController.text.trim(),
        );
      }

      if (healthResult is Failure) throw Exception((healthResult as Failure).userMessage);

      // 3. Update Conditions
      final currentConditions = ref.read(userConditionsProvider).value ?? [];
      final currentIds = currentConditions.map((c) => c.id).toSet();

      // Add new ones
      for (final id in _selectedConditionIds) {
        if (!currentIds.contains(id)) {
          await healthRepository.addUserCondition(userId: user.id, conditionId: id);
        }
      }

      // Remove unselected ones
      for (final id in currentIds) {
        if (!_selectedConditionIds.contains(id)) {
          await healthRepository.removeUserCondition(userId: user.id, conditionId: id);
        }
      }

      // Refresh providers
      ref.invalidate(authStateProvider);
      ref.invalidate(userHealthProfileProvider);
      ref.invalidate(userConditionsProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully! 🎯', style: TextStyle(fontWeight: FontWeight.w700)),
            backgroundColor: AppColors.success,
          ),
        );
        // Removed Navigator.pop(context) because this is a persistent tab.
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}', style: const TextStyle(fontWeight: FontWeight.w700)),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _pickAndUploadAvatar(UserEntity? user) async {
    if (user == null) return;
    
    final hasPermission = await PermissionHelper.requestPhotosPermission(context);
    if (!hasPermission) return;
    
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 500,
      maxHeight: 500,
      imageQuality: 85,
    );
    
    if (image == null) return;
    
    setState(() => _isSaving = true);
    
    try {
      final authRepository = ref.read(authRepositoryProvider);
      final result = await authRepository.uploadAvatar(
        userId: user.id,
        imagePath: image.path,
      );
      
      result.when(
        success: (updatedUser) {
          ref.invalidate(authStateProvider);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile picture updated successfully! 📸', style: TextStyle(fontWeight: FontWeight.w700)),
              backgroundColor: AppColors.success,
            ),
          );
        },
        failure: (error) {
          throw Exception(error.userMessage);
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to upload picture: ${e.toString()}', style: const TextStyle(fontWeight: FontWeight.w700)),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(authStateProvider);
    final healthProfileAsync = ref.watch(userHealthProfileProvider);
    final userConditionsAsync = ref.watch(userConditionsProvider);
    final allConditionsAsync = ref.watch(allConditionsProvider);

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: Text(
          'Health Profile',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
              ),
        ),
        backgroundColor: AppColors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false, // Inside bottom nav
      ),
      body: userAsync.when(
        loading: () => const Center(child: LoadingWidget()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (user) {
          return healthProfileAsync.when(
            loading: () => const Center(child: LoadingWidget()),
            error: (e, _) => Center(child: Text('Error: $e')),
            data: (healthProfile) {
              return userConditionsAsync.when(
                loading: () => const Center(child: LoadingWidget()),
                error: (e, _) => Center(child: Text('Error: $e')),
                data: (userConditions) {
                  _initializeData(user, healthProfile, userConditions);
                  
                  return allConditionsAsync.when(
                    loading: () => const Center(child: LoadingWidget()),
                    error: (e, _) => Center(child: Text('Error: $e')),
                    data: (allConditions) {
                      return Form(
                        key: _formKey,
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Beautiful Profile Picture Header
                              Center(
                                child: GestureDetector(
                                  onTap: () => _pickAndUploadAvatar(user),
                                  child: Stack(
                                    children: [
                                      CircleAvatar(
                                        radius: 60,
                                        backgroundColor: AppColors.primaryContainer,
                                        backgroundImage: user?.avatarUrl != null && user!.avatarUrl!.isNotEmpty
                                            ? (user.avatarUrl!.startsWith('http')
                                                ? NetworkImage(user.avatarUrl!) as ImageProvider
                                                : FileImage(File(user.avatarUrl!)) as ImageProvider)
                                            : NetworkImage(
                                                user?.gender == 'Female'
                                                    ? 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?q=80&w=200&auto=format&fit=crop'
                                                    : 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?q=80&w=200&auto=format&fit=crop',
                                              ),
                                      ),
                                      Positioned(
                                        bottom: 0,
                                        right: 0,
                                        child: Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: const BoxDecoration(
                                            color: AppColors.primary,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.camera_alt_rounded,
                                            color: AppColors.white,
                                            size: 20,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 32),
                              _buildSectionTitle('Personal Information'),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: CustomTextField(
                                      label: 'First Name',
                                      controller: _firstNameController,
                                      validator: (v) => v!.isEmpty ? 'Required' : null,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: CustomTextField(
                                      label: 'Last Name',
                                      controller: _lastNameController,
                                      validator: (v) => v!.isEmpty ? 'Required' : null,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: CustomTextField(
                                      label: 'Age',
                                      controller: _ageController,
                                      keyboardType: TextInputType.number,
                                      validator: (v) => v!.isEmpty ? 'Required' : null,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: _buildDropdownField<String>(
                                      label: 'Gender',
                                      value: _selectedGender,
                                      items: ['Male', 'Female', 'Other'],
                                      onChanged: (v) => setState(() => _selectedGender = v),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              CustomTextField(
                                label: 'Phone Number',
                                controller: _phoneController,
                                keyboardType: TextInputType.phone,
                              ),
                              const SizedBox(height: 16),
                              CustomTextField(
                                label: 'Emergency Contact Number',
                                controller: _emergencyContactController,
                                keyboardType: TextInputType.phone,
                                hint: 'e.g. Doctor or Family',
                                validator: (v) => v!.isNotEmpty && v.length < 10 ? 'Invalid number' : null,
                              ),
                              
                              const SizedBox(height: 48),
                              _buildSectionTitle('Health Metrics'),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: CustomTextField(
                                      label: 'Weight (kg)',
                                      controller: _weightController,
                                      keyboardType: TextInputType.number,
                                      validator: (v) => v!.isEmpty ? 'Required' : null,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: CustomTextField(
                                      label: 'Height (cm)',
                                      controller: _heightController,
                                      keyboardType: TextInputType.number,
                                      validator: (v) => v!.isEmpty ? 'Required' : null,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              _buildDropdownField<String>(
                                label: 'Blood Type',
                                value: _selectedBloodType,
                                items: ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'],
                                onChanged: (v) => setState(() => _selectedBloodType = v),
                              ),
                              const SizedBox(height: 16),
                              CustomTextField(
                                label: 'Allergies',
                                controller: _allergiesController,
                                hint: 'e.g. Peanuts, Penicillin',
                                maxLines: 3,
                              ),

                              const SizedBox(height: 48),
                              _buildSectionTitle('Health Conditions'),
                              const SizedBox(height: 8),
                              Text(
                                'Select all that apply to you. This helps us customize your meal recommendations and drug warnings.',
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      color: AppColors.textSecondary,
                                      height: 1.4,
                                    ),
                              ),
                              const SizedBox(height: 24),
                              ...allConditions.map((condition) {
                                final isSelected = _selectedConditionIds.contains(condition.id);
                                return _buildConditionTile(condition, isSelected);
                              }).toList(),

                              const SizedBox(height: 48),
                              AppButton(
                                label: 'Save Profile Changes',
                                onPressed: _isSaving ? () {} : _saveProfile,
                                isLoading: _isSaving,
                                width: double.infinity,
                              ),
                              const SizedBox(height: 48),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary,
          ),
    );
  }

  Widget _buildDropdownField<T>({
    required String label,
    required T? value,
    required List<T> items,
    required ValueChanged<T?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
              ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.divider, width: 2),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              isExpanded: true,
              icon: const Icon(Icons.expand_more_rounded, color: AppColors.primary, size: 28),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
              items: items.map((item) {
                return DropdownMenuItem<T>(
                  value: item,
                  child: Text(item.toString()),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildConditionTile(ConditionEntity condition, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            _selectedConditionIds.remove(condition.id);
          } else {
            _selectedConditionIds.add(condition.id);
          }
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryContainer : AppColors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.divider,
            width: isSelected ? 3 : 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.2),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  )
                ]
              : [],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.veryLightGrey,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isSelected ? Icons.check_rounded : Icons.add_rounded,
                color: isSelected ? AppColors.white : AppColors.grey,
                size: 28,
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    condition.conditionName,
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                      color: isSelected ? AppColors.primary : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    condition.description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: isSelected ? AppColors.primary.withOpacity(0.8) : AppColors.textSecondary,
                          height: 1.4,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
