// import 'package:flutter/material.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:video_player/Pages/permission_page.dart';
//
// class VideoPage extends StatefulWidget {
//   const VideoPage({super.key});
//
//   @override
//   State<VideoPage> createState() => _VideoPageState();
// }
//
// class _VideoPageState extends State<VideoPage> {
//
//   @override
//   void initState() {
//     super.initState();
//     _checkPermission();
//   }
//
//   Future<void> _checkPermission() async {
//     final status = await Permission.storage.status;
//     final granted = await Permission.storage.isGranted;
//     print("Status : ${status}, Granted : ${granted}");
//
//     if(granted == false){
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//             builder: (context) => PermissionPage()
//         )
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return const Center(
//       child: Text('Video Page Content', style: TextStyle(fontSize: 24)),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class VideoPage extends StatefulWidget {
  const VideoPage({super.key});

  @override
  State<VideoPage> createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> {
  late Future<bool> _permissionStatus;

  @override
  void initState() {
    super.initState();
    _permissionStatus = _checkPermission();
  }

  Future<bool> _checkPermission() async {
    final status = await Permission.storage.status;
    return status.isGranted;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _permissionStatus,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text('Error checking permission'));
        } else if (snapshot.hasData) {
          final isGranted = snapshot.data!;
          if (isGranted) {
            return const Center(
              child: Text('Video Page Content', style: TextStyle(fontSize: 24)),

            );
          } else {
            return const Center(
              child: Text('Permission Denied', style: TextStyle(fontSize: 24)),
            );
          }
        } else {
          return const Center(child: Text('Unknown status'));
        }
      },
    );
  }
}
