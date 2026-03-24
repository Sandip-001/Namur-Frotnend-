// lib/core/api/api_constants.dart

class ApiConstants {
  // --------------------------
  // BASE URL
  // --------------------------
  // static const String baseUrl = "https://namur-backend-f09v.onrender.com/api";
  static const String baseUrl = "https://api.inkaanalysis.com/api";

  // --------------------------
  // CATEGORY APIs
  // --------------------------
  static const String getCategories = "$baseUrl/categories/";

  // Subcategories
  static String subCategoryByCategory(int categoryId) =>
      "$baseUrl/subcategories/category/$categoryId?exclude=Medicine,Fertilizer,Seeds";

  static String productDetails(int productId) => "$baseUrl/products/$productId";
  // --------------------------
  // PRODUCT APIs
  // --------------------------
  // Products
  static String productsBySubCategory(int subCategoryId) =>
      "$baseUrl/products/subcategory/$subCategoryId";
  static const String getProductDetails = "$baseUrl/products/details";

  static String groupsByDistrict(String district) {
    return "$baseUrl/groups/by-district/$district";
  }

  static String landProductsByCategoryForLand(
    String userId,
    int landId,
    String category,
  ) {
    return "$baseUrl/land-product/$userId/$landId?category_name=$category";
  }

  static String userBarcode(String userId) {
    return "$baseUrl/user/barcode/$userId";
  }

  static String filterAdsBySubcategory({
    required String district,
    required String subcategoryName,
  }) {
    return "$baseUrl/ads/filter"
        "?status=active"
        "&districts=[\"$district\"]"
        "&subcategoryName=$subcategoryName";
  }

  static String filteredBySubcategory({
    required String subcategoryName,
    required String sort,
    String? district,
  }) {
    String url =
        "$baseUrl/ads/filtered-by-subcategory"
        "?subcategory_name=$subcategoryName"
        "&sort=$sort";
    if (district != null && district.isNotEmpty) {
      url += "&district=$district";
    }
    return url;
  }
  // --------------------------
  // AUTH APIs
  // --------------------------

  // Auth
  static const String loginWithGoogle = "$baseUrl/user/login-google";

  // User
  static const String saveBasicDetails = "$baseUrl/user/save-basic";

  //verify otp
  static const String verifyOtp = "$baseUrl/user/verify-otp";

  //save-token

  static const String saveToken = "$baseUrl/notifications/save-token";

  //delete
  static const String deleteUser = "$baseUrl/user/delete";

  //Profile

  // 🔹 UPLOAD PROFILE
  static const String uploadProfile = "$baseUrl/user/upload-profile";

  // 🔹 FETCH USER BY FIREBASE UID
  static const String getUserByFirebase = "$baseUrl/user/firebase";

  static const String saveAddressDetails = "$baseUrl/user/update-extra";

  static const String saveLandDetails = "$baseUrl/user/update-extra";

  //delete
  static String deleteLandProduct(int productId) {
    return "$baseUrl/land-product/delete/$productId";
  }

  static String landProductsByUser(String userId) {
    return "$baseUrl/land-product/user/$userId";
  }

  static const String enquiry = "$baseUrl/enquiry/";

  // LAND APIs
  static const createLand = "$baseUrl/land/create";
  static const getLandsByUser = "$baseUrl/land/user"; // append /:id
  static const getLandById = "$baseUrl/land"; // append /:id
  static const updateLand = "$baseUrl/land"; // append /:id
  static const deleteLand = "$baseUrl/land"; // append /:id

  static const String getProductsByCategory = "$baseUrl/products/by-category";

  //fetch product based and user id and land id
  static String landProducts(int userId, int landId) =>
      "$baseUrl/land-product/$userId/$landId";

  // New API: fetch products by category
  static String landProductsByCategory(int userId, String category) =>
      "$baseUrl/land-product/user/$userId?category_name=$category";

  static const String getLandProducts = "$baseUrl/land-product";

  static const createLandProduct = "$baseUrl/land-product/create";

  //fetch news

  static const newsList = "$baseUrl/news";

  ///create ads
  static const createAds = "$baseUrl/ads";

  static String adDetails(String adId) => "$baseUrl/ads/$adId";

  static String filterAds({required String userId, required String productId}) {
    return "$baseUrl/ads/filter?userType=user&userId=$userId&productId=$productId";
  }

  static String cropPlanByUser(String userId) =>
      "$baseUrl/crop-plan/user/$userId";

  static String createcropPlan() => "$baseUrl/crop-plan";

  static String activeAdsByDistrict(String district) =>
      "$baseUrl/ads/active/by-district?district=$district";

  static const String notificationLogs = "$baseUrl/notifications/logs";

  static String notificationsByUser(String userId) =>
      "$baseUrl/notifications/user/$userId";

  static String cropCalendarByProduct(int productId) =>
      "$baseUrl/crop-calendars/product/$productId";

  static String filterAdsByDistrict(String district) =>
      '$baseUrl/ads/filter?districts=["Belgaum"]&status=active';

  static String filterAdminAds(String district) =>
      '$baseUrl/ads/filter?userType=admin&districts=["Belgaum"]&status=active';

  static String getCropPlanById(int planId) => "$baseUrl/crop-plan/$planId";

  static String getFilteredAds({
    required String correctType,
    required int productId,
    required String district,
  }) {
    return "$baseUrl/ads/filter"
        "?status=active"
        "&ad_type=$correctType"
        "&productId=$productId"
        "&districts=[\"Belgaum\"]";
  }

  static String landProductByUserFood(String userId) =>
      "${baseUrl}land-product/user/$userId?category_name=food";
  // --------------------------
  // FARMERS / FRIENDS
  // --------------------------
  static const String totalFarmers = "$baseUrl/farmers/count";

  // --------------------------
  // MACHINE / ANIMAL / FOOD
  // --------------------------
  static const String getMachineDetails = "$baseUrl/machine/details";
  static const String getAnimalDetails = "$baseUrl/animal/details";
  static const String getFoodDetails = "$baseUrl/food/details";

  // --------------------------
  // SEARCH API
  // --------------------------
  static const String search = "$baseUrl/search";
}
