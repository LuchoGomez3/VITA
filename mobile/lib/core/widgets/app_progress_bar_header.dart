import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';

/// Header that shows the current step and animated progress.
class StepProgressBar extends StatelessWidget {
  /// Creates a progress header for a multi-step flow.
  const StepProgressBar({
    required this.currentStep,
    required this.totalSteps,
    required this.stepTitle,
    super.key,
  });

  /// One-based current step.
  final int currentStep;

  /// Total number of steps in the flow.
  final int totalSteps;

  /// Short label for the current step.
  final String stepTitle;

  @override
  Widget build(BuildContext context) {
    final targetProgress = currentStep / totalSteps;

    return Container(
      width: double.infinity,
      color: AppColors.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'PASO $currentStep DE $totalSteps',
                  style: AppTypography.mediumEmphasis,
                ),
                Flexible(
                  child: Text(
                    stepTitle,
                    style: AppTypography.smallEmphasis,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          ),

          LayoutBuilder(
            builder: (context, constraints) {
              final availableWidth = constraints.maxWidth;

              return Container(
                width: availableWidth,
                height: 2.5,
                color: Colors.grey.shade200,
                alignment: Alignment.centerLeft,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOut,
                  width: availableWidth * targetProgress,
                  height: 2.5,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
