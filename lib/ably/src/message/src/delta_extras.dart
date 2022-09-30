import '../../../ably_flutter.dart';
import '../../../src/common/src/object_hash.dart';
import '../../../src/generated/platform_constants.dart';
import 'package:meta/meta.dart';

/// Delta extension configuration for [MessageExtras]
@immutable
class DeltaExtras with ObjectHash {
  /// the id of the message the delta was generated from
  final String? from;

  /// the delta format. Only "vcdiff" is supported currently
  final String? format;

  /// create instance from a map
  @protected
  DeltaExtras.fromMap(Map<String, dynamic> value)
      : format = value[TxDeltaExtras.format] as String?,
        from = value[TxDeltaExtras.from] as String?;

  @override
  bool operator ==(Object other) =>
      other is DeltaExtras && other.from == from && other.format == format;

  @override
  int get hashCode => objectHash([
        from,
        format,
      ]);
}
