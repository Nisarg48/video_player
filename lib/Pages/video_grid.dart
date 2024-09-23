import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:path_provider/path_provider.dart';
import './video_player_screen.dart';
import '../Model/video_model.dart';

class VideoGrid extends StatelessWidget {
  final List<Video_Model> videoList;

  const VideoGrid({Key? key, required this.videoList}) : super(key: key);

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

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => VideoPlayerScreen(videoPath: filePath, videoTitle: fileName),
              ),
            );
          },
          child: FutureBuilder<String?>(
            future: _getVideoThumbnail(filePath),
            builder: (context, snapshot) {
              Widget thumbnailWidget;

              if (snapshot.connectionState == ConnectionState.waiting) {
                thumbnailWidget = const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError || snapshot.data == null || !File(snapshot.data!).existsSync()) {
                thumbnailWidget = _buildDefaultThumbnail();
              } else {
                thumbnailWidget = ClipRRect(
                  borderRadius: BorderRadius.circular(12.0),
                  child: Image.file(
                    File(snapshot.data!),
                    fit: BoxFit.cover,
                  ),
                );
              }

              return Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Colors.cyanAccent,
                      Colors.purple,
                      Colors.pinkAccent,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12.0),
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
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
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