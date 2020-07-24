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
              photo TEXT,
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

  Future<List<SAPFA>> getSAPFA() async {
    //returns the barcodes as a list (array)

    final db = await init();
    final maps = await db
        .query("sapfa"); //query all the rows in a table as an array of maps

    return List.generate(maps.length, (i) {
      //create a list of memos
      return SAPFA(
          barcodeId: maps[i]['barcodeid'],
          coCode: maps[i]['cocode'],
          mainCode: maps[i]['maincode'],
          subCode: maps[i]['subcode'],
          desc: maps[i]['desc'],
          loc: maps[i]['loc'],
          qty: maps[i]['qty'],
          scanqty: maps[i]['scanqty']);
    });
  }

  Future<List<SAPFA>> getList() async {
    final db = await init();
    final maps = await db.rawQuery(
        'select sapfa.barcodeid,sapfa.cocode,sapfa.maincode,sapfa.subcode,sapfa.desc,sapfa.loc,sapfa.photo,sapfa.qty, count(scanfa.seq) as scanqty, max(createdat) as createdat from sapfa left join scanfa using(barcodeid) group by sapfa.barcodeid,sapfa.cocode,sapfa.maincode,sapfa.subcode,sapfa.desc,sapfa.loc, sapfa.qty');

    return List.generate(maps.length, (i) {
      //create a list of memos
      return SAPFA(
          barcodeId: maps[i]['barcodeid'],
          coCode: maps[i]['cocode'],
          mainCode: maps[i]['maincode'],
          subCode: maps[i]['subcode'],
          desc: maps[i]['desc'],
          loc: maps[i]['loc'],
          photo: maps[i]['photo'],
          qty: maps[i]['qty'],
          scanqty: maps[i]['scanqty'],
          createdAt: maps[i]['createdat']);
    });
  }

  Future<List<SCANFA>> getItems(String id, int qty) async {
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

  Future<int> updatePhoto(String id, String photo) async {
    //returns number of items deleted
    final db = await init();

    Map<String, dynamic> row = {
      "photo": photo,
    };

    // do the update and get the number of affected rows
    int updateCount = await db.update("sapfa", row,
        where: "barcodeid = ?",
        whereArgs: [id]); // use whereArgs to avoid SQL injection);

    print(id);
    return updateCount;
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
