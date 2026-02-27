import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../models/vault_item.dart';

class MediaViewerPage extends StatefulWidget {
  const MediaViewerPage({
    super.key,
    required this.item,
  });

  final VaultItem item;

  @override
  State<MediaViewerPage> createState() => _MediaViewerPageState();
}

class _MediaViewerPageState extends State<MediaViewerPage>
    with SingleTickerProviderStateMixin {
  VideoPlayerController? _videoController;
  Future<void>? _initializeVideoFuture;
  bool _showVideoControls = true;

  late final TransformationController _imageTransformationController;
  late final AnimationController _zoomAnimationController;
  Animation<Matrix4>? _zoomAnimation;
  TapDownDetails? _doubleTapDetails;
  Size _imageViewportSize = Size.zero;

  @override
  void initState() {
    super.initState();
    _imageTransformationController = TransformationController();
    _zoomAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    _zoomAnimationController.addListener(() {
      final Animation<Matrix4>? animation = _zoomAnimation;
      if (animation == null) return;
      _imageTransformationController.value = animation.value;
    });

    if (widget.item.type == VaultItemType.video) {
      final VideoPlayerController controller =
          VideoPlayerController.file(File(widget.item.path));
      _videoController = controller;
      _initializeVideoFuture = controller.initialize().then((_) {
        if (!mounted) return;
        // Pastikan orientasi/aspectRatio sudah siap.
        setState(() {});
      });
    }
  }

  @override
  void dispose() {
    _zoomAnimationController.dispose();
    _imageTransformationController.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.item.name),
      ),
      backgroundColor: Colors.black,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: _buildContent(),
        ),
      ),
    );
  }

  Widget _buildContent() {
    switch (widget.item.type) {
      case VaultItemType.image:
        return LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            _imageViewportSize = constraints.biggest;
            return GestureDetector(
              onDoubleTapDown: (TapDownDetails details) {
                _doubleTapDetails = details;
              },
              onDoubleTap: _onDoubleTapZoom,
              child: InteractiveViewer(
                transformationController: _imageTransformationController,
                minScale: 0.5,
                maxScale: 4,
                onInteractionStart: (_) {
                  // Jika user mulai pinch/pan saat animasi, hentikan animasinya.
                  if (_zoomAnimationController.isAnimating) {
                    _zoomAnimationController.stop();
                  }
                },
                child: Image.file(
                  File(widget.item.path),
                  fit: BoxFit.contain,
                ),
              ),
            );
          },
        );
      case VaultItemType.video:
        if (_videoController == null || _initializeVideoFuture == null) {
          return const CircularProgressIndicator();
        }
        return FutureBuilder<void>(
          future: _initializeVideoFuture,
          builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }
            if (_videoController == null ||
                !_videoController!.value.isInitialized) {
              return const Text(
                'Gagal memuat video',
                style: TextStyle(color: Colors.white),
              );
            }
            final VideoPlayerController controller = _videoController!;
            final double aspect =
                controller.value.aspectRatio == 0 ? 16 / 9 : controller.value.aspectRatio;
            return AspectRatio(
              aspectRatio: aspect,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  setState(() {
                    _showVideoControls = !_showVideoControls;
                  });
                },
                child: ValueListenableBuilder<VideoPlayerValue>(
                  valueListenable: controller,
                  builder: (
                    BuildContext context,
                    VideoPlayerValue value,
                    Widget? _,
                  ) {
                    return Stack(
                      fit: StackFit.expand,
                      children: <Widget>[
                        VideoPlayer(controller),
                        if (_showVideoControls) ...<Widget>[
                          // Center play/pause button
                          Center(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black45,
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                iconSize: 56,
                                icon: Icon(
                                  value.isPlaying
                                      ? Icons.pause
                                      : Icons.play_arrow,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  if (value.isPlaying) {
                                    controller.pause();
                                  } else {
                                    controller.play();
                                  }
                                },
                              ),
                            ),
                          ),
                          // Bottom progress bar + duration
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: <Color>[
                                    Colors.transparent,
                                    Colors.black54,
                                  ],
                                ),
                              ),
                              child: Row(
                                children: <Widget>[
                                  Text(
                                    _formatDuration(value.position),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: VideoProgressIndicator(
                                      controller,
                                      allowScrubbing: true,
                                      padding: EdgeInsets.zero,
                                      colors: const VideoProgressColors(
                                        playedColor: Colors.redAccent,
                                        bufferedColor: Colors.white38,
                                        backgroundColor: Colors.white24,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _formatDuration(value.duration),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    );
                  },
                ),
              ),
            );
          },
        );
      case VaultItemType.document:
        return const Text(
          'Preview untuk dokumen belum didukung.',
          style: TextStyle(color: Colors.white),
          textAlign: TextAlign.center,
        );
    }
  }

  void _onDoubleTapZoom() {
    final TapDownDetails? details = _doubleTapDetails;
    final Offset tapPosition = details?.localPosition ?? Offset.zero;

    final Matrix4 begin = _imageTransformationController.value;
    final Matrix4 end;

    final double currentScale = begin.getMaxScaleOnAxis();
    if (currentScale > 1.01) {
      end = Matrix4.identity();
    } else {
      const double zoomScale = 2.5;
      final Offset scenePoint = _imageTransformationController.toScene(
        tapPosition,
      );
      final Offset viewportCenter = _imageViewportSize.center(Offset.zero);

      // Zoom ke titik tap dan bawa titik tersebut ke tengah viewport.
      end = Matrix4.identity()
        ..translate(viewportCenter.dx, viewportCenter.dy)
        ..scale(zoomScale)
        ..translate(-scenePoint.dx, -scenePoint.dy);
    }

    _zoomAnimationController.stop();
    _zoomAnimation = Matrix4Tween(begin: begin, end: end).animate(
      CurvedAnimation(
        parent: _zoomAnimationController,
        curve: Curves.easeOutCubic,
      ),
    );
    _zoomAnimationController
      ..reset()
      ..forward();
  }

  String _formatDuration(Duration duration) {
    if (duration == Duration.zero) {
      return '0:00';
    }
    final int totalSeconds = duration.inSeconds;
    final int minutes = totalSeconds ~/ 60;
    final int seconds = totalSeconds % 60;
    final String secondsPadded = seconds.toString().padLeft(2, '0');
    return '$minutes:$secondsPadded';
  }
}

