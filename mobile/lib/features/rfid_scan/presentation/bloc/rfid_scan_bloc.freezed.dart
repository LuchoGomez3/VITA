// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'rfid_scan_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$RfidScanEvent {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RfidScanEvent);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'RfidScanEvent()';
}


}

/// @nodoc
class $RfidScanEventCopyWith<$Res>  {
$RfidScanEventCopyWith(RfidScanEvent _, $Res Function(RfidScanEvent) __);
}


/// Adds pattern-matching-related methods to [RfidScanEvent].
extension RfidScanEventPatterns on RfidScanEvent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _ListeningRequested value)?  listeningRequested,TResult Function( _Stopped value)?  stopped,TResult Function( _ReadingReceived value)?  readingReceived,TResult Function( _InvalidReadingDetected value)?  invalidReadingDetected,TResult Function( _AnimalFound value)?  animalFound,TResult Function( _AnimalNotFound value)?  animalNotFound,TResult Function( _TimeoutElapsed value)?  timeoutElapsed,TResult Function( _ErrorOccurred value)?  errorOccurred,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ListeningRequested() when listeningRequested != null:
return listeningRequested(_that);case _Stopped() when stopped != null:
return stopped(_that);case _ReadingReceived() when readingReceived != null:
return readingReceived(_that);case _InvalidReadingDetected() when invalidReadingDetected != null:
return invalidReadingDetected(_that);case _AnimalFound() when animalFound != null:
return animalFound(_that);case _AnimalNotFound() when animalNotFound != null:
return animalNotFound(_that);case _TimeoutElapsed() when timeoutElapsed != null:
return timeoutElapsed(_that);case _ErrorOccurred() when errorOccurred != null:
return errorOccurred(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _ListeningRequested value)  listeningRequested,required TResult Function( _Stopped value)  stopped,required TResult Function( _ReadingReceived value)  readingReceived,required TResult Function( _InvalidReadingDetected value)  invalidReadingDetected,required TResult Function( _AnimalFound value)  animalFound,required TResult Function( _AnimalNotFound value)  animalNotFound,required TResult Function( _TimeoutElapsed value)  timeoutElapsed,required TResult Function( _ErrorOccurred value)  errorOccurred,}){
final _that = this;
switch (_that) {
case _ListeningRequested():
return listeningRequested(_that);case _Stopped():
return stopped(_that);case _ReadingReceived():
return readingReceived(_that);case _InvalidReadingDetected():
return invalidReadingDetected(_that);case _AnimalFound():
return animalFound(_that);case _AnimalNotFound():
return animalNotFound(_that);case _TimeoutElapsed():
return timeoutElapsed(_that);case _ErrorOccurred():
return errorOccurred(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _ListeningRequested value)?  listeningRequested,TResult? Function( _Stopped value)?  stopped,TResult? Function( _ReadingReceived value)?  readingReceived,TResult? Function( _InvalidReadingDetected value)?  invalidReadingDetected,TResult? Function( _AnimalFound value)?  animalFound,TResult? Function( _AnimalNotFound value)?  animalNotFound,TResult? Function( _TimeoutElapsed value)?  timeoutElapsed,TResult? Function( _ErrorOccurred value)?  errorOccurred,}){
final _that = this;
switch (_that) {
case _ListeningRequested() when listeningRequested != null:
return listeningRequested(_that);case _Stopped() when stopped != null:
return stopped(_that);case _ReadingReceived() when readingReceived != null:
return readingReceived(_that);case _InvalidReadingDetected() when invalidReadingDetected != null:
return invalidReadingDetected(_that);case _AnimalFound() when animalFound != null:
return animalFound(_that);case _AnimalNotFound() when animalNotFound != null:
return animalNotFound(_that);case _TimeoutElapsed() when timeoutElapsed != null:
return timeoutElapsed(_that);case _ErrorOccurred() when errorOccurred != null:
return errorOccurred(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  listeningRequested,TResult Function()?  stopped,TResult Function( String reading)?  readingReceived,TResult Function( String reading)?  invalidReadingDetected,TResult Function( IdentifiedAnimal animal)?  animalFound,TResult Function( String rfid)?  animalNotFound,TResult Function()?  timeoutElapsed,TResult Function()?  errorOccurred,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ListeningRequested() when listeningRequested != null:
return listeningRequested();case _Stopped() when stopped != null:
return stopped();case _ReadingReceived() when readingReceived != null:
return readingReceived(_that.reading);case _InvalidReadingDetected() when invalidReadingDetected != null:
return invalidReadingDetected(_that.reading);case _AnimalFound() when animalFound != null:
return animalFound(_that.animal);case _AnimalNotFound() when animalNotFound != null:
return animalNotFound(_that.rfid);case _TimeoutElapsed() when timeoutElapsed != null:
return timeoutElapsed();case _ErrorOccurred() when errorOccurred != null:
return errorOccurred();case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  listeningRequested,required TResult Function()  stopped,required TResult Function( String reading)  readingReceived,required TResult Function( String reading)  invalidReadingDetected,required TResult Function( IdentifiedAnimal animal)  animalFound,required TResult Function( String rfid)  animalNotFound,required TResult Function()  timeoutElapsed,required TResult Function()  errorOccurred,}) {final _that = this;
switch (_that) {
case _ListeningRequested():
return listeningRequested();case _Stopped():
return stopped();case _ReadingReceived():
return readingReceived(_that.reading);case _InvalidReadingDetected():
return invalidReadingDetected(_that.reading);case _AnimalFound():
return animalFound(_that.animal);case _AnimalNotFound():
return animalNotFound(_that.rfid);case _TimeoutElapsed():
return timeoutElapsed();case _ErrorOccurred():
return errorOccurred();}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  listeningRequested,TResult? Function()?  stopped,TResult? Function( String reading)?  readingReceived,TResult? Function( String reading)?  invalidReadingDetected,TResult? Function( IdentifiedAnimal animal)?  animalFound,TResult? Function( String rfid)?  animalNotFound,TResult? Function()?  timeoutElapsed,TResult? Function()?  errorOccurred,}) {final _that = this;
switch (_that) {
case _ListeningRequested() when listeningRequested != null:
return listeningRequested();case _Stopped() when stopped != null:
return stopped();case _ReadingReceived() when readingReceived != null:
return readingReceived(_that.reading);case _InvalidReadingDetected() when invalidReadingDetected != null:
return invalidReadingDetected(_that.reading);case _AnimalFound() when animalFound != null:
return animalFound(_that.animal);case _AnimalNotFound() when animalNotFound != null:
return animalNotFound(_that.rfid);case _TimeoutElapsed() when timeoutElapsed != null:
return timeoutElapsed();case _ErrorOccurred() when errorOccurred != null:
return errorOccurred();case _:
  return null;

}
}

}

