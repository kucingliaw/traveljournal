class JournalException implements Exception {
  final String message;
  const JournalException([this.message = "An unknown journal error occurred."]);

  @override
  String toString() => "JournalException: $message";
}

class JournalFetchFailedException extends JournalException {
  const JournalFetchFailedException([super.message = "Failed to retrieve journals."]);
}

class JournalUploadImageFailedException extends JournalException {
  const JournalUploadImageFailedException([super.message = "Failed to upload image."]);
}

class JournalCreateFailedException extends JournalException {
  const JournalCreateFailedException([super.message = "Failed to create journal."]);
}

class JournalUpdateFailedException extends JournalException {
  const JournalUpdateFailedException([super.message = "Failed to update journal."]);
}

class JournalDeleteFailedException extends JournalException {
  const JournalDeleteFailedException([super.message = "Failed to delete journal."]);
}

class JournalUserNotAuthenticatedException extends JournalException {
  const JournalUserNotAuthenticatedException([super.message = "User not authenticated for this operation."]);
} 