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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getStoryUsers();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return story.isEmpty?Center(
      child: CircularProgressIndicator(color: Colors.red[300],),
    ):ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: story.length,
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
                    image: NetworkImage(story[index].userDp)
                )
            ),
          ),
          title: Text(story[index].userName, style: const TextStyle(color: Colors.white, fontSize: 15),),
          subtitle: Text(story[index].name, style: const TextStyle(color: Colors.white60, fontSize: 12),),
          onTap: ()=>Navigator.push(context, MaterialPageRoute(builder: (context)=>StoryViewer(story[index].pk, story[index].userDp, story[index].name, story[index].userName))),
        );
      },
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}