/// @nodoc


class _ListeningRequested implements RfidScanEvent {
  const _ListeningRequested();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ListeningRequested);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'RfidScanEvent.listeningRequested()';
}


}




/// @nodoc


class _Stopped implements RfidScanEvent {
  const _Stopped();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Stopped);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'RfidScanEvent.stopped()';
}


}




/// @nodoc


class _ReadingReceived implements RfidScanEvent {
  const _ReadingReceived({required this.reading});
  

 final  String reading;

/// Create a copy of RfidScanEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReadingReceivedCopyWith<_ReadingReceived> get copyWith => __$ReadingReceivedCopyWithImpl<_ReadingReceived>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReadingReceived&&(identical(other.reading, reading) || other.reading == reading));
}


@override
int get hashCode => Object.hash(runtimeType,reading);

@override
String toString() {
  return 'RfidScanEvent.readingReceived(reading: $reading)';
}


}

/// @nodoc
abstract mixin class _$ReadingReceivedCopyWith<$Res> implements $RfidScanEventCopyWith<$Res> {
  factory _$ReadingReceivedCopyWith(_ReadingReceived value, $Res Function(_ReadingReceived) _then) = __$ReadingReceivedCopyWithImpl;
@useResult
$Res call({
 String reading
});




}
/// @nodoc
class __$ReadingReceivedCopyWithImpl<$Res>
    implements _$ReadingReceivedCopyWith<$Res> {
  __$ReadingReceivedCopyWithImpl(this._self, this._then);

  final _ReadingReceived _self;
  final $Res Function(_ReadingReceived) _then;

/// Create a copy of RfidScanEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? reading = null,}) {
  return _then(_ReadingReceived(
reading: null == reading ? _self.reading : reading // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class _InvalidReadingDetected implements RfidScanEvent {
  const _InvalidReadingDetected({required this.reading});
  

 final  String reading;

/// Create a copy of RfidScanEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InvalidReadingDetectedCopyWith<_InvalidReadingDetected> get copyWith => __$InvalidReadingDetectedCopyWithImpl<_InvalidReadingDetected>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _InvalidReadingDetected&&(identical(other.reading, reading) || other.reading == reading));
}


@override
int get hashCode => Object.hash(runtimeType,reading);

@override
String toString() {
  return 'RfidScanEvent.invalidReadingDetected(reading: $reading)';
}


}

/// @nodoc
abstract mixin class _$InvalidReadingDetectedCopyWith<$Res> implements $RfidScanEventCopyWith<$Res> {
  factory _$InvalidReadingDetectedCopyWith(_InvalidReadingDetected value, $Res Function(_InvalidReadingDetected) _then) = __$InvalidReadingDetectedCopyWithImpl;
@useResult
$Res call({
 String reading
});




}
/// @nodoc
class __$InvalidReadingDetectedCopyWithImpl<$Res>
    implements _$InvalidReadingDetectedCopyWith<$Res> {
  __$InvalidReadingDetectedCopyWithImpl(this._self, this._then);

  final _InvalidReadingDetected _self;
  final $Res Function(_InvalidReadingDetected) _then;

/// Create a copy of RfidScanEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? reading = null,}) {
  return _then(_InvalidReadingDetected(
reading: null == reading ? _self.reading : reading // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class _AnimalFound implements RfidScanEvent {
  const _AnimalFound({required this.animal});
  

 final  IdentifiedAnimal animal;

/// Create a copy of RfidScanEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AnimalFoundCopyWith<_AnimalFound> get copyWith => __$AnimalFoundCopyWithImpl<_AnimalFound>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AnimalFound&&(identical(other.animal, animal) || other.animal == animal));
}


@override
int get hashCode => Object.hash(runtimeType,animal);

@override
String toString() {
  return 'RfidScanEvent.animalFound(animal: $animal)';
}


}

/// @nodoc
abstract mixin class _$AnimalFoundCopyWith<$Res> implements $RfidScanEventCopyWith<$Res> {
  factory _$AnimalFoundCopyWith(_AnimalFound value, $Res Function(_AnimalFound) _then) = __$AnimalFoundCopyWithImpl;
@useResult
$Res call({
 IdentifiedAnimal animal
});


$IdentifiedAnimalCopyWith<$Res> get animal;

}
/// @nodoc
class __$AnimalFoundCopyWithImpl<$Res>
    implements _$AnimalFoundCopyWith<$Res> {
  __$AnimalFoundCopyWithImpl(this._self, this._then);

  final _AnimalFound _self;
  final $Res Function(_AnimalFound) _then;

/// Create a copy of RfidScanEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? animal = null,}) {
  return _then(_AnimalFound(
animal: null == animal ? _self.animal : animal // ignore: cast_nullable_to_non_nullable
as IdentifiedAnimal,
  ));
}

/// Create a copy of RfidScanEvent
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$IdentifiedAnimalCopyWith<$Res> get animal {
  
  return $IdentifiedAnimalCopyWith<$Res>(_self.animal, (value) {
    return _then(_self.copyWith(animal: value));
  });
}
}

/// @nodoc


class _AnimalNotFound implements RfidScanEvent {
  const _AnimalNotFound({required this.rfid});
  

 final  String rfid;

/// Create a copy of RfidScanEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AnimalNotFoundCopyWith<_AnimalNotFound> get copyWith => __$AnimalNotFoundCopyWithImpl<_AnimalNotFound>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AnimalNotFound&&(identical(other.rfid, rfid) || other.rfid == rfid));
}


@override
int get hashCode => Object.hash(runtimeType,rfid);

@override
String toString() {
  return 'RfidScanEvent.animalNotFound(rfid: $rfid)';
}


}

