import 'dart:async';

import 'package:flutter/material.dart';

import '../services/app_update_service.dart';

enum _AppUpdateAction { later, updateNow }

class AppUpdateFlow {
  static bool _busy = false;

  static Future<void> check(BuildContext context, {bool manual = false}) async {
    final service = AppUpdateService.instance;
    if (!service.isInAppUpdateSupported || _busy) return;

    _busy = true;
    try {
      final update = await service.checkForUpdate();
      if (!context.mounted) return;

      if (update == null) {
        await service.clearDismissedRelease();
        if (manual && context.mounted) {
          _showSnack(context, 'Already up to date');
        }
        return;
      }

      if (!manual && await service.isReleaseDismissed(update.releaseId)) {
        return;
      }
      if (!context.mounted) return;

      final action = await _showUpdateDialog(context, update);
      if (action != _AppUpdateAction.updateNow) {
        if (!update.force) {
          await service.rememberDismissedRelease(update.releaseId);
        }
        return;
      }

      if (context.mounted) {
        await _downloadAndInstall(context, update);
      }
    } catch (error) {
      if (manual && context.mounted) {
        _showSnack(context, _errorText(error));
      }
    } finally {
      _busy = false;
    }
  }

  static Future<_AppUpdateAction?> _showUpdateDialog(
    BuildContext context,
    AppUpdateInfo update,
  ) {
    return showDialog<_AppUpdateAction>(
      context: context,
      barrierDismissible: !update.force,
      builder: (context) {
        return AlertDialog(
          title: const Text('Update available'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Current: ${update.current.releaseId}'),
              Text('Latest: ${update.releaseId}'),
              if (update.notes.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(update.notes),
              ],
            ],
          ),
          actions: [
            if (!update.force)
              TextButton(
                onPressed: () =>
                    Navigator.of(context).pop(_AppUpdateAction.later),
                child: const Text('Later'),
              ),
            FilledButton(
              onPressed: () =>
                  Navigator.of(context).pop(_AppUpdateAction.updateNow),
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }

  static Future<void> _downloadAndInstall(
    BuildContext context,
    AppUpdateInfo update,
  ) async {
    final progress = ValueNotifier<double?>(null);
    unawaited(
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            title: const Text('Downloading update'),
            content: ValueListenableBuilder<double?>(
              valueListenable: progress,
              builder: (context, value, _) {
                final percent = value == null ? null : (value * 100).round();
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LinearProgressIndicator(value: value),
                    const SizedBox(height: 12),
                    Text(percent == null ? 'Preparing...' : '$percent%'),
                  ],
                );
              },
            ),
          );
        },
      ),
    );

    try {
      final apk = await AppUpdateService.instance.downloadUpdate(
        update,
        onProgress: (received, total) {
          if (total > 0) {
            progress.value = (received / total).clamp(0, 1).toDouble();
          }
        },
      );

      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }
      await AppUpdateService.instance.installDownloaded(apk.path);
    } catch (error) {
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        _showSnack(context, _errorText(error));
      }
    } finally {
      progress.dispose();
    }
  }

  static void _showSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  static String _errorText(Object error) {
    final text = error.toString().replaceFirst('Exception: ', '').trim();
    return text.isEmpty ? 'Update failed' : text;
  }
}
