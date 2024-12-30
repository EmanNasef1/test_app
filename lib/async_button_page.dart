import 'package:async_button_handler/async_button_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AsyncButtonPage extends StatelessWidget {
  const AsyncButtonPage({super.key});

  Future<void> asyncOperation() async {
    await Future.delayed(
      const Duration(seconds: 2),
      () => print('Hello world'),
    );
  }

  Future<String> asyncTypedOperation() async {
    return await Future.delayed(
      const Duration(seconds: 2),
      () => 'Hello world',
    );
  }

  void syncOperation() {
    print('Hello world');
  }

  Future<String> getDeviceId() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (defaultTargetPlatform == TargetPlatform.android) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      print("Android ID: ${androidInfo.id}");
      return androidInfo.id ?? "Unknown Android ID";
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      return iosInfo.identifierForVendor ?? "Unknown iOS ID";
    } else {
      return "Unsupported Platform";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Async Button Example')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AsyncButtonHandler<Future<void>>(
              overlayLoading: false,
              onPressed: asyncOperation,
              loadingChild: const CircularProgressIndicator(),
              widget: const Text('Async Button'),
            ),
            const SizedBox(height: 10),
            AsyncButtonHandler<Future<String>>(
              overlayLoading: true,
              onPressed: asyncTypedOperation,
              loadingChild: const CircularProgressIndicator(),
              //     buttonChild: const Text('Typed Async Button'),
            ),
            const SizedBox(height: 10),
            AsyncButtonHandler<void>(
              onPressed: syncOperation,
              loadingChild: const CircularProgressIndicator(),
              //    buttonChild: const Text('Sync Button'),
            ),
            ElevatedButton(
                onPressed: () => getDeviceId(), child: Text("Get Device ID")),
          ],
        ),
      ),
    );
  }
}
