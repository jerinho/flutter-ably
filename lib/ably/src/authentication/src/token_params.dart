import '../../../ably_flutter.dart';
import 'package:meta/meta.dart';

/// A class providing parameters of a token request.
///
/// Parameters for a token request
///
/// [Auth.authorize], [Auth.requestToken] and [Auth.createTokenRequest]
/// accept an instance of TokenParams as a parameter
///
/// https://docs.ably.com/client-lib-development-guide/features/#TK1
@immutable
class TokenParams {
  /// Capability of the token.
  ///
  /// If the token request is successful, the capability of the
  /// returned token will be the intersection of this [capability]
  /// with the capability of the issuing key.
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#TK2b
  final String? capability;

  /// A clientId to associate with this token.
  ///
  /// The generated token may be used to authenticate as this clientId.
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#TK2c
  final String? clientId;

  /// An opaque nonce string of at least 16 characters to ensure uniqueness.
  ///
  /// Timestamps, in conjunction with the nonce,
  /// are used to prevent requests from being replayed
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#TK2d
  final String? nonce;

  /// The timestamp (in millis since the epoch) of this request.
  ///
  ///	Timestamps, in conjunction with the nonce, are used to prevent
  ///	token requests from being replayed.
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#TK2d
  final DateTime? timestamp;

  /// Requested time to live for the token.
  ///
  /// If the token request is successful, the TTL of the returned
  /// token will be less than or equal to this value depending on
  /// application settings and the attributes of the issuing key.
  ///
  /// 0 means Ably will set it to the default value
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#TK2a
  final int? ttl;

  /// instantiates a [TokenParams] with provided values
  const TokenParams({
    this.capability,
    this.clientId,
    this.nonce,
    this.timestamp,
    this.ttl,
  });

  /// converts to a map of objects
  Map<String, dynamic> toMap() {
    final jsonMap = <String, dynamic>{};
    if (capability != null) jsonMap['capability'] = capability;
    if (clientId != null) jsonMap['clientId'] = clientId;
    if (nonce != null) jsonMap['nonce'] = nonce;
    if (timestamp != null) {
      jsonMap['timestamp'] = timestamp?.millisecondsSinceEpoch.toString();
    }
    if (ttl != null) jsonMap['ttl'] = ttl.toString();
    return jsonMap;
  }
}
