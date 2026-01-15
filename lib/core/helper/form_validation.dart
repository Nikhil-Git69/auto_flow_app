class FormValidators {
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }

    final emailRegex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w{2,}$');

    if (!emailRegex.hasMatch(value.trim())) {
      return 'Enter a valid Email';
    }

    return null;
  }

  static String? validateEmailOrPhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email or Phone is required';
    }

    final input = value.trim();

    final emailRegex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w{2,}$');

    final phoneRegex = RegExp(r'^[0-9]{10}$');

    if (!emailRegex.hasMatch(input) && !phoneRegex.hasMatch(input)) {
      return 'Enter a valid Email or 10-digit Phone Number';
    }

    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Password is required';
    }

    if (value.trim().length < 8) {
      return 'Password must be exactly 8 characters long';
    }

    return null;
  }

  static String? validateOldPassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Old Password is required';
    }

    return null;
  }

  static String? validateUsername(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email or Username is required';
    }

    final usernameRegex = RegExp(r'^[a-zA-Z0-9._-]{3,20}$');

    if (!usernameRegex.hasMatch(value.trim())) {
      return 'Username must be 3-20 characters and contain only letters, numbers, dots, underscores or hyphens';
    }

    return null;
  }

  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Full Name is required';
    }
    final nameRegex = RegExp(r'[!@#<>?":_`~;[\]\\|=+)(*&^%0-9-]');
    if(nameRegex.hasMatch(value)){
      return 'Full Name can only contain characters';
    }
    // final words = value.trim().split(RegExp(r'\s+'));
    // if (words.length < 2) {
    //   return 'Please enter both first and last name';
    // }

    return null;
  }

  static String? validateContact(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Contact Number is required';
    }
    if (value.trim().length != 10) {
      return 'Valid Numbers should be 10 digits long';
    }
    if (!(value.trim().startsWith('97') || value.trim().startsWith('98'))) {
      return 'Number should start with 97 or 98';
    }
    return null;
  }

  static String? validateMessage(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Message is required';
    }
    return null;
  }

  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.trim().isEmpty) {
      return 'Confirm Password is required';
    }

    if (value.trim().length < 8) {
      return 'Password must be exactly 8 characters long';
    }
    if (value != password) {
      return 'Passwords do not match';
    }
    return null;
  }

  //Login Page Validation
  static String? validLoginEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    return null;
  }

  static String? validLoginPassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Password is required';
    }

    return null;
  }
}
