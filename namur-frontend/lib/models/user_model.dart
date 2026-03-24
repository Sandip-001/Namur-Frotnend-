class LoginResponse {
  String? message;
  AuthUser? user;

  LoginResponse({this.message, this.user});

  LoginResponse.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    user = json['user'] != null ? AuthUser.fromJson(json['user']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['message'] = message;
    if (user != null) {
      data['user'] = user!.toJson();
    }
    return data;
  }
}

class AuthUser {
  int? id;
  String? firebaseUid;
  String? email;
  String? username;
  String? mobile;
  String? district;
  String? profession;
  int? age;
  String? taluk;
  String? village;
  String? panchayat;
  String? profileImageUrl;
  String? profileImagePublicId;
  bool? isVerified;
  bool? isBlocked;
  String? createdAt;
  double? profileProgress; // ✅ Add profile progress

  AuthUser({
    this.id,
    this.firebaseUid,
    this.email,
    this.username,
    this.mobile,
    this.district,
    this.profession,
    this.age,
    this.taluk,
    this.village,
    this.panchayat,
    this.profileImageUrl,
    this.profileImagePublicId,
    this.isVerified,
    this.isBlocked,
    this.createdAt,
    this.profileProgress, // ✅ Constructor
  });

  AuthUser.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    firebaseUid = json['firebase_uid'];
    email = json['email'];
    username = json['username'];
    mobile = json['mobile'];
    district = json['district'];
    profession = json['profession'];
    age = json['age'];
    taluk = json['taluk']?.toString();
    village = json['village']?.toString();
    panchayat = json['panchayat']?.toString();
    profileImageUrl = json['profile_image_url'];
    profileImagePublicId = json['profile_image_public_id']?.toString();
    isVerified = json['is_verified'];
    isBlocked = json['is_blocked'];
    createdAt = json['created_at'];
    profileProgress = (json['profile_progress'] != null)
        ? double.tryParse(json['profile_progress'].toString())
        : 0.0; // ✅ parse profile_progress
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['id'] = id;
    data['firebase_uid'] = firebaseUid;
    data['email'] = email;
    data['username'] = username;
    data['mobile'] = mobile;
    data['district'] = district;
    data['profession'] = profession;
    data['age'] = age;
    data['taluk'] = taluk;
    data['village'] = village;
    data['panchayat'] = panchayat;
    data['profile_image_url'] = profileImageUrl;
    data['profile_image_public_id'] = profileImagePublicId;
    data['is_verified'] = isVerified;
    data['is_blocked'] = isBlocked;
    data['created_at'] = createdAt;
    data['profile_progress'] = profileProgress; // ✅ include in toJson
    return data;
  }

  AuthUser copyWith({
    int? id,
    String? firebaseUid,
    String? email,
    String? username,
    String? mobile,
    String? district,
    String? profession,
    int? age,
    String? taluk,
    String? village,
    String? panchayat,
    String? profileImageUrl,
    String? profileImagePublicId,
    bool? isVerified,
    bool? isBlocked,
    String? createdAt,
    double? profileProgress, // ✅ copyWith field
  }) {
    return AuthUser(
      id: id ?? this.id,
      firebaseUid: firebaseUid ?? this.firebaseUid,
      email: email ?? this.email,
      username: username ?? this.username,
      mobile: mobile ?? this.mobile,
      district: district ?? this.district,
      profession: profession ?? this.profession,
      age: age ?? this.age,
      taluk: taluk ?? this.taluk,
      village: village ?? this.village,
      panchayat: panchayat ?? this.panchayat,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      profileImagePublicId: profileImagePublicId ?? this.profileImagePublicId,
      isVerified: isVerified ?? this.isVerified,
      isBlocked: isBlocked ?? this.isBlocked,
      createdAt: createdAt ?? this.createdAt,
      profileProgress: profileProgress ?? this.profileProgress, // ✅
    );
  }
}
