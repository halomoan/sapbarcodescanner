import 'package:flutter/material.dart';

class CustomListItem extends StatelessWidget {
  const CustomListItem(
      {this.thumbnail,
      this.barcodeid,
      this.desc,
      this.tqty,
      this.scanqty,
      this.latestdate});

  final Widget thumbnail;
  final String barcodeid;
  final String desc;
  final int tqty;
  final int scanqty;
  final String latestdate;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: SizedBox(
        height: 100,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            AspectRatio(
              aspectRatio: 1.0,
              child: thumbnail,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10.0, 0.0, 2.0, 0.0),
                child: _BarcodeInfo(
                    barcodeid: barcodeid,
                    desc: desc,
                    tqty: tqty,
                    scanqty: scanqty,
                    latestdate: latestdate),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _BarcodeInfo extends StatelessWidget {
  const _BarcodeInfo(
      {Key key,
      this.barcodeid,
      this.desc,
      this.tqty,
      this.scanqty,
      this.latestdate})
      : super(key: key);

  final String barcodeid;
  final String desc;
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
            flex: 1,
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
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12.0,
                    color: Colors.black87,
                  ),
                ),
                const Padding(padding: EdgeInsets.only(bottom: 2.0)),
                Text(
                  tqty == null ? 'Qty: 0' : 'Qty: $tqty',
                  style: const TextStyle(
                    fontSize: 12.0,
                    color: Colors.black87,
                  ),
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
                  scanqty == null ? 'Scanned: 0' : 'Scanned: $scanqty',
                  style: const TextStyle(
                    fontSize: 12.0,
                    color: Colors.amber,
                  ),
                ),
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