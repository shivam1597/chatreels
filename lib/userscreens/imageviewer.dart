import 'package:flutter/material.dart';

class ImageViewer extends StatefulWidget {
  String imageUrl;
  ImageViewer(this.imageUrl, {Key? key}) : super(key: key);

  @override
  State<ImageViewer> createState() => _ImageViewerState();
}

class _ImageViewerState extends State<ImageViewer> {
  @override
  Widget build(BuildContext context) {
    return Image.network(widget.imageUrl, fit: BoxFit.contain,);
  }
}
