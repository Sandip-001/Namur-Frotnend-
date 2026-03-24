extension StringCasingExtension on String {
  String toTitleCase() {
    if (trim().isEmpty) return this;
    
    return split(' ').map((word) {
      if (word.trim().isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }
}

extension NullableStringCasingExtension on String? {
  String? toTitleCase() {
    if (this == null) return null;
    return this!.toTitleCase();
  }
}
