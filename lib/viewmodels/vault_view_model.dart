import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/vault_item.dart';

/// ViewModel untuk mengelola file tersembunyi (vault).
class VaultViewModel extends ChangeNotifier {
  VaultViewModel();

  static const String _prefsKey = 'vault_items';

  final List<VaultItem> _items = [];

  List<VaultItem> get items => List.unmodifiable(_items);

  Future<void> load() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? raw = prefs.getString(_prefsKey);
    if (raw == null || raw.isEmpty) {
      return;
    }

    try {
      final List<dynamic> decoded = jsonDecode(raw) as List<dynamic>;
      _items
        ..clear()
        ..addAll(
          decoded
              .whereType<Map<String, dynamic>>()
              .map(VaultItem.fromJson),
        );
      notifyListeners();
    } catch (_) {
      // Jika parsing gagal, abaikan dan mulai dari kosong.
    }
  }

  Future<void> addFiles() async {
    final FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: <String>[
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
      if (<String>['.jpg', '.jpeg', '.png', '.gif'].contains(ext)) {
        type = VaultItemType.image;
      } else if (<String>['.mp4', '.mov', '.avi'].contains(ext)) {
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

    await _save();
    notifyListeners();
  }

  Future<void> deleteItem(VaultItem item) async {
    final File file = File(item.path);
    if (await file.exists()) {
      await file.delete();
    }
    _items.removeWhere((VaultItem e) => e.id == item.id);
    await _save();
    notifyListeners();
  }

  Future<void> _save() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(
      _items.map((VaultItem e) => e.toJson()).toList(),
    );
    await prefs.setString(_prefsKey, encoded);
  }
}

