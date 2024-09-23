import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:external_path/external_path.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:path_provider/path_provider.dart';
import './video_player_screen.dart';
import '../Database/database_service.dart';
import '../Model/video_model.dart';

class VideoPage extends StatefulWidget {
  const VideoPage({super.key});

  @override
  State<VideoPage> createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> {
  late Future<bool> _permissionStatus;
  late Future<List<Video_Model>> _videoListFuture;
  final DatabaseService _databaseService = DatabaseService();
  bool _videosFetched = false;

  @override
  void initState() {
    super.initState();
    _permissionStatus = _checkPermission();
    _videoListFuture = _fetchVideosFromDatabase(); // Initialize _videoListFuture
  }

  Future<bool> _checkPermission() async {
    final status = await Permission.manageExternalStorage.request();
    return status.isGranted;
  }

  Future<void> _fetchVideosIfNeeded() async {
    if (_videosFetched) return; // Prevent refetching
    try {
      List<Video_Model> videos = await _databaseService.getVideos();

      if (videos.isEmpty) {
        await _fetchVideosFromLocalStorage();
      } else {
        await _fetchVideosFromLocalStorage(); // Optional: Refresh existing videos
      }
      setState(() {
        _videoListFuture = _fetchVideosFromDatabase();
        _videosFetched = true; // Mark videos as fetched
      });
    } catch (e) {
      print('Error fetching videos: $e');
    }
  }

  Future<void> _fetchVideosFromLocalStorage() async {
    try {
      List<FileSystemEntity> videoFiles = await _getLocalVideos();
      List<Video_Model> currentVideos = await _databaseService.getVideos();

      // Remove non-existing videos
      for (var video in currentVideos) {
        if (!videoFiles.any((file) => file.path == video.path)) {
          await _databaseService.deleteVideo(video.path);
        }
      }

      // Add new videos to the database
      for (var file in videoFiles) {
        if (!currentVideos.any((video) => video.path == file.path)) {
          final video = Video_Model(title: file.path.split('/').last, path: file.path);
          await _databaseService.insertVideo(video);
        }
      }
    } catch (e) {
      print('Error fetching videos from local storage: $e');
    }
  }

  Future<List<FileSystemEntity>> _getLocalVideos() async {
    List<String> directories = [
      await ExternalPath.getExternalStoragePublicDirectory(ExternalPath.DIRECTORY_MOVIES),
      await ExternalPath.getExternalStoragePublicDirectory(ExternalPath.DIRECTORY_DCIM),
      await ExternalPath.getExternalStoragePublicDirectory(ExternalPath.DIRECTORY_DOWNLOADS),
    ];

    List<FileSystemEntity> videoFiles = [];

    Future<void> scanDirectory(Directory dir) async {
      try {
        List<FileSystemEntity> entities = dir.listSync();
        for (var entity in entities) {
          if (entity is File && entity.path.endsWith('.mp4')) {
            videoFiles.add(entity);
          } else if (entity is Directory) {
            await scanDirectory(entity);
          }
        }
      } catch (e) {
        print('Error scanning directory: $e');
      }
    }

    for (var path in directories) {
      Directory dir = Directory(path);
      if (await dir.exists()) {
        await scanDirectory(dir);
      }
    }

    return videoFiles;
  }

  Future<List<Video_Model>> _fetchVideosFromDatabase() async {
    return await _databaseService.getVideos();
  }

  Future<String?> _getVideoThumbnail(String videoPath) async {
    try {
      final thumbnailPath = await VideoThumbnail.thumbnailFile(
        video: videoPath,
        thumbnailPath: (await getTemporaryDirectory()).path,
        imageFormat: ImageFormat.PNG,
        quality: 100,
      );
      return thumbnailPath;
    } catch (e) {
      print('Error generating thumbnail: $e');
      return null;
    }
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
          } else if (snapshot.hasData && snapshot.data!) {
            if (!_videosFetched) {
              _fetchVideosIfNeeded(); // Fetch videos once permission is granted
            }

            return FutureBuilder<List<Video_Model>>(
              future: _videoListFuture,
              builder: (context, videoSnapshot) {
                if (videoSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (videoSnapshot.hasError) {
                  return const Center(child: Text('Error loading videos'));
                } else if (videoSnapshot.hasData && videoSnapshot.data!.isNotEmpty) {
                  return _buildVideoGrid(videoSnapshot.data!);
                } else {
                  return const Center(child: Text('No videos found', style: TextStyle(fontSize: 24)));
                }
              },
            );
          } else {
            return const Center(child: Text('Permission Denied', style: TextStyle(fontSize: 24)));
          }
        },
      ),
    );
  }

  Widget _buildVideoGrid(List<Video_Model> videoList) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16.0,
        mainAxisSpacing: 16.0,
        childAspectRatio: 1.2,
      ),
      itemCount: videoList.length,
      itemBuilder: (context, index) {
        String filePath = videoList[index].path;
        String fileName = videoList[index].title;

        return FutureBuilder<String?>(
          future: _getVideoThumbnail(filePath),
          builder: (context, snapshot) {
            Widget thumbnailWidget;

            if (snapshot.connectionState == ConnectionState.waiting) {
              thumbnailWidget = const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError || snapshot.data == null || !File(snapshot.data!).existsSync()) {
              thumbnailWidget = _buildDefaultThumbnail();
            } else {
              thumbnailWidget = ClipRRect(
                borderRadius: BorderRadius.circular(1.0),
                child: Image.file(
                  File(snapshot.data!),
                  fit: BoxFit.cover,
                ),
              );
            }

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => VideoPlayerScreen(videoPath:
                    filePath, videoTitle: fileName),
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.blue, Colors.white, Colors.yellow],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            thumbnailWidget,
                            const Icon(
                              Icons.play_circle_outline,
                              size: 50.0,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: SizedBox(
                        child: Text(
                          fileName,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDefaultThumbnail() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12.0),
      child: Container(
        color: Colors.grey[800],
        child: Center(
          child: Image.asset(
            'assets/logo.png', // Replace with your app logo path
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
