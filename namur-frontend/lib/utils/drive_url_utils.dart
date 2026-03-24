String normalizeUrl(String url) {
  final clean = url.trim();
  if (clean.isEmpty) return clean;

  if (clean.startsWith("http://") || clean.startsWith("https://")) {
    return clean;
  }

  return "https://$clean";
}

String? extractDriveFileId(String url) {
  final normalized = normalizeUrl(url);
  if (!normalized.contains("drive.google.com")) return null;

  try {
    final fileMatch = RegExp(r"/file/d/([^/]+)").firstMatch(normalized);
    if (fileMatch != null && fileMatch.groupCount >= 1) {
      return fileMatch.group(1);
    }

    final uri = Uri.parse(normalized);
    final id = uri.queryParameters["id"];
    if (id != null && id.isNotEmpty) {
      return id;
    }

    final ucMatch = RegExp(r"/uc\?[^#]*id=([^&]+)").firstMatch(normalized);
    if (ucMatch != null && ucMatch.groupCount >= 1) {
      return ucMatch.group(1);
    }
  } catch (_) {
    return null;
  }

  return null;
}

String toDirectOpenUrl(String url) {
  final normalized = normalizeUrl(url);
  final driveId = extractDriveFileId(normalized);

  if (driveId == null) {
    return normalized;
  }

  // Drive preview URL opens inline instead of triggering a download flow.
  return "https://drive.google.com/file/d/$driveId/preview";
}
