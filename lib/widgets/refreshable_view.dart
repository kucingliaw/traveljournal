import 'package:flutter/material.dart';
import 'package:traveljournal/widgets/error_handler.dart';
import 'package:traveljournal/widgets/loading_handler.dart';
import 'package:traveljournal/widgets/empty_state.dart';

class RefreshableView extends StatelessWidget {
  final Future<void> Function() onRefresh;
  final bool isLoading;
  final String? errorMessage;
  final String? emptyMessage;
  final Widget Function(BuildContext context) builder;
  final VoidCallback? onRetry;

  const RefreshableView({
    super.key,
    required this.onRefresh,
    required this.isLoading,
    required this.builder,
    this.errorMessage,
    this.emptyMessage,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const LoadingDisplay();
    }

    if (errorMessage != null) {
      return ErrorDisplay(
        message: errorMessage!,
        onRetry: onRetry ?? onRefresh,
      );
    }

    if (emptyMessage != null) {
      return EmptyStateDisplay(message: emptyMessage!, icon: Icons.note_add);
    }

    return RefreshIndicator(onRefresh: onRefresh, child: builder(context));
  }
}
