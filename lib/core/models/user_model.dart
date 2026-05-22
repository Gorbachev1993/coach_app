class UserModel {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String role;
  final String? gender;
  final double? heightCm;
  final double? currentWeightKg;
  final double? bodyFatPercentage;
  final double? waistCm;
  final double? hipCm;
  final String? experienceLevel;
  final String? jobType;
  final String? primaryGoal;
  final int? workoutsPerWeek;
  final List<String>? workoutTypes;
  final Map<String, dynamic>? metabolicProfile;

  UserModel({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.role,
    this.gender,
    this.heightCm,
    this.currentWeightKg,
    this.bodyFatPercentage,
    this.waistCm,
    this.hipCm,
    this.experienceLevel,
    this.jobType,
    this.primaryGoal,
    this.workoutsPerWeek,
    this.workoutTypes,
    this.metabolicProfile,
  });

  Map<String, dynamic> toJson() => {
    'id': id, 'email': email, 'firstName': firstName,
    'lastName': lastName, 'role': role, 'gender': gender,
    'heightCm': heightCm, 'currentWeightKg': currentWeightKg,
    'bodyFatPercentage': bodyFatPercentage, 'waistCm': waistCm,
    'hipCm': hipCm, 'experienceLevel': experienceLevel,
    'jobType': jobType, 'primaryGoal': primaryGoal,
    'workoutsPerWeek': workoutsPerWeek, 'workoutTypes': workoutTypes,
    'metabolicProfile': metabolicProfile,
  };

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json['id'] ?? '',
    email: json['email'] ?? '',
    firstName: json['firstName'] ?? '',
    lastName: json['lastName'] ?? '',
    role: json['role'] ?? 'client',
    gender: json['gender'],
    heightCm: json['heightCm']?.toDouble(),
    currentWeightKg: json['currentWeightKg']?.toDouble(),
    bodyFatPercentage: json['bodyFatPercentage']?.toDouble(),
    waistCm: json['waistCm']?.toDouble(),
    hipCm: json['hipCm']?.toDouble(),
    experienceLevel: json['experienceLevel'],
    jobType: json['jobType'],
    primaryGoal: json['primaryGoal'],
    workoutsPerWeek: json['workoutsPerWeek'],
    workoutTypes: json['workoutTypes'] != null ? List<String>.from(json['workoutTypes']) : null,
    metabolicProfile: json['metabolicProfile'] != null ? Map<String, dynamic>.from(json['metabolicProfile']) : null,
  );
}
