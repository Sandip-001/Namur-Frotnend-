// booking_model.dart

// =======================
// Booking API Response
// =======================

import 'package:the_namur_frontend/models/machinery_ad_model.dart';

class BookingResponse {
  final bool success;
  final int count;
  final List<BookingModel> data;

  BookingResponse({
    required this.success,
    required this.count,
    required this.data,
  });

  factory BookingResponse.fromJson(Map<String, dynamic> json) {
    return BookingResponse(
      success: json['success'] ?? false,
      count: json['count'] ?? 0,
      data: (json['data'] as List? ?? [])
          .map((e) => BookingModel.fromJson(e))
          .toList(),
    );
  }
}

// =======================
// Booking Model
// =======================

class BookingModel {
  final int bookingId;
  final String bookingDate;
  final String startTime;
  final String endTime;
  final int totalHours;
  final String status;
  final String createdAt;
  final BookedBy bookedBy;
  final Land land;
  final MachineryAdModel ad;

  BookingModel({
    required this.bookingId,
    required this.bookingDate,
    required this.startTime,
    required this.endTime,
    required this.totalHours,
    required this.status,
    required this.createdAt,
    required this.bookedBy,
    required this.land,
    required this.ad,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      bookingId: json['booking_id'],
      bookingDate: json['booking_date'] ?? '',
      startTime: json['start_time'] ?? '',
      endTime: json['end_time'] ?? '',
      totalHours: json['total_hours'] ?? 0,
      status: json['status'] ?? '',
      createdAt: json['created_at'] ?? '',
      bookedBy: BookedBy.fromJson(json['booked_by']),
      land: Land.fromJson(json['land']),
      ad: MachineryAdModel.fromJson(json['ad']),
    );
  }
}

// =======================
// Booked By (User)
// =======================

class BookedBy {
  final int id;
  final String username;
  final String email;
  final String mobile;
  final String profileImageUrl;

  BookedBy({
    required this.id,
    required this.username,
    required this.email,
    required this.mobile,
    required this.profileImageUrl,
  });

  factory BookedBy.fromJson(Map<String, dynamic> json) {
    return BookedBy(
      id: json['id'],
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      mobile: json['mobile'] ?? '',
      profileImageUrl: json['profile_image_url'] ?? '',
    );
  }
}

// =======================
// Land Model
// =======================

class Land {
  final int id;
  final String landName;
  final String district;
  final String taluk;
  final String village;
  final String panchayat;
  final String farmSize;

  Land({
    required this.id,
    required this.landName,
    required this.district,
    required this.taluk,
    required this.village,
    required this.panchayat,
    required this.farmSize,
  });

  factory Land.fromJson(Map<String, dynamic> json) {
    return Land(
      id: json['id'],
      landName: json['land_name'] ?? '',
      district: json['district'] ?? '',
      taluk: json['taluk'] ?? '',
      village: json['village'] ?? '',
      panchayat: json['panchayat'] ?? '',
      farmSize: json['farm_size'] ?? '',
    );
  }
}

// =======================
// Booking Ad (Lightweight)
// =======================

class BookingAd {
  final int id;
  final String adUid;
  final String title;
  final String price;
  final String quantity;
  final String? unit;
  final String description;
  final String adType;
  final String status;
  final String createdAt;
  final List<AdImage> images;
  final AdCreator creator;

  BookingAd({
    required this.id,
    required this.adUid,
    required this.title,
    required this.price,
    required this.quantity,
    this.unit,
    required this.description,
    required this.adType,
    required this.status,
    required this.createdAt,
    required this.images,
    required this.creator,
  });

  factory BookingAd.fromJson(Map<String, dynamic> json) {
    return BookingAd(
      id: json['id'],
      adUid: json['ad_uid'] ?? '',
      title: json['title'] ?? '',
      price: json['price'] ?? '',
      quantity: json['quantity'] ?? '',
      unit: json['unit'],
      description: json['description'] ?? '',
      adType: json['ad_type'] ?? '',
      status: json['status'] ?? '',
      createdAt: json['created_at'] ?? '',
      images: (json['images'] as List? ?? [])
          .map((e) => AdImage.fromJson(e))
          .toList(),
      creator: AdCreator.fromJson(json['creator']),
    );
  }
}

// =======================
// Ad Image
// =======================

class AdImage {
  final String url;
  final String publicId;

  AdImage({
    required this.url,
    required this.publicId,
  });

  factory AdImage.fromJson(Map<String, dynamic> json) {
    return AdImage(
      url: json['url'] ?? '',
      publicId: json['public_id'] ?? '',
    );
  }
}

// =======================
// Ad Creator
// =======================

class AdCreator {
  final String role;
  final String name;
  final String email;
  final String mobile;
  final String profileImage;

  AdCreator({
    required this.role,
    required this.name,
    required this.email,
    required this.mobile,
    required this.profileImage,
  });

  factory AdCreator.fromJson(Map<String, dynamic> json) {
    return AdCreator(
      role: json['role'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      mobile: json['mobile'] ?? '',
      profileImage: json['profile_image'] ?? '',
    );
  }
}
