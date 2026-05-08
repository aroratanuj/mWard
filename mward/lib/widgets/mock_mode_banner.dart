import 'package:flutter/material.dart';
import '../config/mock_config.dart';

class MockModeBanner extends StatefulWidget {
  final Widget child;

  const MockModeBanner({
    super.key,
    required this.child,
  });

  @override
  State<MockModeBanner> createState() => _MockModeBannerState();
}

class _MockModeBannerState extends State<MockModeBanner> {
  bool _isVisible = true;

  @override
  Widget build(BuildContext context) {
    if (!MockConfig.isMockMode || !MockConfig.showMockBanner) {
      return widget.child;
    }

    return Column(
      children: [
        if (_isVisible)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              color: MockConfig.mockModeBannerColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    MockConfig.mockModeBannerText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _isVisible = false;
                    });
                    MockConfig.showMockBanner = false;
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    'Dismiss',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        Expanded(child: widget.child),
      ],
    );
  }
}
