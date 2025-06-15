class ProfileException implements Exception {
  final String message;
  const ProfileException([this.message = "An unknown profile error occurred."]);

  @override
  String toString() => "ProfileException: $message";
}

class ProfileFetchFailedException extends ProfileException {
  const ProfileFetchFailedException([super.message = "Failed to retrieve profile."]);
}

class ProfileUploadAvatarFailedException extends ProfileException {
  const ProfileUploadAvatarFailedException([super.message = "Failed to upload avatar."]);
}

class ProfileUpdateFailedException extends ProfileException {
  const ProfileUpdateFailedException([super.message = "Failed to update profile."]);
}

class ProfileDeleteAvatarFailedException extends ProfileException {
  const ProfileDeleteAvatarFailedException([super.message = "Failed to delete avatar."]);
}

class ProfileUserNotAuthenticatedException extends ProfileException {
  const ProfileUserNotAuthenticatedException([super.message = "User not authenticated for this operation."]);
} 