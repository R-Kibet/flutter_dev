import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';
import 'package:trial/extensions/list/filter.dart';

import 'crud_exceptions.dart';

class NotesService {
  Database? _db;

  //Stream and Stream control
  List<DatabaseNotes> _notes = [];

  DatabaseUser? _user;

  ///Singleton -
  ///prevents creating many instance of one class causing app crush when reloading
  static final NotesService _shared = NotesService._sharedInstance();

  NotesService._sharedInstance() {
    _notesStreamController = StreamController<List<DatabaseNotes>>.broadcast(
      onListen: () {
        _notesStreamController.sink.add(_notes);
      },
    );
  }

  //make it public as it is private
  factory NotesService() => _shared;

  late final StreamController<List<DatabaseNotes>> _notesStreamController;

  Stream<List<DatabaseNotes>> get allNotes =>
      _notesStreamController.stream.filter((note) {
        final currentUser = _user;
        if (currentUser != null) {
          return note.userId == currentUser.id;
        }else {
          throw UserShouldBeSetBeforeReadingAllNotes();
        }
      });

  Future<DatabaseUser> getOrCreateUser({
    required String email,
    bool setAsCurrentUser = true,
  }) async {
    try {
      final user = await getUser(email: email);
      if (setAsCurrentUser) {
        _user = user;
      }
      return user;
    } on CouldNotFindUser {
      final createdUser = await createUser(email: email);
      if (setAsCurrentUser) {
        _user = createdUser;
      }
      return createdUser;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _cacheNotes() async {
    final allNotes = await getAllNotes();
    _notes = allNotes.toList();
    _notesStreamController.add(_notes);
  }

  Database _getDatabaseOrThrow() {
    final db = _db;
    if (db == null) {
      throw DatabaseNotOpen();
    } else {
      return db;
    }
  }

  Future<void> _ensureDbIsOpen() async {
    try {
      await open();
    } on DatabaseAlreadyOpennedException {}
  }

  //opening the db
  Future<void> open() async {
    if (_db != null) {
      throw DatabaseAlreadyOpennedException();
    }
    try {
      final docsPath = await getApplicationDocumentsDirectory();
      final dbPath = join(docsPath.path, dbName);
      final db = await openDatabase(dbPath);
      _db = db;

      // create user table
      await db.execute(createUserTable);

      // notes table
      await db.execute(createNotes);
      await _cacheNotes();
    } on MissingPlatformDirectoryException {
      throw UnableToGetDocumentsDirectory();
    }
  }

  //closing db
  Future<void> close() async {
    final db = _db;
    if (db == null) {
      throw DatabaseNotOpen();
    } else {
      await db.close();
      _db = null;
    }
  }

  //CRUD METHODS

  ///USER SECTION

  //create user
  Future<DatabaseUser> createUser({required String email}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final result = await db.query(
      userTable,
      limit: 1,
      where: "email = ?",
      whereArgs: [email.toLowerCase()],
    );
    if (result.isNotEmpty) {
      throw UserAlreadyExists();
    }

    final userId = await db.insert(userTable, {
      emailColumn: email.toLowerCase(),
    });

    return DatabaseUser(
      id: userId,
      email: email,
    );
  }

  //Fetch user
  Future<DatabaseUser> getUser({required String email}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    final result = await db.query(
      userTable,
      limit: 1,
      where: "email = ?",
      whereArgs: [email.toLowerCase()],
    );
    if (result.isEmpty) {
      throw CouldNotFindUser();
    } else {
      return DatabaseUser.fromRow(result.first);
    }
  }

  //deleteUser
  Future<void> deleteUser({required String email}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final deletedAcc = await db.delete(
      userTable,
      where: "email = ?",
      whereArgs: [email.toLowerCase()],
    );
    if (deletedAcc != 1) {
      throw CouldNotDeleteUser();
    }
  }

  //NOTES SECTION

  //Create Notes
  Future<DatabaseNotes> createNote({required DatabaseUser owner}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    // check if user is in the database
    final dbUser = await getUser(email: owner.email);
    if (dbUser != owner) {
      throw CouldNotFindUser();
    }

    // create the note
    const text = "";
    final noteid = await db.insert(notesTable,
        {userIdColumn: owner.id, textColumn: text, syncedColumn: 1});

    final note = DatabaseNotes(
      id: noteid,
      userId: owner.id,
      text: text,
      syncedWithCloud: true,
    );

    //stream contoller - reflect value of notesto the UI
    _notes.add(note);
    _notesStreamController.add(_notes);

    return note;
  }

  //Fetch a note
  Future<DatabaseNotes> getNote({required int id}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final notes = await db.query(
      notesTable,
      limit: 1,
      where: "id = ?",
      whereArgs: [id],
    );
    if (notes.isEmpty) {
      throw CouldNotFindNote();
    } else {
      final note = DatabaseNotes.fromRow(notes.first);
      _notes.retainWhere((note) => note.id == id);
      _notes.add(note);
      _notesStreamController.add(_notes);

      return note;
    }
  }

  //Get all notes
  Future<Iterable<DatabaseNotes>> getAllNotes() async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final notes = await db.query(notesTable);
    final result = notes.map((noteRow) => DatabaseNotes.fromRow(noteRow));

    return result;
  }

  //Update note
  Future<DatabaseNotes> updateNote({
    required DatabaseNotes note,
    required String text,
  }) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    await getNote(id: note.id);

    //update db
    final updateCount = await db.update(
      notesTable,
      {
        textColumn: text,
        syncedColumn: 0,
      },
      where: 'id = ?',
      whereArgs: [note.id],
    );
    if (updateCount == 0) {
      throw CouldNotUpdateNote();
    } else {
      final updateNote = await getNote(id: note.id);
      _notes.removeWhere((note) => note.id == updateNote.id);
      _notes.add(updateNote);
      _notesStreamController.add(_notes);

      return updateNote;
    }
  }

