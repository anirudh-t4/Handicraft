import 'package:cottage_app/diners/storeComponents/store.dart';
import 'package:flutter/material.dart';

import 'package:cottage_app/diners/individualstore.dart';
class StoreCard extends StatelessWidget {
  final Store store;
  StoreCard({this.store});

  @override
  Widget build(BuildContext context) {
    return
   Hero(tag: '${store.id}',child: Padding(padding: EdgeInsets.symmetric(horizontal: 8,vertical: 2)
      ,child:
    Card(
      shape:RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0))
      ,
      child:
   Padding(
    padding: EdgeInsets.all(16.0),
    child: Card(
      child: Row(
        children: <Widget>[
          Container(
            child: InkWell(
              onTap: () {
                 Navigator.push(
            context,
            new MaterialPageRoute(
                builder: (context) => MyStorePage(
                      store: store,
                    )));
              },
            ),
            width: 70.0,
            height: 70.0,
            decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(
        store.picUrl ??
            "https://upload.wikimedia.org/wikipedia/commons/thumb/5/53/Store_Building_Flat_Icon_Vector.svg/768px-Store_Building_Flat_Icon_Vector.svg.png",
        
      ),
                  fit: BoxFit.cover,
                ),
                borderRadius: BorderRadius.circular(10.0)),
          ),
          SizedBox(width: 10.0),
          Expanded(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                store.name,
                style: TextStyle(
                    fontSize: 20.0,
                    color: Colors.blueGrey,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 5.0),
              Text(
                store.description,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14.0,
                ),
              ),
                SizedBox(height: 5.0),
              Text((this.store.distance>1000?'${this.store.distance/1000} Km':'${this.store.distance} meters')??'...',
              
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14.0,
                ),
              )

            ],
          )),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: <Widget>[
                Text(
                  "Open",
                  style: TextStyle(
                      fontSize: 14.0,
                      color: Colors.grey,
                      fontWeight: FontWeight.bold),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Ratings: 4",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15.0,
                        color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  ))));
    
  }
}
