enum VaultItemType {
  image,
  video,
  document,
}

class VaultItem {
  VaultItem({
    required this.id,
    required this.name,
    required this.path,
    required this.type,
  });

  final String id;
  final String name;
  final String path;
  final VaultItemType type;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'path': path,
      'type': type.name,
    };
  }

  factory VaultItem.fromJson(Map<String, dynamic> json) {
    final String typeString = json['type'] as String? ?? 'document';
    final VaultItemType parsedType = VaultItemType.values.firstWhere(
      (VaultItemType t) => t.name == typeString,
      orElse: () => VaultItemType.document,
    );
    return VaultItem(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      path: json['path'] as String? ?? '',
      type: parsedType,
    );
  }
}

