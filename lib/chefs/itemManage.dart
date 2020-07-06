import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cottage_app/models/itemListingModel.dart';
import 'itemcategory.dart';
import 'package:cottage_app/services/chefsDetailProvider.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:provider/provider.dart';

class ItemManagePage extends StatefulWidget {
  // ItemManagePage(});

  @override
  _ItemManagePageState createState() => _ItemManagePageState();
}

class _ItemManagePageState extends State<ItemManagePage> {
  //create var for availablevegetables
  Stream<QuerySnapshot> availableItemsStream;

  List<ItemListingModel> availableItems = new List();
  String storeId;
  @override
  void initState() {
    super.initState();
    this.storeId =
        Provider.of<SellerDetailsProvider>(context, listen: false).store.id;
    this.availableItemsStream =
        Provider.of<SellerDetailsProvider>(context, listen: false)
            .availableItemStream;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(
     // backgroundColour :
      title : Text("Set Your Menu Card",
    style: TextStyle(
      fontFamily: "Lobster"
    ),
    
    ),
    
    centerTitle: true,
     backgroundColor: Colors.red[600],),
    body :
     CustomScrollView(
      physics: BouncingScrollPhysics(),
      slivers: <Widget>[
        CategoryComponent(
          categoryID: 1,
          categoryName: 'Breakfast',
        ),
        CategoryComponent(
          categoryID: 2,
          categoryName: 'Brunch',
        ),
        CategoryComponent(
          categoryID: 3,
          categoryName: 'Lunch',
        ),
        CategoryComponent(
          categoryID: 4,
          categoryName: 'Dinner',
        ),
      ],
     ) );
  }
}