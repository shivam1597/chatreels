import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:chatreels/userscreens/userfeed.dart';
import 'package:chatreels/userscreens/videoplayer.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_share_me/flutter_share_me.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_cookie_manager/webview_cookie_manager.dart';
import 'package:whatsapp_share/whatsapp_share.dart';
import 'imageviewer.dart';
import 'package:http/http.dart' as http;

class StoryViewer extends StatefulWidget {
  int pk;
  String dpUrl;
  String username;
  String name;
  StoryViewer(this.pk, this.dpUrl, this.name, this.username, {Key? key}) : super(key: key);

  @override
  State<StoryViewer> createState() => _StoryViewerState();
}

class StoryModel{
  int postTime;
  String imageUrl;
  String videoUrl;
  int mediaType;
  String pk;
  StoryModel(this.imageUrl, this.mediaType, this.postTime, this.pk, this.videoUrl);
}

class _StoryViewerState extends State<StoryViewer> {

  final cookieManager = WebviewCookieManager();
  Dio dio = Dio();
  List<StoryModel> storyItems = [];
  bool _sendUrl = true;

  getStoryList()async{
    String cookies = '';
    cookieManager.getCookies('https://www.instagram.com/').then((value)async{
      for(var v in value){
        cookies = '${v.name}=${v.value}; $cookies';
      }
      var storyResponse = await http.get(Uri.parse('https://i.instagram.com/api/v1/feed/reels_media/?reel_ids=${widget.pk}'),
          headers: {
            'cookie': cookies,
            'x-ig-app-id': '936619743392459',
            'user-agent': "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/96.0.4664.45 Safari/537.36"
          }
      );
      for(var v in json.decode(storyResponse.body)['reels'][widget.pk.toString()]['items']){
        StoryModel storyModel = StoryModel(v['image_versions2']['candidates'][0]['url'], v['media_type'], v['taken_at'], v['pk'], v['media_type']==1?' ':v['video_versions'][0]['url']);
        storyItems.add(storyModel);
      }
      setState(() {});
    });
  }

  getPrefsValues()async{
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    if (_prefs.getBool('sendUrl') != null) {
      setState(() {
        _sendUrl = _prefs.getBool('sendUrl') as bool;
      });
    }
  }

  Future downloadFile(String url, mediaType) async {
    Directory tempDir = await getTemporaryDirectory();
    DateTime dateTime = DateTime.now();
    String path = '${tempDir.path}/${dateTime.millisecondsSinceEpoch}.png';
    if(!await Directory(tempDir.path).exists()){
      Directory(tempDir.path).createSync(recursive: true);
    }
    if(mediaType==1){
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
            msg: 'Check this story from ${widget.username}... 😁',
            fileType: FileType.video,
            imagePath: path
        );
      });
    }
    return path;
  }

  _saveToGallery(int mediaType, url)async{
    DateTime dateTime = DateTime.now();
    if(mediaType==1){
      var response = await Dio().get(url,
          options: Options(responseType: ResponseType.bytes));
      await ImageGallerySaver.saveImage(
          Uint8List.fromList(response.data),
          quality: 60,
          name: dateTime.millisecondsSinceEpoch.toString());
      Fluttertoast.showToast(msg: 'Image saved to gallery.');
    }else{
      var appDocDir = await getTemporaryDirectory();
      String savePath = "${appDocDir.path}/${dateTime.millisecondsSinceEpoch}.mp4";
      await Dio().download(url, savePath);
      await ImageGallerySaver.saveFile(savePath).then((value) => Fluttertoast.showToast(msg: 'Video saved to gallery.'));
    }
  }

  @override
  void initState() {
    super.initState();
    getStoryList();
    getPrefsValues();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return storyItems.isEmpty?Center(
      child: CircularProgressIndicator(
        color: Colors.red[300],
      ),
    ):Scaffold(
      backgroundColor: Colors.black,
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
                  Text(widget.username, style: const TextStyle(color: Colors.white, fontSize: 13),),
                  Text(widget.name, style: const TextStyle(color: Colors.white, fontSize: 13),),
                ],
              )
            ],
          ),
          actions: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: ()async{
                    String cookies = '';
                    showDialog<void>(
                      context: context,
                      barrierDismissible: false,
                      builder: (BuildContext context) {
                        return SimpleDialog(
                          elevation: 0.0,
                          backgroundColor: Colors.transparent, // can change this to your prefered color
                          children: <Widget>[
                            Center(
                              child: CircularProgressIndicator(color: Colors.red[900],),
                            )
                          ],
                        );
                      },
                    );
                    cookieManager.getCookies('url').then((value)async{
                      for(var v in value){
                        cookies = '${v.name}=${v.value}; $cookies';
                      }
                      var response = await http.get(Uri.parse('https://www.instagram.com/api/v1/users/web_profile_info/?username=${widget.username}'),
                          headers: {
                            'cookie': cookies,
                            'x-ig-app-id': '936619743392459',
                            'user-agent': "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/96.0.4664.45 Safari/537.36"
                          }
                      );
                      var body = json.decode(response.body);
                      String userId = body['data']['user']['id'];
                      String dpUrl = body['data']['user']['profile_pic_url_hd'];
                      String fullName = body['data']['user']['full_name'];
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (context)=> UserFeed(widget.username, userId, dpUrl, fullName)));
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    height: 38,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.deepOrange[400],
                      borderRadius: BorderRadius.circular(15)
                    ),
                    child: const Text('View Profile', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600),),
                  ),
                )
              ],
            )
          ],
      ),
      body: GridView.count(
        padding: const EdgeInsets.only(top: 10),
        crossAxisCount: 3,
        crossAxisSpacing: 6,
        mainAxisSpacing: 6,
        children: List.generate(storyItems.length, (index){
          return GestureDetector(
            onTap: (){
              _openCustomDialog(index, storyItems[index].mediaType==1?storyItems[index].imageUrl:storyItems[index].videoUrl, storyItems[index].mediaType, widget.username, storyItems[index].pk);
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(storyItems[index].imageUrl,
                loadingBuilder: (context, child, loadingProgress){
                  child = imageCard(index);
                  if(loadingProgress==null){
                    return child;
                  }
                  return const Center(
                      child: Icon(Icons.nature_people_outlined, size: 50, color: Colors.white60,)
                  );
                  throw 'error';
                },
              ),
            )
          );
        }),
      ),
    );
  }

  Widget imageCard(index){
    return Container(
      padding: const EdgeInsets.only(right: 5, top: 5),
      alignment: Alignment.topRight,
      decoration: BoxDecoration(
          image: DecorationImage(
              fit: BoxFit.cover,
              image: NetworkImage(storyItems[index].imageUrl)
          )
      ),
      child: storyItems[index].mediaType==2?const Icon(Icons.slow_motion_video_outlined, color: Colors.white60,):const Center(),
    );
  }

  void _openCustomDialog(int index, url, mediaType, username, pk) {
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
                    Expanded(
                      child: storyItems[index].mediaType==1?ImageViewer(storyItems[index].imageUrl):VidPlayer(storyItems[index].videoUrl),
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
                            String storyUrl = "https://instagram.com/stories/$username/$pk";
                            if(isInstalled){
                              if(_sendUrl){
                                FlutterShareMe().shareToWhatsApp(
                                  msg: 'Checkout this story from $username... \n $storyUrl',
                                );
                              }
                              else{
                                downloadFile(url, mediaType);
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
                              _saveToGallery(mediaType, url);
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

}
