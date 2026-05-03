// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'save_envelope.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SaveEnvelope<T> {

 int get version; DateTime get savedAt; T get payload;
/// Create a copy of SaveEnvelope
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SaveEnvelopeCopyWith<T, SaveEnvelope<T>> get copyWith => _$SaveEnvelopeCopyWithImpl<T, SaveEnvelope<T>>(this as SaveEnvelope<T>, _$identity);

  /// Serializes this SaveEnvelope to a JSON map.
  Map<String, dynamic> toJson(Object? Function(T) toJsonT);


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SaveEnvelope<T>&&(identical(other.version, version) || other.version == version)&&(identical(other.savedAt, savedAt) || other.savedAt == savedAt)&&const DeepCollectionEquality().equals(other.payload, payload));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,version,savedAt,const DeepCollectionEquality().hash(payload));

@override
String toString() {
  return 'SaveEnvelope<$T>(version: $version, savedAt: $savedAt, payload: $payload)';
}


}

/// @nodoc
abstract mixin class $SaveEnvelopeCopyWith<T,$Res>  {
  factory $SaveEnvelopeCopyWith(SaveEnvelope<T> value, $Res Function(SaveEnvelope<T>) _then) = _$SaveEnvelopeCopyWithImpl;
@useResult
$Res call({
 int version, DateTime savedAt, T payload
});




}
/// @nodoc
class _$SaveEnvelopeCopyWithImpl<T,$Res>
    implements $SaveEnvelopeCopyWith<T, $Res> {
  _$SaveEnvelopeCopyWithImpl(this._self, this._then);

  final SaveEnvelope<T> _self;
  final $Res Function(SaveEnvelope<T>) _then;

/// Create a copy of SaveEnvelope
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? version = null,Object? savedAt = null,Object? payload = freezed,}) {
  return _then(_self.copyWith(
version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as int,savedAt: null == savedAt ? _self.savedAt : savedAt // ignore: cast_nullable_to_non_nullable
as DateTime,payload: freezed == payload ? _self.payload : payload // ignore: cast_nullable_to_non_nullable
as T,
  ));
}

}


/// Adds pattern-matching-related methods to [SaveEnvelope].
extension SaveEnvelopePatterns<T> on SaveEnvelope<T> {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SaveEnvelope<T> value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SaveEnvelope() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SaveEnvelope<T> value)  $default,){
final _that = this;
switch (_that) {
case _SaveEnvelope():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SaveEnvelope<T> value)?  $default,){
final _that = this;
switch (_that) {
case _SaveEnvelope() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int version,  DateTime savedAt,  T payload)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SaveEnvelope() when $default != null:
return $default(_that.version,_that.savedAt,_that.payload);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int version,  DateTime savedAt,  T payload)  $default,) {final _that = this;
switch (_that) {
case _SaveEnvelope():
return $default(_that.version,_that.savedAt,_that.payload);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int version,  DateTime savedAt,  T payload)?  $default,) {final _that = this;
switch (_that) {
case _SaveEnvelope() when $default != null:
return $default(_that.version,_that.savedAt,_that.payload);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable(genericArgumentFactories: true)

class _SaveEnvelope<T> implements SaveEnvelope<T> {
  const _SaveEnvelope({required this.version, required this.savedAt, required this.payload});
  factory _SaveEnvelope.fromJson(Map<String, dynamic> json,T Function(Object?) fromJsonT) => _$SaveEnvelopeFromJson(json,fromJsonT);

@override final  int version;
@override final  DateTime savedAt;
@override final  T payload;

/// Create a copy of SaveEnvelope
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SaveEnvelopeCopyWith<T, _SaveEnvelope<T>> get copyWith => __$SaveEnvelopeCopyWithImpl<T, _SaveEnvelope<T>>(this, _$identity);

@override
Map<String, dynamic> toJson(Object? Function(T) toJsonT) {
  return _$SaveEnvelopeToJson<T>(this, toJsonT);
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SaveEnvelope<T>&&(identical(other.version, version) || other.version == version)&&(identical(other.savedAt, savedAt) || other.savedAt == savedAt)&&const DeepCollectionEquality().equals(other.payload, payload));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,version,savedAt,const DeepCollectionEquality().hash(payload));

@override
String toString() {
  return 'SaveEnvelope<$T>(version: $version, savedAt: $savedAt, payload: $payload)';
}


}

/// @nodoc
abstract mixin class _$SaveEnvelopeCopyWith<T,$Res> implements $SaveEnvelopeCopyWith<T, $Res> {
  factory _$SaveEnvelopeCopyWith(_SaveEnvelope<T> value, $Res Function(_SaveEnvelope<T>) _then) = __$SaveEnvelopeCopyWithImpl;
@override @useResult
$Res call({
 int version, DateTime savedAt, T payload
});




}
/// @nodoc
class __$SaveEnvelopeCopyWithImpl<T,$Res>
    implements _$SaveEnvelopeCopyWith<T, $Res> {
  __$SaveEnvelopeCopyWithImpl(this._self, this._then);

  final _SaveEnvelope<T> _self;
  final $Res Function(_SaveEnvelope<T>) _then;

/// Create a copy of SaveEnvelope
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? version = null,Object? savedAt = null,Object? payload = freezed,}) {
  return _then(_SaveEnvelope<T>(
version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as int,savedAt: null == savedAt ? _self.savedAt : savedAt // ignore: cast_nullable_to_non_nullable
as DateTime,payload: freezed == payload ? _self.payload : payload // ignore: cast_nullable_to_non_nullable
as T,
  ));
}


}

// dart format on
