import 'package:flutter/material.dart';
import 'package:sapfascanner/model/dbHelper.dart';
import 'package:sapfascanner/model/model.dart';
import 'package:intl/intl.dart';
import 'package:sapfascanner/camera/camera.dart';
import 'package:sapfascanner/screens/previewDetail/previewDetail.dart';

import '../displayPhoto/displayPhoto.dart';

class CustomListItem extends StatelessWidget {
  CustomListItem({
    this.thumbnail,
    this.barcode,
    this.callback,
  });

  final Widget thumbnail;
  final SAPFA barcode;
  final Function callback;
  final DBHelper _dbHelper = DBHelper();
  final f = new DateFormat('yyyy-MM-dd hh:mm a');

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 1.0),
        child: SizedBox(
          height: 90,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: FractionalOffset.bottomRight,
                colors: [Colors.grey[300], Colors.white70],
                stops: [0, 1],
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                GestureDetector(
                    child: SizedBox(
                        width: 90,
                        height: 90,
                        child: FittedBox(
                          fit: BoxFit.fill,
                          child: thumbnail,
                        )),
                    onTap: () => _onPhotoTap(context, barcode)),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(10.0, 5.0, 0.0, 0.0),
                    child: GestureDetector(
                        child: _BarcodeInfo(
                            barcodeid: barcode.barcodeId,
                            desc: barcode.desc,
                            loc: barcode.loc,
                            tqty: barcode.qty,
                            scanqty: barcode.scanqty,
                            latestdate: f.format(
                                DateTime.fromMillisecondsSinceEpoch(
                                    barcode.createdAt * 1000))),
                        onTap: () => _onItemTap(context, barcode)),
                  ),
                ),
                Container(
                    width: 50.0,
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          IconButton(
                              icon: Icon(Icons.delete, size: 25.0),
                              tooltip: 'Delete This Item',
                              onPressed: () {
                                _confirmDel1Dialog(context);
                              })
                        ]))
              ],
            ),
          ),
        ));
  }

  _confirmDel1Dialog(BuildContext context) {
    // set up the buttons
    Widget cancelButton = FlatButton(
      child: Text("Cancel"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
    Widget deleteButton = FlatButton(
      child: Text("Delete"),
      onPressed: () {
        _dbHelper.delSAPFA(barcode.barcodeId);
        callback();
        Navigator.of(context).pop();
      },
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Delete Confirmation"),
      content: Text("Are you sure to delete this item?"),
      actions: [
        cancelButton,
        deleteButton,
      ],
    );
    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  _onItemTap(BuildContext context, SAPFA barcode) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => PreviewDetail(barcode: barcode)));
  }

  _onPhotoTap(BuildContext context, SAPFA barcode) {
    if (!barcode.photo) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => Camera(
                    barcode: barcode,
                  )));
    } else {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => DisplayPhoto(
                    barcode: barcode,
                    imagePath: null,
                  )));
    }
  }
}

class _BarcodeInfo extends StatelessWidget {
  const _BarcodeInfo(
      {Key key,
      this.barcodeid,
      this.desc,
      this.loc,
      this.tqty,
      this.scanqty,
      this.latestdate})
      : super(key: key);

  final String barcodeid;
  final String desc;
  final String loc;
  final int tqty;
  final int scanqty;
  final String latestdate;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            flex: 0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  '$barcodeid',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Padding(padding: EdgeInsets.only(bottom: 2.0)),
                Text(
                  '$desc',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12.0,
                    color: Colors.black,
                  ),
                ),
                const Padding(padding: EdgeInsets.only(bottom: 2.0)),
                Text(
                  'Loc: $loc',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12.0,
                    color: Colors.black,
                  ),
                ),
                const Padding(padding: EdgeInsets.only(bottom: 2.0)),
                Row(
                  children: [
                    Text(
                      tqty == null ? 'Qty: 0' : 'Qty: $tqty / ',
                      style: const TextStyle(
                        fontSize: 12.0,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      scanqty == null ? 'Scanned: 0' : 'Scanned: $scanqty',
                      style: (scanqty > tqty)
                          ? TextStyle(
                              fontSize: 12.0,
                              color: Colors.red,
                            )
                          : TextStyle(
                              fontSize: 12.0,
                              color: Colors.black,
                            ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Text(
                  'Last scan: $latestdate',
                  style: const TextStyle(
                    fontSize: 12.0,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
