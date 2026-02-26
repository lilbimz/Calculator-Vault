import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../models/vault_item.dart';

/// ViewModel untuk mengelola file tersembunyi (vault).
class VaultViewModel extends ChangeNotifier {
  final List<VaultItem> _items = [];

  List<VaultItem> get items => List.unmodifiable(_items);

  Future<void> load() async {
    // Versi awal: tidak ada persistensi metadata.
    // Di masa depan bisa ditambah menyimpan ke file JSON.
  }

  Future<void> addFiles() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: [
        'jpg',
        'jpeg',
        'png',
        'gif',
        'mp4',
        'mov',
        'avi',
        'pdf',
        'doc',
        'docx',
      ],
    );
    if (result == null) return;

    final Directory appDir = await getApplicationDocumentsDirectory();
    final Directory vaultDir = Directory(p.join(appDir.path, 'vault'));
    if (!await vaultDir.exists()) {
      await vaultDir.create(recursive: true);
    }

    for (final PlatformFile file in result.files) {
      if (file.path == null) continue;
      final String fileName = file.name;
      final String newPath = p.join(vaultDir.path, fileName);

      await File(file.path!).copy(newPath);

      final String ext = p.extension(fileName).toLowerCase();
      final VaultItemType type;
      if (['.jpg', '.jpeg', '.png', '.gif'].contains(ext)) {
        type = VaultItemType.image;
      } else if (['.mp4', '.mov', '.avi'].contains(ext)) {
        type = VaultItemType.video;
      } else {
        type = VaultItemType.document;
      }

      _items.add(
        VaultItem(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          name: fileName,
          path: newPath,
          type: type,
        ),
      );
    }

    notifyListeners();
  }

  Future<void> deleteItem(VaultItem item) async {
    final File file = File(item.path);
    if (await file.exists()) {
      await file.delete();
    }
    _items.removeWhere((VaultItem e) => e.id == item.id);
    notifyListeners();
  }
}

