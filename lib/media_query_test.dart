import 'package:flutter/material.dart';
import 'package:test_app/media_query_helper.dart';

class MediaQueryTest extends StatelessWidget {
  const MediaQueryTest({super.key});

  @override
  Widget build(BuildContext context) {
    return const TextScaleExample();
  }
}

class SafeAreaExample extends StatelessWidget {
  const SafeAreaExample({super.key});

  @override
  Widget build(BuildContext context) {
    EdgeInsets padding = MediaQuery.paddingOf(context);
    print("Padding: $padding");
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.only(
          top: padding.top, // Top padding for notch
          bottom: padding.bottom, // Bottom padding for gesture navigation
        ),
        child: Column(
          children: [
            const Text("Content with Safe Area"),
            Padding(
              padding: EdgeInsets.only(top: padding.top),
              child: Text("Content with Safe Area"),
            ),
            const Text("Content with Safe Area"),
          ],
        ),
      ),
    );
  }
}

class MediaQueryHelperExample extends StatelessWidget {
  const MediaQueryHelperExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("MediaQueryHelper Example")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Screen Width: ${MediaQueryHelper.getScreenWidth(context)}"),
            Text("Screen Height: ${MediaQueryHelper.getScreenHeight(context)}"),
            Text("Is Portrait: ${MediaQueryHelper.isPortrait(context)}"),
            Text(
                "Device Pixel Ratio: ${MediaQueryHelper.getDevicePixelRatio(context)}"),
            SizedBox(height: MediaQueryHelper.scaleHeight(context, 20)),
            Container(
              width: MediaQueryHelper.scaleWidth(context, 150),
              height: MediaQueryHelper.scaleHeight(context, 50),
              color: Colors.blue,
              child: Center(
                child: Text(
                  "Scaled Box",
                  style: TextStyle(
                      fontSize: MediaQueryHelper.scaleWidth(context, 16),
                      color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TextScaleExample extends StatelessWidget {
  const TextScaleExample({super.key});

  @override
  Widget build(BuildContext context) {
    // Retrieve the current text scale factor
    final double textScale = MediaQueryHelper.getTextScaleFactor(context);
    double limitedScale = textScale.clamp(1.0, 1.5);

    return Scaffold(
      appBar: AppBar(title: Text("Text Scale Factor Example")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Normal Text",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              "Scaled Text",
              style: TextStyle(fontSize: 16 * textScale),
            ),
            SizedBox(height: 16),
            Text(
              "Text Scale Factor: $textScale",
              style: TextStyle(fontSize: 14),
            ),
            Text(
              "Limited Scaled Text",
              style: TextStyle(fontSize: 16 * limitedScale),
            )
          ],
        ),
      ),
    );
  }
}
