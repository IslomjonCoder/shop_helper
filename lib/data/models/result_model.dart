enum Status {
  success,
  fail,
}

class Result<T> {
  Status status;
  dynamic data;
  String? errorMessage;

  Result.success(this.data) : status = Status.success;

  Result.fail(this.errorMessage) : status = Status.fail;

  bool get isSuccess => status == Status.success;

  bool get isFail => status == Status.fail;
}
