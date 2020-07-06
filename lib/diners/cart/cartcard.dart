import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CartCard extends  StatelessWidget{
  DocumentSnapshot cartDetails;

  CartCard({this.cartDetails});

  @override
  Widget build(BuildContext context) {
    List<Widget > items = new List();

    return Expanded(
      child :Padding(
      padding: const EdgeInsets.all(6.0),
      child: Card(
        elevation: 2,
        child: ListTile(
          title: Text(this.cartDetails['storeName'],
          style: TextStyle(
            fontWeight : FontWeight.bold
          ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: this.cartDetails['items'].map<Widget>((item){
                return //Text(item['itemName']+" - ₹"+ item["itemPrice"].toString()+' x'+item['quantity'].toString());
             Padding(
        padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Color(0xFFD3D3D3), width: 1.0),
                borderRadius: BorderRadius.circular(10.0),
              ),
              width: 45.0,
              height: 73.0,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 10.0,
                ),
                child: Column(
                  children: <Widget>[
                    InkWell(
                        onTap: () {},
                        child: Icon(Icons.keyboard_arrow_up,
                            color: Color(0xFFD3D3D3))),
                    Text(
                      item['quantity'].toString(),
                      style: TextStyle(fontSize: 18.0, color: Colors.grey),
                    ),
                    InkWell(
                        onTap: () {},
                        child: Icon(Icons.keyboard_arrow_down,
                            color: Color(0xFFD3D3D3))),
                  ],
                ),
              ),
            ),
            SizedBox(
              width: 20.0,
            ),
            Container(
              height: 50.0,
              width: 50.0,
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage("assets/foodie.jpg"),
                      fit: BoxFit.cover),
                  borderRadius: BorderRadius.circular(35.0),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black,
                        blurRadius: 5.0,
                        offset: Offset(0.0, 2.0))
                  ]),
            ),
            SizedBox(
              width: 20.0,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  
                  item['itemName'],
                  style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 5.0),
                Text(
                  "\u20B9"+ item["itemPrice"].toString(),
                  style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.orangeAccent,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 5.0),
                
              ],
            ),
            Spacer(),
            GestureDetector(
              onTap: () {
                
              },
              child: Icon(
                Icons.cancel,
                color: Colors.grey,
              ),
            ),
          ],
        ),
              );
            }).toList() ),
        ),
      ),
    ));
  }
}