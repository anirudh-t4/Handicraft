/*import 'package:maps/diners/dinerinfo.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong/latlong.dart';
import 'package:maps/services/authservice.dart';
import 'package:maps/diners/storeComponents/store.dart';
import 'package:maps/diners/shopCard.dart';
class StoresPage extends StatefulWidget {
 final String phNo;
  StoresPage({Key key,this.phNo}) : super(key: key);
  @override
  _StoresPageState createState() => _StoresPageState(phNo:phNo);
}

class _StoresPageState extends State<StoresPage> {
  final CollectionReference storesRef  = Firestore.instance.collection("stores");
  String phNo;
  _StoresPageState({this.phNo});
  List<double> myLocation=[0.0,0.0];

  @override
  void initState() {
    // TODO: implement initState
    _getMyLocation();
    super.initState();
  }

  _getMyLocation()async {

    var mylocation = await getLocation();
    setState(() {
      myLocation = mylocation;
    });
  }
   double _calcDistance(List<dynamic> storeLoc){
      if(this.myLocation[0] == 0.0 && this.myLocation[1]==0.0){
        return 0.0;
      }
      else{
          final Distance distance = new Distance();
              
          // km = 423
          final double km = distance.as(LengthUnit.Kilometer,
          new LatLng(storeLoc[0],storeLoc[1]),new LatLng(this.myLocation[0],this.myLocation[1]));
          
          // // meter = 422591.551
          final double meter = distance(
              new LatLng(storeLoc[0],storeLoc[1]),new LatLng(this.myLocation[0],this.myLocation[1])
              );
          // if(meter>1000){
          //   return '$km Km';
          // }
          // else{
            return meter;

          // }

      }
    }

  @override
  Widget build(BuildContext context) {
      bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    Color dynamiciconcolor = (!isDarkMode) ? Colors.black : Colors.white;
    Color dynamicuicolor =
        (!isDarkMode) ? new Color(0xfff8faf8) : Color.fromRGBO(25, 25, 25, 1.0);
        Color dynamicbgcolor =
        (!isDarkMode) ? Colors.grey[200] : Colors.black;
    return Container(
    //  backgroundColor: Colors.redAccent[900],
      /* appBar: AppBar(title:Text("Stores Near Me",
       
       ),
       centerTitle: true,
       backgroundColor: Colors.redAccent[900],
       actions: <Widget>[
         RaisedButton(
           child: Text('Sign Out'),
           onPressed: ()async{
                          AuthService().signOut();
                          Navigator.pushReplacement(context, new MaterialPageRoute(builder: (context)=> AuthService().handleAuth()));


         })
       ],
       
       ),
       
       
       */
       
      child: StreamBuilder<QuerySnapshot>(
        stream: storesRef.snapshots(),
        builder: (context,snapshot){
            if(snapshot.hasData)
              {
              final List<StoreCard> docs = snapshot.data.documents.map(
                (doc)=>
                StoreCard(
                  store:Store(
                      name: doc['name'],
                      distance:  _calcDistance(doc['location']),
                      description: doc['description']??"" ,
                      contact: doc['phno'],
                      id:doc['id'],
                      sellerId: doc['sellerId'],
                      location: doc['location']
                  )  
                )
              ).toList();
             // docs.removeWhere((doc)=>doc.store.distance>2099.0);
              docs.sort((a,b)=>a.store.distance.compareTo(b.store.distance));
              
              return ListView(children: docs,physics: BouncingScrollPhysics(),);
            }
            else return Center(child: CupertinoActivityIndicator());
            

        },),

    );
  }
}

*/
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cottage_app/chefs/manageStore.dart';
import 'package:cottage_app/diners/previousOrders.dart';
import 'package:cottage_app/models/about.dart';
import 'package:cottage_app/services/sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cottage_app/diners/dinerinfo.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geocoder/geocoder.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong/latlong.dart';
import 'package:cottage_app/models/payments.dart';
import 'package:cottage_app/services/authservice.dart';
import 'package:cottage_app/diners/storeComponents/store.dart';
import 'package:cottage_app/diners/shopCard.dart';
import 'package:flutter/material.dart';
import 'package:cottage_app/diners/feedback.dart';
import 'package:cottage_app/diners/storePage.dart';
import 'package:theme_provider/theme_provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:wiredash/wiredash.dart';
import 'filters.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'account.dart';
import 'package:cottage_app/diners/about.dart';
import 'notification.dart';
import 'feedback.dart';
import 'pastorder.dart';
import 'package:cottage_app/diners/search.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cottage_app/screens/HomeScreen.dart';




