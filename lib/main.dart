import 'package:flutter/material.dart';
import 'insert.dart';
import 'data.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
 
void main() => runApp(MyApp());
 
class MyApp extends StatelessWidget {
    @override
    Widget build(BuildContext context) {
        return MaterialApp(
            theme: ThemeData(
                primarySwatch: Colors.blue,
            ),
            home: MyHomePage(),
        );
    }
}
 
class MyHomePage extends StatefulWidget {
    MyHomePage({Key? key}) : super(key: key);
 
    @override
    _MyHomePageState createState() => _MyHomePageState();
}
 
class _MyHomePageState extends State<MyHomePage> {
    // data customer yang akan ditampilkan di list view
    // beri nilai awal berupa list kosong agar tidak error
    // nantinya akan diisi data dari Shared Preferences
    var savedData = [];
 
    // method untuk mengambil data Shared Preferences
    getSavedData() async {
        var data = await Data.getData();
        // setelah data didapat panggil setState agar data segera dirender
        setState(() {
          savedData = data;
        });
    }
 
    // init state ini dipanggil pertama kali oleh flutter
    @override
    initState() {
        super.initState();
        // baca Shared Preferences
        getSavedData();
    }
 
    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(
                title: Text('Home'),
                backgroundColor: Colors.blue,
                actions: <Widget>[
                    FlatButton(
                        onPressed: (){
                            // action tombol ADD untuk proses insert
                            // nilai yang dikirim diisi null
                            // agar di halaman insert tahu jika null berarti operasi insert data
                            // jika tidak null maka update data
                            Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => Insert(index: null, value: null))
                            ).then((value){
                                // jika halaman insert ditutup ambil kembali Shared Preferences
                                // untuk mendapatkan data terbaru dan segera ditampilkan ke user
                                // misal jika ada data customer yang ditambahkan
                                getSavedData();
                            });
                        },
                        child: Text(
                            'ADD',
                            style: TextStyle(
                                color: Colors.white
                            ),
                        ),
                    )
                ],
            ),
            body: Padding(
                padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
                child: ListView.builder(
                    itemCount: savedData.length,
                    itemBuilder: (context, index){
                        return ListTile(
                            leading: 
                                // jika tidak ada gambar tampil default
                                savedData[index]['image'] == null? 
                                CircleAvatar(
                                    radius: 50,
                                    child: Icon(
                                    Icons.person
                                    ),
                                ) : 
                                // jika terdapat gambar
                                // check jika web build gunakan network image
                                kIsWeb ? 
                                CircleAvatar(
                                    radius: 50,
                                    backgroundImage: NetworkImage(savedData[index]['image']!),
                                ) : 
                                // jika mobile build gunakan file image
                                CircleAvatar(
                                    radius: 50,
                                    // tambahkan .image di akhir statement untuk mengubah ke bentuk class image
                                    backgroundImage: Image.file(File(savedData[index]['image']!)).image,
                                ),
                            title: Text(savedData[index]['name']),
                            subtitle: Text(savedData[index]['address'] + ' ' + savedData[index]['phone']),
                            contentPadding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                            onTap: (){
                                // aksi saat user klik pada item customer pada list view
                                // nilai diisi selain null menandakan di halaman insert operasi yang berjalan adalah update atau delete
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => Insert(index: index, value: savedData[index]))
                                ).then((value){
                                    // jika halaman insert ditutup ambil kembali Shared Preferences
                                    // untuk mendapatkan data terbaru dan segera ditampilkan ke user
                                    // misal jika ada data customer yang diedit atau dihapus
                                    getSavedData();
                                });
                            },
                        );
                    }
                ),
            )
        );
    }
}