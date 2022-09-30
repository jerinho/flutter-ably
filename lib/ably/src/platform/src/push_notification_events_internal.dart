import 'dart:async';
import 'dart:io' as io show Platform;
import 'dart:ui';

import '../../../ably_flutter.dart';
import '../../../src/platform/platform_internal.dart';

/// package-private implementation of [PushNotificationEvents]
class PushNotificationEventsInternal implements PushNotificationEvents {
  /// Invoked when pushOpenSettingsFor platform method is called
  VoidCallback? onOpenSettingsHandler;

  /// Invoked when pushOnShowNotificationInForeground platform method is called
  Future<bool> Function(RemoteMessage message)?
      onShowNotificationInForegroundHandler;

  /// Exposes stream of received [RemoteMessage] objects
  /// New message is emitted after pushOnMessage platform method is called
  StreamController<RemoteMessage> onMessageStreamController =
      StreamController();

  /// Controller used to indicate notification was tapped
  StreamController<RemoteMessage> onNotificationTapStreamController =
      StreamController();

  BackgroundMessageHandler? _onBackgroundMessage;

  @override
  Future<RemoteMessage?> get notificationTapLaunchedAppFromTerminated =>
      Platform().invokePlatformMethod<RemoteMessage>(
          PlatformMethod.pushNotificationTapLaunchedAppFromTerminated);

  @override
  Stream<RemoteMessage> get onMessage => onMessageStreamController.stream;

  @override
  Stream<RemoteMessage> get onNotificationTap =>
      onNotificationTapStreamController.stream;

  @override
  void setOnOpenSettings(VoidCallback callback) {
    onOpenSettingsHandler = callback;
  }

  @override
  void setOnShowNotificationInForeground(
      Future<bool> Function(RemoteMessage message) callback) {
    onShowNotificationInForegroundHandler = callback;
  }

  /// An internal method that is called from the Platform side to check if the
  /// user wants notifications to be shown when the app is in the foreground.
  Future<bool> showNotificationInForeground(RemoteMessage message) async {
    if (onShowNotificationInForegroundHandler == null) {
      return false;
    }
    return onShowNotificationInForegroundHandler!(message);
  }

  /// Implementation of setOnBackgroundMessage. For more documentation,
  /// see [PushNotificationEvents.setOnBackgroundMessage]
  @override
  Future<void> setOnBackgroundMessage(BackgroundMessageHandler handler) async {
    _onBackgroundMessage = handler;
    if (io.Platform.isAndroid) {
      // Inform Android side that the Flutter application
      // is ready to receive push messages.
      await BackgroundIsolateAndroidPlatform().invokeMethod<void>(
        PlatformMethod.pushBackgroundFlutterApplicationReadyOnAndroid,
      );
    }
  }

  /// Handles a RemoteMessage passed from the platform side.
  void handleBackgroundMessage(RemoteMessage remoteMessage) {
    if (_onBackgroundMessage != null) {
      _onBackgroundMessage!(remoteMessage);
    } else {
      // ignore:avoid_print
      print('Received RemoteMessage but no handler was set. '
          'RemoteMessage.data: ${remoteMessage.data}. '
          'RemoteMessage.notification: ${remoteMessage.notification}. '
          'Set `ably.Push.notificationEvents.setOnBackgroundMessage()`.');
    }
  }

  /// Used to close internal [StreamController] instances
  // FIXME: This method is not called anywhere
  // See: https://github.com/ably/ably-flutter/issues/382
  void close() {
    onMessageStreamController.close();
    onNotificationTapStreamController.close();
  }
}
