
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cottage_app/diners/about.dart';
import 'dart:io';
import 'package:cottage_app/screens/HomeScreen.dart';
import 'package:cottage_app/services/authservice.dart';
import 'package:wiredash/wiredash.dart';
import 'package:cottage_app/models/about.dart';
import 'package:cottage_app/models/feedback.dart';
import 'package:cottage_app/models/notification.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'chefinfo.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:cottage_app/chefs/account.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:async';
import 'package:cottage_app/services/chefsDetailProvider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:flutter/services.dart';
import 'package:multi_media_picker/multi_media_picker.dart';
import 'dart:io';

import 'chefaccount.dart';
class ManageStore extends StatefulWidget {
  @override
  _ManageStoreState createState() => _ManageStoreState();
}

class _ManageStoreState extends State<ManageStore> {
   FirebaseUser user;
  TabController _tabController;
  String storeName = " ";
  String phoneNo = " ";
  List<String> cuisineslist =  List<String>();
  List imgurls =  List();
  String sellerName = " ";
  String storeId;
  bool isDataLoaded;
     var sellerDetails;
      String storeid ;
      var storeDetails ;
       var scaffoldKey = GlobalKey<ScaffoldState>();
    List<bool> choicesChipcuisine = [
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
  ];
  static const cuisine = ['American',
    'Belizean ',
     'Chinese',
     'Canadian',
     'Japaneese',
    'Indian',
    'Italian',
    'Mexican',
    'Texan',];
    List<File> _imgs;
    List<String> imgUrls = List ();
    Future<void> resetUserType() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('User Type', 'None');
  }
  _onImageButtonPressed(ImageSource source, {bool singleImage = false}) async {
    var imgs;
    imgs = await MultiMediaPicker.pickImages(source: source, singleImage: singleImage);
    setState(() {
       _imgs = imgs;
    });
  }
   @override
  void initState() {
    init();
    super.initState();}
     init() async {
    user = await getUser();
    isDataLoaded =
        Provider.of<SellerDetailsProvider>(context, listen: false).isDataLoaded;
    await _loadStoreDetails();
    await choice();

  }
  choice() async {
for(int i =0 ; i< cuisineslist.length ; i++)
{
  for(int j = 0; j< cuisine.length ; j++)
  {
    if(cuisineslist[i].compareTo(cuisine[j])==0)
    {
      choicesChipcuisine[j] = true;
      print(choicesChipcuisine[j]);
    }
  }
}
  }
