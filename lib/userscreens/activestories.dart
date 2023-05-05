import 'dart:convert';

import 'package:chatreels/userscreens/stories.dart';
import 'package:facebook_audience_network/ad/ad_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_cookie_manager/webview_cookie_manager.dart';
import 'package:dio/dio.dart';


class ActiveStories extends StatefulWidget {
  @override
  _ActiveStoriesState createState() => _ActiveStoriesState();
}

class _ActiveStoriesState extends State<ActiveStories> with AutomaticKeepAliveClientMixin{

  Dio dio = Dio();
  bool isFeed = false;
  int widgetIndex = 0;
  final cookieManager = WebviewCookieManager();
  List<dynamic> storyTray = [];
  String cookies = '';
  TextEditingController textEditingController = TextEditingController();
  var storyResponse;
  bool searchView = false;
  final FocusNode _focus = FocusNode();
  String queryString = '';

  getStories()async{
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    String url = 'https://i.instagram.com/api/v1/feed/reels_tray/';
    cookieManager.getCookies('https://www.instagram.com/').then((value)async{
      for(var v in value){
        cookies = '${v.name}=${v.value}; $cookies';
      }
      var request = await http.get(Uri.parse('https://i.instagram.com/api/v1/feed/reels_tray/'),
          headers: {
            'cookie': cookies.substring(0, cookies.length-2),
            'x-ig-app-id': '936619743392459',
            'user-agent': "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/96.0.4664.45 Safari/537.36"
          }
      );
      if(mounted){
        setState(() {
          storyResponse = json.decode(request.body);
        });
      }
    });
  }

  getPermission()async{
    var status = await Permission.storage.status;
    if(status.isDenied){
      Permission.storage.request();
    }else if(status.isPermanentlyDenied){
      openAppSettings();
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getStories();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.black,
        statusBarColor: Colors.black
    ));
    getPermission();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    super.build(context);
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        body: storyResponse==null?const Center():StoriesList(storyResponse),
      ),
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}