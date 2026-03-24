import 'dart:convert';

class AdsFilter {
  final int productId;
  final String? district;
  final String? taluk;
  final String? village;
  final String? panchayat;
  final String? sort; // price_low_to_high | price_high_to_low
  final List<String>? breeds;
  final String? machineCondition;
  AdsFilter({
    required this.productId,
    this.district,
    this.taluk,
    this.village,
    this.panchayat,
    this.sort,
    this.breeds,
    this.machineCondition,
  });

  Map<String, String> toQueryParams() {
    final Map<String, String> params = {
      "product_id": productId.toString(),
    };

    if (district != null && district!.isNotEmpty) {
      params["district"] = district!;
    }
    if (taluk != null && taluk!.isNotEmpty) {
      params["taluk"] = taluk!;
    }
    if (village != null && village!.isNotEmpty) {
      params["village"] = village!;
    }
    if (panchayat != null && panchayat!.isNotEmpty) {
      params["panchayat"] = panchayat!;
    }
    if (sort != null) {
      params["sort"] = sort!;
    }
    /// ✅ FIX HERE
    if (breeds != null && breeds!.isNotEmpty) {
      params["breed"] = jsonEncode(
        breeds!.map((e) => e.toString()).toList(),
      );
    }
    if (machineCondition != null && machineCondition!.isNotEmpty) {
      params["machine_condition"] = machineCondition!;
    }

    return params;
  }
}
