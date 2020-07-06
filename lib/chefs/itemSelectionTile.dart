import 'package:cottage_app/models/itemListingModel.dart';
import 'package:cottage_app/services/chefsDetailProvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
class ItemCatalogSelectionTile extends StatefulWidget {

  final String itemName;
  final bool isAdded;
  final double price;
  final int categoryId;
   ItemCatalogSelectionTile({
    Key key,
    this.itemName='Enter a dish',
    // @required this.refresh,
    this.isAdded=false,
    this.price=0.0,
    this.categoryId=1,
  }) : super(key: key);

  @override
  _ItemCatalogSelectionTileState createState() => _ItemCatalogSelectionTileState();
}

class _ItemCatalogSelectionTileState extends State<ItemCatalogSelectionTile> with AutomaticKeepAliveClientMixin{
  TextEditingController _priceController = TextEditingController();
  TextEditingController _nameController = TextEditingController();
  bool isAdded;
  double price;
  String itemnName;
  String storeId;
  String collectionName;
  @override
  void initState() { 
    super.initState();
    this.isAdded = widget.isAdded;
    this.price = widget.price;
    this.itemnName =widget.itemName;
     this.storeId =
        Provider.of<SellerDetailsProvider>(context, listen: false).store.id;
setState(() {
this.collectionName=Provider.of<SellerDetailsProvider>(context,listen: false).getCollectionNameFromCategory(category: widget.categoryId);});
  }


 

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar : AppBar(title : Text("Add Dishes to your Menu",),
      centerTitle: true,backgroundColor: Colors.red[800],
      ),
      floatingActionButton: FloatingActionButton(
        child:  Icon( Icons.add),
        onPressed:(){ showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return Padding(
            padding: const EdgeInsets.all(20),
            child: AlertDialog(

              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
              title: Text('Enter your delicious dish here of '),
              content: ListView(children: <Widget>[
                 TextField(

                controller: _nameController,
                decoration: InputDecoration(hintText: "Enter dish name"),
                 ),
                TextField(
                keyboardType: TextInputType.numberWithOptions(decimal: true,signed: false),
                controller: _priceController,
                decoration: InputDecoration(hintText: "\u20B9 10.00"),
              ),]),
              actions: <Widget>[
                new FlatButton(
                  child: new Text('Cancel'),
                  onPressed: () {

                    Navigator.of(context).pop();
                  },
                ),
                new FlatButton(
                  child: new Text('Add Item to Store',style: TextStyle(color: Colors.green),),
                  onPressed: () {
                    double price = _priceController.text==""?0.0 : double.parse(_priceController.text);
                    String itemName = _nameController.text == null?"Enter a dish":_nameController.text;
                    Provider.of<SellerDetailsProvider>(context,listen: false).addToAvailableItems(itemListingModel:  ItemListingModel(price, itemName),category: widget.categoryId);
                    setState(() {
                      this.isAdded=true;
                      this.itemnName = itemName;
                    this.price =price;
                    });
                    Navigator.of(context).pop();
                  },
                )
              ],
            ),
          );
        });}),
    body :   StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance.collection('stores').document(this.storeId).collection('${collectionName}').snapshots(),
        builder: (context, snapshot) {
          return ListView.builder(
            itemCount: snapshot.data.documents.length,
            itemBuilder: (context,index){
              DocumentSnapshot documentSnapshot = snapshot.data.documents[index];
             return
             Dismissible(
               onDismissed: (direction){
 Provider.of<SellerDetailsProvider>(context,listen: false).removeAvailableItem(itemListingModel:  ItemListingModel(documentSnapshot['price'], documentSnapshot['itemName']),category: widget.categoryId);
        setState(() {
          this.isAdded=false;
          this.price =0.0;
          this.itemnName ='Enter a Dish';
        });
               },
               key: Key(documentSnapshot.data['itemName']),
               child: 
              Card(
                elevation :4.0,
                margin : EdgeInsets.all(8),
                shape: RoundedRectangleBorder(
                  borderRadius : BorderRadius.circular(8)
                ),
   child:
              
     ListTile(
      title:
      Text(documentSnapshot['itemName']),
      subtitle :Text('\u20B9 ${documentSnapshot['price']}'),
     
     
      trailing: IconButton(icon: Icon(Icons.delete),onPressed: (){
       
       Provider.of<SellerDetailsProvider>(context,listen: false).removeAvailableItem(itemListingModel:  ItemListingModel(documentSnapshot['price'], documentSnapshot['itemName']),category: widget.categoryId);
        setState(() {
          this.isAdded=false;
          this.price =0.0;
          this.itemnName ='Enter a Dish';
        });
      },),
    )
    

    ));});
        }));
  }
  @override
 
  bool get wantKeepAlive => true;
}
