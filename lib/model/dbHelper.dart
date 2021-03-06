import 'package:sapfascanner/model/apimodel.dart';
import 'package:sqflite/sqflite.dart'; //sqflite package
import 'package:path_provider/path_provider.dart'; //path_provider package
import 'package:path/path.dart'; //used to join paths
import 'model.dart'; //import model class
import 'dart:io';
import 'dart:async';

class DBHelper {
  DBHelper() {
    init();
  }

  Future<Database> init() async {
    Directory directory =
        await getApplicationDocumentsDirectory(); //returns a directory which stores permanent files
    final path = join(directory.path, "sapfa.db"); //create path to database

    return await openDatabase(
        //open the database or create a database if there isn't any
        path,
        version: 1,
        onCreate: _onCreate,
        onConfigure: _onConfigure);
  }

  _onConfigure(Database db) async {
    // Add support for cascade delete
    await db.execute("PRAGMA foreign_keys = ON");
  }

  _onCreate(Database db, int version) async {
    await db.execute("""
              CREATE TABLE sapfa(
              barcodeid TEXT NOT NULL PRIMARY KEY,
              cocode TEXT,         
              maincode TEXT,
              subcode TEXT,              
              desc TEXT,
              loc TEXT,
              acqdate TEXT,
              photo BOOLEAN,
              info BOOLEAN,              
              qty INTEGER                      
              )""");
    await db.execute("""
              CREATE TABLE scanfa(
              barcodeid TEXT NOT NULL,                    
              seq TEXT,
              createdat INTEGER NULL DEFAULT (cast(strftime('%s','now') as int)),
               FOREIGN KEY (barcodeid) REFERENCES sapfa (barcodeid) 
                  ON DELETE CASCADE ON UPDATE NO ACTION           
              )""");
    await db.execute("CREATE UNIQUE INDEX scanfa_idx ON scanfa(barcodeid,seq)");
  }

  Future<int> addSAPFA(SAPFA item) async {
    //returns number of items inserted as an integer
    final db = await init(); //open database
    return db.insert(
      "sapfa", item.toMap(), //toMap() function from MemoModel
      conflictAlgorithm:
          ConflictAlgorithm.ignore, //ignores conflicts due to duplicate entries
    );
  }

  Future<int> addScanFA(SCANFA item) async {
    //returns number of items inserted as an integer
    final db = await init(); //open database
    return db.insert(
      "scanfa", item.toMap(), //toMap() function from MemoModel
      conflictAlgorithm:
          ConflictAlgorithm.ignore, //ignores conflicts due to duplicate entries
    );
  }

  Future<SAPFA> getSAPFA(String id) async {
    //returns the barcodes as a list (array)

    final db = await init();
    final res = await db.query("sapfa",
        where: "barcodeid = ?",
        whereArgs: [id]); //query all the rows in a table as an array of maps

    return res.isNotEmpty ? SAPFA.fromMap(res.first) : null;
  }

  Future<List<SAPFA>> getList() async {
    final db = await init();
    final maps = await db.rawQuery(
        'select sapfa.barcodeid,sapfa.cocode,sapfa.maincode,sapfa.subcode,sapfa.desc,sapfa.loc,sapfa.photo,sapfa.info,sapfa.qty, count(scanfa.seq) as scanqty, max(createdat) as createdat from sapfa left join scanfa using(barcodeid) group by sapfa.barcodeid,sapfa.cocode,sapfa.maincode,sapfa.subcode,sapfa.desc,sapfa.loc, sapfa.qty');

    return List.generate(maps.length, (i) {
      //create a list of memos
      return SAPFA(
          barcodeId: maps[i]['barcodeid'],
          coCode: maps[i]['cocode'],
          mainCode: maps[i]['maincode'],
          subCode: maps[i]['subcode'],
          desc: maps[i]['desc'],
          loc: maps[i]['loc'],
          photo: (maps[i]['photo'] == 1) ? true : false,
          info: (maps[i]['info'] == 1) ? true : false,
          qty: maps[i]['qty'],
          scanqty: maps[i]['scanqty'],
          createdAt: maps[i]['createdat']);
    });
  }

