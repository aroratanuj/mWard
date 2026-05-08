import 'package:validators/validators.dart' as validators;
import '../utils/constants.dart';

class AppValidators {
  static String? validatePhoneNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppConstants.validationRequired;
    }
    if (!RegExp(AppConstants.indianPhoneRegex).hasMatch(value.trim())) {
      return AppConstants.validationInvalidPhone;
    }
    if (value.trim().length < AppConstants.phoneMinLength) {
      return '${AppConstants.validationMinLength} ${AppConstants.phoneMinLength} digits';
    }
    if (value.trim().length > AppConstants.phoneMaxLength) {
      return '${AppConstants.validationMaxLength} ${AppConstants.phoneMaxLength} digits';
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppConstants.validationRequired;
    }
    if (!validators.isEmail(value.trim())) {
      return AppConstants.validationInvalidEmail;
    }
    return null;
  }

  static String? validateOTP(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppConstants.validationRequired;
    }
    if (value.trim().length != 6) {
      return AppConstants.validationInvalidOTP;
    }
    if (!validators.isNumeric(value.trim())) {
      return AppConstants.validationInvalidOTP;
    }
    return null;
  }

  static String? validateRequired(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppConstants.validationRequired;
    }
    return null;
  }

  static String? validateMinLength(String? value, int minLength) {
    if (value == null || value.trim().isEmpty) {
      return AppConstants.validationRequired;
    }
    if (value.trim().length < minLength) {
      return '${AppConstants.validationMinLength} $minLength characters';
    }
    return null;
  }

  static String? validateMaxLength(String? value, int maxLength) {
    if (value != null && value.trim().length > maxLength) {
      return '${AppConstants.validationMaxLength} $maxLength characters';
    }
    return null;
  }

  static String? validateRange(String? value, int minLength, int maxLength) {
    final minError = validateMinLength(value, minLength);
    if (minError != null) return minError;

    return validateMaxLength(value, maxLength);
  }

  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppConstants.validationRequired;
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    if (value.trim().length > 50) {
      return 'Name must be less than 50 characters';
    }
    return null;
  }

  static String? validateTitle(String? value) {
    final rangeError = validateRange(value, 5, 100);
    if (rangeError != null) return rangeError;

    // Check for at least some alphabets
    if (!RegExp(r'[a-zA-Z\u0900-\u097F]').hasMatch(value!)) {
      return 'Title must contain letters';
    }
    return null;
  }

  static String? validateDescription(String? value) {
    final rangeError = validateRange(value, 10, 1000);
    if (rangeError != null) return rangeError;

    // Check for at least some alphabets
    if (!RegExp(r'[a-zA-Z\u0900-\u097F]').hasMatch(value!)) {
      return 'Description must contain letters';
    }
    return null;
  }

  static String? validateDropdown(String? value, List<String> options) {
    if (value == null || value.trim().isEmpty) {
      return AppConstants.validationRequired;
    }
    if (!options.contains(value)) {
      return 'Please select a valid option';
    }
    return null;
  }
}