/// @nodoc
abstract mixin class _$AnimalNotFoundCopyWith<$Res> implements $RfidScanEventCopyWith<$Res> {
  factory _$AnimalNotFoundCopyWith(_AnimalNotFound value, $Res Function(_AnimalNotFound) _then) = __$AnimalNotFoundCopyWithImpl;
@useResult
$Res call({
 String rfid
});




}
/// @nodoc
class __$AnimalNotFoundCopyWithImpl<$Res>
    implements _$AnimalNotFoundCopyWith<$Res> {
  __$AnimalNotFoundCopyWithImpl(this._self, this._then);

  final _AnimalNotFound _self;
  final $Res Function(_AnimalNotFound) _then;

/// Create a copy of RfidScanEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? rfid = null,}) {
  return _then(_AnimalNotFound(
rfid: null == rfid ? _self.rfid : rfid // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class _TimeoutElapsed implements RfidScanEvent {
  const _TimeoutElapsed();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TimeoutElapsed);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'RfidScanEvent.timeoutElapsed()';
}


}




/// @nodoc


class _ErrorOccurred implements RfidScanEvent {
  const _ErrorOccurred();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ErrorOccurred);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'RfidScanEvent.errorOccurred()';
}


}




/// @nodoc
mixin _$RfidScanState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RfidScanState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'RfidScanState()';
}


}

