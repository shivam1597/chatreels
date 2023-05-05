import 'package:chatreels/userscreens/storyview.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ignore: use_key_in_widget_constructors
class StoriesList extends StatefulWidget {
  var storyResponse;
  StoriesList(this.storyResponse);
  @override
  _StoriesListState createState() => _StoriesListState();
}

class StoryModel{
  String userName;
  String userDp;
  String name;
  int pk;
  StoryModel(this.userDp, this.userName, this.name, this.pk);
}

class _StoriesListState extends State<StoriesList> with AutomaticKeepAliveClientMixin{

  List<StoryModel> story = [];
  List<StoryModel> searchedStory = [];

  getStoryUsers()async{
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    story.clear();
    for(var v in widget.storyResponse['tray']){
      StoryModel storyModel = StoryModel(v['user']['profile_pic_url'], v['user']['username'], v['user']['full_name'], int.parse(v['user']['pk']));
      story.add(storyModel);
    }
    _prefs.setString('myUserName', story[0].userName);
    setState((){});
  }

  bool tapped = false;
  double animatedWidth = 75;
  double animatedHeight = 75;
  FocusNode inputNode = FocusNode();
// to open keyboard call this function;
  void openKeyboard(){
    FocusScope.of(context).requestFocus(inputNode);
  }

  TextEditingController queryController = TextEditingController();
  bool keyboardActive = false;
  String queryString = '';

  searchQuery(query){
    if(query.isNotEmpty){
      setState(() {
        queryString = query;
        searchedStory = story.where((element) => element!.name!.toLowerCase().startsWith(query)).toList();
      });
    }else{
      setState(() {
        searchedStory = story;
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getStoryUsers();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: (){
        FocusScope.of(context).unfocus();
        if(keyboardActive){
          setState(() {
            keyboardActive =! keyboardActive;
          });
        }
        else{
          Navigator.pop(context);
        }
        throw 'e';
      },
      child: story.isEmpty?Center(
        child: CircularProgressIndicator(color: Colors.red[300],),
      ):
      Column(
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            height: 45,
            width: size.width*0.8,
            decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(15)
            ),
            child: TextField(
              focusNode: inputNode,
              controller: queryController,
              onTap: (){
                setState(() {
                  keyboardActive = true;
                });
              },
              keyboardType: TextInputType.text,
              style: const TextStyle(color: Colors.white70, fontFamily: 'Font1'),
              onChanged: (value) {
                searchQuery(value);
              },
              cursorColor: Colors.red[300],
              cursorHeight: 26,
              textAlignVertical: TextAlignVertical.bottom,
              // controller: textFieldController,
              decoration:
              const InputDecoration(
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.transparent)
                  ),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.transparent)
                  ),
                  prefixIcon: Icon(Icons.search, color: Colors.white70,),
                  hintStyle: TextStyle(color: Colors.white70, fontFamily: 'Font1'),
                  hintText: "Search User"),
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.zero,
              itemCount:queryString.isEmpty? story.length: searchedStory.length,
              physics: const BouncingScrollPhysics(),
              separatorBuilder: (context, index) {
                return Divider(color: Colors.grey[100]!.withOpacity(0.4),);
              },
              itemBuilder: (context, index){
                StoryModel storyModel = queryString.isEmpty?story[index]:searchedStory[index];
                return ListTile(
                  leading: Container(
                    width: 55,
                    height: 55,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        image: DecorationImage(
                            image: NetworkImage(storyModel.userDp)
                        )
                    ),
                  ),
                  title: Text(storyModel.userName, style: const TextStyle(color: Colors.white, fontSize: 15),),
                  subtitle: Text(storyModel.name, style: const TextStyle(color: Colors.white60, fontSize: 12),),
                  onTap: ()=>Navigator.push(context, MaterialPageRoute(builder: (context)=>StoryViewer(storyModel.pk, storyModel.userDp, storyModel.name, storyModel.userName))),
                );
              },
            ),
          )
        ],
      ),
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}