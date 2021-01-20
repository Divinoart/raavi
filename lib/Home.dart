import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:admob_flutter/admob_flutter.dart';
import 'package:audio_manager/audio_manager.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:eof_podcast_feed/eof_podcast_feed.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:raavi/assets/ad_manager.dart';
import 'package:raavi/assets/constants.dart';
import 'package:raavi/elements.dart';
import 'package:raavi/firebase_analytics.dart';
import 'package:raavi/pages/login.page.dart';
import 'package:raavi/search_box.dart';
import 'package:search_page/search_page.dart';
class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}


class _HomeState extends State<Home> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  PersistentBottomSheetController controller;
  Future<List> future;
  ScrollController _controller = new ScrollController();
  List lists;
  List list2;
  bool isList = true;
  //todo: new audio player plugin
  String _platformVersion = 'Unknown';
  bool isPlaying = false;
  Duration _duration;
  Duration _position;
  double _slider;
  double _sliderVolume;
  bool _loading = false;
  String _error;
  String _title = '';
  num curIndex = 0;
  PlayMode playMode = AudioManager.instance.playMode;
  AdmobBannerSize bannerSize;
  AdmobBannerSize bannerSize2;
  AdmobInterstitial interstitialAd;

  void _openEndDrawer() {
    _scaffoldKey.currentState.openEndDrawer();
  }

  void handleEvent(
      AdmobAdEvent event, Map<String, dynamic> args, String adType) {
    print(adType + ": " + event.toString());
  }



  @override
  void initState() {
//    setupAudio();
    future = _getPodcast();
    //todo: new audio plugin
    initPlatformState();

//    loadFile();
    //end

    // TODO: implement initState
    super.initState();
    Admob.requestTrackingAuthorization();
    bannerSize = AdmobBannerSize.BANNER;
    bannerSize2 = AdmobBannerSize.LARGE_BANNER;
    if (kShowAd) {
      interstitialAd = AdmobInterstitial(
        adUnitId: AdManager.interstitialAdUnitId,
        listener: (AdmobAdEvent event, Map<String, dynamic> args) {
          if (event == AdmobAdEvent.closed) interstitialAd.load();
          handleEvent(event, args, 'Interstitial');
        },
      );

      interstitialAd.load();

    }
  }

  _showInterstitial () async {
    if ( kShowAd) {
      print("Display interstitialAd");
      if (await interstitialAd.isLoaded) {
        interstitialAd.show();
      }
    }
  }

  @override
  void dispose() {
    // 释放所有资源
    AudioManager.instance.release();
    if (kShowAd) {
      interstitialAd.dispose();
    }
    super.dispose();
  }

  Future<List> _getPodcast() async {
    var podcast =
        await EOFPodcast.fromFeed('https://anchor.fm/s/44efcd1c/podcast/rss');

    print('Podcast Autor: ' + podcast.author);
    print('Podcast Title: ' + podcast.title);
    print('Podcast Link: ' + podcast.url);
    print('Podcast Has Episode: ' + podcast.hasEpisodes.toString());
    print('Podcast Episode Count: ' + podcast.countEpisodes.toString());
    print('Podcast Playback: ' + podcast.playbackState.toString());

    var episode = podcast.episodes.first;

//    print('Episode Title: ' + episode.title);
//    print('Episode Description: ' + episode.description);
//    print('Episode PubDate: ' + episode.pubDate);
//    print('Episode Url: ' + episode.url);
//    print('Episode Cover: ' + episode.cover);
//    print('Episode Playback: ' + episode.playbackState.toString());
    print('printing all podcasts');
    var list = podcast.episodes;

    print(list);
//    list = list2;
    //todo: new audio file code starts here
    List<AudioInfo> _list = [];
//    final audioFile = await _getPodcast();
    list.forEach((item) { _list.add(AudioInfo(item.url,
        title: item.title, desc: item.description, coverUrl: item.cover));});
    setState(() {
      AudioManager.instance.audioList = _list;
    });
    return list;
  }

  void _closeBottomSheet() {
    print(controller.toString());
    if (controller != null) {
      controller.setState(controller.close);
    } else if (controller == null){
      print('Controller is null');
    }
  }




  _showBtmSheet(context){
    controller =
        _scaffoldKey.currentState
            .showBottomSheet<Null>((BuildContext context) {
//          new Timer.periodic(Duration(seconds: 1), (Timer t) => controller.setState((){}));
          return new Stack(
            children: [
              Container(
                child: CachedNetworkImage(
                  fit: BoxFit.fill,
                  imageUrl: AudioManager.instance.info.coverUrl,
                  placeholder: (context, url) =>
                      Image.asset(
                        'assets/images/loading.gif',
                        fit: BoxFit.cover,
                      ),
                  errorWidget: (context, url, error) =>
                      Image.asset(
                        'assets/images/loading.gif',
                        fit: BoxFit.none,
                      ),
                ),
                width: MediaQuery
                    .of(context)
                    .size
                    .width,
                height: MediaQuery
                    .of(context)
                    .size
                    .height,
              ),
              Container(
                width: MediaQuery
                    .of(context)
                    .size
                    .width,
                height: MediaQuery
                    .of(context)
                    .size
                    .height,
                  child: ClipRect(
                    child: new BackdropFilter(
                      filter: new ImageFilter.blur(sigmaX: 30.0, sigmaY: 30.0,),
                      child: new Container(
//                      height: 250,
                        decoration: new BoxDecoration(
                            color: Colors.white.withOpacity(0.0)),
                      ),
                    ),
                  ),
              ),
              Container(
//                height: 250,
                width: MediaQuery
                    .of(context)
                    .size
                    .width,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Card(
                      elevation: 15.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Container(
                        height: MediaQuery
                            .of(context)
                            .size
                            .width / 2,
                        width: MediaQuery
                            .of(context)
                            .size
                            .width / 2,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10.0),
                          child: CachedNetworkImage(
                            placeholder: (context, url) =>
                                Image.asset(
                                  'assets/images/loading.gif',
                                  fit: BoxFit.cover,
                                ),
                            imageUrl: AudioManager.instance.info.coverUrl ?? '',
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),
                    ),

                    ListTile(
                        title: Center(child: Text(
                          AudioManager.instance.info.title, maxLines: 2,
                          overflow: TextOverflow.fade,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white,
                              fontWeight: FontWeight.w800),)),
                        subtitle: MarqueeWidget(
//                    pauseDuration: const Duration(minutes: 1),
                          animationDuration: const Duration(minutes: 2),
                          direction: Axis.horizontal,
                          child: Text(AudioManager.instance.info.desc.replaceAll('</p>', '').replaceAll('<p>', ''),
                            style: TextStyle(color: Colors.white),),)),
                    //todo continue content here
//                    StatefulBuilder(
//                      builder: (context, setState){
//                        return bottomPanel();
//                      },
//                    ),
//                    bottomPanel(),

                  ],
                ),
              ),
              Positioned(
                top: 10.0,
                right: 18.0,
                child:
                SafeArea(
                  top: true,
                  child: InkWell(
                    onTap: () {
                      _closeBottomSheet();
                      print('back pressed');
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30.0),
                        color: Colors.white.withOpacity(0.3),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(Icons.close, color: Colors.white,),
                      ),
                    ),
                  ),
                ),
              ),

              Positioned(
                top: 60.0,
                left: 18.0,
                right: 18.0,
                child:
                SafeArea(
                  child: Column(

                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      kShowAd
                          ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AdmobBanner(
                            adUnitId: AdManager.bannerAdUnitId,
                            adSize: bannerSize2,
                            listener: (AdmobAdEvent event,
                                Map<String, dynamic> args) {
                              handleEvent(event, args, 'Banner');
                            },
                          )
                        ],
                      )
                          : Row(),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 60.0,
                left: 18.0,
                right: 18.0,
                child:
                SafeArea(
                  child: Column(

                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      kShowAd
                          ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AdmobBanner(
                            adUnitId: AdManager.bannerAdUnitId,
                            adSize: bannerSize,
                            listener: (AdmobAdEvent event,
                                Map<String, dynamic> args) {
                              handleEvent(event, args, 'Banner');
                            },
                          )
                        ],
                      )
                          : Row(),
                    ],
                  ),
                ),
              ),