/// @nodoc
class $RfidScanStateCopyWith<$Res>  {
$RfidScanStateCopyWith(RfidScanState _, $Res Function(RfidScanState) __);
}


/// Adds pattern-matching-related methods to [RfidScanState].
extension RfidScanStatePatterns on RfidScanState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _Inactive value)?  inactive,TResult Function( _Listening value)?  listening,TResult Function( _Invalid value)?  invalid,TResult Function( _Found value)?  found,TResult Function( _NotFound value)?  notFound,TResult Function( _Timeout value)?  timeout,TResult Function( _Error value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Inactive() when inactive != null:
return inactive(_that);case _Listening() when listening != null:
return listening(_that);case _Invalid() when invalid != null:
return invalid(_that);case _Found() when found != null:
return found(_that);case _NotFound() when notFound != null:
return notFound(_that);case _Timeout() when timeout != null:
return timeout(_that);case _Error() when error != null:
return error(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _Inactive value)  inactive,required TResult Function( _Listening value)  listening,required TResult Function( _Invalid value)  invalid,required TResult Function( _Found value)  found,required TResult Function( _NotFound value)  notFound,required TResult Function( _Timeout value)  timeout,required TResult Function( _Error value)  error,}){
final _that = this;
switch (_that) {
case _Inactive():
return inactive(_that);case _Listening():
return listening(_that);case _Invalid():
return invalid(_that);case _Found():
return found(_that);case _NotFound():
return notFound(_that);case _Timeout():
return timeout(_that);case _Error():
return error(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _Inactive value)?  inactive,TResult? Function( _Listening value)?  listening,TResult? Function( _Invalid value)?  invalid,TResult? Function( _Found value)?  found,TResult? Function( _NotFound value)?  notFound,TResult? Function( _Timeout value)?  timeout,TResult? Function( _Error value)?  error,}){
final _that = this;
switch (_that) {
case _Inactive() when inactive != null:
return inactive(_that);case _Listening() when listening != null:
return listening(_that);case _Invalid() when invalid != null:
return invalid(_that);case _Found() when found != null:
return found(_that);case _NotFound() when notFound != null:
return notFound(_that);case _Timeout() when timeout != null:
return timeout(_that);case _Error() when error != null:
return error(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  inactive,TResult Function()?  listening,TResult Function( String reading)?  invalid,TResult Function( IdentifiedAnimal animal)?  found,TResult Function( String rfid)?  notFound,TResult Function()?  timeout,TResult Function()?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Inactive() when inactive != null:
return inactive();case _Listening() when listening != null:
return listening();case _Invalid() when invalid != null:
return invalid(_that.reading);case _Found() when found != null:
return found(_that.animal);case _NotFound() when notFound != null:
return notFound(_that.rfid);case _Timeout() when timeout != null:
return timeout();case _Error() when error != null:
return error();case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  inactive,required TResult Function()  listening,required TResult Function( String reading)  invalid,required TResult Function( IdentifiedAnimal animal)  found,required TResult Function( String rfid)  notFound,required TResult Function()  timeout,required TResult Function()  error,}) {final _that = this;
switch (_that) {
case _Inactive():
return inactive();case _Listening():
return listening();case _Invalid():
return invalid(_that.reading);case _Found():
return found(_that.animal);case _NotFound():
return notFound(_that.rfid);case _Timeout():
return timeout();case _Error():
return error();}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  inactive,TResult? Function()?  listening,TResult? Function( String reading)?  invalid,TResult? Function( IdentifiedAnimal animal)?  found,TResult? Function( String rfid)?  notFound,TResult? Function()?  timeout,TResult? Function()?  error,}) {final _that = this;
switch (_that) {
case _Inactive() when inactive != null:
return inactive();case _Listening() when listening != null:
return listening();case _Invalid() when invalid != null:
return invalid(_that.reading);case _Found() when found != null:
return found(_that.animal);case _NotFound() when notFound != null:
return notFound(_that.rfid);case _Timeout() when timeout != null:
return timeout();case _Error() when error != null:
return error();case _:
  return null;

}
}

}

/// @nodoc


class _Inactive implements RfidScanState {
  const _Inactive();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Inactive);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'RfidScanState.inactive()';
}


}




