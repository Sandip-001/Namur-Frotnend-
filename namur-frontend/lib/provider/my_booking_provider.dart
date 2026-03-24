import 'dart:convert';

import 'package:flutter/cupertino.dart';

import '../models/booking_model.dart';
import 'package:http/http.dart' as http;
class MyBookingsProvider extends ChangeNotifier {
  bool isLoading = false;
  List<BookingModel> bookings = [];

  Future<void> fetchMyBookings(String userId) async {
    isLoading = true;
    notifyListeners();

    final url = Uri.parse(
      'https://api.inkaanalysis.com/api/book-ads/user/$userId',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        bookings = (data['data'] as List)
            .map((e) => BookingModel.fromJson(e))
            .toList();
      }
    } catch (_) {}

    isLoading = false;
    notifyListeners();
  }
}
