import 'package:flutter/material.dart';

class LoadingDisplay extends StatelessWidget {
  final String? message;
  final bool isOverlay;

  const LoadingDisplay({super.key, this.message, this.isOverlay = false});

  @override
  Widget build(BuildContext context) {
    final loadingContent = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const CircularProgressIndicator(),
        if (message != null) ...[
          const SizedBox(height: 16),
          Text(
            message!,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );

    if (isOverlay) {
      return Container(
        color: Colors.black54,
        child: Center(child: loadingContent),
      );
    }

    return Center(child: loadingContent);
  }
}
