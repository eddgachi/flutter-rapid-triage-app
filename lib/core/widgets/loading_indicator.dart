import 'package:flutter/material.dart';

/// Consistent loading spinner for list/section-level async states.
class LoadingIndicator extends StatelessWidget {
  final double padding;

  const LoadingIndicator({super.key, this.padding = 48});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: SizedBox(
          width: 32,
          height: 32,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
    );
  }
}
