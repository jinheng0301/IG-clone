import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class ZoomImage extends StatelessWidget {
  final List<String> imageUrls;
  final int currentIndex;

  ZoomImage({
    required this.imageUrls,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return PhotoViewGallery.builder(
      scrollPhysics: BouncingScrollPhysics(),
      builder: (context, index) {
        return PhotoViewGalleryPageOptions(
          imageProvider: NetworkImage(
            imageUrls[index],
          ),
          minScale: PhotoViewComputedScale.contained * 0.8,
          maxScale: PhotoViewComputedScale.covered * 2,
        );
      },
      itemCount: imageUrls.length,
      backgroundDecoration: BoxDecoration(
        color: Colors.black,
      ),
      pageController: PageController(
        initialPage: currentIndex,
      ),
    );
  }
}
