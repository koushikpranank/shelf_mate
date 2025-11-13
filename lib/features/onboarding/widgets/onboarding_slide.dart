import 'package:flutter/material.dart';

class OnboardingSlide extends StatelessWidget {
  final String imageAsset;
  final String title;
  final String description;

  const OnboardingSlide({
    super.key,
    required this.imageAsset,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(child: Image.asset(imageAsset)),
          const SizedBox(height: 32),
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          Text(
            description,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }
}
