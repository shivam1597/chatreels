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
    final size = MediaQuery.of(context).size;
    return Container(
      alignment: Alignment.bottomRight,
      width: size.width*0.75,
      height: 500,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: NetworkImage(widget.imageUrl),
          fit: BoxFit.fill
        )
      ),
      child: GestureDetector(
        child: CircleAvatar(
          radius: 25,
          backgroundColor: Colors.orange[700],
          child: const Icon(Icons.save_alt, color: Colors.white70,),
        ),
      ),
    );
    return Stack(
      children: [
        Image.network(widget.imageUrl, fit: BoxFit.fill,),
        Align(
          alignment: Alignment.bottomRight,
          child: GestureDetector(
            child: CircleAvatar(
              backgroundColor: Colors.grey[900],
              child: const Icon(Icons.save_alt, color: Colors.white70,),
            ),
          ),
        ),
      ],
    );
  }
}
