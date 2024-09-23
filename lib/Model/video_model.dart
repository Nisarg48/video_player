class Video_Model {
  final int? id; // Use nullable type for auto-increment
  final String title;
  final String path;

  Video_Model({this.id, required this.title, required this.path});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'path': path,
    };
  }

  @override
  String toString() {
    return 'Video{id: $id, title: $title, path: $path}';
  }
}