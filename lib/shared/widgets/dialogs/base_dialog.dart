import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';

class BaseDialog extends StatelessWidget {
  final Widget? icon;
  final String title;
  final Widget? content;
  final List<Widget>? actions;
  final Color? backgroundColor;
  final Gradient? gradient;
  final bool barrierDismissible;
  final EdgeInsetsGeometry? padding;
  final double? maxWidth;
  final double? maxHeight;

  const BaseDialog({
    super.key,
    this.icon,
    required this.title,
    this.content,
    this.actions,
    this.backgroundColor,
    this.gradient,
    this.barrierDismissible = true,
    this.padding,
    this.maxWidth,
    this.maxHeight,
  });

  static Future<T?> show<T>({
    required BuildContext context,
    Widget? icon,
    required String title,
    Widget? content,
    List<Widget>? actions,
    Color? backgroundColor,
    Gradient? gradient,
    bool barrierDismissible = true,
    EdgeInsetsGeometry? padding,
    double? maxWidth,
    double? maxHeight,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => BaseDialog(
        icon: icon,
        title: title,
        content: content,
        actions: actions,
        backgroundColor: backgroundColor,
        gradient: gradient,
        barrierDismissible: barrierDismissible,
        padding: padding,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.largeBorderRadius),
      ),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: maxWidth ?? 400,
          maxHeight: maxHeight ?? MediaQuery.of(context).size.height * 0.8,
        ),
        padding: padding ?? const EdgeInsets.all(AppConstants.largePadding),
        decoration: BoxDecoration(
          color: backgroundColor,
          gradient: gradient ??
              LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppConstants.backgroundColor,
                  AppConstants.backgroundColor.withOpacity(0.9),
                ],
              ),
          borderRadius: BorderRadius.circular(AppConstants.largeBorderRadius),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              icon!,
              const SizedBox(height: AppConstants.largeSpacing),
            ],
            Text(
              title,
              style: const TextStyle(
                fontSize: AppConstants.headingFontSize,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            if (content != null) ...[
              const SizedBox(height: AppConstants.largeSpacing),
              Flexible(child: content!),
            ],
            if (actions != null && actions!.isNotEmpty) ...[
              const SizedBox(height: AppConstants.largePadding),
              Row(
                mainAxisAlignment: actions!.length == 1
                    ? MainAxisAlignment.center
                    : MainAxisAlignment.spaceEvenly,
                children: actions!,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class DialogButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final bool isPrimary;
  final IconData? icon;
  final bool isDestructive;

  const DialogButton({
    super.key,
    required this.text,
    this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.isPrimary = false,
    this.icon,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    Color btnColor = backgroundColor ??
        (isDestructive
            ? AppConstants.errorColor
            : isPrimary
                ? AppConstants.primaryColor
                : Colors.grey);

    Color btnTextColor = textColor ??
        (isPrimary || isDestructive ? Colors.white : Colors.black87);

    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: btnColor,
        foregroundColor: btnTextColor,
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.largePadding,
          vertical: AppConstants.padding,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        ),
        elevation: 3,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon!, size: 20),
            const SizedBox(width: AppConstants.spacing),
          ],
          Text(
            text,
            style: const TextStyle(
              fontSize: AppConstants.bodyFontSize,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
