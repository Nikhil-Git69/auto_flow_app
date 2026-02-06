class SignupModel {
  SignupModel({
    required this.success,
    required this.code,
    required this.message,
    this.data,
  });

  final bool success;
  final int code;
  final String message;
  final SignupData? data;

  factory SignupModel.fromJson(Map<String, dynamic> json) {
    return SignupModel(
      success: json["success"] ?? false,
      code: json["code"] ?? 0,
      message: json["message"] ?? "",
      data: json["data"] == null
          ? null
          : SignupData.fromJson(json["data"]),
    );
  }
}

class SignupData {
  SignupData({
    required this.email,
  });

  final String email;

  factory SignupData.fromJson(Map<String, dynamic> json) {
    return SignupData(
      email: json["email"] ?? "",
    );
  }
}
