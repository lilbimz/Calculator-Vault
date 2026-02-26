import 'dart:io';

import 'package:flutter/material.dart';

import '../models/vault_item.dart';
import '../viewmodels/vault_view_model.dart';

class VaultPage extends StatefulWidget {
  const VaultPage({super.key});

  @override
  State<VaultPage> createState() => _VaultPageState();
}

class _VaultPageState extends State<VaultPage> {
  late final VaultViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = VaultViewModel()..load();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vault'),
      ),
      body: AnimatedBuilder(
        animation: _viewModel,
        builder: (BuildContext context, _) {
          if (_viewModel.items.isEmpty) {
            return const Center(
              child: Text('Belum ada file tersembunyi'),
            );
          }
          return ListView.builder(
            itemCount: _viewModel.items.length,
            itemBuilder: (BuildContext context, int index) {
              final VaultItem item = _viewModel.items[index];
              return ListTile(
                leading: _buildLeading(item),
                title: Text(item.name),
                subtitle: Text(item.type.toString().split('.').last),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => _viewModel.deleteItem(item),
                ),
                onTap: () {
                  // Versi sederhana: belum ada viewer khusus.
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Viewer belum diimplementasikan'),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _viewModel.addFiles(),
        icon: const Icon(Icons.add),
        label: const Text('Tambah File'),
      ),
    );
  }

  Widget _buildLeading(VaultItem item) {
    switch (item.type) {
      case VaultItemType.image:
        return ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Image.file(
            File(item.path),
            width: 40,
            height: 40,
            fit: BoxFit.cover,
          ),
        );
      case VaultItemType.video:
        return const Icon(Icons.videocam_outlined);
      case VaultItemType.document:
        return const Icon(Icons.insert_drive_file_outlined);
    }
  }
}

