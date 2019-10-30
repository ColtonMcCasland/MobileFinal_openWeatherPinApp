import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feedly/pages/createPostPage.dart';
import 'package:flutter_feedly/widgets/compose_box.dart';
import 'package:simple_moment/simple_moment.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:geolocator/geolocator.dart';

import 'dart:async';




//TODO: Import  openWeather plugins


class MainFeedPage extends StatefulWidget {
  @override
  _MainFeedPageState createState() => _MainFeedPageState();
}

List<Widget> _pins_All = [];
List<Widget> _pins_Recent = [];

List<DocumentSnapshot> _postAllDocuments = [];
List<DocumentSnapshot> _postRecentDocuments = [];

Future _getPins_from_Firebase_All_Future;
Future _getPins_from_Firebase_Recent_Future;

Firestore _firestore_AllMarkers = Firestore.instance;
Firestore _firestore_RecentMarkers = Firestore.instance;

bool hideRecentsList;
var location = new Location();
Map<String, double> userLocation;

class GoogleMapWidget extends StatefulWidget {
  GoogleMapWidget({Key key}) : super(key: key);

  @override
  _MainFeedPageState createState() => _MainFeedPageState();
}

class _MainFeedPageState extends State<MainFeedPage> {
  Completer _controller = Completer();
  LocationData currentLocation;
  var currentlocation = new Location();





  _navigateToCreatePage() async {
    await Navigator.push(context,
        MaterialPageRoute(builder: (BuildContext ctx) {
      return CreatePage();
    }));

    /// refreshes list feed
    _getPins_from_Firebase_All_Future = _getPins_from_Firebase_All();
    _getPins_from_Firebase_Recent_Future = _getPins_from_Firebase_Recent();

    hideRecentsList = false;
  }


  Future _getPins_from_Firebase_Recent() async {
    _pins_Recent = [];

    FirebaseUser user = await FirebaseAuth.instance.currentUser();

      Query _query = _firestore_RecentMarkers
          .collection(user.displayName)
//          .orderBy('created', descending: false)
          .limit(10)
          ;
      QuerySnapshot _quertSnapshot = await _query.getDocuments();
    _postRecentDocuments = _quertSnapshot.documents;




    for (var i = 0; i < _postRecentDocuments.length; ++i) {
      Widget w = _makeCard(_postRecentDocuments[i]);

      _pins_Recent.add(w);
    }

    return _postRecentDocuments;
  }

  Future _getPins_from_Firebase_All() async {
    _pins_All = [];

    FirebaseUser user = await FirebaseAuth.instance.currentUser();

    Query _query = _firestore_AllMarkers
        .collection(user.displayName)
        .orderBy('created', descending: true)
        .limit(10) // limits number of items
        ;
    QuerySnapshot _quertSnapshot = await _query.getDocuments();
    _postAllDocuments = _quertSnapshot.documents;


    for (var i = 0; i < _postAllDocuments.length; ++i) {
      Widget w = _makeCard(_postAllDocuments[i]);

      _pins_All.add(w);
    }

    return _postAllDocuments;
  }

//TODO: replace to have googleMap inside widget

  _ComposeBox() {
    List<Widget> _items = [];

    Widget _composeBox = GestureDetector(
      child: ComposeBox(),
      onTap: () {
        _navigateToCreatePage();
      },
    );

    _items.add(_composeBox);
  }

  _get_Markers_All() {
    List<Widget> _items = [];

//    Widget _composeBox = GestureDetector(
//      child: ComposeBox(),
//      onTap: () {
//        _navigateToCreatePage();
//      },
//    );
//
//    _items.add(_composeBox);

    Widget separator = Container(
      padding: const EdgeInsets.all(10),
      child: Text(
        'All Posts',
        style: TextStyle(
          color: Colors.black54,
        ),
      ),
    );

    _items.add(separator);

    Widget feed = FutureBuilder(
      future: _getPins_from_Firebase_All_Future,
      builder: (BuildContext ctx, AsyncSnapshot snapshot) {
//        loading
        if (snapshot.connectionState == ConnectionState.waiting ||
            snapshot.data == null) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              CircularProgressIndicator(),
              SizedBox(
                height: 16.0,
              ),
              Text('Loading ....'),
            ],
          );
        }
        //no info was found
        else if (snapshot.data.length == 0) {
          return Text('No data to display');
        }
//        populate with info
        else {
//          if( ) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: _pins_All,
          );
//          }
        }
      },
    );

    _items.add(feed);

    return _items;
  }

  _get_Markers_Recent() {
    List<Widget> _items = [];

//    Widget _composeBox = GestureDetector(
//      child: ComposeBox(),
//      onTap: () {
//        _navigateToCreatePage();
//      },
//    );
//
//    _items.add(_composeBox);
//
    Widget separator = Container(
      padding: const EdgeInsets.all(10),
      child: Text(
        'Recently updated Posts',
        style: TextStyle(
          color: Colors.black54,
        ),
      ),
    );

    _items.add(separator);

    Widget feed = FutureBuilder(
      future: _getPins_from_Firebase_Recent_Future,
      builder: (BuildContext ctx, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting ||
            snapshot.data == null) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              CircularProgressIndicator(),
              SizedBox(
                height: 16.0,
              ),
              Text('Loading ....'),
            ],
          );
        } else if (snapshot.data.length == 0) {
          return Text('No data to display');
        } else {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: _pins_Recent,
          );
        }
      },
    );

    _items.add(feed);

    return _items;
  }

  _getLocation() async {
    var location = new Location();
    try {
      currentLocation = await location.getLocation();

      print("locationLatitude: ${currentLocation.latitude.toString()}");
      print("locationLongitude: ${currentLocation.longitude.toString()}");
      setState(
              () {}); //rebuild the widget after getting the current location of the user
    } on Exception {
      currentLocation = null;
    }
  }



  @override
  void initState() {

    super.initState();

    _getLocation();

    _getPins_from_Firebase_All_Future = _getPins_from_Firebase_All();

    _getPins_from_Firebase_Recent_Future = _getPins_from_Firebase_Recent();

//    load markers here..
//    ******************

    updateGoogleMap(); //auto orient to current location with user

  }


  CameraPosition initPosition = CameraPosition(
    target: LatLng(14.5, 25.7), // default initial coordinates
    zoom: 7,
  );

  void updateGoogleMap()
  async{

    try {
      currentLocation = await location.getLocation();

      print("locationLatitude: ${currentLocation.latitude.toString()}");
      print("locationLongitude: ${currentLocation.longitude.toString()}");
      setState(
              () {}); //rebuild the widget after getting the current location of the user
    } on Exception {
      currentLocation = null;
    }

    GoogleMapController cont = await _controller.future;
    setState(() {
      CameraPosition newtPosition = CameraPosition(
        target: LatLng(currentLocation.latitude, currentLocation.longitude), //re-orient to user location on call
        zoom: 4,

      );
      cont.animateCamera(CameraUpdate.newCameraPosition(newtPosition));

    });
  }

