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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Column(
        children: [
          // Progress Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (index) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: 96,
                height: 8,
                decoration: BoxDecoration(
                  color: index < currentStep ? AppColors.primary : AppColors.accent,
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),
          const SizedBox(height: 16),
          // Step Icons and Labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(3, (index) {
              final isActive = index == currentStep - 1;
              final isCompleted = index < currentStep - 1;
              
              return Column(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: isActive || isCompleted 
                          ? AppColors.primary 
                          : AppColors.accent,
                      shape: BoxShape.circle,
                      border: !isActive && !isCompleted 
                          ? Border.all(color: Colors.grey.shade400)
                          : null,
                    ),
                    child: Icon(
                      stepIcons[index],
                      color: isActive || isCompleted 
                          ? Colors.white 
                          : Colors.grey.shade600,
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    stepNames[index],
                    style: TextStyle(
                      fontSize: 12,
                      color: isActive || isCompleted 
                          ? AppColors.primary 
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}