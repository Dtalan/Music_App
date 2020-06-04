import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flute_music_player/flute_music_player.dart';
// import 'package:sleek_circular_slider/sleek_circular_slider.dart';

void main() {  
  runApp(MyApp());}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  var songs,s;
  var artfile;
  bool playing =true;
  Duration duration,position;
  MusicFinder audioPlayer;
  var flagDown=false;
  @override
  void initState(){
    super.initState();
    initPlayer();
  }

  void initPlayer() async {
    audioPlayer=new MusicFinder();
    var song;
    try{
      song=await MusicFinder.allSongs();
    }catch(e){print(e.toString());}
    song=new List.from(song);
    audioPlayer.setDurationHandler((d)=> setState((){
      duration = d;
    }));
    audioPlayer.setPositionHandler((p)=>setState((){
      position=p;
    }));
    setState(() {
      songs=song;
    });
  }

  Future nextSong()async{
    if(duration==position){
      await audioPlayer.play(songs.uri,isLocal:true);
    }
  }
  String positiontext(){
    return position.toString().split('.').first;
  }
  String durationtext(){
    return duration.toString().split('.').first;
  }
  String tempSong;
  String audioName(String name){
    String aname;
    if(name.length>20){
      aname=name.substring(0,20);
      aname=aname+"....";
    }
    else{
      aname=name;
      aname=aname+"....";
    }
    return aname;
  }
  Future playLocal(String url)async{
    if(playing==false){
      if(tempSong==null){
        await audioPlayer.play(url,isLocal:true);
        tempSong=url;
        playing=true;
      }
      else{
        if(tempSong==url){
          await audioPlayer.play(url,isLocal:true);
          tempSong=url;
          playing=true;
        }
        else{
          await audioPlayer.stop();
          await audioPlayer.play(url,isLocal:true);
          tempSong=url;
          playing=true;
        }
      } 
    }
    else{
      if(tempSong==url){
        await audioPlayer.pause();
        playing=false;
      }
      else{
          await audioPlayer.stop();
          await audioPlayer.play(url,isLocal:true);
          tempSong=url;
          playing=true;
      }
    }  
  }

  Widget shape(){
    Widget icon;
    if(playing==false&&flagDown==true){
      icon= Icon(Icons.play_arrow,color:Colors.white,size: 35,);
    }
    else if(playing==false&&flagDown==false){
      icon= Icon(Icons.play_arrow,color:Colors.white,size: 60,);
    }
    else if(playing==true&&flagDown==true){
      icon= Icon(Icons.pause,color:Colors.white,size: 40,);
    }
    else if(playing==true&&flagDown==false){
      icon= Icon(Icons.pause,color:Colors.white,size: 60,);
    }
    return icon;
  }


  Widget build(BuildContext context) {
  SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);          //this automatically hides the android status bar
    return MaterialApp(
      home:Scaffold(
        body: Center(                                                         //safearea is not here because safearea automatically starts build from under the status bar of android, and as we are hiding the status bar, so whole screen is ours and hence no need for safearea.....
          child: Stack(                                     //This is to make different layers for background or something same stuff......
            children: <Widget>[
              Container(                                    //This is first children of stack for that backgound color(white)...
                height:900,
                width:900,
                color:Colors.white
              ),
              Column(                                      //Here i have described whole page as a column.......everything will come under this column section....
                children: <Widget>[
                  AnimatedContainer(                       //this is an animated container background for upper section....without this you might face some difficulty in those top left and right icon's alignment.......
                      height:flagDown==true?550.0:450.0,
                      width:900,
                      duration: Duration(milliseconds:200 ),
                      color:Colors.white,
                      child: Center(
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: Row(                           //this is row section of top 2 icons and top nf image 
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Column(                           //ye sab icon maine column mai isliye rakhe hai kyonki row ka size in terms of height bohot jyada ho gya hai so by default ye row ke mid mai aayenge ......so ye inhe column mai rakh diya hai taaki ye by default column ke starting mai aa jaae that is top of the column....
                                children: <Widget>[
                                  Container(
                                    height:40,
                                    width:40,
                                    child:Center(
                                      child:Icon(Icons.arrow_back_ios)
                                    )
                                  ),
                                ],
                              ),
                              Column(                               //ye middle image posture k`a column hai.....
                                children: <Widget>[
                                  GestureDetector(
                                    onPanUpdate: (details){         // this gives the details about the motion of the finger swipping on the phone
                                      if(details.delta.dy>0){       //ye value 5 isliye dii hai taki ungli touch karte hi swipe na ho jaae........
                                        setState(() {               //ye setstate function hai jo har baari invoke hone par state ko alter karta hai ......idhar mai ise use kar rha huun just to alter value of flagDown so that we can determine wheather user is swiping up or down......so that container ki height and width change ki jaa sake......
                                          flagDown=false;
                                        });
                                      }
                                      else if(details.delta.dy<0){
                                        setState(() {
                                          flagDown=true;
                                        });
                                      }
                                    },
                                    child:AnimatedContainer(                            //ye wo image waale poster ka animated container hai........jiski height and width hum change kar rhe hai according to the flagDown value that is changed.......
                                      height:flagDown==true?550.0:400.0,
                                      width:flagDown==true?280.0:300.0,
                                      duration: Duration(milliseconds:200),
                                      decoration: BoxDecoration(
                                        // artfile!=null?new Image.file(artfile,fit:BoxFit.cover):Text("no image found"),
                                        boxShadow:[
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.3),
                                            blurRadius: 30.0, // soften the shadow
                                            spreadRadius: 2.0, //extend the shadow
                                            offset: Offset(
                                              0.0, // Move to right 10  horizontally
                                              5.0, // Move to bottom 10 Vertically
                                            ),
                                          )
                                        ],
                                        color:Colors.black,
                                        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(150),bottomRight: Radius.circular(150)),
                                        // image:DecorationImage(image: AssetImage("assets/friends.jpg"),fit:BoxFit.cover)
                                      ),
                                      child:artfile!=null?new Image.file(artfile,fit:BoxFit.cover):Text("no image found"),
                                      // child:Stack(
                                      //   children: <Widget>[
                                          
                                      //     Align(          //ye song name ke liye hai jo poster pe aane waala hai.....but i m having difficulty with the color of this text....means how to determine color of text so that it could fit on the poster as every poster has its own different from others color combination......but mere paas ek idea hai to shi iske liye bhi .....main abhi use implement kar rha huun....hoga to btauunga......
                                      //       alignment: Alignment.bottomCenter,
                                      //       child: Padding(
                                      //         padding: const EdgeInsets.fromLTRB(0, 0, 0, 20),
                                      //         child: Text("Song Name",style:TextStyle(fontWeight: FontWeight.w900,fontSize: 20,color:Colors.teal)),
                                      //       ),
                                      //     ),
                                      //   ],
                                      // )
                                    ),
                                  ),
                                ],
                              ),
                              Column(mainAxisAlignment: MainAxisAlignment.start,                //this is third icon on the top right corner...........
                                children: <Widget>[
                                  Container(
                                    height:40,
                                    width:40,
                                    child:Center(
                                      child:Icon(Icons.more_vert)
                                    )
                                  ),
                                ],
                              ),
                            ],
                          ),
                      ),
                    ),
                  ),
                  AnimatedContainer(                               //This container is used just as sizedbox as we can't have have a constant height sizedbox , so thats why........
                    duration: Duration(milliseconds: 200),
                    width:800,
                    height: flagDown==true?80.0:0.0,
                  ),
                  AnimatedContainer(                              //this here is for the "position - duration" section of the section that is only visible when flagDown is 0 that is when poster is swipped downward.....
                    duration: Duration(milliseconds: 200),
                    width:800,
                    height: flagDown==true?30.0:0.0,
                    child:Center(
                      child:Text(positiontext()+" - "+durationtext(),style: TextStyle(fontSize: 16),)
                    )
                  ),
                  SizedBox(height:10),
                  AnimatedContainer(                            //this here is for the play pause icon's row.......
                    duration: Duration(milliseconds: 200),
                    height:flagDown==false?50.0:80.0,
                    width:flagDown==false?800.0:800.0,
                    child:Padding(
                      padding: const EdgeInsets.fromLTRB(20,0,20,0),
                      child: Row(                                                     //ye play pause waali row hai
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children:<Widget>[
                          AnimatedContainer(
                            duration: Duration(milliseconds: 200),
                            width:flagDown==true?40.0:30.0,
                            height: flagDown==true?40.0:30.0,
                            child:Center(
                              child:Icon(Icons.format_align_center)
                            )
                          ),
                          SizedBox(width:10),
                          AnimatedContainer(
                            duration: Duration(milliseconds: 200),
                            width:flagDown==true?40.0:30.0,
                            height: flagDown==true?40.0:30.0,
                            child:Center(
                              child:Icon(Icons.fast_rewind,size:30,)
                            )
                          ),
                          InkWell(
                            onTap: (){
                              setState(() {
                                
                              });
                            },
                            child: AnimatedContainer(
                              duration: Duration(milliseconds: 200),
                              width:flagDown==true?80.0:50.0,
                              height: flagDown==true?80.0:50.0,
                              decoration: BoxDecoration(
                                color:Colors.black,
                                borderRadius: flagDown==true?BorderRadius.circular(40):BorderRadius.circular(30),
                                // image:DecorationImage(image: AssetImage("assets/play.png"))
                              ),
                              child:Center(
                                child:shape()
                              )
                            ),
                          ),
                          AnimatedContainer(
                            duration: Duration(milliseconds: 200),
                            width:flagDown==true?40.0:30.0,
                            height: flagDown==true?40.0:30.0,
                            child:Center(
                              child:Icon(Icons.fast_forward,size:30,)
                            )
                          ),
                          SizedBox(width:10),
                          AnimatedContainer(
                            duration: Duration(milliseconds: 200),
                            width:flagDown==true?40.0:30.0,
                            height: flagDown==true?40.0:30.0,
                            child:Center(
                              child:Icon(Icons.sentiment_very_satisfied,size:30,)
                            )
                          ),
                        ]
                      ),
                    )
                  ),
                  AnimatedContainer(                            //this right here is sizedbox between play pause row and the song list section........... 
                    duration: Duration(milliseconds: 200),
                    color:Colors.transparent,
                    width:800,
                    height: flagDown==true?80.0:30.0,
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20,0,20,0),
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 200),
                      height:flagDown==false?300.0:0.0,
                      width:flagDown==false?800.0:0.0,
                      child: new ListView.builder(
                        itemCount:songs.length,
                        itemBuilder: (context,int index){
                          return new ListTile(
                            title:Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Row(mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    AnimatedContainer(
                                      height:flagDown==false?30.0:0.0,
                                      duration: Duration(milliseconds:200),
                                      child: new Text(audioName(songs[index].title).toLowerCase(),style: TextStyle(fontWeight: FontWeight.w700))),
                                  ],
                                ),
                                Row(mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    AnimatedContainer(
                                      height:flagDown==false?30.0:0.0,
                                      duration: Duration(milliseconds:200),
                                      child: new Text("Artist's name",style: TextStyle(fontWeight: FontWeight.w400,fontSize: 13),)),
                                  ],
                                ),
                              ],
                            ),
                            onTap: ()=>{
                              setState(() {
                                s=songs[index];
                                artfile=s.albumArt==null?null:new File.fromUri(Uri.parse(s.albumArt));
                              }),
                              playLocal(songs[index].uri),
                              print("URI OF THE SONG IS : " +songs[index].uri)
                              // audioPlayer.play(songs[index].uri,isLocal:true)
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
              Align(                                              //ye maine sabse uppar top center mai 40 height ki ek layer dii hai poster ke uppar as due to animated container swipping effect, android status bar was having a difficulty in opening while swipping and as this is just a static container so ye status bar ki us swipe down pe opening problem ko short out kar de rha hai..........
                alignment: Alignment.topCenter,
                  child: Container(
                  height:40,
                  width:300,
                  color:Colors.transparent
                ),
              )
            ],
          ),
        ),
      ),
    );
  }     
}

//hope u can understand all the points used here......for any trouble please contact me.......and this file is not having dimensions valid for every device........so we have to fix that thing also as stateful widget doesn't contain a mediaquery......so we can't query about size of device using mediaquery......so for that if u have any suggetion , you are most welcome.....