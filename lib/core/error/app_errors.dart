enum AppErrorType { noInternet, serverUnreachable, invalidCredentials, unauthenticated, unknown }

class AppErrors {
  final AppErrorType type;
  final String message;
  const AppErrors(this.type, this.message);

  factory AppErrors.noInternet() =>
      const AppErrors(AppErrorType.noInternet, 'No internet connection. Please try again.');

  factory AppErrors.serverUnreachable() =>
      const AppErrors(AppErrorType.serverUnreachable, 'Something went wrong. Please try again.');

  factory AppErrors.invalidCredentials(String detail) =>
      AppErrors(AppErrorType.invalidCredentials, detail);

  factory AppErrors.unauthenticated() =>
      const AppErrors(AppErrorType.unauthenticated, 'You must be signed in to do that.');

  factory AppErrors.unknown() =>
      const AppErrors(AppErrorType.unknown, 'Something went wrong. Please try again.');

  @override
  String toString() => message;
}