/// @nodoc


class _Listening implements RfidScanState {
  const _Listening();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Listening);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'RfidScanState.listening()';
}


}




/// @nodoc


class _Invalid implements RfidScanState {
  const _Invalid({required this.reading});
  

 final  String reading;

/// Create a copy of RfidScanState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InvalidCopyWith<_Invalid> get copyWith => __$InvalidCopyWithImpl<_Invalid>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Invalid&&(identical(other.reading, reading) || other.reading == reading));
}


@override
int get hashCode => Object.hash(runtimeType,reading);

@override
String toString() {
  return 'RfidScanState.invalid(reading: $reading)';
}


}

/// @nodoc
abstract mixin class _$InvalidCopyWith<$Res> implements $RfidScanStateCopyWith<$Res> {
  factory _$InvalidCopyWith(_Invalid value, $Res Function(_Invalid) _then) = __$InvalidCopyWithImpl;
@useResult
$Res call({
 String reading
});




}
/// @nodoc
class __$InvalidCopyWithImpl<$Res>
    implements _$InvalidCopyWith<$Res> {
  __$InvalidCopyWithImpl(this._self, this._then);

  final _Invalid _self;
  final $Res Function(_Invalid) _then;

/// Create a copy of RfidScanState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? reading = null,}) {
  return _then(_Invalid(
reading: null == reading ? _self.reading : reading // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class _Found implements RfidScanState {
  const _Found({required this.animal});
  

 final  IdentifiedAnimal animal;

/// Create a copy of RfidScanState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FoundCopyWith<_Found> get copyWith => __$FoundCopyWithImpl<_Found>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Found&&(identical(other.animal, animal) || other.animal == animal));
}


@override
int get hashCode => Object.hash(runtimeType,animal);

@override
String toString() {
  return 'RfidScanState.found(animal: $animal)';
}


}

/// @nodoc
abstract mixin class _$FoundCopyWith<$Res> implements $RfidScanStateCopyWith<$Res> {
  factory _$FoundCopyWith(_Found value, $Res Function(_Found) _then) = __$FoundCopyWithImpl;
@useResult
$Res call({
 IdentifiedAnimal animal
});


$IdentifiedAnimalCopyWith<$Res> get animal;

}
/// @nodoc
class __$FoundCopyWithImpl<$Res>
    implements _$FoundCopyWith<$Res> {
  __$FoundCopyWithImpl(this._self, this._then);

  final _Found _self;
  final $Res Function(_Found) _then;

/// Create a copy of RfidScanState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? animal = null,}) {
  return _then(_Found(
animal: null == animal ? _self.animal : animal // ignore: cast_nullable_to_non_nullable
as IdentifiedAnimal,
  ));
}

/// Create a copy of RfidScanState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$IdentifiedAnimalCopyWith<$Res> get animal {
  
  return $IdentifiedAnimalCopyWith<$Res>(_self.animal, (value) {
    return _then(_self.copyWith(animal: value));
  });
}
}

/// @nodoc


class _NotFound implements RfidScanState {
  const _NotFound({required this.rfid});
  

 final  String rfid;

/// Create a copy of RfidScanState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NotFoundCopyWith<_NotFound> get copyWith => __$NotFoundCopyWithImpl<_NotFound>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _NotFound&&(identical(other.rfid, rfid) || other.rfid == rfid));
}


@override
int get hashCode => Object.hash(runtimeType,rfid);

@override
String toString() {
  return 'RfidScanState.notFound(rfid: $rfid)';
}


}

/// @nodoc
abstract mixin class _$NotFoundCopyWith<$Res> implements $RfidScanStateCopyWith<$Res> {
  factory _$NotFoundCopyWith(_NotFound value, $Res Function(_NotFound) _then) = __$NotFoundCopyWithImpl;
@useResult
$Res call({
 String rfid
});




}
/// @nodoc
class __$NotFoundCopyWithImpl<$Res>
    implements _$NotFoundCopyWith<$Res> {
  __$NotFoundCopyWithImpl(this._self, this._then);

  final _NotFound _self;
  final $Res Function(_NotFound) _then;

/// Create a copy of RfidScanState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? rfid = null,}) {
  return _then(_NotFound(
rfid: null == rfid ? _self.rfid : rfid // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class _Timeout implements RfidScanState {
  const _Timeout();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Timeout);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'RfidScanState.timeout()';
}


}




/// @nodoc


class _Error implements RfidScanState {
  const _Error();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Error);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'RfidScanState.error()';
}


}




// dart format on
