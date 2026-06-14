// lib/core/utils/permission_helper.dart

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../theme/app_colors.dart';

class PermissionHelper {
  /// Request Notification Permission (Required for Android 13+ and iOS)
  static Future<bool> requestNotificationPermission(BuildContext context) async {
    final status = await Permission.notification.status;
    
    if (status.isGranted) {
      return true;
    }

    // Explicitly request permission
    final result = await Permission.notification.request();
    
    if (result.isGranted) {
      return true;
    }

    if (result.isPermanentlyDenied) {
      if (context.mounted) {
        _showSettingsDialog(
          context: context,
          title: 'Notifications Disabled',
          message: 'Medication reminders and alerts require notifications. Please enable them in your device settings.',
        );
      }
      return false;
    }

    return false;
  }

  /// Request Camera Permission (Required for scanning prescription labels)
  static Future<bool> requestCameraPermission(BuildContext context) async {
    final status = await Permission.camera.status;
    
    if (status.isGranted) {
      return true;
    }

    final result = await Permission.camera.request();
    
    if (result.isGranted) {
      return true;
    }

    if (result.isPermanentlyDenied) {
      if (context.mounted) {
        _showSettingsDialog(
          context: context,
          title: 'Camera Access Disabled',
          message: 'Scanning prescription labels requires camera access. Please enable it in your device settings.',
        );
      }
      return false;
    }

    return false;
  }

  /// Request Photos / Gallery Permission (For uploading avatar images)
  static Future<bool> requestPhotosPermission(BuildContext context) async {
    // Android 13+ uses Permission.photos, while Android 12 and below uses Permission.storage
    final Permission photoPermission = Permission.photos;
    
    final status = await photoPermission.status;
    if (status.isGranted) {
      return true;
    }

    final result = await photoPermission.request();
    
    if (result.isGranted) {
      return true;
    }

    // Fallback check for older storage permission if Permission.photos is not applicable
    final storageStatus = await Permission.storage.status;
    if (storageStatus.isGranted) {
      return true;
    }
    
    final storageResult = await Permission.storage.request();
    if (storageResult.isGranted) {
      return true;
    }

    if (result.isPermanentlyDenied || storageResult.isPermanentlyDenied) {
      if (context.mounted) {
        _showSettingsDialog(
          context: context,
          title: 'Photo Gallery Access Disabled',
          message: 'Uploading a profile picture requires photo library access. Please enable it in your device settings.',
        );
      }
      return false;
    }

    return false;
  }

  /// Reusable Settings Dialog
  static void _showSettingsDialog({
    required BuildContext context,
    required String title,
    required String message,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          backgroundColor: AppColors.white,
          title: Row(
            children: [
              const Icon(Icons.settings_suggest_rounded, color: AppColors.primary, size: 28),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20),
              ),
            ],
          ),
          content: Text(
            message,
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
              height: 1.4,
              fontWeight: FontWeight.w500,
            ),
          ),
          actionsPadding: const EdgeInsets.only(bottom: 16, right: 16, left: 16),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                openAppSettings();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                elevation: 0,
              ),
              child: const Text(
                'Open Settings',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
