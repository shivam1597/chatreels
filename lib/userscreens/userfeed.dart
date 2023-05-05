import 'dart:convert';
import 'dart:io';
import 'package:chatreels/userscreens/videoplayer.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_share_me/flutter_share_me.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:webview_cookie_manager/webview_cookie_manager.dart';
import 'package:whatsapp_share/whatsapp_share.dart';

import 'imageviewer.dart';

// ignore: must_be_immutable
class UserFeed extends StatefulWidget {
  String userName;
  String userId;
  String dpUrl;
  String fullName;
  UserFeed(this.userName, this.userId, this.dpUrl, this.fullName, {Key? key}) : super(key: key);

  @override
  _UserFeedState createState() => _UserFeedState();
}

class FeedModel{
  String imageUrl;
  String videoUrl;
  String shortCode;
  bool isVideo;
  int timeStamp;
  bool hasMultiplePosts;
  List<dynamic> multiplePosts;
  FeedModel(this.imageUrl, this.videoUrl, this.isVideo, this.shortCode, this.timeStamp, this.hasMultiplePosts, this.multiplePosts);
}

class _UserFeedState extends State<UserFeed> with AutomaticKeepAliveClientMixin{

  List<FeedModel> feedList = [];
  Dio dio = Dio();
  String endCursor = '';
  bool _sendUrl = true;
  final cookieManager = WebviewCookieManager();

  getPrefsValues()async{
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    // bool sendUrl = _prefs.getBool('sendUrl') as bool;
    if (_prefs.getBool('sendUrl') != null) {
      setState(() {
        _sendUrl = _prefs.getBool('sendUrl') as bool;
      });
    }
  }

  _saveToGallery(String url, bool isVideo)async{
    Directory tempDir = await getTemporaryDirectory();
    DateTime dateTime = DateTime.now();
    String path = '${tempDir.path}/${dateTime.millisecondsSinceEpoch}.png';
    if(!await Directory(tempDir.path).exists()){
      Directory(tempDir.path).createSync(recursive: true);
    }
    if(!isVideo){
      dio.download(url, path).then((value) {
        Fluttertoast.showToast(msg: 'Image saved to the gallery');
      });
    }
    else{
      Directory tempDir = await getTemporaryDirectory();
      DateTime dateTime = DateTime.now();
      String path = '${tempDir.path}/${dateTime.millisecondsSinceEpoch}.mp4';
      dio.download(url, path).then((value){
        Fluttertoast.showToast(msg: 'Video saved to the gallery');
      });
    }
  }

  Future downloadFile(String url, bool isVideo)async{
    Directory tempDir = await getTemporaryDirectory();
    DateTime dateTime = DateTime.now();
    String path = '${tempDir.path}/${dateTime.millisecondsSinceEpoch}.png';
    if(!await Directory(tempDir.path).exists()){
      Directory(tempDir.path).createSync(recursive: true);
    }
    if(!isVideo){
      dio.download(url, path).then((value)async{
        Fluttertoast.showToast(
            msg: "Sharing file",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            textColor: Colors.white,
            fontSize: 16.0
        );
        await FlutterShareMe().shareToWhatsApp(
            fileType: FileType.image,
            imagePath: path
        );
      });
    }
    else{
      Directory tempDir = await getTemporaryDirectory();
      DateTime dateTime = DateTime.now();
      String path = '${tempDir.path}/${dateTime.millisecondsSinceEpoch}.mp4';
      dio.download(url, path).then((value)async{
        Fluttertoast.showToast(
            msg: "Sharing file",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            textColor: Colors.white,
            fontSize: 16.0
        );
        await FlutterShareMe().shareToWhatsApp(
            msg: 'Check this story from ${widget.userName}... 😁',
            fileType: FileType.video,
            imagePath: path
        );
      });
    }
    return path;
  }

