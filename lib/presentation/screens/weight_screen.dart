// lib/presentation/screens/weight_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutricare_elderly/presentation/widgets/custom_text_field.dart';
import 'package:nutricare_elderly/presentation/widgets/app_button.dart';
import 'package:nutricare_elderly/presentation/providers/auth_provider.dart';
import 'package:nutricare_elderly/presentation/providers/weight_provider.dart';
import 'package:nutricare_elderly/theme/app_colors.dart';

class WeightScreen extends ConsumerStatefulWidget {
  const WeightScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _WeightScreenState();
}

class _WeightScreenState extends ConsumerState<WeightScreen> {
  final _weightController = TextEditingController();
  final _notesController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _weightController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _logWeight() async {
    if (_weightController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your weight', style: TextStyle(fontWeight: FontWeight.w700)),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final weight = double.tryParse(_weightController.text);
    if (weight == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid weight number', style: TextStyle(fontWeight: FontWeight.w700)),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final logWeightUseCase = ref.read(logWeightUseCaseProvider);
      final user = await ref.read(userProvider.future);

      if (user == null) {
        throw Exception('Not logged in');
      }

      final result = await logWeightUseCase.call(
        userId: user.id,
        weightKg: weight,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      );

      result.when(
        success: (_) {
          if (mounted) {
            _weightController.clear();
            _notesController.clear();

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Weight logged successfully! 🎯', style: TextStyle(fontWeight: FontWeight.w700)),
                backgroundColor: AppColors.success,
              ),
            );

            // Refresh weight providers
            ref.invalidate(latestWeightProvider);
            ref.invalidate(weightHistoryProvider);
          }
        },
        failure: (failure) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${failure.userMessage}', style: const TextStyle(fontWeight: FontWeight.w700)),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e', style: const TextStyle(fontWeight: FontWeight.w700)),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final latestWeightAsync = ref.watch(latestWeightProvider);
    final weightHistoryAsync = ref.watch(weightHistoryProvider);

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: Text(
          'Track Weight',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
              ),
        ),
        backgroundColor: AppColors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false, // Inside bottom nav
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // CURRENT WEIGHT - Soft Card
            Text(
              'Current Weight',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
            ),
            const SizedBox(height: 16),
            latestWeightAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => _buildErrorCard(context, 'Error loading weight data'),
              data: (weight) {
                if (weight == null) {
                  return Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(color: AppColors.divider, width: 2),
                    ),
                    child: Center(
                      child: Text(
                        'No weight data yet.\nLog your first weight below!',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                              height: 1.5,
                            ),
                      ),
                    ),
                  );
                }

                return Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.monitor_weight_rounded, color: AppColors.white.withOpacity(0.8), size: 48),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            '${weight.weightKg}',
                            style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                  color: AppColors.white,
                                  fontWeight: FontWeight.w900,
                                ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'kg',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  color: AppColors.white.withOpacity(0.8),
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          'BMI: ${weight.bmi?.toStringAsFixed(1) ?? "N/A"}',
                          style: const TextStyle(
                            color: AppColors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Last recorded: ${weight.recordedDate.toString().split(' ')[0]}',
                        style: TextStyle(
                          color: AppColors.white.withOpacity(0.7),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 48),

            // LOG WEIGHT FORM
            Text(
              'Log New Weight',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(32),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.softShadow,
                    blurRadius: 24,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  CustomTextField(
                    label: 'Weight (kg)',
                    hint: 'e.g. 70.5',
                    controller: _weightController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    prefixIcon: const Icon(Icons.scale_rounded, size: 28),
                  ),
                  const SizedBox(height: 24),
                  CustomTextField(
                    label: 'Notes (Optional)',
                    hint: 'How are you feeling?',
                    controller: _notesController,
                    maxLines: 3,
                    minLines: 3,
                    prefixIcon: const Icon(Icons.note_alt_rounded, size: 28),
                  ),
                  const SizedBox(height: 32),
                  AppButton(
                    label: 'Save Weight',
                    isLoading: _isLoading,
                    onPressed: _logWeight,
                    width: double.infinity,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),

            // WEIGHT HISTORY
            Text(
              'Weight History',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
            ),
            const SizedBox(height: 16),
            weightHistoryAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => _buildErrorCard(context, 'Error loading history. Tap to retry.', onTap: () {
                ref.invalidate(weightHistoryProvider);
              }),
              data: (history) {
                if (history.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.veryLightGrey,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Center(
                      child: Text(
                        'No history available',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: history.length,
                  itemBuilder: (context, index) {
                    final record = history[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: const [
                          BoxShadow(color: AppColors.softShadow, blurRadius: 16, offset: Offset(0, 4)),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.secondaryContainer,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.monitor_weight_rounded, color: AppColors.secondary, size: 28),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${record.weightKg} kg',
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                        fontWeight: FontWeight.w900,
                                        color: AppColors.textPrimary,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  record.recordedDate.toString().split(' ')[0],
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: AppColors.textSecondary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.veryLightGrey,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'BMI: ${record.bmi?.toStringAsFixed(1) ?? "--"}',
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorCard(BuildContext context, String message, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.error.withOpacity(0.1),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.error.withOpacity(0.5), width: 2),
        ),
        child: Row(
          children: [
            const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: AppColors.error,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
