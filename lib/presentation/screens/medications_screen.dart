// lib/presentation/screens/medications_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutricare_elderly/domain/entities/medication_entity.dart';
import 'package:nutricare_elderly/domain/entities/medication_log_entity.dart';
import 'package:nutricare_elderly/presentation/providers/medication_provider.dart';
import 'package:nutricare_elderly/presentation/providers/repository_providers.dart';
import 'package:nutricare_elderly/presentation/providers/auth_provider.dart';
import 'package:nutricare_elderly/theme/app_colors.dart';
import 'package:nutricare_elderly/presentation/widgets/app_button.dart';
import 'package:nutricare_elderly/presentation/widgets/custom_text_field.dart';
import 'package:nutricare_elderly/presentation/widgets/loading_widget.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nutricare_elderly/core/services/ocr_service.dart';
import 'package:nutricare_elderly/core/utils/permission_helper.dart';
import 'package:intl/intl.dart';

class ScheduledPill {
  final MedicationEntity medication;
  final String reminderTime;
  final String slotType; // 'morning', 'afternoon', 'evening', 'general'

  ScheduledPill({
    required this.medication,
    required this.reminderTime,
    required this.slotType,
  });
}

class MedicationsScreen extends ConsumerStatefulWidget {
  const MedicationsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<MedicationsScreen> createState() => _MedicationsScreenState();
}

