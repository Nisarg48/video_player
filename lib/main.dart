import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import './Pages/video_page.dart';
import './Pages/playlist_page.dart';
import './Pages/browse_page.dart';
import './Pages/setting_page.dart';
import './Pages/splash_screen.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: const Splashscreen(),

    themeMode: ThemeMode.dark,
    theme: ThemeData.dark().copyWith(
      primaryColor: Colors.blueAccent,
      scaffoldBackgroundColor: Colors.black,
      appBarTheme: const AppBarTheme(
        color: Colors.transparent,
        elevation: 0,
      ),
    ),
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
        // backgroundColor: Colors.black,
        title: const Row(
          children: [
            Image(
              image: AssetImage('./assets/logo.png'),
              width: 50,
              height: 50,
            ),
            Text(
              "VideoPlayFlix",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.0,
                // color: Colors.black,
              ),
            ),
          ],
        ),

        actions: [
          IconButton(
              onPressed: () {},
              icon: const Icon(EvaIcons.search)
          ),
          IconButton(
              onPressed: () {},
              icon: const Icon(Bootstrap.three_dots_vertical)
          )
        ],
      ),
      
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _pages[_currentIndex],
      ),
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
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onItemTapped,
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.grey[900],
      selectedItemColor: Colors.cyanAccent,
      unselectedItemColor: Colors.white54,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(FontAwesome.file_video_solid),
          label: 'Videos',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.playlist_play_rounded),
          label: 'Playlist',
        ),
        BottomNavigationBarItem(
          icon: Icon(Bootstrap.folder),
          label: 'Browse',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: 'Setting',
        ),
      ],
    );
  }
}

//
// const TextField(
// decoration: InputDecoration(
// hintText: 'Search...',
// hintStyle: TextStyle(color: Colors.white54),
// border: InputBorder.none,
// filled: true,
// fillColor: Colors.white12,
// contentPadding: EdgeInsets.symmetric(horizontal: 20),
// prefixIcon: Icon(EvaIcons.search, color: Colors.white),
// suffixIcon: Icon(EvaIcons.options_2_outline, color: Colors.white),
// enabledBorder: OutlineInputBorder(
// borderRadius: BorderRadius.all(Radius.circular(30)),
// borderSide: BorderSide.none,
// ),
// focusedBorder: OutlineInputBorder(
// borderRadius: BorderRadius.all(Radius.circular(30)),
// borderSide: BorderSide.none,
// ),
// ),
// ),