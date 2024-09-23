import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:external_path/external_path.dart';
import '../Database/database_service.dart';
import '../Model/video_model.dart';
import './video_grid.dart';

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
    _videoListFuture = _fetchVideosFromDatabase();
  }

  Future<bool> _checkPermission() async {
    final status = await Permission.manageExternalStorage.request();
    return status.isGranted;
  }

  Future<void> _fetchVideosIfNeeded() async {
    if (_videosFetched) return;

    try {
      List<Video_Model> videos = await _databaseService.getVideos();
      if (videos.isEmpty) {
        await _fetchVideosFromLocalStorage();
      } else {
        await _fetchVideosFromLocalStorage();
      }
      setState(() {
        _videoListFuture = _fetchVideosFromDatabase();
        _videosFetched = true;
      });
    } catch (e) {
      print('Error fetching videos: $e');
    }
  }

  Future<void> _fetchVideosFromLocalStorage() async {
    try {
      List<FileSystemEntity> videoFiles = await _getLocalVideos();
      List<Video_Model> currentVideos = await _databaseService.getVideos();

      for (var video in currentVideos) {
        if (!videoFiles.any((file) => file.path == video.path)) {
          await _databaseService.deleteVideo(video.path);
        }
      }

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
              _fetchVideosIfNeeded();
            }

            return FutureBuilder<List<Video_Model>>(
              future: _videoListFuture,
              builder: (context, videoSnapshot) {
                if (videoSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (videoSnapshot.hasError) {
                  return const Center(child: Text('Error loading videos'));
                } else if (videoSnapshot.hasData && videoSnapshot.data!.isNotEmpty) {
                  return VideoGrid(videoList: videoSnapshot.data!);
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
}