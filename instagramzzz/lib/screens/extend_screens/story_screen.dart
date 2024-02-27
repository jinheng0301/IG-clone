import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:instagramzzz/models/story/story.dart';
import 'package:instagramzzz/models/story/user_story.dart';
import 'package:instagramzzz/widgets/animated_bar.dart';
import 'package:instagramzzz/widgets/user_info_story.dart';
import 'package:video_player/video_player.dart';

class StoryScreen extends StatefulWidget {
  late final List<Story> stories;

  @override
  State<StoryScreen> createState() => _StoryScreenState();
}

class _StoryScreenState extends State<StoryScreen>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animationController;
  late VideoPlayerController _videoController;
  int currentIndex = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _pageController = PageController();
    _animationController = AnimationController(vsync: this);

    _videoController = VideoPlayerController.networkUrl(
      Uri.parse(widget.stories[2].url),
    )..initialize().then((value) => setState);
    _videoController.play();

    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _animationController.stop();
        _animationController.reset();
        setState(() {
          if (currentIndex + 1 < widget.stories.length) {
            currentIndex += 1;
            loadStory(story: widget.stories[currentIndex]);
          } else {
            // Out of bounds - loop story
            // You can also Navigator.of(context).pop() here
            currentIndex = 0;
            loadStory(story: widget.stories[currentIndex]);
          }
        });
      }
    });
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
          loadStory(story: widget.stories[currentIndex]);
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
          _animationController.stop();
        } else {
          // otherwise it will continue to run
          _videoController.play();
        }
      }
    }
  }

  void loadStory({required Story story, bool animateToPage = true}) {
    // reason of this boolean is to avoid running the page controllers animate to page on index 0
    // when the screen loads for the first time

    _animationController.stop();
    _animationController.reset();

    switch (story.media) {
      case MediaType.image:
        _animationController.duration = story.duration;
        _animationController.forward();
        break;
      case MediaType.video:
        _videoController.dispose();
        _videoController =
            VideoPlayerController.networkUrl(Uri.parse(widget.stories[2].url))
              ..initialize().then(
                (_) {
                  setState(() {});
                  if (_videoController.value.isInitialized) {
                    _animationController.duration =
                        _videoController.value.duration;
                    _videoController.play();
                    _animationController.forward();
                  }
                },
              );
        break;
    }

    if (animateToPage) {
      _pageController.animateToPage(
        currentIndex,
        duration: const Duration(milliseconds: 1),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _pageController.dispose();
    _animationController.dispose();
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          GestureDetector(
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
          Positioned(
            top: 40.0,
            left: 10.0,
            right: 10.0,
            child: Column(
              children: [
                Row(
                  children: widget.stories
                      .asMap()
                      .map((i, e) {
                        return MapEntry(
                          i,
                          AnimatedBar(
                            animationController: _animationController,
                            position: i,
                            currentIndex: currentIndex,
                          ),
                        );
                      })
                      .values
                      .toList(),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 1.5, vertical: 10),
                  child: UserInfoStory(
                    user: UserStory.user,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
