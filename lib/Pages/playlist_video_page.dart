import 'package:flutter/material.dart';
import '../Model/playlist_model.dart';
import '../Database/database_service.dart';
import 'video_selection_page.dart';

class PlaylistVideoPage extends StatefulWidget {
  final Playlist_Model playlist;
  final Function onVideoAdded;

  const PlaylistVideoPage({Key? key, required this.playlist, required this.onVideoAdded}) : super(key: key);

  @override
  _PlaylistVideoPageState createState() => _PlaylistVideoPageState();
}

class _PlaylistVideoPageState extends State<PlaylistVideoPage> {
  List<String> videoPaths = [];

  @override
  void initState() {
    super.initState();
    _loadVideos();
  }

  Future<void> _loadVideos() async {
    final videos = await DatabaseService().getVideoPathsForPlaylist(widget.playlist.id!);
    setState(() {
      videoPaths = videos;
    });
  }

  void _goToVideoSelection() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VideoSelectionPage(playlistId: widget.playlist.id!),
      ),
    );
    _loadVideos(); // Refresh the video list after returning from selection page
    widget.onVideoAdded();
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
      body: videoPaths.isEmpty
          ? const Center(child: Text('No Videos in Playlist'))
          : ListView.builder(
        itemCount: videoPaths.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(videoPaths[index]),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () async {
                await DatabaseService().removeVideoFromPlaylist(widget.playlist.id!, videoPaths[index]);
                _loadVideos(); // Refresh the video list after deletion
              },
            ),
          );
        },
      ),
    );
  }
}
