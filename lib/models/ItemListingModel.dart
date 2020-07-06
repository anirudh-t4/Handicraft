class ItemListingModel {
  final double itemPrice;
  final String itemName;

  ItemListingModel(
   this.itemPrice,
   this.itemName,
    
  );

  factory ItemListingModel.fromJson(dynamic json){
  return ItemListingModel(
    
    json['price'] +0.0,
    json['itemName'],
    
  );
}
}