class _MedicationsScreenState extends ConsumerState<MedicationsScreen> {
  String _selectedTab = 'pillbox'; // 'pillbox' or 'all'
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      if (mounted) {
        PermissionHelper.requestNotificationPermission(context);
      }
    });
  }

  List<DateTime> _getWeekDays() {
    final now = DateTime.now();
    final firstDayOfWeek = now.subtract(Duration(days: now.weekday - 1));
    return List.generate(7, (index) => firstDayOfWeek.add(Duration(days: index)));
  }

  int? _parseHour(String timeStr) {
    try {
      final parts = timeStr.split(':');
      return int.parse(parts[0]);
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final medicationsAsync = ref.watch(userMedicationsProvider);
    final logsAsync = ref.watch(medicationLogsProvider(_selectedDate));

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: Text(
          'My Medications',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
        ),
        backgroundColor: AppColors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Elegant Soft-UI Segment Switcher
          _buildSegmentSwitcher(),
          const SizedBox(height: 12),
          
          Expanded(
            child: _selectedTab == 'pillbox'
                ? _buildPillboxView(medicationsAsync, logsAsync)
                : _buildAllMedsView(medicationsAsync, logsAsync),
          ),
        ],
      ),
      floatingActionButton: _selectedTab == 'all'
          ? FloatingActionButton.extended(
              onPressed: () => _showAddMedicationDialog(context),
              backgroundColor: AppColors.primary,
              icon: const Icon(Icons.add, color: AppColors.white),
              label: const Text(
                'Add Medication',
                style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
              ),
            )
          : null,
    );
  }

  Widget _buildSegmentSwitcher() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(
              color: AppColors.softShadow,
              blurRadius: 16,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedTab = 'pillbox'),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: _selectedTab == 'pillbox' ? AppColors.primaryContainer : AppColors.transparent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Text(
                      '💊 Pillbox Plan',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: _selectedTab == 'pillbox' ? AppColors.primary : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedTab = 'all'),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: _selectedTab == 'all' ? AppColors.primaryContainer : AppColors.transparent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Text(
                      '⚙️ All Meds',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: _selectedTab == 'all' ? AppColors.primary : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDayPicker() {
    final weekDays = _getWeekDays();
    return Container(
      height: 90,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: weekDays.length,
        itemBuilder: (context, index) {
          final date = weekDays[index];
          final isSelected = date.year == _selectedDate.year &&
              date.month == _selectedDate.month &&
              date.day == _selectedDate.day;
          final isToday = date.year == DateTime.now().year &&
              date.month == DateTime.now().month &&
              date.day == DateTime.now().day;
          
          final weekdayStr = DateFormat('E').format(date).substring(0, 1);
          final dayNumberStr = DateFormat('d').format(date);

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: GestureDetector(
              onTap: () => setState(() => _selectedDate = date),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 60,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary
                      : isToday
                          ? AppColors.primaryContainer.withOpacity(0.4)
                          : AppColors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : isToday
                            ? AppColors.primary
                            : AppColors.transparent,
                    width: 2,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.softShadow,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      weekdayStr,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? AppColors.white : AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dayNumberStr,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: isSelected ? AppColors.white : AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPillboxView(AsyncValue<List<MedicationEntity>> medicationsAsync, AsyncValue<List<MedicationLogEntity>> logsAsync) {
    return Column(
      children: [
        _buildDayPicker(),
        Expanded(
          child: medicationsAsync.when(
            loading: () => const Center(child: LoadingWidget()),
            error: (e, _) => Center(child: Text('Error: $e')),
            data: (medications) {
              if (medications.isEmpty) {
                return _buildEmptyState();
              }

              return logsAsync.when(
                loading: () => const Center(child: LoadingWidget()),
                error: (e, _) => Center(child: Text('Error: $e')),
                data: (logs) {
                  final morningPills = <ScheduledPill>[];
                  final afternoonPills = <ScheduledPill>[];
                  final eveningPills = <ScheduledPill>[];
                  final generalPills = <ScheduledPill>[];

                  for (final med in medications) {
                    if (!med.active) continue;
                    
                    if (med.reminderTimes.isEmpty) {
                      generalPills.add(ScheduledPill(
                        medication: med,
                        reminderTime: 'As Needed',
                        slotType: 'general',
                      ));
                    } else {
                      for (final time in med.reminderTimes) {
                        final hour = _parseHour(time);
                        if (hour == null) {
                          generalPills.add(ScheduledPill(
                            medication: med,
                            reminderTime: time,
                            slotType: 'general',
                          ));
                        } else if (hour >= 6 && hour < 12) {
                          morningPills.add(ScheduledPill(
                            medication: med,
                            reminderTime: time,
                            slotType: 'morning',
                          ));
                        } else if (hour >= 12 && hour < 18) {
                          afternoonPills.add(ScheduledPill(
                            medication: med,
                            reminderTime: time,
                            slotType: 'afternoon',
                          ));
                        } else {
                          eveningPills.add(ScheduledPill(
                            medication: med,
                            reminderTime: time,
                            slotType: 'evening',
                          ));
                        }
                      }
                    }
                  }

                  morningPills.sort((a, b) => a.reminderTime.compareTo(b.reminderTime));
                  afternoonPills.sort((a, b) => a.reminderTime.compareTo(b.reminderTime));
                  eveningPills.sort((a, b) => a.reminderTime.compareTo(b.reminderTime));

                  return ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    physics: const BouncingScrollPhysics(),
                    children: [
                      _buildCompartmentSection(
                        title: 'Morning Plan 🌅',
                        subtitle: '6:00 AM - 12:00 PM',
                        pills: morningPills,
                        logs: logs,
                        color: Colors.orange.shade600,
                        bgColor: Colors.orange.shade50,
                      ),
                      const SizedBox(height: 24),
                      _buildCompartmentSection(
                        title: 'Afternoon Plan ☀️',
                        subtitle: '12:00 PM - 6:00 PM',
                        pills: afternoonPills,
                        logs: logs,
                        color: Colors.blue.shade600,
                        bgColor: Colors.blue.shade50,
                      ),
                      const SizedBox(height: 24),
                      _buildCompartmentSection(
                        title: 'Evening & Night Plan 🌙',
                        subtitle: '6:00 PM - 6:00 AM',
                        pills: eveningPills,
                        logs: logs,
                        color: Colors.indigo.shade600,
                        bgColor: Colors.indigo.shade50,
                      ),
                      if (generalPills.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        _buildCompartmentSection(
                          title: 'As Needed & General 💊',
                          subtitle: 'No specific time scheduled',
                          pills: generalPills,
                          logs: logs,
                          color: Colors.teal.shade600,
                          bgColor: Colors.teal.shade50,
                        ),
                      ],
                    ],
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCompartmentSection({
    required String title,
    required String subtitle,
    required List<ScheduledPill> pills,
    required List<MedicationLogEntity> logs,
    required Color color,
    required Color bgColor,
  }) {
    final takenCount = pills.where((p) => logs.any((l) => l.medicationId == p.medication.id)).length;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: AppColors.softShadow,
            blurRadius: 20,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: color,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$takenCount/${pills.length} Taken',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (pills.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'No medications scheduled.',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textSecondary.withOpacity(0.5),
                  fontStyle: FontStyle.italic,
                ),
              ),
            )
          else
            Column(
              children: pills.map((pill) {
                final isTaken = logs.any((l) => l.medicationId == pill.medication.id);
                return _buildPillRow(pill, isTaken);
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildPillRow(ScheduledPill pill, bool isTaken) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.scaffoldBackground,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isTaken ? AppColors.success.withOpacity(0.3) : AppColors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isTaken
                    ? AppColors.success.withOpacity(0.1)
                    : AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.circle_notifications_rounded,
                color: isTaken ? AppColors.success : AppColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pill.medication.medicationName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${pill.medication.dosage ?? "No Dosage"} • ⏰ ${pill.reminderTime}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () async {
                final repository = ref.read(medicationLogRepositoryProvider);
                if (isTaken) {
                  final result = await repository.deleteMedicationLog(
                    medicationId: pill.medication.id,
                    date: _selectedDate,
                  );
                  
                  result.when(
                    success: (_) {
                      ref.invalidate(medicationLogsProvider(_selectedDate));
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Removed taken log for ${pill.medication.medicationName} 🛑'),
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: AppColors.textSecondary,
                          ),
                        );
                      }
                    },
                    failure: (error) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Failed to remove log: ${error.userMessage}'),
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: AppColors.error,
                          ),
                        );
                      }
                    },
                  );
                } else {
                  final now = DateTime.now();
                  final takenAt = DateTime(
                    _selectedDate.year,
                    _selectedDate.month,
                    _selectedDate.day,
                    now.hour,
                    now.minute,
                    now.second,
                  );
                  final result = await repository.logMedication(
                    medicationId: pill.medication.id,
                    status: 'taken',
                    takenAt: takenAt,
                  );
                  
                  result.when(
                    success: (_) {
                      ref.invalidate(medicationLogsProvider(_selectedDate));
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Logged ${pill.medication.medicationName} as taken! 💊'),
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: AppColors.success,
                          ),
                        );
                      }
                    },
                    failure: (error) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Failed to log: ${error.userMessage}'),
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: AppColors.error,
                          ),
                        );
                      }
                    },
                  );
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: isTaken ? AppColors.success : AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isTaken ? AppColors.success : AppColors.textSecondary.withOpacity(0.3),
                    width: 2,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.softShadow,
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  isTaken ? Icons.check_rounded : Icons.radio_button_unchecked_rounded,
                  color: isTaken ? AppColors.white : AppColors.textSecondary,
                  size: 28,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAllMedsView(AsyncValue<List<MedicationEntity>> medicationsAsync, AsyncValue<List<MedicationLogEntity>> logsAsync) {
    return medicationsAsync.when(
      loading: () => const Center(child: LoadingWidget()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (medications) {
        if (medications.isEmpty) {
          return _buildEmptyState();
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          physics: const BouncingScrollPhysics(),
          itemCount: medications.length,
          itemBuilder: (context, index) {
            final med = medications[index];
            return _buildMedicationCard(med);
          },
        );
      },
    );
  }

  Widget _buildMedicationCard(MedicationEntity med) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: AppColors.scaffoldBackground, width: 2),
      ),
      color: AppColors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    med.medicationName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 28),
                  onPressed: () => _confirmDelete(med),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.scaffoldBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Dosage: ${med.dosage ?? "Not set"}',
                style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.scaffoldBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Frequency: ${med.frequency ?? "Not set"}',
                style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
            ),
            const SizedBox(height: 16),
            const Divider(height: 1, thickness: 1.5),
            const SizedBox(height: 16),
            Row(
              children: const [
                Icon(Icons.notifications_active_outlined, size: 20, color: AppColors.secondary),
                const SizedBox(width: 8),
                Text(
                  'Reminder Times:',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: med.reminderTimes.map((time) => Chip(
                label: Text(time),
                backgroundColor: AppColors.primaryContainer,
                labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: AppColors.primary),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                side: BorderSide.none,
              )).toList(),
            ),
            if (med.reminderTimes.isEmpty)
              const Text(
                'No reminders set',
                style: TextStyle(fontStyle: FontStyle.italic, color: AppColors.textSecondary),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.medication_outlined, size: 80, color: AppColors.primary),
            ),
            const SizedBox(height: 24),
            Text(
              'No Medications Yet',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                  ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Tap the button below to scan or add medications and construct your custom physical visual pillbox.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 32),
            AppButton(
              label: 'Add First Medication',
              onPressed: () => _showAddMedicationDialog(context),
              width: 240,
            ),
          ],
        ),
      ),
    );
  }

  void _showAddMedicationDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => const _AddMedicationForm(),
    );
  }

  void _confirmDelete(MedicationEntity med) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: const Text('Delete Medication', style: TextStyle(fontWeight: FontWeight.w900)),
        content: Text('Are you sure you want to remove ${med.medicationName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () async {
              await ref.read(medicationRepositoryProvider).removeMedication(med.id);
              ref.invalidate(userMedicationsProvider);
              if (mounted) Navigator.pop(context);
            },
            child: const Text('DELETE', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

class _AddMedicationForm extends ConsumerStatefulWidget {
  const _AddMedicationForm({Key? key}) : super(key: key);

  @override
  ConsumerState<_AddMedicationForm> createState() => _AddMedicationFormState();
}

class _AddMedicationFormState extends ConsumerState<_AddMedicationForm> {
  final _nameController = TextEditingController();
  final _dosageController = TextEditingController();
  final _frequencyController = TextEditingController();
  final List<String> _reminderTimes = [];
  bool _isSaving = false;
  bool _isScanning = false;
  final _ocrService = OcrService();
  final _imagePicker = ImagePicker();

  static const List<String> _frequencies = [
    'Once daily',
    'Twice daily',
    'Three times daily',
    'Four times daily',
    'As needed',
    'Custom'
  ];

  String _selectedFrequency = 'Once daily';

  @override
  void initState() {
    super.initState();
    _selectedFrequency = 'Once daily';
    _frequencyController.text = _selectedFrequency;
    _updateRemindersForFrequency(_selectedFrequency);
  }

  void _updateRemindersForFrequency(String freq) {
    setState(() {
      _reminderTimes.clear();
      if (freq == 'Once daily') {
        _reminderTimes.addAll(['08:00']);
      } else if (freq == 'Twice daily') {
        _reminderTimes.addAll(['08:00', '20:00']);
      } else if (freq == 'Three times daily') {
        _reminderTimes.addAll(['08:00', '14:00', '20:00']);
      } else if (freq == 'Four times daily') {
        _reminderTimes.addAll(['08:00', '12:00', '16:00', '20:00']);
      }
      _reminderTimes.sort();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    _frequencyController.dispose();
    _ocrService.dispose();
    super.dispose();
  }

  Future<void> _scanLabel() async {
    final hasPermission = await PermissionHelper.requestCameraPermission(context);
    if (!hasPermission) return;

    try {
      final XFile? image = await _imagePicker.pickImage(source: ImageSource.camera);
      if (image == null) return;

      setState(() => _isScanning = true);
      
      final result = await _ocrService.processImage(image.path);
      
      if (result.likelyName != null && _nameController.text.isEmpty) {
        _nameController.text = result.likelyName!;
      }
      if (result.likelyDosage != null && _dosageController.text.isEmpty) {
        _dosageController.text = result.likelyDosage!;
      }
      
    } catch (e) {
      debugPrint('Scan Error: $e');
    } finally {
      if (mounted) setState(() => _isScanning = false);
    }
  }

  void _addTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (time != null) {
      setState(() {
        final timeStr = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
        if (!_reminderTimes.contains(timeStr)) {
          _reminderTimes.add(timeStr);
          _reminderTimes.sort();
        }
      });
    }
  }

  Future<void> _save() async {
    if (_nameController.text.isEmpty) return;

    setState(() => _isSaving = true);
    final user = await ref.read(userProvider.future);
    
    if (user != null) {
      await ref.read(medicationRepositoryProvider).addMedication(
        userId: user.id,
        medicationName: _nameController.text.trim(),
        dosage: _dosageController.text.trim(),
        frequency: _frequencyController.text.trim(),
        reminderTimes: _reminderTimes,
      );
      ref.invalidate(userMedicationsProvider);
      if (mounted) Navigator.pop(context);
    }
    setState(() => _isSaving = false);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 24,
        right: 24,
        top: 24,
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add New Medication',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 20),
            
            if (_isScanning)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: LoadingWidget(),
                ),
              )
            else
              AppButton(
                label: '📷 Scan Prescription Label',
                onPressed: _scanLabel,
                width: double.infinity,
                height: 60,
              ),
            const SizedBox(height: 24),
            
            CustomTextField(label: 'Medication Name', controller: _nameController, hint: 'e.g. Lisinopril'),
            const SizedBox(height: 16),
            CustomTextField(label: 'Dosage', controller: _dosageController, hint: 'e.g. 10mg'),
            const SizedBox(height: 20),
            
            // Frequency Dropdown
            Text(
              'Frequency',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.softShadow,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: DropdownButtonFormField<String>(
                value: _selectedFrequency,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(color: AppColors.textSecondary.withOpacity(0.2), width: 2),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(color: AppColors.textSecondary.withOpacity(0.2), width: 2),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: const BorderSide(color: AppColors.primary, width: 2),
                  ),
                  fillColor: AppColors.white,
                  filled: true,
                ),
                dropdownColor: AppColors.white,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                items: _frequencies.map((freq) {
                  return DropdownMenuItem<String>(
                    value: freq,
                    child: Text(freq),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _selectedFrequency = val;
                      _frequencyController.text = val;
                    });
                    _updateRemindersForFrequency(val);
                  }
                },
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Reminders',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                ),
                TextButton.icon(
                  onPressed: _addTime,
                  icon: const Icon(Icons.add_alarm_rounded),
                  label: const Text('Add Time', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _reminderTimes.map((time) => InputChip(
                label: Text(time),
                onDeleted: () => setState(() => _reminderTimes.remove(time)),
                deleteIconColor: AppColors.error,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              )).toList(),
            ),
            const SizedBox(height: 32),
            AppButton(
              label: 'Save Medication',
              onPressed: _isSaving ? () {} : _save,
              isLoading: _isSaving,
              width: double.infinity,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
