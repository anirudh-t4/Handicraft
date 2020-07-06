import 'package:cottage_app/diners/dinerinfo.dart';
import 'package:cottage_app/models/itemListingModel.dart';
import 'package:flutter/material.dart';
import 'package:cottage_app/diners/storeDetailsbloc.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ItemBuyTable extends StatefulWidget {
  List<ItemListingModel> itemListings;
    GlobalKey<ScaffoldState> scaffoldKey;

  ItemBuyTable({Key key, this.itemListings,this.scaffoldKey}) : super(key: key);
  @override
  _ItemBuyTableState createState() =>
      _ItemBuyTableState(itemListings: itemListings);
}

class _ItemBuyTableState extends State<ItemBuyTable> {
  List<ItemListingModel> itemListings;

  _ItemBuyTableState({this.itemListings});

  List<DataRow> itemsRows = new List();

  _add2cart(String itemName,double itemPrice){
    Provider.of<MyStorePageBLoc>(context,listen:false).add2cart(itemName,itemPrice).then(
      (added){
        if(added){
         Fluttertoast.showToast(
                msg: "$itemName added to cart",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                textColor: Colors.white,
                fontSize: 16.0);
        }
        else{
          Fluttertoast.showToast(
                msg: "Try again later",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                textColor: Colors.white,
                fontSize: 16.0);

        }
      }
    );
  }

  _buildRows() {
    for (var itemobj in itemListings) {
      itemsRows.add(DataRow(
        cells: [
          DataCell(Text(
            '${itemobj.itemName}',
            style: TextStyle(color: Colors.grey[700], fontSize: 15),
          )),
          DataCell(Text(
            '₹ ${itemobj.itemPrice}',
            style: TextStyle(color: Colors.grey[700], fontSize: 15),
          )),
          DataCell(
            IconButton(icon: Icon(Icons.add_shopping_cart),
            onPressed: ()=>_add2cart(itemobj.itemName,itemobj.itemPrice),)
            ),
        ],
      ));
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _buildRows();
  }

  @override
  Widget build(BuildContext context) {
    print(itemListings.length);
    return (itemListings == null)
        ? CircularProgressIndicator()
        : SingleChildScrollView(
            child: DataTable(
              columns: kTableColumns,

              rows: itemsRows,
              // rows: ItemTableDataSource(source: itemListings),
            ),
          );
  }
}

////// Columns in table.
const kTableColumns = <DataColumn>[
  DataColumn(
    label: const Text(
      'Item',
      style: TextStyle(fontSize: 16),
    ),
  ),
  DataColumn(
    label: const Text(
      'Price',
      style: TextStyle(fontSize: 16),
    ),
    tooltip: 'Price',
    numeric: true,
  ),
  DataColumn(
    label: const Text(
      'Buy?',
      style: TextStyle(fontSize: 16),
    ),
    tooltip: 'Price',
    numeric: true,
  ),
];

////// Data source class for obtaining row data for PaginatedDataTable.
class ItemTableDataSource extends DataTableSource {
  int _selectedCount = 0;

  ItemTableDataSource({
    this.source,
  });
  List<ItemListingModel> source;

  @override
  DataRow getRow(int index) {
    assert(index >= 0);
    if (index >= source.length) return null;
    final ItemListingModel itemElement = source[index];
    return DataRow.byIndex(index: index, cells: <DataCell>[
      DataCell(Text(
        '${itemElement.itemName}',
        style: TextStyle(color: Colors.grey[700], fontSize: 15),
      )),
      DataCell(Text(
        "\u20B9 ${itemElement.itemPrice}",
        style: TextStyle(color: Colors.grey[700], fontSize: 15),
      )),
    ]);
  }

  @override
  int get rowCount => source.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => _selectedCount;
}
