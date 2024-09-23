import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';
import 'package:volume_controller/volume_controller.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String videoPath;
  final String videoTitle;
  final Function()? onNext; // Callback for next video
  final Function()? onPrevious; // Callback for previous video

  const VideoPlayerScreen({
    super.key,
    required this.videoPath,
    required this.videoTitle,
    this.onNext,
    this.onPrevious,
  });

  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _videoPlayerController;
  late ChewieController _chewieController;
  late VolumeController _volumeController;

  bool _isFullscreen = false;
  double _volume = 1.0;
  bool _controlsVisible = true; // Control visibility state
  bool _isPlaying = false; // Track playing state

  @override
  void initState() {
    super.initState();
    _volumeController = VolumeController();
    _initializeVideo();
    _initializeVolume();
  }

  void _initializeVideo() async {
    _videoPlayerController = VideoPlayerController.file(File(widget.videoPath));
    await _videoPlayerController.initialize();

    setState(() {
      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController,
        autoPlay: false,
        looping: true,
        showControls: true,
        placeholder: const Center(child: CircularProgressIndicator()),
        errorBuilder: (context, error) => Center(child: Text(error.toString())),
      );
    });
  }

  void _initializeVolume() async {
    _volume = await _volumeController.getVolume();
    setState(() {});

    _volumeController.listener((vol) {
      setState(() {
        _volume = vol;
      });
    });
  }

  @override
  void dispose() {
    _chewieController.dispose();
    _videoPlayerController.dispose();
    _volumeController.removeListener();
    super.dispose();
  }

  void _toggleFullscreen(bool fullscreen) {
    setState(() {
      _isFullscreen = fullscreen;
      if (_isFullscreen) {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ]);
      } else {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
        SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
      }
    });
  }

  void _setVolume(double volume) {
    setState(() {
      _volume = volume;
      _volumeController.setVolume(_volume);
    });
  }

  void _toggleControls() {
    setState(() {
      _controlsVisible = !_controlsVisible;
    });
  }

  void _playPauseVideo() {
    setState(() {
      _isPlaying = !_isPlaying;
      if (_isPlaying) {
        _videoPlayerController.play();
      } else {
        _videoPlayerController.pause();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          _toggleControls();
          _playPauseVideo(); // Toggle play/pause on tap
        },
        child: Stack(
          children: [
            if (_chewieController != null) // Check if ChewieController is initialized
              Chewie(
                controller: _chewieController,
              ),
            // Overlay for title and back button
            Positioned(
              top: 40,
              left: 10,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    color: Colors.white,
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  const SizedBox(width: 10),
                  Text(
                    widget.videoTitle,
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ],
              ),
            ),
            // Show controls when toggled
            if (_controlsVisible)
              Positioned(
                bottom: 100,
                left: 10,
                right: 10,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Previous button
                    IconButton(
                      icon: const Icon(Icons.skip_previous, color: Colors.white),
                      onPressed: widget.onPrevious,
                    ),
                    // Volume slider
                    Expanded(
                      child: Slider(
                        value: _volume,
                        min: 0.0,
                        max: 1.0,
                        activeColor: Colors.white,
                        inactiveColor: Colors.grey,
                        onChanged: _setVolume,
                      ),
                    ),
                    // Next button
                    IconButton(
                      icon: const Icon(Icons.skip_next, color: Colors.white),
                      onPressed: widget.onNext,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}