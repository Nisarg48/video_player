class Playlist_Model {
  final int? id;
  final String name;
  final List<String> videoPaths; // Store video paths in the playlist

  Playlist_Model({this.id, required this.name, this.videoPaths = const []});

  // Convert Playlist_Model to a Map to store in SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'videoPaths': videoPaths.join(','), // Store as a comma-separated string
    };
  }

  // Factory constructor to create Playlist_Model from a Map
  factory Playlist_Model.fromMap(Map<String, dynamic> map) {
    return Playlist_Model(
      id: map['id'],
      name: map['name'],
      videoPaths: map['videoPaths'] != null
          ? (map['videoPaths'] as String).split(',') // Split string back into list
          : [],
    );
  }
}