import 'package:flutter/material.dart';
import '../Database/database_service.dart';
import '../Model/playlist_model.dart';
import './playlist_video_page.dart';

class PlaylistPage extends StatefulWidget {
  const PlaylistPage({super.key});

  @override
  _PlaylistPageState createState() => _PlaylistPageState();
}

class _PlaylistPageState extends State<PlaylistPage> {
  List<Playlist_Model> playlists = [];

  @override
  void initState() {
    super.initState();
    _loadPlaylists();
  }

  Future<void> _loadPlaylists() async {
    final loadedPlaylists = await DatabaseService().getPlaylists();
    setState(() {
      playlists = loadedPlaylists;
    });
  }

  void _addPlaylist() async {
    String? name = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        TextEditingController controller = TextEditingController();
        return AlertDialog(
          title: const Text('Create Playlist'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: 'Enter playlist name'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(controller.text);
              },
              child: const Text('Create'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );

    if (name != null && name.isNotEmpty) {
      await DatabaseService().createPlaylist(name);
      _loadPlaylists();  // Refresh the playlist after creation
    }
  }

  void _deletePlaylist(int playlistId) async {
    await DatabaseService().deletePlaylist(playlistId);
    _loadPlaylists();  // Refresh after deletion
  }

  void _showPlaylistVideos(Playlist_Model playlist) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlaylistVideoPage(
          playlist: playlist,
          onVideoAdded: _loadPlaylists, // Callback to refresh playlists
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: playlists.isEmpty
          ? const Center(child: Text('No Playlists'))
          : ListView.builder(
              itemCount: playlists.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                  elevation: 4,
                  child: ListTile(
                    title: Text(
                      playlists[index].name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('${playlists[index].videoPaths.length} videos'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      color: Colors.red,
                      onPressed: () => _deletePlaylist(playlists[index].id!),
                    ),
                    onTap: () => _showPlaylistVideos(playlists[index]),
                  ),
                );
              },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addPlaylist,
        child: const Icon(Icons.add),
        backgroundColor: Colors.teal,
      ),
    );
  }
}