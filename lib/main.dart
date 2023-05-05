// Key Pass: 15041997

import 'dart:convert';
import 'dart:io';
import 'package:chatreels/logins/login.dart';
import 'package:chatreels/userscreens/activestories.dart';
import 'package:chatreels/userscreens/feed.dart';
import 'package:chatreels/userscreens/search_screen.dart';
import 'package:chatreels/userscreens/stories.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_share_me/flutter_share_me.dart';
import 'package:http/http.dart' as http;
import 'package:webview_cookie_manager/webview_cookie_manager.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() {

  runApp(const MaterialApp(home: SplashScreen(),));
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  int _selectedIndex = 0;
  void _onTap(int index){
    setState(() {
      _selectedIndex = index;
    });
  }
  List<Widget> widgets = [ActiveStories(), const SearchUser()];
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.black,
      body: IndexedStack(
        index: _selectedIndex,
        children: widgets,
      ),
      bottomNavigationBar: BottomNavigationBar(
        onTap: _onTap,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home, color: _selectedIndex==0?Colors.red[900]:Colors.white70,),
            label: ' ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search, color: _selectedIndex==1?Colors.red[900]:Colors.white70,),
            label: ' '
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        backgroundColor: Colors.grey[900],
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final cookieManager = WebviewCookieManager();

  // List cookies = [];

  checkJson(jsonString)async{
    try {
      var decodedJSON = json.decode(jsonString) as Map<String, dynamic>;
    } on FormatException catch (e) {
      print('The provided string is not valid JSON');
    }
  }

  Future getCookies()async{
    List<Cookie> cookies = await cookieManager.getCookies('https://www.instagram.com/');
    return cookies;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(const Duration(seconds: 1)).then((value){
      getCookies().then((value){
        if(value.length >= 11){
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>const MyHomePage()));
        }else{
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>const WebLogin()));
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Image.asset('assets/images/sharechat_logo.png', height: 128, width: 128,),
          ),
          const SizedBox(height: 20,),
          CircularProgressIndicator(color: Colors.grey[700],)
        ],
      ),
    );
  }
}
