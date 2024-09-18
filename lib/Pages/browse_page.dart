import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:external_path/external_path.dart';

class BrowsePage extends StatefulWidget {
  const BrowsePage({super.key});

  @override
  _BrowsePageState createState() => _BrowsePageState();
}

class _BrowsePageState extends State<BrowsePage> {
  List<Directory> _videoFolders = [];
  bool _permissionGranted = false;

  @override
  void initState() {
    super.initState();
    _checkPermissionAndScanStorage();
  }

  // Check permission and scan storage if granted
  Future<void> _checkPermissionAndScanStorage() async {
    final status = await Permission.manageExternalStorage.status;
    if (status.isGranted) {
      setState(() {
        _permissionGranted = true;
      });
      await _scanForVideoFolders();
    } else {
      setState(() {
        _permissionGranted = false;
      });
    }
  }

  // Scan external storage directories for video folders
  Future<void> _scanForVideoFolders() async {
    List<Directory> videoFolders = [];
    try {
      // Get the path to external storage for Movies
      String externalStoragePath =
      await ExternalPath.getExternalStoragePublicDirectory(ExternalPath.DIRECTORY_MOVIES);

      print("External Storage Path: $externalStoragePath");  // Debugging statement

      Directory rootDirectory = Directory(externalStoragePath);
      if (await rootDirectory.exists()) {
        List<FileSystemEntity> entities = rootDirectory.listSync();

        print("Entities found: ${entities.length}");  // Debugging statement

        for (var entity in entities) {
          if (entity is Directory) {
            // Check if this directory contains any video files
            bool containsVideos = _directoryContainsVideos(entity);
            if (containsVideos) {
              videoFolders.add(entity);
            }
          }
        }
      } else {
        print("Root directory does not exist");
      }
    } catch (e) {
      print("Error accessing storage: $e");
    }

    setState(() {
      _videoFolders = videoFolders;
    });
  }

  // Check if a directory contains video files
  bool _directoryContainsVideos(Directory directory) {
    List<FileSystemEntity> files = directory.listSync();
    for (var file in files) {
      if (file is File && _isVideoFile(file.path)) {
        return true;
      }
    }
    return false;
  }

  // Check if a file has a video extension
  bool _isVideoFile(String filePath) {
    return filePath.endsWith(".mp4") ||
        filePath.endsWith(".mkv") ||
        filePath.endsWith(".avi");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _permissionGranted
          ? (_videoFolders.isEmpty
          ? const Center(child: Text('No video folders found'))
          : ListView.builder(
        itemCount: _videoFolders.length,
        itemBuilder: (context, index) {
          String folderName = _videoFolders[index].path.split('/').last;
          return ListTile(
            title: Text(folderName),
            onTap: () {
              // Open the folder to display its contents
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => VideoFolderPage(
                    directory: _videoFolders[index],
                  ),
                ),
              );
            },
          );
        },
      ))
          : const Center(
            child: Text('Storage permission denied', style: TextStyle(fontSize: 24)),
      ),
    );
  }
}

class VideoFolderPage extends StatelessWidget {
  final Directory directory;

  const VideoFolderPage({super.key, required this.directory});

  @override
  Widget build(BuildContext context) {
    List<FileSystemEntity> videoFiles = directory
        .listSync()
        .where((file) =>
    file is File &&
        (file.path.endsWith(".mp4") ||
            file.path.endsWith(".mkv") ||
            file.path.endsWith(".avi")))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(directory.path.split('/').last),
      ),
      body: videoFiles.isEmpty
          ? const Center(child: Text('No videos found in this folder'))
          : ListView.builder(
        itemCount: videoFiles.length,
        itemBuilder: (context, index) {
          String fileName = videoFiles[index].path.split('/').last;
          return ListTile(
            title: Text(fileName),
            onTap: () {
              // Handle video playback
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Selected video: ${videoFiles[index].path}')),
              );
            },
          );
        },
      ),
    );
  }
}
