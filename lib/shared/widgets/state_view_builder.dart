import 'package:cute_pet/core/error/failures.dart';
import 'package:cute_pet/l10n/app_localizations.dart';
import 'package:cute_pet/shared/widgets/view_state.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class StateViewBuilder<T> extends StatelessWidget {
  const StateViewBuilder({
    required this.state,
    required this.onData,
    this.loading,
    this.empty,
    this.onError,
    this.onRetry,
    super.key,
  });

  final Rx<ViewState<T>> state;
  final Widget Function(T data) onData;
  final Widget? loading;
  final Widget? empty;
  final Widget Function(Failure failure)? onError;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final value = state.value;
      return switch (value) {
        Loading<T>() => loading ?? const _DefaultLoading(),
        Empty<T>() => empty ?? const _DefaultEmpty(),
        ErrorState<T>(:final failure) =>
          onError?.call(failure) ??
              _DefaultError(failure: failure, onRetry: onRetry),
        Data<T>(:final data) => onData(data),
      };
    });
  }
}

class _DefaultLoading extends StatelessWidget {
  const _DefaultLoading();

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

class _DefaultEmpty extends StatelessWidget {
  const _DefaultEmpty();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Text(
        l10n.commonEmpty,
        style: Theme.of(context).textTheme.bodyLarge,
      ),
    );
  }
}

class _DefaultError extends StatelessWidget {
  const _DefaultError({required this.failure, this.onRetry});

  final Failure failure;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 12),
          Text(failure.message, textAlign: TextAlign.center),
          if (failure.traceId != null) ...[
            const SizedBox(height: 4),
            Text(
              'traceId: ${failure.traceId}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
          if (onRetry != null) ...[
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: Text(l10n.commonRetry)),
          ],
        ],
      ),
    );
  }
}
