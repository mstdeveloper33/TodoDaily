import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:random_string/random_string.dart';
import 'package:todooapp/services/database.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  TextEditingController todocontroller = TextEditingController();
  bool bugun = true, yarin = false, gelecekhafta = false;
  bool suggest = false;
  Stream? todoStream;
  getontheload() async {
    todoStream = await DatabaseMethods().getallthework(bugun
        ? "Bugün"
        : yarin
            ? "Yarın"
            : "Gelecek Hafta");
    setState(() {});
  }

  @override
  void initState() {
    getontheload();
    super.initState();
  }

  void openEditDialog(DocumentSnapshot ds) {
    TextEditingController editController = TextEditingController();
    editController.text = ds["Work"]; // Mevcut görev adını ayarla

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Görevi Düzenle"),
          content: TextField(
            controller: editController,
            decoration: InputDecoration(hintText: "Yeni görev adını girin"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Düzenlemeyi iptal et
              },
              child: Text("İptal"),
            ),
            TextButton(
              onPressed: () async {
                await DatabaseMethods().updateWork(
                  ds["Id"],
                  bugun
                      ? "Bugün"
                      : yarin
                          ? "Yarın"
                          : "Gelecek Hafta",
                  {"Work": editController.text}, // Yeni görev adı
                );

                Navigator.pop(context); // Dialogu kapat
                getontheload(); // Güncellenmiş veriyi yükle
              },
              child: Text("Kaydet"),
            ),
          ],
        );
      },
    );
  }

  Widget allWork() {
    return StreamBuilder(
      stream: todoStream,
      builder: (context, AsyncSnapshot snapshot) {
        return snapshot.hasData
            ? ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: snapshot.data.docs.length,
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                scrollDirection: Axis.vertical,
                itemBuilder: (context, index) {
                  DocumentSnapshot ds = snapshot.data.docs[index];
                  return GestureDetector(
                    onLongPress: () {
                      showModalBottomSheet(
                        backgroundColor: Colors.tealAccent.shade100,
                        context: context,
                        builder: (context) {
                          return Wrap(
                            children: [
                              ListTile(
                                leading: Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                title: Text("Sil"),
                                onTap: () async {
                                  await DatabaseMethods().deleteWork(
                                      ds["Id"],
                                      bugun
                                          ? "Bugün"
                                          : yarin
                                              ? "Yarın"
                                              : "Gelecek Hafta");
                                  Navigator.pop(context);
                                  getontheload();
                                },
                              ),
                              ListTile(
                                leading: Icon(
                                  Icons.edit,
                                  color: Colors.blue,
                                ),
                                title: Text("Düzenle"),
                                onTap: () {
                                  Navigator.pop(context);
                                  openEditDialog(ds);
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: CheckboxListTile(
                      activeColor: Color(0xFF279cfb),
                      title: Text(
                        ds["Work"],
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w400),
                      ),
                      value: ds["Yes"],
                      onChanged: (newValue) async {
                        bool updatedValue = !ds["Yes"];
                        await DatabaseMethods().updateifTicked(
                            ds["Id"],
                            bugun
                                ? "Bugün"
                                : yarin
                                    ? "Yarın"
                                    : "Gelecek Hafta",
                            updatedValue);
                        todocontroller.clear();
                        setState(() {});
                      },
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                  );
                },
              )
            : CircularProgressIndicator();
      },
    );
  }

  Widget buildHeader(String title, bool isActive) {
    return GestureDetector(
      onLongPress: () {
        showModalBottomSheet(
          context: context,
          builder: (context) {
            return Wrap(
              children: [
                ListTile(
                  tileColor: Colors.tealAccent.shade100,
                  leading: Icon(Icons.delete, color: Colors.black),
                  title: Text("Bütün görevleri sil"),
                  onTap: () async {
                    // Kullanıcıdan onay alma
                    bool confirmed = await showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text("Onay"),
                        content: Text(
                            "Bu başlık altındaki tüm görevleri silmek istediğinizden emin misiniz?"),
                        actions: [
                          TextButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).clearSnackBars();
                              Navigator.pop(context, false); // İptal
                            },
                            child: Text("Hayır"),
                          ),
                          TextButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).clearSnackBars();
                              Navigator.pop(context, true); // Onayla
                            },
                            child: Text("Evet"),
                          ),
                        ],
                      ),
                    );

                    if (confirmed) {
                      await DatabaseMethods().deleteAll(
                          title); // Başlık altındaki tüm belgeleri sil
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Tüm görevler silindi"),
                          backgroundColor: Colors.blue,
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).clearSnackBars();
                    }
                    Navigator.pop(context); // Alt menüyü kapat
                  },
                ),
              ],
            );
          },
        );
      },
      child: isActive
          ? Material(
              elevation: 5,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                decoration: BoxDecoration(
                  color: Color(0xFF3dffe3),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            )
          : GestureDetector(
              onTap: () {
                setState(() {
                  bugun = title == "Bugün";
                  yarin = title == "Yarın";
                  gelecekhafta = title == "Gelecek Hafta";
                  getontheload(); // Veriyi tekrar yükle
                });
              },
              child: Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
    );
  }
   Future openBox() => showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) => AlertDialog(
          content: SingleChildScrollView(
            child: Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Icon(Icons.cancel),
                      ),
                      SizedBox(
                        width: 30,
                      ),
                      Text(
                        "Yapılacak Etkinliğinizi Ekleyiniz",
                        style: TextStyle(
                            color: Color(0xff008080),
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black38, width: 2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TextField(
                      expands: false,
                      maxLength: 75,
                      maxLines: 2,
                      controller: todocontroller,
                      decoration: InputDecoration(
                          border: InputBorder.none, hintText: "Hedef Giriniz"),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  GestureDetector(
                    onTap: () {
                      String text =
                          todocontroller.text.trim(); // Boşlukları temizle

                      if (text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Görev adı boş olamaz"),
                            backgroundColor: Color.fromARGB(255, 28, 194, 172),
                          ),
                        );
                        return; // İşlem yapılmaz
                      }
                      String id = randomAlphaNumeric(10);
                      Map<String, dynamic> userTodo = {
                        "Work": todocontroller.text,
                        "Id": id,
                        "Yes": false,
                      };
                      bugun
                          ? DatabaseMethods().addBugunWork(userTodo, id)
                          : yarin
                              ? DatabaseMethods().addYarinWork(userTodo, id)
                              : DatabaseMethods().addGelecekWork(userTodo, id);
                      Navigator.pop(context);
                      todocontroller.clear();
                    },
                    child: Center(
                      child: Container(
                        width: 100,
                        padding: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                            color: Color(0xFF008080),
                            borderRadius: BorderRadius.circular(10)),
                        child: Center(
                          child: Text(
                            "Ekle",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          openBox();
        },
        child: Icon(
          Icons.add,
          color: Color(0xFF249fff),
          size: 30,
        ),
      ),
      body: Container(
        padding: EdgeInsets.only(top: 80, left: 30),
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF232FDA2),
              Color(0xFF13D8CA),
              Color(0xFF09adfe),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Merhaba\nHoşgeldin",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 3,
              ),
              Text(
                "Neler Yapacaksın?",
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
              SizedBox(
                height: 30,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  buildHeader("Bugün", bugun),
                  buildHeader("Yarın", yarin),
                  buildHeader("Gelecek Hafta", gelecekhafta),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              allWork(),
            ],
          ),
        ),
      ),
    );
  }

 
}
