import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:external_path/external_path.dart';
import 'package:video_thumbnail_imageview/video_thumbnail_imageview.dart';
import 'video_player_screen.dart';

class VideoPage extends StatefulWidget {
  const VideoPage({super.key});

  @override
  State<VideoPage> createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> {
  late Future<bool> _permissionStatus;
  List<FileSystemEntity> _videoFiles = [];

  @override
  void initState() {
    super.initState();
    _permissionStatus = _checkPermission();
  }

  Future<bool> _checkPermission() async {
    final status = await Permission.manageExternalStorage.status;
    if (status.isGranted) {
      await _fetchVideos();  // Fetch videos when permission is granted
    } else {
      // Handle permission denied case
      setState(() {
        _videoFiles = [];
      });
    }
    return status.isGranted;
  }

  Future<void> _fetchVideos() async {
    List<FileSystemEntity> videoFiles = [];

    try {
      // Get external storage paths
      String moviesPath = await ExternalPath.getExternalStoragePublicDirectory(ExternalPath.DIRECTORY_MOVIES);
      String dcimPath = await ExternalPath.getExternalStoragePublicDirectory(ExternalPath.DIRECTORY_DCIM);
      String downloadPath = await ExternalPath.getExternalStoragePublicDirectory(ExternalPath.DIRECTORY_DOWNLOADS);

      // Check if the directories exist
      if (Directory(moviesPath).existsSync()) {
        videoFiles.addAll(_getVideoFilesFromDirectory(Directory(moviesPath)));
      }
      if (Directory(dcimPath).existsSync()) {
        videoFiles.addAll(_getVideoFilesFromDirectory(Directory(dcimPath)));
      }
      if (Directory(downloadPath).existsSync()) {
        videoFiles.addAll(_getVideoFilesFromDirectory(Directory(downloadPath)));
      }
    } catch (e) {
      print("Error accessing storage: $e");
    }

    setState(() {
      _videoFiles = videoFiles;
    });
  }

  List<FileSystemEntity> _getVideoFilesFromDirectory(Directory directory) {
    List<FileSystemEntity> videoFiles = [];
    try {
      videoFiles = directory
          .listSync()
          .where((file) =>
      file is File &&
          (file.path.endsWith(".mp4") ||
              file.path.endsWith(".mkv") ||
              file.path.endsWith(".avi"))) // Add more video extensions as needed
          .toList();
    } catch (e) {
      print("Error reading directory: $e");
    }
    return videoFiles;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<bool>(
        future: _permissionStatus,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error checking permission'));
          } else if (snapshot.hasData) {
            final isGranted = snapshot.data!;
            if (isGranted) {
              return _buildVideoGrid();
            } else {
              return const Center(
                child: Text('Permission Denied', style: TextStyle(fontSize: 24)),
              );
            }
          } else {
            return const Center(child: Text('Unknown status'));
          }
        },
      ),
    );
  }

  Widget _buildVideoGrid() {
    if (_videoFiles.isEmpty) {
      return const Center(
        child: Text('No videos found', style: TextStyle(fontSize: 24)),
      );
    }

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // Number of columns
        crossAxisSpacing: 8.0, // Horizontal spacing between items
        mainAxisSpacing: 8.0, // Vertical spacing between items
        childAspectRatio: 16 / 9, // Aspect ratio of the grid items
      ),
      itemCount: _videoFiles.length,
      itemBuilder: (context, index) {
        String filePath = _videoFiles[index].path;
        String fileName = filePath.split('/').last;
        int fileSize = File(filePath).lengthSync(); // Get file size in bytes

        return GestureDetector(
          onTap: () {
            // Navigate to VideoPlayerScreen when a video tile is tapped
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => VideoPlayerScreen(videoPath: filePath),
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.accents[index % Colors.accents.length], // Different color for each item
                width: 2.0, // Border thickness
              ),
            ),
            child: GridTile(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.0),
                child: VTImageView(
                  videoUrl: filePath,
                  errorBuilder: (context, error, stack) {
                    return Container(
                      // color: Colors.redAccent, // Placeholder background color
                      child: const Center(
                        child: Text(
                          "Thumbnail Error",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    );
                  },
                  assetPlaceHolder: './assets/logo.png',
                ),
              ),
              footer: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                ),
                padding: const EdgeInsets.symmetric(
                                            vertical: 2.0,
                                            horizontal: 3.0
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fileName,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}