class LandModel {
  final int id;
  final int userId;
  final String landName;
  final String district;
  final String taluk;
  final String village;
  final String panchayat;
  final String surveyNo;
  final String hissaNo;
  final String farmSize;
  final String createdAt;

  LandModel({
    required this.id,
    required this.userId,
    required this.landName,
    required this.district,
    required this.taluk,
    required this.village,
    required this.panchayat,
    required this.surveyNo,
    required this.hissaNo,
    required this.farmSize,
    required this.createdAt,
  });

  factory LandModel.fromJson(Map<String, dynamic> json) {
    return LandModel(
      id: json["id"],
      userId: json["user_id"],
      landName: json["land_name"],
      district: json["district"],
      taluk: json["taluk"],
      village: json["village"],
      panchayat: json["panchayat"],
      surveyNo: json["survey_no"],
      hissaNo: json["hissa_no"],
      farmSize: json["farm_size"].toString(),
      createdAt: json["created_at"],
    );
  }
}
