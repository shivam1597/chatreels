import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VidPlayer extends StatefulWidget {
  String videoUrl;
  VidPlayer(this.videoUrl, {Key? key}) : super(key: key);

  @override
  State<VidPlayer> createState() => _VidPlayerState();
}

class _VidPlayerState extends State<VidPlayer> {

  late FlickManager flickManager;
  late VideoPlayerController _controller;
  int tapCount = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller = VideoPlayerController.network(
        widget.videoUrl)
      ..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        setState(() {});
      });
    _controller.play();
    // flickManager = FlickManager(videoPlayerController: VideoPlayerController.network(widget.videoUrl));
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return SizedBox(
      width: size.width,
      child: _controller.value.isInitialized
          ? GestureDetector(
              onTap: (){
                setState(() {
                  tapCount += 1;
                });
              },
              child: AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              ),
      )
          : Container(),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
