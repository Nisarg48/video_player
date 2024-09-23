class Playlist_Model {
  final int? id;
  final String name;
  final List<String> videoPaths;

  Playlist_Model({this.id, required this.name, required this.videoPaths});

  factory Playlist_Model.fromMap(Map<String, dynamic> map) {
    return Playlist_Model(
      id: map['id'],
      name: map['name'],
      videoPaths: (map['videoPaths'] as String).isNotEmpty ? (map['videoPaths'] as String).split(',') : [],
    );
  }
}