  getFeed()async{
    String firstPostNumber = "18";
    cookieManager.getCookies('https://www.instagram.com/').then((value)async{
      String cookies = '';
      for(var v in value){
        cookies = '${v.name}=${v.value}; $cookies';
      }
      var feedResponse = await http.get(Uri.parse('https://www.instagram.com/graphql/query/?query_hash=8c2a529969ee035a5063f2fc8602a0fd&variables={"id":"${widget.userId}","first":"$firstPostNumber"$endCursor}'),
          headers: {
        'cookie': cookies,
        'x-ig-app-id': '936619743392459',
        'user-agent': "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/96.0.4664.45 Safari/537.36"
      });
      for (var v in json.decode(feedResponse.body)['data']['user']['edge_owner_to_timeline_media']['edges']){
        if(v['node']['is_video']){
          json.decode(feedResponse.body);
          FeedModel feedModel = FeedModel(v['node']['display_url'], v['node']['video_url'], v['node']['is_video'], v['node']['shortcode'], v['node']['taken_at_timestamp'],
              v['node']['edge_sidecar_to_children']==null?false:true, v['node']['edge_sidecar_to_children']==null?[]:v['node']['edge_sidecar_to_children']['edges']);
          feedList.add(feedModel);
        }
        else{
          FeedModel feedModel = FeedModel(v['node']['display_url'], ' ', v['node']['is_video'], v['node']['shortcode'], v['node']['taken_at_timestamp'],
              v['node']['edge_sidecar_to_children']==null?false:true, v['node']['edge_sidecar_to_children']==null?[]:v['node']['edge_sidecar_to_children']['edges']);
          feedList.add(feedModel);
        }
      }
      if(json.decode(feedResponse.body)['data']['user']['edge_owner_to_timeline_media']['page_info']['has_next_page']){
        setState(() {
          endCursor = ',"after":"${json.decode(feedResponse.body)['data']['user']['edge_owner_to_timeline_media']['page_info']['end_cursor']}"';
        });
      }
      setState(() {
        firstPostNumber = "12";
      });
    });
  }

  String name = '';

  final ScrollController _controller = ScrollController();
  bool noData = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getPrefsValues();
    getFeed();
    _controller.addListener(() {
      if (_controller.position.pixels == _controller.position.maxScrollExtent) {
        Fluttertoast.showToast(
            msg: "Loading feed. Please wait...",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            textColor: Colors.white,
            fontSize: 16.0
        );
        getFeed();
      }
    });
    Future.delayed(const Duration(milliseconds: 3000)).then((value){
      if(feedList.isEmpty){
        setState(() {
          noData = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.grey[900],
          elevation: 3,
          title: Row(
            children: [
              SizedBox(
                width: size.width*0.02,
              ),
              CircleAvatar(
                backgroundColor: Colors.transparent,
                backgroundImage: NetworkImage(widget.dpUrl),
              ),
              const SizedBox(
                width: 10,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(widget.userName, style: const TextStyle(color: Colors.white, fontSize: 13),),
                  Text(widget.fullName, style: const TextStyle(color: Colors.white, fontSize: 13),),
                ],
              )
            ],
          )
      ),
      backgroundColor: Colors.black,
      body: feedList.isEmpty?Center(
          child: noData?Text('${widget.userName} has no posts.', style: const TextStyle(color: Colors.white60, fontSize: 16),):CircularProgressIndicator(
            color: Colors.red[300],
          )):GridView.count(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(top: 10),
        controller: _controller,
        crossAxisCount: 3,
        crossAxisSpacing: 6,
        mainAxisSpacing: 6,
        children: List.generate(feedList.length, (index){
          return ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Image.network(feedList[index].imageUrl,
              loadingBuilder: (context, child, loadingProgress){
                child = imageCard(index);
                if(loadingProgress==null){
                  return child;
                }
                return const Center(
                    child: Icon(Icons.nature_people_outlined, size: 50, color: Colors.white60,)
                );
              },
            ),
          );
        }),
      ),
    );
  }

