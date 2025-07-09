import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class ProgressIndicatorWidget extends StatelessWidget {
  final int currentStep;
  final List<String> stepNames;
  final List<IconData> stepIcons;

  const ProgressIndicatorWidget({
    super.key,
    required this.currentStep,
    required this.stepNames,
    required this.stepIcons,
  });

  @override
  Widget build(BuildContext context) {
    final totalSteps = stepNames.length;

    return Column(
      children: [
        // Top Row with Icon + Text
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(totalSteps, (index) {
            final isActive = index == currentStep - 1;
            final isCompleted = index < currentStep - 1;

            return Column(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppColors.primary
                        : Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isCompleted
                          ? AppColors.primary
                          : Colors.grey.shade400,
                    ),
                  ),
                  child: Icon(
                    stepIcons[index],
                    color: isActive || isCompleted
                        ? (isActive ? Colors.white : AppColors.primary)
                        : Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  stepNames[index],
                  style: TextStyle(
                    fontSize: 12,
                    color: isActive
                        ? AppColors.primary
                        : Colors.grey.shade600,
                  ),
                ),
              ],
            );
          }),
        ),

        const SizedBox(height: 16),

        // Bottom Progress Line
        Row(
          children: List.generate(totalSteps, (index) {
            final isFilled = index < currentStep;
            return Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                height: 4,
                decoration: BoxDecoration(
                  color: isFilled
                      ? AppColors.primary
                      : AppColors.accent,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}
