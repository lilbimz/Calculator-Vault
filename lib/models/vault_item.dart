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
}