  Future<List<SAPFA>> getInvalidList() async {
    final db = await init();

    String sql =
        'select sapfa.barcodeid,sapfa.cocode,sapfa.maincode,sapfa.subcode,sapfa.desc,sapfa.loc,sapfa.photo,sapfa.info,sapfa.qty, count(scanfa.seq) as scanqty, max(createdat) as createdat from sapfa left join scanfa using(barcodeid) ';
    sql = sql + 'where (sapfa.qty > 0) ';
    sql = sql +
        'group by sapfa.barcodeid,sapfa.cocode,sapfa.maincode,sapfa.subcode,sapfa.desc,sapfa.loc, sapfa.qty ';
    sql = sql + 'having qty < scanqty';
    final maps = await db.rawQuery(sql);

    return List.generate(maps.length, (i) {
      //create a list of memos
      return SAPFA(
          barcodeId: maps[i]['barcodeid'],
          coCode: maps[i]['cocode'],
          mainCode: maps[i]['maincode'],
          subCode: maps[i]['subcode'],
          desc: maps[i]['desc'],
          loc: maps[i]['loc'],
          photo: (maps[i]['photo'] == 1) ? true : false,
          info: (maps[i]['info'] == 1) ? true : false,
          qty: maps[i]['qty'],
          scanqty: maps[i]['scanqty'],
          createdAt: maps[i]['createdat']);
    });
  }

  Future<bool> delInvalidData() async {
    final db = await init();

    String sql =
        'select sapfa.barcodeid,scanfa.seq, sapfa.qty, cast(scanfa.seq as INTEGER) as scanqty from sapfa left join scanfa using(barcodeid) ';
    sql = sql + 'where (sapfa.qty > 0 and qty < scanqty) ';
    final res = await db.rawQuery(sql);

    for (final data in res) {
      int result = await db.delete('scanfa',
          where: 'barcodeid = ? and seq = ?',
          whereArgs: [data["barcodeid"], data["seq"]]);
    }
    return true;
  }

  Future<List<SAPFA>> getValidList() async {
    final db = await init();

    String sql =
        'select sapfa.barcodeid,sapfa.cocode,sapfa.maincode,sapfa.subcode,sapfa.desc,sapfa.loc,sapfa.photo,sapfa.info,sapfa.qty, count(scanfa.seq) as scanqty, max(createdat) as createdat from sapfa left join scanfa using(barcodeid) ';
    sql = sql + 'where (sapfa.qty > 0 and sapfa.info = 1)';
    sql = sql +
        'group by sapfa.barcodeid,sapfa.cocode,sapfa.maincode,sapfa.subcode,sapfa.desc,sapfa.loc, sapfa.qty ';
    sql = sql + 'having qty >= scanqty';
    final maps = await db.rawQuery(sql);

    return List.generate(maps.length, (i) {
      //create a list of memos
      return SAPFA(
          barcodeId: maps[i]['barcodeid'],
          coCode: maps[i]['cocode'],
          mainCode: maps[i]['maincode'],
          subCode: maps[i]['subcode'],
          desc: maps[i]['desc'],
          loc: maps[i]['loc'],
          photo: (maps[i]['photo'] == 1) ? true : false,
          info: (maps[i]['info'] == 1) ? true : false,
          qty: maps[i]['qty'],
          scanqty: maps[i]['scanqty'],
          createdAt: maps[i]['createdat']);
    });
  }

  Future<List<SCANFA>> allScannedFA() async {
    final db = await init();
    final maps = await db.rawQuery('select * from scanfa order by barcodeid');

    List<SCANFA> res = new List();
    maps.forEach((row) => {
          res.add(SCANFA(
              barcodeId: row['barcodeid'],
              seq: row['seq'],
              createdAt: row['createdat']))
        });
    return res;
  }

