class ApiUrl {

  // static const  baseUrl = "http://192.168.1.7:6969";
  //my hotspot
  // static const  baseUrl = "http://172.20.10.14:6969";

  //garvits hotspot
  // static const  baseUrl = "http://10.187.101.164:6969";


  static const baseUrl = "http://192.168.21.231:5000";
  static const fastUrl = "http://192.168.21.231:6969";

  //Auth APIs
  static const String login = "$baseUrl/api/auth/login";
  static const String signup = "$baseUrl/api/auth/signup";
  static const String verifySingup = "$baseUrl/api/auth/verifySignupOtp";
  static const String forgotPassword = "$baseUrl/api/auth/forgotPassword";
  static const String verifyForgotPasswordOtp = "$baseUrl/api/auth/verifyForgotPasswordOtp";
  static const String resetPassword = "$baseUrl/api/auth/ResetPassword";

  //check Auth
  static const String checkAuth = "$baseUrl/api/auth/checkAuth";

  //OTP
  static const String resendOtp = "$baseUrl/api/otp/resendOtp";

  //User
  static const String userProfile = "$baseUrl/api/user/profile";
  static const String updateUserProfile = "$baseUrl/api/user/updateProfile";


  //Analysis History
  // static const String analysisHistory = "$baseUrl/api/analysis/history";

  //Workspace
  // static const String createWorkspace = "$baseUrl/api/workspace/create";
  // static const String updateWorkspace = "$baseUrl/api/workspace/update";
  // static const String deleteWorkspace = "$baseUrl/api/workspace/delete";
  // static const String inviteWorkspace = "$baseUrl/api/workspace/invite";

  //Submission
  // static const String uploadSubmission = "$baseUrl/api/submission/upload";
  // static const String replaceSubmission = "$baseUrl/api/submission/replace";
  // static const String deleteSubmission = "$baseUrl/api/submission/delete";

  //Note to Submission
  // static const String createNote = "$baseUrl/api/note/create";
  // static const String updateNote = "$baseUrl/api/note/update";
  // static const String deleteNote = "$baseUrl/api/note/delete";




  //Python FastAPI
  static const String analysisUpload = "$fastUrl/api/v1/analysis/upload";

}