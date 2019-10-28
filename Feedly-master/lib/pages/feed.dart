import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feedly/pages/create.dart';
import 'package:flutter_feedly/widgets/compose_box.dart';
import 'package:simple_moment/simple_moment.dart';
import 'package:transparent_image/transparent_image.dart';

class FeedPage extends StatefulWidget {
  @override
  _FeedPageState createState() => _FeedPageState();
}

List<Widget> _posts = [];
List<DocumentSnapshot> _postDocuments = [];
Future _getFeedFuture;

Firestore _firestore = Firestore.instance;
FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

class _FeedPageState extends State<FeedPage> {
  _navigateToCreatePage() async {
    await Navigator.push(context,
        MaterialPageRoute(builder: (BuildContext ctx) {
      return CreatePage();
    }));

    /// refreshes list feed
    _getFeedFuture = _getFeed();
  }

  Future _getFeed() async {
    _posts = [];

    Query _query = _firestore
        .collection('posts')
        .orderBy('created', descending: true)
        .limit(10);
    QuerySnapshot _quertSnapshot = await _query.getDocuments();

    _postDocuments = _quertSnapshot.documents;

    for (var i = 0; i < _postDocuments.length; ++i) {
      Widget w = _makeCard(_postDocuments[i]);

      _posts.add(w);
    }

    return _postDocuments;
  }

  _getItems() {
    List<Widget> _items = [];

    Widget _composeBox = GestureDetector(
      child: ComposeBox(),
      onTap: () {
        _navigateToCreatePage();
      },
    );

    _items.add(_composeBox);

    Widget separator = Container(
      padding: const EdgeInsets.all(10),
      child: Text(
        'Recent Posts',
        style: TextStyle(
          color: Colors.black54,
        ),
      ),
    );

    _items.add(separator);

    Widget feed = FutureBuilder(
      future: _getFeedFuture,
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
            children: _posts,
          );
        }
      },
    );

    _items.add(feed);



    return _items;
  }

  @override
  void initState() {
    super.initState();

    _getFeedFuture = _getFeed();
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
    height: 200,
    color: Colors.blue,
    margin: EdgeInsets.symmetric(vertical: 10),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("ListView")),
      body: Padding(
        padding: const EdgeInsets.all(40.0),
        child: ListView( // parent ListView
          children: <Widget>[
//            _container,
//            _container,
            Container(
              height: 200, // give it a fixed height constraint
              color: Colors.teal,
              // child ListView
              child: ListView.builder(itemBuilder: (_, i) => ListTile(title: Text("Item ${i}"))),
            ),
            _container,
            Container(
              height: 200, // give it a fixed height constraint
              color: Colors.teal,
              // child ListView
              child: ListView.builder(itemBuilder: (_, i) => ListTile(title: Text("Item ${i}"))),
            ),
            _container,
          ],
        ),
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
              Expanded(
                child: FlatButton(
                  onPressed: () {},
                  child: Text(
                    '7 Likes',
                    style: TextStyle(
                      fontSize: 12.0,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: FlatButton(
                  onPressed: () {},
                  child: Text(
                    '3 Comments',
                    style: TextStyle(
                      fontSize: 12.0,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: FlatButton(
                  onPressed: () {},
                  child: Text(
                    'Share',
                    style: TextStyle(
                      fontSize: 12.0,
                    ),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
