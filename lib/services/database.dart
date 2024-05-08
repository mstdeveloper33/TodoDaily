import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseMethods {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  Future addBugunWork(Map<String, dynamic> userBugunMap, String id) async {
    return await firestore.collection("Bugün").doc(id).set(userBugunMap);
  }

  Future addYarinWork(Map<String, dynamic> userBugunMap, String id) async {
    return await firestore.collection("Yarın").doc(id).set(userBugunMap);
  }

  Future addGelecekWork(Map<String, dynamic> userBugunMap, String id) async {
    return await firestore
        .collection("Gelecek Hafta")
        .doc(id)
        .set(userBugunMap);
  }

  Future deleteWork(String id, String day) async {
    return await firestore.collection(day).doc(id).delete();
  }

  Future<Stream<QuerySnapshot>> getallthework(String day) async {
    return await firestore.collection(day).snapshots();
  }

  updateifTicked(String id, String day, bool newValue) async {
    return await firestore.collection(day).doc(id).update({"Yes": newValue});
  }

  // Güncelleme işlemi için oluşturulan metod
  Future<void> updateWork(
      String id, String day, Map<String, dynamic> updatedData) async {
    return await firestore
        .collection(day)
        .doc(id)
        .update(updatedData); // Belgeyi günceller
  }

  Future<void> deleteAll(String collectionName) async {
    var collection = firestore.collection(collectionName);
    var snapshots = await collection.get();

    for (var doc in snapshots.docs) {
      await doc.reference.delete(); // Tüm belgeleri sil
    }
  }
}
