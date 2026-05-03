// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'view_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ViewState<T> {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ViewState<T>);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ViewState<$T>()';
}


}

/// @nodoc
class $ViewStateCopyWith<T,$Res>  {
$ViewStateCopyWith(ViewState<T> _, $Res Function(ViewState<T>) __);
}


/// Adds pattern-matching-related methods to [ViewState].
extension ViewStatePatterns<T> on ViewState<T> {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( Loading<T> value)?  loading,TResult Function( Empty<T> value)?  empty,TResult Function( ErrorState<T> value)?  error,TResult Function( Data<T> value)?  data,required TResult orElse(),}){
final _that = this;
switch (_that) {
case Loading() when loading != null:
return loading(_that);case Empty() when empty != null:
return empty(_that);case ErrorState() when error != null:
return error(_that);case Data() when data != null:
return data(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( Loading<T> value)  loading,required TResult Function( Empty<T> value)  empty,required TResult Function( ErrorState<T> value)  error,required TResult Function( Data<T> value)  data,}){
final _that = this;
switch (_that) {
case Loading():
return loading(_that);case Empty():
return empty(_that);case ErrorState():
return error(_that);case Data():
return data(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( Loading<T> value)?  loading,TResult? Function( Empty<T> value)?  empty,TResult? Function( ErrorState<T> value)?  error,TResult? Function( Data<T> value)?  data,}){
final _that = this;
switch (_that) {
case Loading() when loading != null:
return loading(_that);case Empty() when empty != null:
return empty(_that);case ErrorState() when error != null:
return error(_that);case Data() when data != null:
return data(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  loading,TResult Function()?  empty,TResult Function( Failure failure)?  error,TResult Function( T data)?  data,required TResult orElse(),}) {final _that = this;
switch (_that) {
case Loading() when loading != null:
return loading();case Empty() when empty != null:
return empty();case ErrorState() when error != null:
return error(_that.failure);case Data() when data != null:
return data(_that.data);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  loading,required TResult Function()  empty,required TResult Function( Failure failure)  error,required TResult Function( T data)  data,}) {final _that = this;
switch (_that) {
case Loading():
return loading();case Empty():
return empty();case ErrorState():
return error(_that.failure);case Data():
return data(_that.data);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  loading,TResult? Function()?  empty,TResult? Function( Failure failure)?  error,TResult? Function( T data)?  data,}) {final _that = this;
switch (_that) {
case Loading() when loading != null:
return loading();case Empty() when empty != null:
return empty();case ErrorState() when error != null:
return error(_that.failure);case Data() when data != null:
return data(_that.data);case _:
  return null;

}
}

}

/// @nodoc


class Loading<T> implements ViewState<T> {
  const Loading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Loading<T>);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ViewState<$T>.loading()';
}


}




/// @nodoc


class Empty<T> implements ViewState<T> {
  const Empty();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Empty<T>);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ViewState<$T>.empty()';
}


}




/// @nodoc


class ErrorState<T> implements ViewState<T> {
  const ErrorState(this.failure);
  

 final  Failure failure;

/// Create a copy of ViewState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ErrorStateCopyWith<T, ErrorState<T>> get copyWith => _$ErrorStateCopyWithImpl<T, ErrorState<T>>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ErrorState<T>&&(identical(other.failure, failure) || other.failure == failure));
}


@override
int get hashCode => Object.hash(runtimeType,failure);

@override
String toString() {
  return 'ViewState<$T>.error(failure: $failure)';
}


}

/// @nodoc
abstract mixin class $ErrorStateCopyWith<T,$Res> implements $ViewStateCopyWith<T, $Res> {
  factory $ErrorStateCopyWith(ErrorState<T> value, $Res Function(ErrorState<T>) _then) = _$ErrorStateCopyWithImpl;
@useResult
$Res call({
 Failure failure
});




}
/// @nodoc
class _$ErrorStateCopyWithImpl<T,$Res>
    implements $ErrorStateCopyWith<T, $Res> {
  _$ErrorStateCopyWithImpl(this._self, this._then);

  final ErrorState<T> _self;
  final $Res Function(ErrorState<T>) _then;

/// Create a copy of ViewState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? failure = null,}) {
  return _then(ErrorState<T>(
null == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as Failure,
  ));
}


}

/// @nodoc


class Data<T> implements ViewState<T> {
  const Data(this.data);
  

 final  T data;

/// Create a copy of ViewState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DataCopyWith<T, Data<T>> get copyWith => _$DataCopyWithImpl<T, Data<T>>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Data<T>&&const DeepCollectionEquality().equals(other.data, data));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(data));

@override
String toString() {
  return 'ViewState<$T>.data(data: $data)';
}


}

/// @nodoc
abstract mixin class $DataCopyWith<T,$Res> implements $ViewStateCopyWith<T, $Res> {
  factory $DataCopyWith(Data<T> value, $Res Function(Data<T>) _then) = _$DataCopyWithImpl;
@useResult
$Res call({
 T data
});




}
/// @nodoc
class _$DataCopyWithImpl<T,$Res>
    implements $DataCopyWith<T, $Res> {
  _$DataCopyWithImpl(this._self, this._then);

  final Data<T> _self;
  final $Res Function(Data<T>) _then;

/// Create a copy of ViewState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? data = freezed,}) {
  return _then(Data<T>(
freezed == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as T,
  ));
}


}

// dart format on
