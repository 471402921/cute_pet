import 'package:cute_pet/core/error/failures.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'view_state.freezed.dart';

@freezed
sealed class ViewState<T> with _$ViewState<T> {
  const factory ViewState.loading() = Loading<T>;
  const factory ViewState.empty() = Empty<T>;
  const factory ViewState.error(Failure failure) = ErrorState<T>;
  const factory ViewState.data(T data) = Data<T>;
}
