class AuthLoginFailedException implements Exception {
  final String message;
  const AuthLoginFailedException([this.message = "Login failed."]);

  @override
  String toString() => "AuthLoginFailedException: $message";
}

class AuthAccountNotFoundException implements Exception {
  final String message;
  const AuthAccountNotFoundException([this.message = "Account not found."]);

  @override
  String toString() => "AuthAccountNotFoundException: $message";
}

class AuthPasswordIncorrectException implements Exception {
  final String message;
  const AuthPasswordIncorrectException([this.message = "Incorrect password."]);

  @override
  String toString() => "AuthPasswordIncorrectException: $message";
}

class AuthEmailAlreadyRegisteredException implements Exception {
  final String message;
  const AuthEmailAlreadyRegisteredException([this.message = "Email already registered."]);

  @override
  String toString() => "AuthEmailAlreadyRegisteredException: $message";
}

class AuthSignUpFailedException implements Exception {
  final String message;
  const AuthSignUpFailedException([this.message = "Sign up failed."]);

  @override
  String toString() => "AuthSignUpFailedException: $message";
}

class AuthSignOutFailedException implements Exception {
  final String message;
  const AuthSignOutFailedException([this.message = "Failed to sign out."]);

  @override
  String toString() => "AuthSignOutFailedException: $message";
}

class AuthGetCurrentUserFailedException implements Exception {
  final String message;
  const AuthGetCurrentUserFailedException([this.message = "Failed to get current user."]);

  @override
  String toString() => "AuthGetCurrentUserFailedException: $message";
} 