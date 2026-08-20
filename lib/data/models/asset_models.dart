class AssetUploadResponse {
  const AssetUploadResponse({
    required this.assetId,
    required this.url,
  });

  final String assetId;
  final String url;

  factory AssetUploadResponse.fromJson(Map<String, dynamic> json) =>
      AssetUploadResponse(
        assetId: json['assetId'] as String,
        url: json['url'] as String,
      );
}

class AssetListItem {
  const AssetListItem({
    required this.id,
    required this.type,
    required this.url,
    required this.createdAt,
  });

  final String id;
  final String type;
  final String url;
  final DateTime createdAt;

  factory AssetListItem.fromJson(Map<String, dynamic> json) => AssetListItem(
        id: json['id'] as String,
        type: json['type'] as String,
        url: json['url'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}