class StoresPage extends StatefulWidget {
 final String phNo;
  StoresPage({Key key,this.phNo}) : super(key: key);
  @override
  _StoresPageState createState() => _StoresPageState(phNo:phNo);
}

class _StoresPageState extends State<StoresPage> {
   Address storeaddress = new Address();
  FirebaseUser user;
   final FirebaseAuth _auth = FirebaseAuth.instance;
   var dinerDetails;
    String dinerName;
    String phoneNo;
      var location;
   var queryResultSet = [];
  var tempSearchStore = [];

  initiateSearch(value) {
    if (value.length == 0) {
      setState(() {
        queryResultSet = [];
        tempSearchStore = [];
      });
    }

    var capitalizedValue =
        value.substring(0, 1).toUpperCase() + value.substring(1);

    if (queryResultSet.length == 0 && value.length == 1) {
      SearchService().searchByName(value).then((QuerySnapshot docs) {
        for (int i = 0; i < docs.documents.length; ++i) {
          queryResultSet.add(docs.documents[i].data);
           setState(() {
                tempSearchStore.add(queryResultSet[i]);
 });
        }
      });
    } else {
      tempSearchStore = [];
       queryResultSet.forEach((element) {
        if (element['name'].toLowerCase().contains(value.toLowerCase()) ==  true) {
            if (element['name'].toLowerCase().indexOf(value.toLowerCase()) ==0) {
              setState(() {
                tempSearchStore.add(element);
              });
            }
          }

      });
    }
    if (tempSearchStore.length == 0 && value.length > 1) {
      setState(() {});
    }

  }

  var scaffoldKey = GlobalKey<ScaffoldState>();
  String dropdownValue = 'Sort';
  List<String> dropdownItems = <String>[
    'Sort',
    'Distance',
    'Popularity',
    'Ratings: High to Low',
    'Cost: High to Low',
    'Cost: Low to High'
  ];

