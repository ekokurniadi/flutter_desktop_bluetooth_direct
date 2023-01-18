// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'bridge_generated.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
mixin _$BluetoothDevice {
  String? get name => throw _privateConstructorUsedError;
  String? get address => throw _privateConstructorUsedError;
  bool get status => throw _privateConstructorUsedError;
  List<String> get serviceUuid => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $BluetoothDeviceCopyWith<BluetoothDevice> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BluetoothDeviceCopyWith<$Res> {
  factory $BluetoothDeviceCopyWith(
          BluetoothDevice value, $Res Function(BluetoothDevice) then) =
      _$BluetoothDeviceCopyWithImpl<$Res, BluetoothDevice>;
  @useResult
  $Res call(
      {String? name, String? address, bool status, List<String> serviceUuid});
}

/// @nodoc
class _$BluetoothDeviceCopyWithImpl<$Res, $Val extends BluetoothDevice>
    implements $BluetoothDeviceCopyWith<$Res> {
  _$BluetoothDeviceCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = freezed,
    Object? address = freezed,
    Object? status = null,
    Object? serviceUuid = null,
  }) {
    return _then(_value.copyWith(
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      address: freezed == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as bool,
      serviceUuid: null == serviceUuid
          ? _value.serviceUuid
          : serviceUuid // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_BluetoothDeviceCopyWith<$Res>
    implements $BluetoothDeviceCopyWith<$Res> {
  factory _$$_BluetoothDeviceCopyWith(
          _$_BluetoothDevice value, $Res Function(_$_BluetoothDevice) then) =
      __$$_BluetoothDeviceCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? name, String? address, bool status, List<String> serviceUuid});
}

/// @nodoc
class __$$_BluetoothDeviceCopyWithImpl<$Res>
    extends _$BluetoothDeviceCopyWithImpl<$Res, _$_BluetoothDevice>
    implements _$$_BluetoothDeviceCopyWith<$Res> {
  __$$_BluetoothDeviceCopyWithImpl(
      _$_BluetoothDevice _value, $Res Function(_$_BluetoothDevice) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = freezed,
    Object? address = freezed,
    Object? status = null,
    Object? serviceUuid = null,
  }) {
    return _then(_$_BluetoothDevice(
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      address: freezed == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as bool,
      serviceUuid: null == serviceUuid
          ? _value._serviceUuid
          : serviceUuid // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc

class _$_BluetoothDevice implements _BluetoothDevice {
  const _$_BluetoothDevice(
      {this.name,
      this.address,
      required this.status,
      required final List<String> serviceUuid})
      : _serviceUuid = serviceUuid;

  @override
  final String? name;
  @override
  final String? address;
  @override
  final bool status;
  final List<String> _serviceUuid;
  @override
  List<String> get serviceUuid {
    if (_serviceUuid is EqualUnmodifiableListView) return _serviceUuid;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_serviceUuid);
  }

  @override
  String toString() {
    return 'BluetoothDevice(name: $name, address: $address, status: $status, serviceUuid: $serviceUuid)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_BluetoothDevice &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.status, status) || other.status == status) &&
            const DeepCollectionEquality()
                .equals(other._serviceUuid, _serviceUuid));
  }

  @override
  int get hashCode => Object.hash(runtimeType, name, address, status,
      const DeepCollectionEquality().hash(_serviceUuid));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_BluetoothDeviceCopyWith<_$_BluetoothDevice> get copyWith =>
      __$$_BluetoothDeviceCopyWithImpl<_$_BluetoothDevice>(this, _$identity);
}

abstract class _BluetoothDevice implements BluetoothDevice {
  const factory _BluetoothDevice(
      {final String? name,
      final String? address,
      required final bool status,
      required final List<String> serviceUuid}) = _$_BluetoothDevice;

  @override
  String? get name;
  @override
  String? get address;
  @override
  bool get status;
  @override
  List<String> get serviceUuid;
  @override
  @JsonKey(ignore: true)
  _$$_BluetoothDeviceCopyWith<_$_BluetoothDevice> get copyWith =>
      throw _privateConstructorUsedError;
}
