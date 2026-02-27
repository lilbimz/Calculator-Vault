import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../models/vault_item.dart';
import '../viewmodels/calculator_view_model.dart';
import '../viewmodels/vault_view_model.dart';
import 'media_viewer_page.dart';

class VaultPage extends StatefulWidget {
  const VaultPage({
    super.key,
    required this.calculatorViewModel,
  });

  final CalculatorViewModel calculatorViewModel;

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
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.lock_reset),
            tooltip: 'Ganti PIN',
            onPressed: _showChangePinDialog,
          ),
        ],
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
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (BuildContext context) => MediaViewerPage(
                        item: item,
                      ),
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
        return _VideoThumbnail(path: item.path);
      case VaultItemType.document:
        return const Icon(Icons.insert_drive_file_outlined);
    }
  }

  Future<void> _showChangePinDialog() async {
    final TextEditingController oldPinController = TextEditingController();
    final TextEditingController newPinController = TextEditingController();
    final TextEditingController confirmPinController = TextEditingController();

    String? errorText;

    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (
            BuildContext context,
            void Function(void Function()) setState,
          ) {
            return AlertDialog(
              title: const Text('Ganti PIN Vault'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextField(
                    controller: oldPinController,
                    decoration: const InputDecoration(
                      labelText: 'PIN lama',
                    ),
                    obscureText: true,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: newPinController,
                    decoration: const InputDecoration(
                      labelText: 'PIN baru',
                    ),
                    obscureText: true,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: confirmPinController,
                    decoration: const InputDecoration(
                      labelText: 'Konfirmasi PIN baru',
                    ),
                    obscureText: true,
                    keyboardType: TextInputType.number,
                  ),
                  if (errorText != null) ...<Widget>[
                    const SizedBox(height: 8),
                    Text(
                      errorText!,
                      style: const TextStyle(
                        color: Colors.redAccent,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Batal'),
                ),
                TextButton(
                  onPressed: () async {
                    final String oldPin = oldPinController.text.trim();
                    final String newPin = newPinController.text.trim();
                    final String confirmPin = confirmPinController.text.trim();

                    if (oldPin != widget.calculatorViewModel.secretPin) {
                      setState(() {
                        errorText = 'PIN lama salah';
                      });
                      return;
                    }
                    if (newPin.isEmpty || confirmPin.isEmpty) {
                      setState(() {
                        errorText = 'PIN baru tidak boleh kosong';
                      });
                      return;
                    }
                    if (newPin != confirmPin) {
                      setState(() {
                        errorText = 'PIN baru dan konfirmasi tidak sama';
                      });
                      return;
                    }

                    await widget.calculatorViewModel.updatePin(newPin);
                    if (!mounted) return;
                    Navigator.of(this.context, rootNavigator: true).pop();
                    ScaffoldMessenger.of(this.context).showSnackBar(
                      const SnackBar(
                        content: Text('PIN berhasil diubah'),
                      ),
                    );
                  },
                  child: const Text('Simpan'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _VideoThumbnail extends StatefulWidget {
  const _VideoThumbnail({required this.path});

  final String path;

  @override
  State<_VideoThumbnail> createState() => _VideoThumbnailState();
}

class _VideoThumbnailState extends State<_VideoThumbnail> {
  late final VideoPlayerController _controller;
  late final Future<void> _initializeFuture;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(File(widget.path));
    _initializeFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: SizedBox(
        width: 40,
        height: 40,
        child: FutureBuilder<void>(
          future: _initializeFuture,
          builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
            if (snapshot.connectionState == ConnectionState.done &&
                _controller.value.isInitialized) {
              return Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: _controller.value.size.width,
                      height: _controller.value.size.height,
                      child: VideoPlayer(_controller),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Container(
                      margin: const EdgeInsets.all(2),
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.play_arrow,
                        size: 12,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              );
            }
            if (snapshot.hasError) {
              return const Icon(
                Icons.videocam_off_outlined,
                size: 20,
              );
            }
            return const Center(
              child: SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            );
          },
        ),
      ),
    );
  }
}
