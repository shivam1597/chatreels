import 'dart:convert';
import 'package:chatreels/userscreens/post_carousel.dart';
import 'package:chatreels/userscreens/videoplayer.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HomeFeed extends StatefulWidget {
  const HomeFeed({Key? key}) : super(key: key);

  @override
  State<HomeFeed> createState() => _HomeFeedState();
}

class HomeFeedModel{
  String shortCode;
  List<dynamic> carouselList = [];
  int mediaType;
  String imageUrl;
  var videoUrl;
  String caption;
  String username;
  String dpUrl;
  HomeFeedModel(this.caption, this.carouselList, this.dpUrl, this.imageUrl, this.mediaType, this.shortCode, this.username, this.videoUrl);
}

class _HomeFeedState extends State<HomeFeed> {

  List<HomeFeedModel> userHomeFeed = [];

  getHomeFeed()async{
    var res = await http.post(Uri.parse('https://www.instagram.com/api/v1/feed/timeline/'),
        headers: {
          "cookie": """ig_did=F1D9D9EC-50AA-4754-86BF-84A1A1A4E15C; mid=YXkiywALAAFvDLPe5ZeTbqo83DsS; datr=E66dYj6ZpRw7qFAKXYBpxrL-; ig_nrcb=1; dpr=1.25; csrftoken=BJjPyK9EqkrMZSq1MFJNvT3653heZuiY; ds_user_id=53735628921; shbid="8181\05453735628921\0541710747452:01f70b93b6f9869f45a0f687374c3436fd43a0fb59b630523c3f8a822adb78a26cc6d921"; shbts="1679211452\05453735628921\0541710747452:01f7c1d4359b0ec7c032a617cf6b47380bb6c9a782a7ef919445e1aef60b8edbc835bace"; sessionid=53735628921%3AZ0OsMCQ43cERuK%3A10%3AAYch1VJ6GkL8OjSDy3--SJkqki0_2XPWX3JBRMU9Dw""",
          "x-ig-app-id": "936619743392459",
          "user-agent":  "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/96.0.4664.45 Safari/537.36",
          "x-csrftoken": "BJjPyK9EqkrMZSq1MFJNvT3653heZuiY",
        },
        body: {
          "feed_view_info": """[{"media_id":"3060951295652289274_1485933718-3060951278589965203_1485933718","media_pct":1,"time_info":{"10":2271,"25":2271,"50":2271,"75":2271},"version":24}]""",
          "device_id": "F1D9D9EC-50AA-4754-86BF-84A1A1A4E15C"
        }
    );
    var jsonObject = json.decode(res.body);
    for(var v in jsonObject['feed_items']){
      // print(v['media_or_ad'].containsKey('carousel_media'));
      if(v['media_or_ad']['label']!="Sponsored"){
       HomeFeedModel homeFeedModel = HomeFeedModel(v['media_or_ad']['caption']['text'],
           v['media_or_ad'].containsKey('carousel_media')?v['media_or_ad']['carousel_media']:[],
           v['media_or_ad']['user']['profile_pic_url'],
           v['media_or_ad']['media_type']==1?v['media_or_ad']['image_versions2']['candidates'][0]['url']:' ', v['media_or_ad']['media_type'],
           v['media_or_ad']['code'],
           v['media_or_ad']['user']['username'],
           v['media_or_ad'].containsKey('video_versions')?v['media_or_ad']['video_versions'][0]:' ');
       userHomeFeed.add(homeFeedModel);
      }
    }
    setState(() {});
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getHomeFeed();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.black,
      body: ListView.builder(
        itemCount: userHomeFeed.length,
        itemBuilder: (context, index){
          return userHomeFeed[index].carouselList.isEmpty?Container(
              height: size.height*0.35,
              width: size.width,
              padding: const EdgeInsets.all(15),
              child: Column(
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundImage: NetworkImage(userHomeFeed[index].dpUrl),
                      ),
                      const SizedBox(width: 15,),
                      Text(userHomeFeed[index].username, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),)
                    ],
                  ),
                  userHomeFeed[index].mediaType==1?Image.network(userHomeFeed[index].imageUrl,
                    height: size.height*0.2,
                    fit: BoxFit.contain,
                  ):VidPlayer(userHomeFeed[index].videoUrl),
                  const SizedBox(height: 10,),
                  GestureDetector(
                    onTap: ()async{

                    },
                    child: Container(
                      alignment: Alignment.center,
                      height: 35,
                      width: size.width*0.35,
                      decoration: BoxDecoration(
                        color: Colors.orange[700],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text('Share with Friends', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),),
                    ),
                  ),
                ],
              )
          ):
          PostSlider(userHomeFeed[index].carouselList);
        },
      ),
    );
  }
}