  Future<List<SCANFA>> getScannedFA(String id, int qty) async {
    final db = await init();
    final maps = await db
        .rawQuery('select * from scanfa where barcodeid = $id order by seq');

    List<SCANFA> lst = [];
    if (maps.length > 0 && qty > 0) {
      var j = 0;

      for (var i = 1; i <= qty; i++) {
        if (j < maps.length && int.parse(maps[j]['seq']) == i) {
          lst.add(SCANFA(
              barcodeId: maps[j]['barcodeid'],
              seq: maps[j]['seq'],
              createdAt: maps[j]['createdat']));
          j++;
        } else {
          lst.add(SCANFA(
              barcodeId: maps[0]['barcodeid'],
              seq: i.toString().padLeft(4, '0'),
              createdAt: 0));
        }
      }
    }

    // var lst = List.generate(maps.length, (i) {
    //   //create a list of memos
    //   return SCANFA(
    //       barcodeId: maps[i]['barcodeid'],
    //       seq: maps[i]['seq'],
    //       createdAt: maps[i]['createdat']);
    // });

    return lst;
  }

  // Future<List<SAPFA>> getItems(String id) async {
  //   final db = await init();
  //   final maps = await db.rawQuery(
  //       'select sapfa.barcodeid,sapfa.cocode,sapfa.maincode,sapfa.subcode,sapfa.desc,sapfa.loc, sapfa.qty, scanfa.seq, createdat from sapfa left join scanfa using(barcodeid) where sapfa.barcodeid = $id order by scanfa.seq');

  //   return List.generate(maps.length, (i) {
  //     //create a list of memos
  //     return SAPFA(
  //         barcodeId: maps[i]['barcodeid'],
  //         coCode: maps[i]['cocode'],
  //         mainCode: maps[i]['maincode'],
  //         subCode: maps[i]['subcode'],
  //         seq: maps[i]['seq'],
  //         desc: maps[i]['desc'],
  //         loc: maps[i]['loc'],
  //         qty: maps[i]['qty'],
  //         scanqty: maps[i]['scanqty'],
  //         createdAt: maps[i]['createdat']);
  //   });
  // }

  Future<int> updatePhoto(String id, int photo) async {
    //returns number of items deleted
    final db = await init();

    Map<String, dynamic> row = {
      "photo": photo,
    };

    // do the update and get the number of affected rows
    int noofrec = await db.update("sapfa", row,
        where: "barcodeid = ?",
        whereArgs: [id]); // use whereArgs to avoid SQL injection);

    return noofrec;
  }

  Future<int> updateInfo(String id, FAInfo infoData) async {
    //returns number of items deleted
    final db = await init();

    // do the update and get the number of affected rows
    int noofrec = await db.update("sapfa", infoData.toMap(),
        where: "barcodeid = ?",
        whereArgs: [id]); // use whereArgs to avoid SQL injection);

    return noofrec;
  }

  Future<int> noOfRecord() async {
    final db = await init();

    final res = await db.rawQuery('select COUNT(*) from scanfa');
    return Sqflite.firstIntValue(res);
  }

  Future<int> delSAPFA(String id) async {
    //returns number of items deleted
    final db = await init();

    int result = await db.delete("sapfa", //table name
        where: "barcodeid = ?",
        whereArgs: [id] // use whereArgs to avoid SQL injection
        );

    return result;
  }

  Future<bool> reset() async {
    //returns number of items deleted
    final db = await init();

    await db.execute('DELETE FROM sapfa');
    await db.execute('DELETE FROM scanfa');

    return true;
  }

  Future<int> updateSAPFA(int id, SAPFA item) async {
    // returns the number of rows updated

    final db = await init();

    int result = await db
        .update("sapfa", item.toMap(), where: "barcodeid = ?", whereArgs: [id]);
    return result;
  }

  Future close() async {
    final db = await init();
    db.close();
  }
}
