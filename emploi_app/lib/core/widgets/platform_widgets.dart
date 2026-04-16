import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class PlatformWidgets {
  static bool get isIOS => Platform.isIOS;

  static Widget adaptiveSwitch({
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    if (isIOS) {
      return CupertinoSwitch(value: value, onChanged: onChanged);
    }
    return Switch(value: value, onChanged: onChanged);
  }

  static Future<bool?> adaptiveDialog({
    required BuildContext context,
    required String title,
    required String content,
    String confirmText = 'OK',
    String cancelText = 'Annuler',
    bool isDestructive = false,
  }) async {
    if (isIOS) {
      return showCupertinoDialog<bool>(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.pop(context, false),
              child: Text(cancelText),
            ),
            CupertinoDialogAction(
              isDestructiveAction: isDestructive,
              onPressed: () => Navigator.pop(context, true),
              child: Text(confirmText),
            ),
          ],
        ),
      );
    }
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(cancelText),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: isDestructive
                ? TextButton.styleFrom(foregroundColor: Colors.red)
                : null,
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }

  static Widget adaptiveButton({
    required VoidCallback onPressed,
    required Widget child,
    bool isDestructive = false,
    bool isFilled = true,
  }) {
    if (isIOS) {
      return CupertinoButton(onPressed: onPressed, child: child);
    }
    if (isFilled) {
      return ElevatedButton(onPressed: onPressed, child: child);
    }
    return TextButton(onPressed: onPressed, child: child);
  }

  static Widget adaptiveIconButton({
    required IconData icon,
    required VoidCallback onPressed,
    Color? color,
    double? size,
  }) {
    if (isIOS) {
      return CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: onPressed,
        child: Icon(icon, color: color, size: size),
      );
    }
    return IconButton(
      icon: Icon(icon),
      onPressed: onPressed,
      color: color,
      iconSize: size,
    );
  }

  static Widget adaptiveLoader({Color? color}) {
    if (isIOS) {
      return CupertinoActivityIndicator(color: color);
    }
    return CircularProgressIndicator(color: color);
  }

  static void showSnackBar(
    BuildContext context,
    String message, {
    bool isError = false,
  }) {
    if (isIOS) {
      showCupertinoModalPopup(
        context: context,
        builder: (context) => Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isError ? Colors.red : Colors.green,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(message, style: const TextStyle(color: Colors.white)),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? Colors.red : null,
        ),
      );
    }
  }
}
