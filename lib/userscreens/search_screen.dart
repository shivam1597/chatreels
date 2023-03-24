import 'dart:convert';

import 'package:chatreels/userscreens/userfeed.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:webview_cookie_manager/webview_cookie_manager.dart';
import 'package:webview_flutter/webview_flutter.dart';
class SearchUser extends StatefulWidget {
  const SearchUser({Key? key}) : super(key: key);

  @override
  State<SearchUser> createState() => _SearchUserState();
}

class SearchModel{
  String userName;
  String name;
  String id;
  String dpUrl;
  SearchModel(this.dpUrl, this.id, this.name, this.userName);
}

class _SearchUserState extends State<SearchUser> {

  TextEditingController textEditingController = TextEditingController();
  String queryString = '';
  final cookieManager = WebviewCookieManager();
  List<SearchModel> searchList = [];

  getSearchQuery(String query)async{
    cookieManager.getCookies('https://www.instagram.com/').then((value)async{
      String cookies = '';
      for(var v in value){
        cookies = '${v.name}=${v.value}; $cookies';
      }
      var request = await http.get(Uri.parse('https://www.instagram.com/api/v1/web/search/topsearch/?context=blended&query=$query'),
          headers: {
            'cookie': cookies.substring(0, cookies.length-2),
            'x-ig-app-id': '936619743392459',
            'user-agent': "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/96.0.4664.45 Safari/537.36"
          }
      );
      var jsonObj = json.decode(request.body);
      searchList.clear();
      print(jsonObj);
      for(var v in jsonObj['users']){
        SearchModel searchModel = SearchModel(v['user']['profile_pic_url'], v['user']['pk'], v['user']['full_name'], v['user']['username']);
        searchList.add(searchModel);
      }
      setState(() {});
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.grey[700] as Color)
              ),
              child: TextField(
                controller: textEditingController,
                decoration: const InputDecoration(
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.transparent, width: 1.0),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.transparent, width: 1.0),
                    ),
                    border: UnderlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    ),
                    contentPadding: EdgeInsets.all(5),
                    hintText: 'Search User',
                    hintStyle: TextStyle(color: Colors.white70)
                ),
                cursorHeight: 25,
                style: const TextStyle(color: Colors.white70),
                cursorColor: Colors.red[900],
                onChanged: (query){
                  getSearchQuery(query);
                },
              ),
            ),
            Expanded(
              child: searchList.isEmpty?Center(child: CircularProgressIndicator(color: Colors.grey[700],),):ListView.separated(
                padding: EdgeInsets.zero,
                itemCount: searchList.length,
                physics: const BouncingScrollPhysics(),
                separatorBuilder: (context, index) {
                  return Divider(color: Colors.grey[100]!.withOpacity(0.4),);
                },
                itemBuilder: (context, index){
                  return ListTile(
                    leading: Container(
                      width: 55,
                      height: 55,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          image: DecorationImage(
                              image: NetworkImage(searchList[index].dpUrl)
                          )
                      ),
                    ),
                    title: Text(searchList[index].userName, style: const TextStyle(color: Colors.white, fontSize: 15),),
                    subtitle: Text(searchList[index].name, style: const TextStyle(color: Colors.white60, fontSize: 12),),
                    onTap: ()=>Navigator.push(context, MaterialPageRoute(builder: (context)=>UserFeed(searchList[index].userName, searchList[index].id, searchList[index].dpUrl, searchList[index].name))),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
