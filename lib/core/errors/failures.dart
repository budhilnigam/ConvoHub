class Failure {
  const Failure(this.message);

  final String message;
}

class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

class DataFailure extends Failure {
  const DataFailure(super.message);
}