//  @override
//  Widget build(BuildContext context) {
//    return Scaffold(
//      appBar: AppBar(
//        leading: Icon(Icons.rss_feed),
//        title: Text('Your Feed'),
//        actions: <Widget>[
//          IconButton(
//            icon: Icon(Icons.exit_to_app),
//            onPressed: () {},
//          )
//        ],
//      ),
////      body: ListView(
////        children: _getItems(),
////
////      ),
//
//
//      floatingActionButton: FloatingActionButton(
//        child: Icon(Icons.add),
//        onPressed: () {
//          _navigateToCreatePage();
//        },
//      ),
//    );
//  }

  var _container = Container(
    height: 50,
    color: Colors.grey,
    margin: EdgeInsets.symmetric(vertical: 10),

  );



  @override
  Widget build(BuildContext context) {

//    show both lists

      return Scaffold(
        appBar: AppBar(title: Text("...workingTitle... App")),
        body: Padding(

          padding: const EdgeInsets.all(10.0),

          child:
          ListView( // parent ListView
            children: <Widget>[

              Container(
                height: 250, // give it a fixed height constraint
                color: Colors.grey,
                // child ListView

                child: ListView(
                  children: _get_Markers_All(),

                ),
              ),

//        Container(
//          height: 100,
//          color: Colors.red,
//        ),

//            _container,

              Container(
                height: 250, // give it a fixed height constraint
                color: Colors.grey,
                // child ListView
                child: ListView(
                  children: _get_Markers_Recent(),
                ),
              ),

              Container(
                height: 150.0,
                child: GoogleMap(
                  mapType: MapType.hybrid,

                  initialCameraPosition: initPosition,
                  scrollGesturesEnabled: false,
                  onMapCreated: (GoogleMapController controller){
                    _controller.complete(controller);
                  },
                ),
              ),
              FlatButton(
                child: Text("Update Map", style: TextStyle(color: Colors.white),),
                color: Colors.deepOrange,
                shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
                onPressed: (){

                  updateGoogleMap();
                },
              )

            ],

          ),
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () {
//              _navigateToCreatePage();

            if(hideRecentsList == false){
              hideRecentsList = true;
            }
            else{
              hideRecentsList = false;
            }

          },
        ),


      );


  }

  Widget _makeCard(DocumentSnapshot postDocument) {
    return Card(

      margin: const EdgeInsets.all(8.0),
      elevation: 5.0,
      child: Column(
        children: <Widget>[
          ListTile(
            title: Text(postDocument.data['owner_name']),
            subtitle: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Icon(
                  Icons.watch_later,
                  size: 14.0,
                ),
                SizedBox(
                  width: 4.0,
                ),
                Text(
                  (Moment.now().from(
                    (postDocument.data['created'] as Timestamp).toDate(),
                  )),
                ),
              ],
            ),
          ),
          postDocument.data['image'] == null
              ? Container()
              : FadeInImage.memoryNetwork(
                  placeholder: kTransparentImage,
                  image: postDocument.data['image'],
                  fit: BoxFit.cover,
                  width: MediaQuery.of(context).size.width,
                ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(postDocument.data['text']),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
//              Expanded(
//                child: FlatButton(
//                  onPressed: () {},
//                  child: Text(
//                    '7 Likes',
//                    style: TextStyle(
//                      fontSize: 12.0,
//                    ),
//                  ),
//                ),
//              ),
//              Expanded(
//                child: FlatButton(
//                  onPressed: () {},
//                  child: Text(
//                    '3 Comments',
//                    style: TextStyle(
//                      fontSize: 12.0,
//                    ),
//                  ),
//                ),
//              ),
//              Expanded(
//                child: FlatButton(
//                  onPressed: () {},
//                  child: Text(
//                    'Share',
//                    style: TextStyle(
//                      fontSize: 12.0,
//                    ),
//                  ),
//                ),
//              ),
            ],
          )
        ],
      ),
    );
  }
}
