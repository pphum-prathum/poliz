// lib/styles/styles.dart
import 'package:flutter/material.dart';
import 'app_theme.dart';

class DarkCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final bool border;
  const DarkCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpace.l),
    this.margin,
    this.border = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: const BorderRadius.all(AppRadii.lg),
        border: border ? Border.all(color: AppColors.sky, width: 1.1) : null,
        boxShadow: AppShadows.soft,
      ),
      child: Padding(
        padding: padding,
        // 👇 Wrap child with DefaultTextStyle to make all text inside white
        child: DefaultTextStyle(
          style: const TextStyle(color: Colors.white),
          child: child,
        ),
      ),
    );
  }
}

class AppBadge extends StatelessWidget {
  final String text;
  final Color color;
  const AppBadge(this.text, {super.key, this.color = AppColors.danger});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.all(AppRadii.pill),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String text;
  final Color? color;
  const SectionTitle(this.text, {this.color, super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context)
          .textTheme
          .titleMedium
          ?.copyWith(
        fontWeight: FontWeight.bold,
        color: color ?? AppColors.textPrimary,
      ),
    );
  }
}

/// Quick spacing helpers
const gap8 = SizedBox(height: 8);
const gap12 = SizedBox(height: 12);
const gap16 = SizedBox(height: 16);
const gap20 = SizedBox(height: 20);
