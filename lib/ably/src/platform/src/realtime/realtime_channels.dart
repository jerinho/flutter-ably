import '../../../../ably_flutter.dart';
import '../../../../src/platform/platform_internal.dart';
import 'package:meta/meta.dart';

/// A collection of realtime channel objects
///
/// https://docs.ably.com/client-lib-development-guide/features/#RTS1
class RealtimeChannels extends Channels<RealtimeChannel> {
  /// instance of ably realtime client
  Realtime realtime;

  /// instantiates with the ably [Realtime] instance
  RealtimeChannels(this.realtime);

  @override
  @protected
  RealtimeChannel createChannel(String name) => RealtimeChannel(realtime, name);

  /// Detaches the channel and then releases the channel resource
  /// so it can be garbage collected.
  @override
  void release(String name) {
    realtime.invoke<void>(PlatformMethod.releaseRealtimeChannel, {
      TxTransportKeys.channelName: name,
    });
    super.release(name);
  }
}