  int i = 2;
  final CollectionReference storesRef  = Firestore.instance.collection("stores");
  String phNo;
  _StoresPageState({this.phNo});
  List<double> myLocation=[0.0,0.0];
  Future<void> resetUserType() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('User Type', 'None');
  }
  @override
  void initState() {
    // TODO: implement initState
    init();
    _getMyLocation();
    super.initState();
  }
 init() async{
 user = await  _auth.currentUser();
 dinerDetails = await Firestore.instance.collection("diners").document(user.uid).get();
 setState(() {
   dinerName = dinerDetails.data['name'];
   location = dinerDetails.data['location'];
   phoneNo = dinerDetails.data['phoneNo'];
 });
_getAddress(location);
 }
  _getAddress(List<dynamic> coordinates) async {
    var addresses = await Geocoder.local.findAddressesFromCoordinates(
        Coordinates(coordinates[0], coordinates[1]));
    var firstresult = addresses.first;
    setState(() {
      storeaddress = firstresult;
    });
  }
  _getMyLocation()async {

    var mylocation = await getLocation();
    setState(() {
      myLocation = mylocation;
    });
  }
   double _calcDistance(List<dynamic> storeLoc){
      if(this.myLocation[0] == 0.0 && this.myLocation[1]==0.0){
        return 0.0;
      }
      else{
          final Distance distance = new Distance();
              
          // km = 423
          final double km = distance.as(LengthUnit.Kilometer,
          new LatLng(storeLoc[0],storeLoc[1]),new LatLng(this.myLocation[0],this.myLocation[1]));
          
          // // meter = 422591.551
          final double meter = distance(
              new LatLng(storeLoc[0],storeLoc[1]),new LatLng(this.myLocation[0],this.myLocation[1])
              );
          // if(meter>1000){
          //   return '$km Km';
          // }
          // else{
            return meter;

          // }

      }
    }

  @override
  Widget build(BuildContext context) {
    final drawerHeader = UserAccountsDrawerHeader(
      accountName: Text(dinerName!=null ? dinerName : "Name"),
      accountEmail: Text(phoneNo!=null ? phoneNo : "Null"),
      decoration: BoxDecoration(
        color: Colors.redAccent[700],
      ),
      currentAccountPicture: CircleAvatar(
        backgroundColor: Colors.white,
        backgroundImage: AssetImage("assets/foodie.jpg"),
      ),
    );
    final drawerItems = ListView(
      children: <Widget>[
        drawerHeader,
        ListTile(
            title: Text('My Account'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Account()),
              );
            }),
        Divider(
          thickness: 1,
          color: Colors.grey,
        ),
        ListTile(
            title: Text('Switch to Chef mode'),
            onTap: ()async {
  await resetUserType();
                          Navigator.pushReplacement(context, new MaterialPageRoute(builder: (context)=>HomeScreen()));

            } //=> Navigator.of(context).push(_NewPage(2)),
        ),
        Divider(
          thickness: 1,
          color: Colors.grey,
        ),
        ListTile(
          title: Text('Previous Orders'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => PrevOrdersPage()),
            );
          },
        ),
        Divider(
          thickness: 1,
          color: Colors.grey,
        ),
        ListTile(
          title: Text('Notifications'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Notifications()),
            );
          },
        ),
        Divider(
          thickness: 1,
          color: Colors.grey,
        ),
        ListTile(
          title: Text('Feedback'),
          onTap: () {
            Wiredash.of(context).show();
          },
        ),
        Divider(
          thickness: 1,
          color: Colors.grey,
        ),
        ListTile(
          title: Text('About'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Credits()),
            );
          },
        ),
        Divider(
          thickness: 1,
          color: Colors.grey,
        ),
        ListTile(
          title: Text('Logout'),
          onTap: () async{
             AuthService().signOut();
                          Navigator.pushReplacement(context, new MaterialPageRoute(builder: (context)=> AuthService().handleAuth()));
             signOutGoogle();


          },
        ),
      ],
    );

    return dinerDetails!=null ?
    Scaffold(
      key: scaffoldKey,
      endDrawer: Drawer(
        child: drawerItems,
      ),
      body:  Container(
        child: Column(
          children: <Widget>[
            Container(
              child: Center(
                child: Column(
                  children: [
                    ClipPath(
                      clipper: MyClip(),
                      child: Container(
                        height: 200.0,
                        color: Colors.redAccent[700],
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 30),
                                    child: Text(
                                      "Welcome to Local Kitchen!",
                                      style: TextStyle(
                                          fontSize: 22.0,
                                          color: Colors.white,
                                          fontFamily: 'Pacifico'),
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.menu),
                                    color: Colors.white,
                                    iconSize: 30,
                                    onPressed: () =>
                                        scaffoldKey.currentState.openEndDrawer(),
                                  )
                                ],
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(22.0),
                                ),
                                height: 45.0,
                                margin: EdgeInsets.symmetric(
                                    horizontal: 34.0, vertical: 30.0),
                                child: TextField(
                                        onChanged: (val) {
                initiateSearch(val);},
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    hintText: "Search for the best home kitchens",
                                    hintStyle: TextStyle(color: Colors.grey[700]),
                                    contentPadding: EdgeInsets.symmetric(
                                        horizontal: 16.0, vertical: 14.0),
                                    suffixIcon: Icon(
                                      FontAwesomeIcons.search,
                                      size: 14.0,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 10.0)
                            ],
                          ),
                        ),
                      ),
                    ),
                    Container(
                      height: 40,
                      child: FlatButton(
                        onPressed: () {},
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.location_on,
                                color: Colors.redAccent[700],
                              ),
                              Flexible(
                                child: new Container(
                      padding: new EdgeInsets.only(right: 13.0),
                             child: new Text(
                                
                                   
                                    storeaddress.addressLine != null ? storeaddress.addressLine :"My Location",
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        fontSize: 15, ),
                                    textAlign: TextAlign.center,
                                  ),)
                                ),
                              
                            ]),
                      ),
                    ),
                    Divider(
                      thickness: 2,
                      color: Colors.grey[200],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Container(
                              child: DropdownButton<String>(
                                value: dropdownValue,
                                icon: Icon(
                                  Icons.arrow_drop_down,
                                  color: Colors.redAccent[700],
                                ),
                                iconSize: 36,
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  fontSize: 15,
                                ),
                                onChanged: (String newValue) {
                                  setState(() {
                                    dropdownValue = newValue;
                                  });
                                },
                                items: dropdownItems
                                    .map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                              ),
                            ),
                            Container(
                              child: RaisedButton(
                                elevation: 1,
                                color: Colors.white,
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => Filter()),
                                  );
                                },
                                child: Row(
                                  children: [
                                    const Text('Filter',
                                        style: TextStyle(
                                            fontSize: 15, color: Colors.grey)),
                                    Icon(
                                      Icons.grain,
                                      color: Colors.redAccent[700],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            FlatButton(
                              color: Colors.transparent,
                              child: Icon(Icons.brightness_6),
                                onLongPress: (){
                                  Navigator.of(context).push(MaterialPageRoute<void>(
                                      builder: (BuildContext context) {
                                        return Scaffold(
                                          body: const WebView(
                                            initialUrl: 'https://playsnake.org/',
                                            javascriptMode: JavascriptMode.unrestricted,
                                          ),
                                        );

                                      }
                                  ));
                                }, onPressed: () {  },


                            )]),
                    ),
                    Container(
                      height: 200,
                      width: 350,
                      child: CarouselSlider(
                        options: CarouselOptions(
                          height: 200,
                          aspectRatio: 16 / 9,
                          viewportFraction: 0.8,
                          initialPage: 0,
                          enableInfiniteScroll: true,
                          reverse: false,
                          autoPlay: true,
                          autoPlayInterval: Duration(seconds: 3),
                          autoPlayAnimationDuration: Duration(milliseconds: 800),
                          autoPlayCurve: Curves.fastOutSlowIn,
                          enlargeCenterPage: true,
                          scrollDirection: Axis.horizontal,
                        ),
                        items: [
                          'assets/First.jpg',
                          'assets/Second.jpg',
                          'assets/Ind1.png',
                          'assets/Amer1.png',
                          'assets/Mex1.png',
                          'assets/Th1.png'
                        ].map((i) {
                          return Builder(
                            builder: (BuildContext context) {
                              return Container(
                                width: MediaQuery.of(context).size.width,
                                margin: EdgeInsets.symmetric(horizontal: 5.0),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                ),
                                child: Image.asset('$i'),
                              );
                            },
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Divider(
              thickness: 2,
              color: Colors.grey[200],
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: storesRef.snapshots(),
                builder: (context,snapshot){
                  if(snapshot.hasData)
                  {
                    final List<StoreCard> docs = tempSearchStore.map(
                            (doc)=>
                            StoreCard(
                                store:Store(
                                    name: doc['name'],
                                    distance:  _calcDistance(doc['location']),
                                    description: doc['description']??"" ,
                                    contact: doc['phno'],
                                    id:doc['id'],
                                    sellerId: doc['sellerId'],
                                    location: doc['location']
                                )
                            )
                    ).toList();
                    // docs.removeWhere((doc)=>doc.store.distance>2099.0);
                    docs.sort((a,b)=>a.store.distance.compareTo(b.store.distance));

                    return ListView(children: docs,physics: BouncingScrollPhysics(),);
                  }
                  else return Center(child: CupertinoActivityIndicator());


                },),
            )
          ],
        ),

      ),
    ): Center(
      child: CircularProgressIndicator()
    );
  }
}


