import '../../../../ably_flutter.dart';
import '../../../../src/platform/platform_internal.dart';

/// Presence object on a [RestChannel] helps to query Presence members
/// and presence history
///
/// https://docs.ably.com/client-lib-development-guide/features/#RSP1
class RestPresence extends PlatformObject {
  final RestChannel _restChannel;

  /// instantiates with a channel
  RestPresence(this._restChannel);

  @override
  Future<int> createPlatformInstance() => _restChannel.rest.handle;

  /// Obtain the set of members currently present for a channel.
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RSP3
  Future<PaginatedResult<PresenceMessage>> get([
    RestPresenceParams? params,
  ]) async {
    final message = await invokeRequest<AblyMessage<dynamic>>(
      PlatformMethod.restPresenceGet,
      {
        TxTransportKeys.channelName: _restChannel.name,
        if (params != null) TxTransportKeys.params: params
      },
    );
    return PaginatedResult<PresenceMessage>.fromAblyMessage(
      AblyMessage.castFrom<dynamic, PaginatedResult<dynamic>>(message),
    );
  }

  /// Return the presence messages history for the channel.
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RSP4
  Future<PaginatedResult<PresenceMessage>> history([
    RestHistoryParams? params,
  ]) async {
    final message = await invokeRequest<AblyMessage<dynamic>>(
      PlatformMethod.restPresenceHistory,
      {
        TxTransportKeys.channelName: _restChannel.name,
        if (params != null) TxTransportKeys.params: params
      },
    );
    return PaginatedResult<PresenceMessage>.fromAblyMessage(
      AblyMessage.castFrom<dynamic, PaginatedResult<dynamic>>(message),
    );
  }
}
