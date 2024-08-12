import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import './Pages/VideoPage.dart';
import './Pages/PlaylistPage.dart';
import './Pages/BrowsePage.dart';
import './Pages/SettingPage.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: MyHomePage(),
  ));
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const VideoPage(),
    const PlaylistPage(),
    const BrowsePage(),
    const SettingPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Center(
          child: Text(
            "VideoPlayFlix",
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              letterSpacing: 2.0,
              color: Colors.black,
            ),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(EvaIcons.search),
          ),
        ],
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onItemTapped;

  const BottomNavBar({
    required this.currentIndex,
    required this.onItemTapped,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: onItemTapped,
      destinations: const [
        NavigationDestination(
          icon: Icon(FontAwesome.file_video_solid),
          label: 'Videos',
        ),
        NavigationDestination(
          icon: Icon(Icons.playlist_play_rounded),
          label: 'Playlist',
        ),
        NavigationDestination(
          icon: Icon(Bootstrap.folder),
          label: 'Browse',
        ),
        NavigationDestination(
          icon: Icon(Icons.settings),
          label: 'Setting',
        ),
      ],
    );
  }
}
