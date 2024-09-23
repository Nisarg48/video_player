import 'package:flutter/material.dart';
import '../Model/playlist_model.dart';
import '../Database/database_service.dart';
import './video_selection_page.dart';
import '../Model/video_model.dart';
import './video_grid.dart';

class PlaylistVideoPage extends StatefulWidget {
  final Playlist_Model playlist;
  final Function onVideoAdded;

  const PlaylistVideoPage({Key? key, required this.playlist, required this.onVideoAdded}) : super(key: key);

  @override
  _PlaylistVideoPageState createState() => _PlaylistVideoPageState();
}

class _PlaylistVideoPageState extends State<PlaylistVideoPage> {
  List<Video_Model> videoList = []; // Change to List<Video_Model>

  @override
  void initState() {
    super.initState();
    _loadVideos();
  }

  Future<void> _loadVideos() async {
    final paths = await DatabaseService().getVideoPathsForPlaylist(widget.playlist.id!);

    // Convert the list of paths to a list of Video_Model
    videoList = paths.map((path) => Video_Model(path: path, title: _extractTitleFromPath(path))).toList();

    setState(() {
      videoList = videoList;
    });
  }

  String _extractTitleFromPath(String path) {
    return path.split('/').last; // Get the file name from the path
  }

  void _goToVideoSelection() async {
    final videoAdded = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VideoSelectionPage(playlistId: widget.playlist.id!),
      ),
    );

    // If video was added, reload the video list
    if (videoAdded == true) {
      _loadVideos(); // Refresh the video list after returning from selection page
      widget.onVideoAdded(); // Call callback if video was added
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.playlist.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _goToVideoSelection,
          )
        ],
      ),
      body: videoList.isEmpty
          ? const Center(child: Text('No Videos in Playlist'))
          : VideoGrid(videoList: videoList), // Pass the list to VideoGrid
    );
  }
}