//              SafeArea(
//                child: Column(
//
//                  crossAxisAlignment: CrossAxisAlignment.end,
//                  children: [
//                    kShowAd
//                        ? Row(
//                      mainAxisAlignment: MainAxisAlignment.center,
//                      children: [
//                        AdmobBanner(
//                          adUnitId: AdManager.bannerAdUnitId,
//                          adSize: bannerSize,
//                          listener: (AdmobAdEvent event,
//                              Map<String, dynamic> args) {
//                            handleEvent(event, args, 'Banner');
//                          },
//                        )
//                      ],
//                    )
//                        : Row(),
//                  ],
//                ),
//              ),
            ],
          );
        });
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,

      endDrawer: Drawer(

        child: Container(
          color: const Color(0xff161920),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
//              const Text('Settings'),
                ListTile(
                  leading: Icon(Icons.settings, color: Colors.white,),
                  title: Text('Settings', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),),
                ),

                ListTile(
//                leading: Icon(Icons.swap_horizontal_circle),
                  title: Text(isList? 'Switch to Grid View': 'Switch to List View', style: TextStyle(color: Colors.white,),),
                  trailing: IconButton(
//                    padding: EdgeInsets.all(0),
//                    constraints: BoxConstraints(maxHeight: 24, maxWidth: 24),
                    icon: Icon(isList?Icons.grid_on : Icons.list, size:20, color: Colors.white),
                    onPressed: !isList ? () {setState(() {
                      isList = true;
                    });} : () {setState(() {
                      isList = false;
                    });},
                  ),
                ),

                ListTile(
//                leading: Icon(Icons.swap_horizontal_circle),
                  title: Text('Reload', style: TextStyle(color: Colors.white),),
                  trailing: IconButton(
//                    padding: EdgeInsets.all(0),
//                    constraints: BoxConstraints(maxHeight: 24, maxWidth: 24),
                    icon: Icon(Icons.refresh, size:20, color: Colors.white),
                    onPressed: (){
                      setState(() {
                        future = _getPodcast();
                      });
                    }
                  ),
                ),
                ListTile(
                  title: Text(
                      'Share App', style: TextStyle(color: Colors.white),
                  ),
                  trailing: IconButton(
//                    padding: EdgeInsets.all(0),
//                    constraints: BoxConstraints(maxHeight: 24, maxWidth: 24),
                    icon: Icon(Icons.share, size:20, color: Colors.white),
                    onPressed: () {

                    },
                  ),
                ),
                FlatButton(
//                  style: ElevatedButton.styleFrom(
//                    primary: Colors.white, // background
//                    onPrimary: const Color(0xff161920), // foreground
//                  ),
                  onPressed: (){
                    Navigator.of(context).pop();
                    if (Platform.isAndroid){
                      _showMaterialDialog();

                    } else if (Platform.isIOS){
                      _showCupertinoDialog();

                    }else{
                      analytics.logEvent(
                        name: 'Log out',
                      );
                      AudioManager.instance.release();
                      FirebaseAuth.instance
                          .signOut()
                          .then((value) {Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => LoginPage()));})
                          .catchError((e) {
                        print(e);
                      });
                    }

                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.exit_to_app),
                      SizedBox(width: 5.0,),
                      const Text('Log Out'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          color: const Color(0xff202835),
          height: 110,
          child: bottomPanel(),
        ),
      ),

      backgroundColor: const Color(0xff161920),
      appBar: AppBar(
        actions: <Widget>[
          new Container(),
        ],
        brightness: Brightness.dark,
        centerTitle: true,
        toolbarHeight: 100.0,
        automaticallyImplyLeading: false,
        title: Column(
          children: [
            Text('Raavi', style: TextStyle(color: Color(0xff3FD2E6)),),
            SizedBox(height: 5.0,),
            Padding(
              padding: const EdgeInsets.only(right:4.0),
              child: Container(
                height: 50,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      flex: 6,
                      child: SearchBox(
                        hintText: 'Search book',
                        function: _loading?(){
                          print('initializing');
                          _scaffoldKey.currentState.showSnackBar( SnackBar
                            (content:  Text( 'Book is initializing', style: TextStyle(color: Colors.white),),
                            backgroundColor: Colors.red,));
//
                        }: (){

                          search ();
                        },),
                    ),

                    SizedBox(width: 5.0,),

                    Expanded(
                      flex: 1,
                      child: RaisedButton(
                        color: const Color(0xff3FD2E6).withOpacity(0.2),
                        onPressed: (){
                                _openEndDrawer();
                        },
                        shape: RoundedRectangleBorder(
                            borderRadius: new BorderRadius.all(Radius.circular(12.0),)),
                        child:Center(child: Icon(Icons.filter_list, color: Colors.white, size: 15,)),
                      ),
                    ),

//
                  ],
                ),
              ),
            ),
