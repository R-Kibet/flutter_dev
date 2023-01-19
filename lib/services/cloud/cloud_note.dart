import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:trial/services/cloud/cloud_storage_constants.dart';
import 'package:flutter/cupertino.dart';

/// create 3 main identifiers in cloud note
///  !. unique id -> pk
///  2. user_id -> owner
///  3. text field
///
/// moving from local storage to firestore

@immutable
class CloudNote {
  final String documentId;
  final String ownerUserId;
  final String text;

  const CloudNote({
    required this.documentId,
    required this.ownerUserId,
    required this.text,
  });

  CloudNote.fromSnapshot(QueryDocumentSnapshot<Map<String, dynamic>> snapshot) :
      documentId = snapshot.id,
      ownerUserId = snapshot.data()[ownerUseridFieldName],
      text = snapshot.data()[textFieldName] as String;
}