  Widget imageCard(index){
    return GestureDetector(
      onTap: (){
        _openCustomDialog(index, feedList[index].isVideo, feedList[index].shortCode, widget.userName);
      },
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.only(right: 5, top: 5),
            alignment: Alignment.topRight,
            decoration: BoxDecoration(
                image: DecorationImage(
                    fit: BoxFit.cover,
                    image: NetworkImage(feedList[index].imageUrl)
                )
            ),
            child: feedList[index].isVideo?const Icon(Icons.slow_motion_video_outlined, color: Colors.white60,):const Center(),
          ),
          Align(
            alignment: Alignment.topLeft,
            child: feedList[index].isVideo?const Icon(Icons.slow_motion_video_outlined, color: Colors.white60):
            (feedList[index].hasMultiplePosts?const Icon(Icons.dynamic_feed, color: Colors.white60):const Center()),
          )
        ],
      ),
    );
  }

  void _openCustomDialog(int index, isVideo, shortCode, username) {
    final size = MediaQuery.of(context).size;
    showGeneralDialog(barrierColor: Colors.black.withOpacity(0.5),
        transitionBuilder: (context, a1, a2, widget) {
          return Transform.scale(
            scale: a1.value,
            child: Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              backgroundColor: Colors.black,
              child: Container(
                height: size.height*0.7,
                width: size.width,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15)
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 25,),
                    // https://www.instagram.com/p/
                    Expanded(
                      child: feedList[index].isVideo?VidPlayer(feedList[index].videoUrl):ImageViewer(feedList[index].imageUrl)
                    ),
                    const SizedBox(height: 15,),
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Sharing File', style: TextStyle(color: Colors.white60, fontWeight: FontWeight.w500)),
                          StatefulBuilder(
                            builder: (context, _setState){
                              return Switch(
                                // This bool value toggles the switch.
                                value: _sendUrl,
                                activeColor: Colors.red,
                                onChanged: (bool value) async{
                                  SharedPreferences prefs = await SharedPreferences.getInstance();
                                  var status = await Permission.storage.status;
                                  if(status.isGranted){

                                  } else{
                                    var request = await Permission.storage.request();
                                    if(request.isGranted){
                                      downloadFile('https://www.instagram.com/p/$shortCode', isVideo);
                                    }
                                  }
                                  // This is called when the user toggles the switch.
                                  _setState(() {
                                    _sendUrl = value;
                                  });
                                  prefs.setBool('sendUrl', value);
                                },
                              );
                            },
                          ),
                          const Text('Sharing URL', style: TextStyle(color: Colors.white60, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        GestureDetector(
                          onTap: ()async{
                            bool isInstalled = await WhatsappShare.isInstalled(
                                package: Package.whatsapp
                            ) as bool;
                            String postUrl = "https://www.instagram.com/p/${feedList[index].shortCode}";
                            if(isInstalled){
                              if(_sendUrl){
                                FlutterShareMe().shareToWhatsApp(
                                  msg: 'Checkout this post from $username... \n $postUrl',
                                );
                                // WhatsappShare.share(phone: contact[index1].value.toString().replaceAll('+', ''), text: 'Hi');
                              }
                              else{
                                downloadFile(feedList[index].isVideo?feedList[index].videoUrl:feedList[index].imageUrl, isVideo);
                              }
                            }
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
                        GestureDetector(
                          onTap: ()async{
                            var status = await Permission.storage.status;
                            if(status.isGranted){
                              _saveToGallery(feedList[index].isVideo?feedList[index].videoUrl:feedList[index].imageUrl, isVideo);
                              if(mounted){
                                Navigator.pop(context);
                              }
                            }
                            else if(status.isDenied){
                              await Permission.storage.request() ;
                            }
                          },
                          child: Container(
                            alignment: Alignment.center,
                            height: 35,
                            width: size.width*0.35,
                            decoration: BoxDecoration(
                              color: Colors.orange[700],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text('Save To Gallery', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 25,),
                  ],
                ),
              ),
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 200),
        barrierDismissible: true,
        barrierLabel: '',
        context: context,
        pageBuilder: (context, animation1, animation2) {
          throw 'e';
        });
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}