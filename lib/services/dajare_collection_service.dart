import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/dajare_entry.dart';

class DajareCollectionException implements Exception {
  const DajareCollectionException();
}

class DajareCollectionService {
  const DajareCollectionService();

  Future<List<DajareEntry>> loadEntries() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      throw const DajareCollectionException();
    }

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('dajareEntries')
          .orderBy('createdAt', descending: true)
          .limit(100)
          .get();

      return snapshot.docs
          .map((document) => DajareEntry.tryFromMap(document.data()))
          .whereType<DajareEntry>()
          .toList();
    } on FirebaseException {
      throw const DajareCollectionException();
    }
  }
}
