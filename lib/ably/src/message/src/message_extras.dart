import '../../../ably_flutter.dart';
import '../../../src/common/src/object_hash.dart';
import '../../../src/platform/platform_internal.dart';
import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

/// Handles supported message extras types, their encoding and decoding
@immutable
class MessageExtras with ObjectHash {
  /// json-encodable map of extras
  final Map<String, dynamic>? map;

  /// configuration for delta compression extension
  final DeltaExtras? _delta;

  /// delta configuration received from channel message
  DeltaExtras? get delta => _delta;

  /// Creates an instance from given extras map
  const MessageExtras(this.map) : _delta = null;

  /// Creates an instance from given extras map and an instance of DeltaExtras
  const MessageExtras._withDelta(this.map, this._delta);

  /// initializes [MessageExtras] with given value and validates
  /// the data type, runtime
  static MessageExtras? fromMap(Map<String, dynamic>? extrasMap) {
    if (extrasMap == null) return null;
    // In some cases, extrasMap may not be a mutable map
    // for example, when it's a CastMap, so we need to create a mutable
    // instance from the existing extras map
    final mutableExtrasMap = Map<String, dynamic>.from(extrasMap);
    final deltaMap =
        mutableExtrasMap.remove(TxMessageExtras.delta) as Map<String, dynamic>?;
    return MessageExtras._withDelta(
      mutableExtrasMap,
      (deltaMap == null) ? null : DeltaExtras.fromMap(deltaMap),
    );
  }

  @override
  String toString() => {'extras': map, 'delta': delta}.toString();

  @override
  bool operator ==(Object other) =>
      other is MessageExtras &&
      const MapEquality<String, dynamic>().equals(other.map, map) &&
      other.delta == delta;

  @override
  int get hashCode => objectHash([
        map,
        delta,
      ]);
}
