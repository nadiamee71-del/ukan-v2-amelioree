import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

/// Widget placeholder pour les vidéos de duel
/// Prêt pour intégrer des vidéos mp4 locales (assets/videos/duel/)
class DuelVideoPlaceholder extends StatefulWidget {
  final String? videoPath; // Chemin vers la vidéo (ex: 'assets/videos/duel/squat.mp4')
  final bool isCameraOff;
  final double width;
  final double height;

  const DuelVideoPlaceholder({
    super.key,
    this.videoPath,
    this.isCameraOff = false,
    this.width = 140,
    this.height = 140,
  });

  @override
  State<DuelVideoPlaceholder> createState() => _DuelVideoPlaceholderState();
}

class _DuelVideoPlaceholderState extends State<DuelVideoPlaceholder> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    if (widget.videoPath == null) {
      // Pas de vidéo fournie, on reste sur le placeholder
      return;
    }

    try {
      _controller = VideoPlayerController.asset(widget.videoPath!);
      await _controller!.initialize();
      
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
        // Lire en boucle
        _controller!.setLooping(true);
        _controller!.play();
      }
    } catch (e) {
      // Si la vidéo n'existe pas ou erreur, on reste sur le placeholder
      debugPrint('Erreur chargement vidéo: $e');
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(DuelVideoPlaceholder oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.videoPath != oldWidget.videoPath) {
      _controller?.dispose();
      _controller = null;
      _isInitialized = false;
      _initializeVideo();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: widget.isCameraOff ? Colors.black : const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFFFC300),
            width: 2,
          ),
        ),
        child: widget.isCameraOff
            ? _buildCameraOffState()
            : (_isInitialized && _controller != null)
                ? _buildVideoPlayer()
                : _buildPlaceholder(),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: const Color(0xFF2A2A2A),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.videocam,
              size: 40,
              color: Colors.white.withOpacity(0.5),
            ),
            const SizedBox(height: 8),
            Text(
              'Vidéo',
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoPlayer() {
    return AspectRatio(
      aspectRatio: _controller!.value.aspectRatio,
      child: VideoPlayer(_controller!),
    );
  }

  Widget _buildCameraOffState() {
    return Container(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.videocam_off,
              size: 40,
              color: Colors.white.withOpacity(0.5),
            ),
            const SizedBox(height: 8),
            Text(
              'Caméra désactivée',
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 10,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}




