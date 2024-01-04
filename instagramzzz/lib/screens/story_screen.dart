import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:instagramzzz/models/story/story.dart';
import 'package:video_player/video_player.dart';

class StoryScreen extends StatefulWidget {
  late final List<Story> stories;

  @override
  State<StoryScreen> createState() => _StoryScreenState();
}

class _StoryScreenState extends State<StoryScreen>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late VideoPlayerController _videoController;
  int currentIndex = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _pageController = PageController();

    _videoController = VideoPlayerController.networkUrl(
      Uri.parse(widget.stories[2].url),
    )..initialize().then((value) => setState);
    _videoController.play();
  }

  void onTapDown(TapDownDetails details, Story story) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double dx = details.globalPosition.dx;
    // dx = the x-axis goes from left to right, means that the user click from left to right

    // when user tap the left or right of the screen,
    // check the index will be balance and decrement or increment the current index by one accordingly
    if (dx < 2 * screenWidth / 3) {
      setState(() {
        if (currentIndex - 1 >= 0) {
          currentIndex -= 1;
        }
      });
    } else if (dx > 2 * screenWidth / 3) {
      setState(() {
        if (currentIndex + 1 < widget.stories.length) {
          currentIndex += 1;
        } else {
          currentIndex = 0;
        }
      });
    } else {
      // check if user is tapped on the screen then the video will stopped
      if (story.media == MediaType.video) {
        if (_videoController.value.isPlaying) {
          _videoController.pause();
        } else {
          // otherwise it will continue to run
          _videoController.play();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTapDown: (details) => onTapDown(
          details,
          widget.stories[currentIndex],
        ),
        child: PageView.builder(
          physics: const NeverScrollableScrollPhysics(),
          controller: _pageController,
          itemCount: widget.stories.length,
          itemBuilder: (context, i) {
            final Story story = widget.stories[i];
            switch (story.media) {
              case MediaType.image:
                return CachedNetworkImage(
                  imageUrl: story.url,
                  fit: BoxFit.cover,
                );
              case MediaType.video:
                if (_videoController.value.isInitialized) {
                  return FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: _videoController.value.size.width,
                      height: _videoController.value.size.height,
                      child: VideoPlayer(_videoController),
                    ),
                  );
                }
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
