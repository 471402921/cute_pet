sealed class Failure {
  const Failure(this.message, {this.traceId});

  final String message;
  final String? traceId;

  @override
  String toString() =>
      '$runtimeType($message${traceId != null ? ', traceId=$traceId' : ''})';
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message, {super.traceId});
}

class AuthFailure extends Failure {
  const AuthFailure(super.message, {super.traceId});
}

class ForbiddenFailure extends Failure {
  const ForbiddenFailure(super.message, {super.traceId});
}

class NotFoundFailure extends Failure {
  const NotFoundFailure(super.message, {super.traceId});
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message, this.fieldErrors, {super.traceId});

  final Map<String, String> fieldErrors;
}

class ServerFailure extends Failure {
  const ServerFailure(super.message, {super.traceId});
}

class UnknownFailure extends Failure {
  const UnknownFailure(super.message, {super.traceId});
}
