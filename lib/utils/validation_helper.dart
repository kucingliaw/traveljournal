class ValidationHelper {
  static String? validateTitle(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Title is required';
    }
    if (value.length > 100) {
      return 'Title cannot be longer than 100 characters';
    }
    return null;
  }

  static String? validateContent(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Content is required';
    }
    if (value.length > 5000) {
      return 'Content cannot be longer than 5000 characters';
    }
    return null;
  }

  static String? validateUsername(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Username is required';
    }
    if (value.length < 3) {
      return 'Username must be at least 3 characters';
    }
    if (value.length > 30) {
      return 'Username cannot be longer than 30 characters';
    }
    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
      return 'Username can only contain letters, numbers, and underscores';
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  static bool isImageValid(String path) {
    final validExtensions = ['.jpg', '.jpeg', '.png'];
    return validExtensions.any((ext) => path.toLowerCase().endsWith(ext));
  }

  static bool isImageSizeValid(int sizeInBytes) {
    const maxSize = 5 * 1024 * 1024; // 5MB
    return sizeInBytes <= maxSize;
  }
}
