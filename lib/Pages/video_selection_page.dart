import 'package:flutter/material.dart';
import '../Database/database_service.dart';
import '../Model/video_model.dart';

class VideoSelectionPage extends StatefulWidget {
  final int playlistId;

  const VideoSelectionPage({Key? key, required this.playlistId}) : super(key: key);

  @override
  _VideoSelectionPageState createState() => _VideoSelectionPageState();
}

class _VideoSelectionPageState extends State<VideoSelectionPage> {
  List<Video_Model> availableVideos = [];
  List<String> selectedVideoPaths = [];

  @override
  void initState() {
    super.initState();
    _loadAvailableVideos();
    _loadSelectedVideos();
  }

  Future<void> _loadAvailableVideos() async {
    final videos = await DatabaseService().getVideos();
    setState(() {
      availableVideos = videos;
    });
  }

  Future<void> _loadSelectedVideos() async {
    final selectedVideos = await DatabaseService().getVideoPathsForPlaylist(widget.playlistId);
    setState(() {
      selectedVideoPaths = selectedVideos;
    });
  }

  void _toggleVideoSelection(String videoPath) async {
    if (selectedVideoPaths.contains(videoPath)) {
      await DatabaseService().removeVideoFromPlaylist(widget.playlistId, videoPath);
      setState(() {
        selectedVideoPaths.remove(videoPath);
      });
    } else {
      await DatabaseService().addVideoToPlaylist(widget.playlistId, videoPath);
      setState(() {
        selectedVideoPaths.add(videoPath); // Update UI when the video is added
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Videos"),
        actions: [
          IconButton(
            icon: const Icon(Icons.done),
            onPressed: () {
              Navigator.pop(context);
            },
          )
        ],
      ),
      body: availableVideos.isEmpty
          ? const Center(child: Text('No videos available'))
          : ListView.builder(
        itemCount: availableVideos.length,
        itemBuilder: (context, index) {
          final video = availableVideos[index];
          final isSelected = selectedVideoPaths.contains(video.path);
          return ListTile(
            title: Text(video.title),
            subtitle: Text(video.path),
            trailing: Icon(
              isSelected ? Icons.check_box : Icons.check_box_outline_blank,
              color: isSelected ? Colors.green : null,
            ),
            onTap: () => _toggleVideoSelection(video.path),
          );
        },
      ),
    );
  }
}