_loadStoreDetails() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String storename = await pref.get("storename");
    if (storename == null) {
       sellerDetails = await Firestore.instance
          .collection('chefs')
          .document(user.uid)
          .get();
       storeid = sellerDetails.data['storeId'];
      this.storeId = storeid;
       storeDetails =
          await Firestore.instance.collection('stores').document(storeid).get();
      setState(() {
        this.storeName = storeDetails.data['name'];
        this.phoneNo = storeDetails.data['phno'];
        this.imgurls = storeDetails['urls'];
       // this.cuisineslist = storeDetails['cuisines'];
        this.sellerName = sellerDetails.data['name'];
      });
      pref.setString("storename", storename);
    } else {
      setState(() {
        this.storeName = storename;
        print(storeName);
      });
    }
  }

     uploadToFirebase() {
   
      _imgs.forEach((image) => {uploadImage(image)});

    } 
   Future  uploadImage (image) async{
     
   
final StorageReference postImgref = FirebaseStorage.instance.ref().child('Post Images');
var timeKey = new DateTime.now();
final StorageUploadTask uploadTask = postImgref.child(timeKey.toString()+'.jpg').putFile(image);
var imgurl = await(await uploadTask.onComplete).ref.getDownloadURL();
 String url = imgurl.toString();
print(url);
 setState(() {
      imgUrls.add(url);
    });
   await Firestore.instance.collection('stores').document(storeid).updateData({
        "urls": FieldValue.arrayUnion([url]),
   });
    print(imgUrls);
  }
 
  @override
    var images = ['assets/chefs.jpg','assets/foodie..jpg'];
  Widget build(BuildContext context) {
     final drawerHeader = UserAccountsDrawerHeader(
      accountName: Text(sellerName),
      accountEmail: Text(phoneNo),
      decoration: BoxDecoration(
        color: Colors.redAccent[700],
      ),
      currentAccountPicture: CircleAvatar(
        backgroundColor: Colors.white,
        backgroundImage: AssetImage("assets/chefs.jpg"),
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
                MaterialPageRoute(builder: (context) => Chefaccount(),
              ));
            }),
        Divider(
          thickness: 1,
          color: Colors.grey,
        ),
        ListTile(
            title: Text('Switch to buyer mode'),
            onTap: () async{
              await resetUserType();
                          Navigator.pushReplacement(context, new MaterialPageRoute(builder: (context)=>HomeScreen()));

            } //=> Navigator.of(context).push(_NewPage(2)),
            ),
        Divider(
          thickness: 1,
          color: Colors.grey,
        ),
         ListTile(
          title: Text('Payment'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Feedbacks()),
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

          },
        ),
      ],
    );
    return  SafeArea(
      child: Scaffold(
        key: scaffoldKey,
        endDrawer: Drawer(
          child: drawerItems,
        ),
        body: SingleChildScrollView(
            child: Container(
          color: Colors.white,
          child: Center(
            child: Column(
              children: [
                ClipPath(
                  clipper: MyClip(),
                  child: Container(
                    height: 200.0,
                    color: Colors.redAccent[700],
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 30),
                        child: Column(
                         
                         
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 30),
                                  child: Text(
                                    "My Kitchen",
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
                            SizedBox(height: 10.0),
                            Text(
                              storeName,
                              style: TextStyle(
                                  fontSize: 22.0,
                                  color: Colors.white,
                                  ),
                            ),
                            
                            SizedBox(height: 10.0)
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20.0),
               Padding(
                 padding: const EdgeInsets.all(10.0),
                 child: Container(
              height: 200,
              child:
                   imgurls.length == 0 ? Text('Upload Images of your Kitchen / Work Area to ensure Safety measures'): ListView(scrollDirection: Axis.horizontal, children:  List<Widget>.generate(imgurls.length, (index) {
                        return 
                  Card(
                   
                   
                    child: Container(
                        width: 200,
                        
                        child: InkWell(
                            onTap: () {
                              
                            },
                            child: Expanded(
                              child: Image(
                              image: NetworkImage(imgurls[index]),
                                
                              ),
                            ))),
                  );
                    }
                  
            ),
            ),
            ),
               ),
  SizedBox(height: 10.0),
  Padding(
    padding: const EdgeInsets.only(left: 30,right:30),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children:[
        IconButton(
                                    icon: Icon(Icons.photo_library),
                                    color: Colors.grey,
                                    iconSize: 30,
                                    onPressed: () {
                                      _onImageButtonPressed(ImageSource.gallery);
                                    }
                                       
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.photo_camera),
                                    color: Colors.grey,
                                    iconSize: 30,
                                    onPressed: () {
                                       _onImageButtonPressed(ImageSource.camera);
                                    }
                                        
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.file_upload),
                                    color: Colors.grey,
                                    iconSize: 30,
                                    onPressed: () {
                                      uploadToFirebase();
                                    }
                                        
                                  )
      ]
    ),
  ),
   SizedBox(height: 10.0),
    Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text("Cuisines",
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.black,
                  fontWeight: FontWeight.bold
                )),
          ),
          Wrap(
            children: List.generate(
              choicesChipcuisine.length,
              (i) => Padding(
                padding: const EdgeInsets.all(4.0),
                child: FilterChip(
                  selected:  choicesChipcuisine[i],
                  onSelected: (t) {
                    
                     //{}
                     {
                    setState(() {
                      //choicesChipcuisine[i] = !choicesChipcuisine[i];
                    // 
                       choicesChipcuisine[i] = !choicesChipcuisine[i];
                     
                  
                    });}
                 if(choicesChipcuisine[i])
                 {
                       Firestore.instance.collection('stores').document(storeid).updateData({
        "cuisines": FieldValue.arrayUnion([cuisine[i]]),
   });
                 }
                 else{
                   Firestore.instance.collection('stores').document(storeid).updateData({
        "cuisines": FieldValue.arrayRemove([cuisine[i]]),
   });
                 }
                  },
                  label: Text(cuisine[i]),
                ),
              ),
            ),
          ),

                          
                
              
              ],
            ),
          ),
        )),
      ),
    );
  }
}
class MyClip extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height - 50.0);
    path.quadraticBezierTo(
        size.width - 70.0, size.height, size.width / 2, size.height - 20);
    path.quadraticBezierTo(size.width / 3.0, size.height - 32, 0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true;
  }
}
    


     