class ApiUrl {
  //Old backend endpoints
  // static const String verifySingup = "$baseUrl/auth/verifySignupOtp";
  // static const String forgotPassword = "$baseUrl/auth/forgotPassword";
  // static const String verifyForgotPasswordOtp = "$baseUrl/auth/verifyForgotPasswordOtp";
  // static const String resetPassword = "$baseUrl/auth/ResetPassword";

  // //check Auth
  // static const String checkAuth = "$baseUrl/auth/checkAuth";

  // //OTP
  // static const String resendOtp = "$baseUrl/otp/resendOtp";

  //User
  // static const String userProfile = "$baseUrl/user/profile";
  // static const String updateUserProfile = "$baseUrl/user/updateProfile";

  //Python FastAPI
  // static const String analysisUpload = "$fastUrl/api/v1/analysis/upload";

  // static const baseUrl = "http://192.168.18.148:5000";

  // static const baseUrl = "http://192.168.0.6:5000";
  static const baseUrl = "http://10.200.174.164:5000";

  static const String login = "$baseUrl/auth/login";
  static const String signup = "$baseUrl/auth/register";
  static const String me = "$baseUrl/auth/me";
  static const String analysis = "$baseUrl/analysis/upload-file";
  static const String allWorkspaces = "$baseUrl/workspace";
  static const String createWorkspace = "$baseUrl/workspace/create";
  static const String joinWorkspace = "$baseUrl/workspace/join";

  // Comments
  static const String comments = "$baseUrl/workspace/comments";
  static const String deleteComment = "$baseUrl/workspace/comments";
}
