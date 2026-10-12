import 'package:flutter/material.dart';
import '../constants/app_theme.dart';

/// A centered reading column remains comfortable on phones and large displays.
class ReaderWidth extends StatelessWidget {
  const ReaderWidth({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topLeft,
            radius: 1.3,
            colors: [
              Theme.of(context).colorScheme.secondaryContainer,
              Theme.of(context).colorScheme.surface
            ],
          ),
        ),
        child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: child)),
      );
}

class StatusView extends StatelessWidget {
  const StatusView(
      {super.key,
      required this.icon,
      required this.title,
      required this.message,
      this.action});
  final IconData icon;
  final String title;
  final String message;
  final Widget? action;
  @override
  Widget build(BuildContext context) => Center(
          child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.section),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 48, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: AppSpacing.large),
          Text(title,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center),
          const SizedBox(height: AppSpacing.small),
          Text(message, textAlign: TextAlign.center),
          if (action != null)
            Padding(
                padding: const EdgeInsets.only(top: AppSpacing.large),
                child: action),
        ]),
      ));
}

void showReaderMessage(BuildContext context, String message,
    {bool error = false, SnackBarAction? action}) {
  final colors = Theme.of(context).colorScheme;
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      content: Text(message,
          style: Theme.of(context)
              .textTheme
              .bodyMedium!
              .copyWith(color: error ? colors.onError : colors.onPrimary)),
      backgroundColor: error ? colors.error : colors.primary,
      action: action,
      duration: const Duration(seconds: 5),
    ));
}

/// A compact introduction uses the reference's blue glow without imagery.
class ReaderIntro extends StatelessWidget {
  const ReaderIntro(
      {super.key,
      required this.eyebrow,
      required this.title,
      required this.subtitle,
      required this.icon});
  final String eyebrow;
  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.section),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colors.primaryContainer, colors.surfaceContainerLow],
        ),
        borderRadius: BorderRadius.circular(AppSpacing.section),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(icon, color: colors.primary, size: 20),
          const SizedBox(width: AppSpacing.small),
          Expanded(child: Text(eyebrow, style: theme.textTheme.labelSmall)),
        ]),
        const SizedBox(height: AppSpacing.large),
        Text(title, style: theme.textTheme.headlineMedium),
        const SizedBox(height: AppSpacing.small),
        Text(subtitle, style: theme.textTheme.bodyMedium),
      ]),
    );
  }
}

/// Numbered cyan medallions connect posts and favorites visually.
class PostNumber extends StatelessWidget {
  const PostNumber({super.key, required this.id});
  final int id;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 44,
      height: 44,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: FittedBox(
            child: Text('$id',
                style: theme.textTheme.titleMedium!
                    .copyWith(color: theme.colorScheme.onPrimary))),
      ),
    );
  }
}