//            ListTile(
//              contentPadding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 5.0),
//              visualDensity: VisualDensity(horizontal: 0, vertical: -4),
//              dense: true,
////              title: Text('Giveaways', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),),
//              trailing: Row(
//                mainAxisSize: MainAxisSize.min,
//                children: [
//                  IconButton(
////                    padding: EdgeInsets.all(0),
////                    constraints: BoxConstraints(maxHeight: 24, maxWidth: 24),
//                    icon: Icon(Icons.format_list_bulleted, size:20, color: Colors.white),
//                    onPressed: isList ? null : () {setState(() {
//                      isList = true;
//                    });},
//
//                  ),
//                  IconButton(
////                    padding: EdgeInsets.all(0),
////                    constraints: BoxConstraints(maxHeight: 24, maxWidth: 24),
//                    icon: Icon(Icons.grid_on, size:20, color: Colors.white),
//                    onPressed: !isList ? null : () {setState(() {
//                      isList = false;
//                    });},
//                  ),

//
//                ]
//                ,
//              ),
//
////              subtitle: Text('Lets find a scholarship for you'),
//            ),
          ],

        ),
        backgroundColor: const Color(0xff202835),
      ),

//      floatingActionButton: FloatingActionButton(
//        backgroundColor: const Color(0xff3FD2E6),
//        child: Icon(Icons.refresh, color: Colors.white,),
//        onPressed: (){
//          setState(() {
//            future = _getPodcast();
//          });
//        },
//      ),
      body: SingleChildScrollView(
        child: Column(
            children: [
              _future(),
//              Center(
//                  child: Text(_error != null
//                      ? _error
//                      : "${AudioManager.instance.info.title} lrc text: $_position")),

//              _future(),
//              _future(),



            ]),
      ),

      );



  }


  Widget _future(){
    return FutureBuilder(
        future: future,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
              return Center(child: Text('Oops a network error, restart page.', style: TextStyle(color: Colors.white),));
            case ConnectionState.active:
            case ConnectionState.waiting:
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Center(child: Theme(data: ThemeData(cupertinoOverrideTheme: CupertinoThemeData(
                    brightness: Brightness.dark)),
                    child: CupertinoActivityIndicator(

          animating: true,
          ),)),
                  ),
                ],
              );
            case ConnectionState.done:
              if (snapshot.hasError) return
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
//                    Container(
//                        height: 150,
//                        width: 180,
//                        child: Lottie.asset('assets/images/error.json', fit: BoxFit.cover,)),
                    SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Center(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('An error occurred trying to load podcasts\n'
                                'You could try reloading the page', style: TextStyle(color: Colors.white), textAlign: TextAlign.center,),
                            FlatButton(
//                              style: ElevatedButton.styleFrom(
//                                primary: Colors.white, // background
//                                onPrimary: const Color(0xff161920), // foreground
//                              ),
                              onPressed: (){
                                setState(() {
                                  future = _getPodcast();
                                });
                              },
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.exit_to_app),
                                  SizedBox(width: 5.0,),
                                  const Text('Reload'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
//              lists.add(snapshot.data);
//              setState(() {
//              });

//                Text('Error: ${snapshot.error}');
              // return Text('Result: ${snapshot.data}');
              return createMyListView(context, snapshot, _controller);
          }
          return null; // unreachable
        });
  }

  createMyListView(BuildContext context, AsyncSnapshot snapshot, ScrollController _scrollcontroller) {
    List<dynamic> values = snapshot.data;
    lists = snapshot.data;
//    setupAudio();
    if(values.isNotEmpty){

      return  isList? ListView.builder(
//        physics: const AlwaysScrollableScrollPhysics(),
        controller: _scrollcontroller,
        itemCount: values.length,
        shrinkWrap: true,
        itemBuilder: (BuildContext context, int index) {

            return GestureDetector(
              onTap:
              () async {
                if(AudioManager.instance.isPlaying && AudioManager.instance.info.title.toString() == values[index].title.toString()) {
                  _showBtmSheet(context);
                }else if (_loading){
                  _scaffoldKey.currentState.showSnackBar( SnackBar
                    (content:  Text( 'Initializing please wait', style: TextStyle(color: Colors.white),),
                    backgroundColor: Colors.red,));
                  print('loading');

                }else{
                  await _showBtmSheet(context);
                  AudioManager.instance.play(index: index);
                  setupAudio();
                }
              },
              child: Padding(
                padding: const EdgeInsets.all(2.0),
                child: new ListTile(
//                        dense: true,
                  contentPadding: EdgeInsets.symmetric(vertical:10.0, horizontal: 8.0),
                  leading: Container(
//                          color: Colors.red,
                    width: 60,
                    height: 60,
//                          width: MediaQuery.of(context).size.width / 4,
//                          height: MediaQuery.of(context).size.Lis,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4.0),
                      child: CachedNetworkImage(
                        placeholder: (context, url) =>
                            Image.asset(
                              'assets/images/loading.gif',
                              fit: BoxFit.cover,
                            ),
                        imageUrl: values[index].cover.toString() ?? '',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  title: Text((values[index].title != null) ? values[index].title.toString() : '',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,)
                  ,
                  subtitle:
                  Text((values[index].description != null) ? values[index].description.toString().replaceAll('</p>', '').replaceAll('<p>', '') : '',
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 10, color: Colors.white.withOpacity(0.5)),
                  ),
                  trailing:Icon((_title == values[index].title.toString())? Icons.pause_circle_outline : Icons.play_circle_outline, color: const Color(0xff3FD2E6), size: 36,),
                ),
              ),
            );

        },
      ): GridView.builder(
//        physics: const AlwaysScrollableScrollPhysics(),
        controller: _scrollcontroller,
        itemCount: values.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3),
        shrinkWrap: true,
        itemBuilder: (BuildContext context, int index) {

          return GestureDetector(
            onTap: () async {
              if(AudioManager.instance.isPlaying && AudioManager.instance.info.title.toString() == values[index].title.toString()) {
                _showBtmSheet(context);
              }else if (_loading){
                _scaffoldKey.currentState.showSnackBar( SnackBar
                  (content:  Text( 'Initializing please wait', style: TextStyle(color: Colors.white),),
                  backgroundColor: Colors.red,));
                print('loading');

              }else{
                await _showBtmSheet(context);
                AudioManager.instance.play(index: index);
                setupAudio();
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(2.0),
              child: new Container(
//                          color: Colors.red,
                width: 60,
                height: 60,
//                          width: MediaQuery.of(context).size.width / 4,
//                          height: MediaQuery.of(context).size.Lis,
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4.0),
                      child: CachedNetworkImage(
                        placeholder: (context, url) =>
                            Center(
                              child: Image.asset(
                                'assets/images/loading.gif',
//                                height: 60,
//                                width: 60,
                                fit: BoxFit.fill,
                              ),
                            ),
                        imageUrl: values[index].cover.toString() ?? '',
                        fit: BoxFit.cover,
                      ),
                    ),

                    Positioned(
                        top: 1,
                        bottom: 1,
                        left: 1,
                        right: 1,
                        child: Icon((_title == values[index].title.toString())? Icons.pause_circle_outline : Icons.play_circle_outline, color: Colors.white, size: 35,))
                  ],

                ),
              ),
            ),
          );

        },
      );
    } else{
      return Center(child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
//          Container(
//              height: 150,
//              width: 180,
//              child: Lottie.asset('assets/images/empty.json', fit: BoxFit.cover,)),
          SizedBox(
            height: 10,
          ),
          Text('Nodata')
//          NoData(),
        ],
      ),);
    }
  }

  void search (){
    analytics.logEvent(
        name: 'SearchPodcast',
        parameters: {'Screen': 'PodcastScreenSearch',});
    showSearch(
      context: context,
      delegate: SearchPage(
        barTheme: ThemeData(

          inputDecorationTheme: InputDecorationTheme(
            fillColor: Colors.white,
            hintStyle: TextStyle(
              color: Colors.white,
              fontSize: 15,
            ),
          ),
          appBarTheme: AppBarTheme(textTheme: TextTheme(caption: TextStyle(color: Colors.white),), ),
          primaryColor: const Color(0xff202835),
        ),

        items: lists,
        searchLabel: 'Search book',
        suggestion: Center(
          child: Text('Filter books by Name'),
        ),
        failure: Center(
          child: Text('No matching book found :('),
        ),
        filter: (person) => [
          person.title.toString(),
//          person['image_url'].toString(),
//          person.surname,
//          person.age.toString(),
        ],
        builder: (person) => InkWell(
          onTap:
              () async {
                await Navigator.of(context).pop();
            if(AudioManager.instance.isPlaying && AudioManager.instance.info.title.toString() == person.title.toString()) {

              _showBtmSheet(context);
            }else if (_loading){
              _scaffoldKey.currentState.showSnackBar( SnackBar
                (content:  Text( 'Initializing please wait', style: TextStyle(color: Colors.white),),
                backgroundColor: Colors.red,));
              print('loading');

            }else{
              await _showBtmSheet(context);
              AudioManager.instance.play(index: lists.indexOf(person, 0));
              setupAudio();
            }
          },

//              () async {
//            print('*********************loading');
//            print(person.title);
////            print(lists.indexOf(person, 0));
//            await Navigator.of(context).pop();
////            AudioManager.instance.start(person.url, person.title);
//            AudioManager.instance.play(index: lists.indexOf(person, 0), auto: true);
//            _showBtmSheet(context);
//
//            print('loading');
//
//          },
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: ListTile(
              leading: Icon(Icons.audiotrack, color: Colors.black,),
              title: Text(person.title.toString(), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),),
//              subtitle: Text(person.author.toString(), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),),
              trailing: Container(
                height: 40,
                width: 40,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4.0),
                  child: CachedNetworkImage(
                    placeholder: (context, url) =>
                        Image.asset(
                          'assets/images/loading.gif',
                          fit: BoxFit.cover,
                        ),
                    imageUrl: person.cover.toString()?? '',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
//            subtitle: Text(person.surname),
//            trailing: Text('${person.age} yrs'),
            ),
          ),
        ),
      ),
    );
  }

  _showMaterialDialog() {
    showDialog(
        context: context,
        builder: (_) => new AlertDialog(
          title: new Text("Log Out"),
          content: new Text("click proceed to logout"),
          actions: <Widget>[
            FlatButton(
              child: Text('Proceed to logout'),
              onPressed: () {
                analytics.logEvent(
                  name: 'Log out',
                );
                AudioManager.instance.release();
                Navigator.of(context).pop();
                FirebaseAuth.instance
                    .signOut()
                    .then((value) {Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => LoginPage()));})
                    .catchError((e) {
                  print(e);
                });
//                Navigator.of(context).pop();
              },
            )
          ],
        ));
  }

  _showCupertinoDialog() {
    showDialog(
        context: context,
        builder: (_) => new CupertinoAlertDialog(
          title: new Text("Log Out"),
          content: new Text("click proceed to logout"),
          actions: <Widget>[
            FlatButton(
              child: Text('Proceed to logout'),
              onPressed: () {
                analytics.logEvent(
                  name: 'Log out',
                );
                Navigator.of(context).pop();
                AudioManager.instance.release();
                FirebaseAuth.instance
                    .signOut()
                    .then((value) {Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => LoginPage()));})
                    .catchError((e) {
                  print(e);
                });
              },
            )
          ],
        ));
  }

  void loadFile() async {
    // read bundle file to local path
    List<AudioInfo> _list = [];
    final audioFile = await _getPodcast();
    audioFile.forEach((item) { _list.add(AudioInfo(item.url,
        title: item.title, desc: item.description, coverUrl: item.cover));});

//    final appDocDir = await getApplicationDocumentsDirectory();
//    print(appDocDir);
//
//    final file = File("${appDocDir.path}/aLIEz.m4a");
//    file.writeAsBytesSync(audio);
//
//    AudioInfo info = AudioInfo("file://${file.path}",
//        title: "file", desc: "local file", coverUrl: "assets/aLIEz.jpg");
//
//    list.add(info.toJson());
//    AudioManager.instance.audioList.add(info);
    setState(() {
      AudioManager.instance.audioList = _list;
    });
  }




  //todo: new audio stuffs
  void setupAudio() {
//    await loadFile();
//    List<AudioInfo> _list = [];
//    lists.forEach((item) => _list.add(AudioInfo(item.url,
//        title: item.title, desc: item.description, coverUrl: item.cover)));


//    AudioManager.instance.audioList = _list;


    AudioManager.instance.intercepter = true;
//    AudioManager.instance.info.title = _title;

//    AudioManager.instance.play(auto: false);

    AudioManager.instance.onEvents((events, args) {
      print('*********************************************');
      print("$events, $args");
      switch (events) {
        case AudioManagerEvents.start:
          print(
              "start load data callback, curIndex is ${AudioManager.instance.curIndex}");
          _position = AudioManager.instance.position;
          _title = AudioManager.instance.info.title;
          _duration = AudioManager.instance.duration;
          _loading = AudioManager.instance.isLoading;
          _slider = 0;
          setState(() {});
//          controller.setState((){});
          break;
        case AudioManagerEvents.ready:
          print("ready to play");
          _error = null;
          _loading = AudioManager.instance.isLoading;
          _sliderVolume = AudioManager.instance.volume;
          _title = AudioManager.instance.info.title;
          _position = AudioManager.instance.position;
          _duration = AudioManager.instance.duration;
          setState(() {});
//          controller.setState((){});
          // if you need to seek times, must after AudioManagerEvents.ready event invoked
          // AudioManager.instance.seekTo(Duration(seconds: 10));
          break;
        case AudioManagerEvents.seekComplete:
          _position = AudioManager.instance.position;
          _loading = AudioManager.instance.isLoading;
          _title = AudioManager.instance.info.title;
          _slider = _position.inMilliseconds / _duration.inMilliseconds;
          setState(() {});
//          controller.setState((){});
          print("seek event is completed. position is [$args]/ms");
          break;
        case AudioManagerEvents.buffering:
          print("buffering $args");
          break;
        case AudioManagerEvents.playstatus:
          _loading = AudioManager.instance.isLoading;
          _title = AudioManager.instance.info.title;
          isPlaying = AudioManager.instance.isPlaying;
          setState(() {});
//          controller.setState((){});
          break;
        case AudioManagerEvents.timeupdate:
          _position = AudioManager.instance.position;
          _loading = AudioManager.instance.isLoading;
          _title = AudioManager.instance.info.title;
          _slider = _position.inMilliseconds / _duration.inMilliseconds;
          setState(() {});
//          controller.setState((){});
          AudioManager.instance.updateLrc(args["position"].toString());
          break;
        case AudioManagerEvents.error:
          _loading = AudioManager.instance.isLoading;
          _error = args;
          setState(() {});
//          controller.setState((){});
          break;
        case AudioManagerEvents.ended:
          _loading = AudioManager.instance.isLoading;
          AudioManager.instance.next();
          break;
        case AudioManagerEvents.volumeChange:
          _sliderVolume = AudioManager.instance.volume;
          setState(() {});
//          controller.setState((){});
          break;
        default:
          break;
      }
    });
  }

  Future<void> initPlatformState() async {
    String platformVersion;
    try {
      platformVersion = await AudioManager.instance.platformVersion;
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  Widget bottomPanel() {
    return Column(children: <Widget>[
      Padding(
        padding: const EdgeInsets.symmetric(vertical:5.0, horizontal: 16),
        child: Row(
          children: [
            Expanded(
              child: _loading?
              Theme(data: ThemeData(cupertinoOverrideTheme: CupertinoThemeData(
                  brightness: Brightness.dark)),
                child: CupertinoActivityIndicator(

                  animating: true,
                ),
              ):
              Text(
                (_title!= null) ? _title : '',
                maxLines: 1,
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
      Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: songProgress(context),
      ),
      Container(
        padding: EdgeInsets.symmetric(vertical: 2),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            IconButton(
                icon: getPlayModeIcon(playMode),
                onPressed: () {
                  playMode = AudioManager.instance.nextMode();
//                  setState(() {});
//                  controller.setState((){});
                }),
            IconButton(
                iconSize: 36,
                icon: Icon(
                  Icons.skip_previous,
                  color: Colors.white,
                ),
                onPressed: () => AudioManager.instance.previous()),
            IconButton(
              onPressed: () async {
                bool playing = await AudioManager.instance.playOrPause();
                print("await -- $playing");
                setState(() {
                  _title = AudioManager.instance.info.title;
                });
              },
              padding: const EdgeInsets.all(0.0),
              icon: Icon(
                isPlaying ? Icons.pause : Icons.play_arrow,
                size: 48.0,
                color: Colors.white,
              ),
            ),
            IconButton(
                iconSize: 36,
                icon: Icon(
                  Icons.skip_next,
                  color: Colors.white,
                ),
                onPressed: () => AudioManager.instance.next()),
            IconButton(
                icon: Icon(
                  Icons.stop,
                  color: Colors.white,
                ),
                onPressed: () {
                  AudioManager.instance.stop();
                setState(() {
                  _title = '';
                });
                }),
          ],
        ),
      ),
    ]);
  }

  Widget getPlayModeIcon(PlayMode playMode) {
    switch (playMode) {
      case PlayMode.sequence:
        return Icon(
          Icons.repeat,
          color: Colors.white,
        );
      case PlayMode.shuffle:
        return Icon(
          Icons.shuffle,
          color: Colors.white,
        );
      case PlayMode.single:
        return Icon(
          Icons.repeat_one,
          color: Colors.white,
        );
    }
    return Container();
  }

  Widget songProgress(BuildContext context) {
    var style = TextStyle(color: Colors.white);
    return Row(
      children: <Widget>[
        Text(
          _formatDuration(_position),
          style: style,
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 5),
            child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 2,
                  thumbColor: Colors.blueAccent,
                  overlayColor: Colors.blue,
                  thumbShape: RoundSliderThumbShape(
                    disabledThumbRadius: 5,
                    enabledThumbRadius: 5,
                  ),
                  overlayShape: RoundSliderOverlayShape(
                    overlayRadius: 10,
                  ),
                  activeTrackColor: Colors.blueAccent,
                  inactiveTrackColor: Colors.grey,
                ),
                child: Slider(
                  value: _slider ?? 0,
                  onChanged: (value) {

                    setState(() {
                      _slider = value;
                    });
                  },
                  onChangeEnd: (value) {
                    if (_duration != null) {
                      Duration msec = Duration(
                          milliseconds:
                          (_duration.inMilliseconds * value).round());
                      AudioManager.instance.seekTo(msec);
                    }
                  },
                )),
          ),
        ),
        Text(
          _formatDuration(_duration),
          style: style,
        ),
      ],
    );
  }

  String _formatDuration(Duration d) {
    if (d == null) return "--:--";
    int minute = d.inMinutes;
    int second = (d.inSeconds > 60) ? (d.inSeconds % 60) : d.inSeconds;
    String format = ((minute < 10) ? "0$minute" : "$minute") +
        ":" +
        ((second < 10) ? "0$second" : "$second");
    return format;
  }

  Widget volumeFrame() {
    return Row(children: <Widget>[
      IconButton(
          padding: EdgeInsets.all(0),
          icon: Icon(
            Icons.audiotrack,
            color: Colors.black,
          ),
          onPressed: () {
            AudioManager.instance.setVolume(0);
          }),
      Expanded(
          child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 0),
              child: Slider(
                value: _sliderVolume ?? 0,
                onChanged: (value) {
                  setState(() {
                    _sliderVolume = value;
                    AudioManager.instance.setVolume(value, showVolume: true);
                  });
                },
              )))
    ]);
  }
}