/*
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:maps/diners/search.dart';

void main() => runApp(new StoresPage());

class StoresPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var queryResultSet = [];
  var tempSearchStore = [];

  initiateSearch(value) {
    if (value.length == 0) {
      setState(() {
        queryResultSet = [];
        tempSearchStore = [];
      });
    }

    var capitalizedValue =
        value.substring(0, 1).toUpperCase() + value.substring(1);

    if (queryResultSet.length == 0 && value.length == 1) {
      SearchService().searchByName(value).then((QuerySnapshot docs) {
        for (int i = 0; i < docs.documents.length; ++i) {
          queryResultSet.add(docs.documents[i].data);
           setState(() {
                tempSearchStore.add(queryResultSet[i]);
 });
        }
      });
    } else {
      tempSearchStore = [];
       queryResultSet.forEach((element) {
        if (element['name'].toLowerCase().contains(value.toLowerCase()) ==  true) {
            if (element['name'].toLowerCase().indexOf(value.toLowerCase()) ==0) {
              setState(() {
                tempSearchStore.add(element);
              });
            }
          }

      });
    }
    if (tempSearchStore.length == 0 && value.length > 1) {
      setState(() {});
    }

  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: Text('Firestore search'),
        ),
        body: ListView(children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextField(
              onChanged: (val) {
                initiateSearch(val);
              },
              decoration: InputDecoration(
                  prefixIcon: IconButton(
                    color: Colors.black,
                    icon: Icon(Icons.arrow_back),
                    iconSize: 20.0,
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  contentPadding: EdgeInsets.only(left: 25.0),
                  hintText: 'Search by name',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4.0))),
            ),
          ),
          SizedBox(height: 10.0),
          GridView.count(
              padding: EdgeInsets.only(left: 10.0, right: 10.0),
              crossAxisCount: 2,
              crossAxisSpacing: 4.0,
              mainAxisSpacing: 4.0,
              primary: false,
              shrinkWrap: true,
              children: tempSearchStore.map((element) {
                return buildResultCard(element);
              }).toList())
        ]));
  }
}

Widget buildResultCard(data) {
  return Card(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
    elevation: 2.0,
    child: Container(
      child: Center(
        child: Text(data['name'],
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.black,
          fontSize: 20.0,
        ),
        )
      )
    )
  );
}*/