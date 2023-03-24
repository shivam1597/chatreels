import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class PostSlider extends StatefulWidget {
  List<dynamic> carouselList;
  PostSlider(this.carouselList, {Key? key}) : super(key: key);

  @override
  State<PostSlider> createState() => _PostSliderState();
}

class PostModel{
  String videoUrl;
  String imageUrl;
  PostModel(this.imageUrl, this.videoUrl);
}

class _PostSliderState extends State<PostSlider> {

  List<PostModel> sliderList = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

  }
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
