class ApiUrl {

  // static const  baseUrl = "http://192.168.1.7:6969";
  //my hotspot
  // static const  baseUrl = "http://172.20.10.14:6969";

  //garvits hotspot
  // static const  baseUrl = "http://10.187.101.164:6969";



  static const baseUrl = "http://192.168.0.6:5000";

  //Auth APIs
  static const String login = "$baseUrl/api/auth/login";
  static const String signup = "$baseUrl/api/auth/signup";
  static const String verifySingup = "$baseUrl/api/auth/verifySignupOtp";
  static const String forgotPassword = "$baseUrl/api/auth/forgotPassword";
  static const String verifyForgotPasswordOtp = "$baseUrl/api/auth/verifyForgotPasswordOtp";
  static const String resetPassword = "$baseUrl/api/auth/ResetPassword";
  //check Auth
  static const String checkAuth ="$baseUrl/api/auth/checkAuth";

  //OTP
  static const String resendOtp = "$baseUrl/api/otp/resendOtp";

  //User
  static const String userProfile = "$baseUrl/api/user/profile";
  static const String updateUserProfile = "$baseUrl/api/user/updateProfile";

  //Python FastAPI
  static const String analysisUpload = "$baseUrl/api/v1/analysis/upload";

}