import 'dart:io' as io show Platform;
import '../../../ably_flutter.dart';
import '../../../src/platform/platform_internal.dart';
import 'package:meta/meta.dart';

/// Class providing push notification functionality
///
/// https://docs.ably.com/client-lib-development-guide/features/#RSH1
class Push extends PlatformObject {
  /// An instance to access activation events related to push, such as device
  /// activation, deactivation and notification permissions.
  static PushActivationEvents activationEvents = PushActivationEventsInternal();

  /// An instance to access message events related to push
  static PushNotificationEvents notificationEvents =
      PushNotificationEventsInternal();

  /// A rest client used platform side to invoke push notification methods
  final Rest? rest;

  /// A realtime client used platform side to invoke push notification methods
  final Realtime? realtime;

  /// Pass an Ably realtime or rest client.
  Push({
    this.realtime,
    this.rest,
  }) : super() {
    final ablyClientNotPresent = rest == null && realtime == null;
    final moreThanOneAblyClientPresent = rest != null && realtime != null;
    if (ablyClientNotPresent || moreThanOneAblyClientPresent) {
      throw Exception(
          'Specify one Ably client when creating ${(Push).toString()}.');
    }
  }

  /// Activate this device for push notifications by registering
  /// with the push transport such as FCM/APNs.
  ///
  /// In the case of network issues, this method will not complete until
  /// network connection is recovered. If the device is
  /// restarted, the results will still be returned by
  /// [PushActivationEvents.onActivate]
  ///
  /// throws: AblyException when the server returns an error.
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RSH2a
  Future<void> activate() => invoke(PlatformMethod.pushActivate);

  /// Request permission from the user to show them notifications. This is
  /// required to show user notifications. Otherwise, notifications may
  /// silently get received by the application.
  ///
  /// This always returns true on Android, since you don't need permissions
  /// to show notifications to the user.
  ///
  /// @param badge The ability to update the app’s badge.
  /// @param sound The ability to play sounds.
  /// @param alert The ability to display alerts.
  /// @param carPlay The ability to display notifications in a CarPlay
  ///   environment.
  /// @param criticalAlerts ignore the mute switch and Do Not Disturb. iOS 12+
  ///   and requires a special entitlement issued by Apple.
  /// @param providesAppNotificationSettings An option indicating the system
  ///   should display a button for in-app notification settings. iOS 12+
  /// @param provisional Send notifications on a trial basis, by delaying
  ///   the permission request until the user first sees the first notification.
  ///   iOS 12+. The notification is first delivered quietly, and the user will
  ///   get an option to deliver it more prominently. If provisional is true,
  ///   the permission request alert will not be shown to the user, regardless
  ///   of other options passed in. For more information, see [Use Provisional Authorization to Send Trial Notifications](https://developer.apple.com/documentation/usernotifications/asking_permission_to_use_notifications?language=objc)
  /// @param announcement The ability for Siri to automatically read out
  ///   messages over AirPods. iOS 13+. Deprecated in iOS 15+, because it is
  ///   automatically/ always granted.
  /// @returns bool Permission was granted.
  ///
  /// [Apple docs](https://developer.apple.com/documentation/usernotifications/unusernotificationcenter/1649527-requestauthorization)
  Future<bool> requestPermission({
    bool alert = true,
    bool announcement = true,
    bool badge = true,
    bool carPlay = true,
    bool criticalAlert = false,
    bool providesAppNotificationSettings = false,
    bool provisional = false,
    bool sound = true,
  }) async {
    if (io.Platform.isIOS) {
      return invokeRequest<bool>(PlatformMethod.pushRequestPermission, {
        TxPushRequestPermission.alert: alert,
        TxPushRequestPermission.announcement: announcement,
        TxPushRequestPermission.badge: badge,
        TxPushRequestPermission.carPlay: carPlay,
        TxPushRequestPermission.criticalAlert: criticalAlert,
        TxPushRequestPermission.providesAppNotificationSettings:
            providesAppNotificationSettings,
        TxPushRequestPermission.provisional: provisional,
        TxPushRequestPermission.sound: sound,
      });
    } else {
      return true;
    }
  }

  /// Gets the iOS notification settings ([UNNotificationSettings]) for
  /// the application.
  ///
  /// [Apple docs](https://developer.apple.com/documentation/usernotifications/unusernotificationcenter/1649524-getnotificationsettings)
  Future<UNNotificationSettings> getNotificationSettings() async {
    if (io.Platform.isIOS) {
      return invokeRequest<UNNotificationSettings>(
          PlatformMethod.pushGetNotificationSettings);
    } else {
      throw UnsupportedError('getNotificationSettings is only valid on iOS.');
    }
  }

  /// Deactivate this device for push notifications by removing
  /// the registration with the push transport such as FCM/APNS.
  ///
  /// In the case or authentication or network issues with Ably, this method
  /// will not complete until these issues are resolved. In the device is
  /// restarted, the results will be returned by
  /// [PushActivationEvents.onDeactivate]
  ///
  /// throws: AblyException
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RSH2b
  Future<void> deactivate() => invoke(PlatformMethod.pushDeactivate);

  /// Resets activation state of Android push device by removing
  /// device data from Android SharedPreferences. After this operation, device
  /// is recognized as a completely new push device and all device data
  /// has to be regenerated with [Push.activate] call
  ///
  /// Warning: This is an experimental method and it's use can lead to
  /// unexpected behavior in Push module
  @experimental
  Future<void> reset() {
    if (io.Platform.isAndroid) {
      return invoke(PlatformMethod.pushReset);
    } else {
      return Future.value();
    }
  }

  @override
  Future<int?> createPlatformInstance() => (realtime != null)
      ? (realtime as Realtime).handle
      : (rest as Rest).handle;
}
