import 'dart:convert';
import 'dart:io';
import 'package:chatreels/main.dart';
import 'package:chatreels/userscreens/activestories.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_cookie_manager/webview_cookie_manager.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;

class WebLogin extends StatefulWidget {
  const WebLogin({Key? key}) : super(key: key);

  @override
  _WebLoginState createState() => _WebLoginState();
}

class _WebLoginState extends State<WebLogin> {
  late WebViewController webViewController;
  final cookieManager = WebviewCookieManager();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
  }

  checkJson(jsonString){
    try {
      var decodedJSON = json.decode(jsonString) as Map<String, dynamic>;
      if(mounted){
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>const MyHomePage()));
      }
    } on FormatException catch (e) {
      print('The provided string is not valid JSON');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: WebView(
        initialUrl: 'https://www.instagram.com/accounts/login',
        javascriptMode: JavascriptMode.unrestricted,
        onPageFinished: (value)async{
          String cookies = '';
          cookieManager.getCookies('https://www.instagram.com/').then((value)async{
            for(var v in value){
              cookies = '${v.name}=${v.value}; $cookies';
            }
            var request = await http.post(Uri.parse('https://www.instagram.com/api/v1/feed/timeline/'),
                headers: {
                  "cookie": cookies,
                  "x-ig-app-id": "936619743392459",
                  "user-agent":  "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/96.0.4664.45 Safari/537.36",
                  "x-csrftoken": "BJjPyK9EqkrMZSq1MFJNvT3653heZuiY",
                },
                body: {
                  "feed_view_info": """[{"media_id":"3060951295652289274_1485933718-3060951278589965203_1485933718","media_pct":1,"time_info":{"10":2271,"25":2271,"50":2271,"75":2271},"version":24}]""",
                  "device_id": "F1D9D9EC-50AA-4754-86BF-84A1A1A4E15C"
                }
            );
            checkJson(request.body);
          });
        },
        onWebViewCreated: (controller)async{
          webViewController = controller;
        },
      ),
    );
  }
}