  // Delete a Note
  Future<void> deleteNote({required int id}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final deletedCount = await db.delete(
      notesTable,
      where: "id = ?",
      whereArgs: [id],
    );
    if (deletedCount == 0) {
      throw CouldNotDeleteNote();
    } else {
      _notes.removeWhere((note) => note.id == id);
      _notesStreamController.add(_notes);
    }
  }

  //Delete all Notes
  Future<int> deleteAllNotes() async {
    final db = _getDatabaseOrThrow();
    final numberOfDeletion = await db.delete(notesTable);

    _notes = [];
    _notesStreamController.add(_notes);

    return numberOfDeletion;
  }
}

@immutable
class DatabaseUser {
  final int id;
  final String email;

  const DatabaseUser({
    required this.id,
    required this.email,
  });

  DatabaseUser.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        email = map[emailColumn] as String;

  //prints out data to console
  @override
  String toString() => "Person, ID = $id, email = $email";

  //equality
  @override
  bool operator ==(covariant DatabaseUser other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class DatabaseNotes {
  final int id;
  final int userId;
  final String text;
  final bool syncedWithCloud;

  DatabaseNotes({
    required this.id,
    required this.userId,
    required this.text,
    required this.syncedWithCloud,
  });

  DatabaseNotes.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        userId = map[userIdColumn] as int,
        text = map[textColumn] as String,
        syncedWithCloud = (map[syncedColumn] as int) == 1 ? true : false;

  @override
  String toString() =>
      "Note, ID = $id, userId =  $userId, syncedWithCloud = $syncedWithCloud, text = $text";

  //equality
  @override
  bool operator ==(covariant DatabaseNotes other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

const dbName = "notes.db";
const notesTable = "notes";
const userTable = "user";
const idColumn = "id";
const emailColumn = 'email';
const userIdColumn = "user_id";
const textColumn = 'text';
const syncedColumn = "synced_with_cloud";

// database
const createUserTable = ''' CREATE TABLE IF NOT EXISTS "user" (
	  "id"	INTEGER NOT NULL,
	  "email"	TEXT NOT NULL UNIQUE,
	  PRIMARY KEY("id" AUTOINCREMENT)
);
    ''';

const createNotes = ''' CREATE TABLE "notes" (
    "id"	INTEGER NOT NULL,
    "user_id"	INTEGER NOT NULL,
    "text"	TEXT,
    "synced_with_cloud"	INTEGER NOT NULL DEFAULT 0,
    FOREIGN KEY("user_id") REFERENCES "user"("id"),
    PRIMARY KEY("id" AUTOINCREMENT)
);
    
    ''';
