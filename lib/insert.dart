import 'package:flutter/material.dart';
import 'data.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart';
import 'package:geocode/geocode.dart';
 
class Insert extends StatefulWidget {
    final index;
    final value;
    Insert({Key? key, @required this.index, @required this.value}) : super(key: key);
 
 
 
    @override
    _InsertState createState() => _InsertState(index: index, value: value);
}
 
class _InsertState extends State<Insert> {
    _InsertState({@required this.index, @required this.value}) : super();
    // variabel untuk menampung data yang dikirim dari halaman home
    final index;
    final value;
 
    // controller TextField untuk validasi
    final nameController = TextEditingController();
    final addressController = TextEditingController();
    final phoneController = TextEditingController();
    
    // variabel untul menyimpan gambar
    String? imagePath;

    // membuat oject image picker
    final ImagePicker _picker = ImagePicker();

    Future GetImage(bool isCamera) async {
        // variabel untuk menampung gambar sementara
        final image;

        // jika yang dipilih dari kamera, image picker akan mengakses camera
        if (isCamera) {
            image = await _picker.pickImage(source: ImageSource.camera);
        // jika yang dipilih dari gallery, image picker akan mengakses storage gallery
        } else {
            image = await _picker.pickImage(source: ImageSource.gallery);
        }

        // jika gambar kosong, akhiri fungsi
        if (image == null) return;
        // jika ada gambar, simpan gambar dari path tersebut
        final imageTemp = File(image.path);

        setState(() {
            imagePath = imageTemp.path;
        });
    }

    Future<LocationData?> getLocation() async {
        // membuat object location
        Location location = new Location();

        bool _serviceEnabled;
        PermissionStatus _permissionGranted;
        LocationData _locationData;

        // cek perizinan akses gps user
        _serviceEnabled = await location.serviceEnabled();
            // jika nonaktif
            if (!_serviceEnabled) {
                // melakukan permintaan untuk mengaktifkan gps
                _serviceEnabled = await location.requestService();
            // jika nonaktif (ditolak), akhiri fungsi
            if (!_serviceEnabled) {
                return null;
            }
        }

        // cek perizinan akses lokasi user
        _permissionGranted = await location.hasPermission();
            // jika ditolak
            if (_permissionGranted == PermissionStatus.denied) {
                // melakukan permintaan untuk akses lokasi terkini
                _permissionGranted = await location.requestPermission();
            // jika tidak diberikan, akhiri fungsi
            if (_permissionGranted != PermissionStatus.granted) {
                return null;
            }
        }

        // jika semua sudah terpenuhi, ambil object lokasi terkini, dan kembalikan nilainya
        _locationData = await location.getLocation();
        return _locationData;
    }

    Future<String?> getAddress(double? lat, double? long) async {
        // jika salah satu koordinat kosong, kembalikan nilai string kosong
        if (lat == null || long == null) return "";

        // membuat object geocode
        GeoCode geoCode = GeoCode();
        // terjemahkan koordinat ke bentuk alamat
        Address address = await geoCode.reverseGeocoding(latitude: lat,  longitude: long);
        // kembalikan string alamatnya
        return "${address.streetAddress}, ${address.city}, ${address.countryName}, ${address.postal}";
    }

    // cek semua data sudah diisi atau belum
    isDataValid() {
        if(nameController.text.isEmpty){
            return false;
        }
 
        if(addressController.text.isEmpty){
            return false;
        }
 
        if(phoneController.text.isEmpty){
            return false;
        }
 
        return true;
    }
 
 
    getData(){
        // jika nilai index dan value yang dikirim dari halaman home tidak null
        // artinya ini adalah operasi update
        // tampilkan data yang dikirim, sehingga user bisa edit
        if(index != null && value != null){
            setState(() {
                nameController.text = value['name'];
                addressController.text = value['address'];
                phoneController.text = value['phone'];
                imagePath = value['image'];
            });
        }
    }
 
    // proses menyimpan data yang diinput user ke Shared Preferences
    saveData() async {
        // cek semua data sudah diisi atau belum
        // jika belum tampilkan pesan error
        if(isDataValid()){
            // data yang akan dimasukkan atau diupdate ke Shared Preferences sesuai input user
            var customer = {
                'name': nameController.text,
                'address': addressController.text,
                'phone': phoneController.text,
                'image': imagePath
            };
 
            // ambil data Shared Preferences sebagai list
            var savedData = await Data.getData();
 
            if(index == null){
                // index == null artinya proses insert
                // masukkan data pada index 0 pada data Shared Preferences
                // sehingga pada halaman Home data yang baru dimasukkan
                // akan tampil paling atas
                savedData.insert(0, customer);
            }else{
                // jika index tidak null artinya proses update
                // update data Shared Preferences sesuai index-nya
                savedData[index] = customer;
            }
            // simpan data yang diinsert / diedit user ke Shared Preferences kembali
            // kemudian tutup halaman insert ini
            await Data.saveData(savedData);
            Navigator.pop(context);
        }else{
            showDialog(
                context: context,
                builder: (context){
                    return AlertDialog(
                        title: Text('Data Kosong'),
                        content: Text('Tidak dapat menyimpan data yang kosong!'),
                        actions: <Widget>[
                            FlatButton(
                                onPressed: (){
                                    Navigator.pop(context);
                                },
                                child: Text('OK'),
                            )
                        ],
                    );
                }
            );
        }
    }
 
    deleteData() async {
        // ambil data Shared Preferences sebagai list
        // delete data pada index yang sesuai
        // kemudian simpan kembali ke Shared Preferences
        // dan kembali ke halaman Home
        var savedData = await Data.getData();
        savedData.removeAt(index);
 
        await Data.saveData(savedData);
 
        Navigator.pop(context);
    }
 
    getDeleteButton(){
        // jika proses update tampilkan tombol delete
        // jika insert return widget kosong
        if(index != null && value != null){
            return FlatButton(
                child: Text(
                    'DELETE',
                    style: TextStyle(
                        color: Colors.white
                    ),
                ),
                onPressed: (){
                    deleteData();
                },
            );
        }else{
            return SizedBox.shrink();
        }
    }
 
    @override
    initState() {
        super.initState();
        getData();
    }
 
    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(
                title: Text('Insert'),
                backgroundColor: Colors.blue,
                actions: <Widget>[
                    getDeleteButton(),
                    FlatButton(
                        onPressed: (){
                            saveData();
                        },
                        child: Text(
                            'SAVE',
                            style: TextStyle(
                                color: Colors.white
                            ),
                        ),
                    ),
                ],
            ),
            body: Padding(
                padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                        Center(
                            child: Column(
                                children: <Widget>[
                                    imagePath == null? 
                                    CircleAvatar(
                                        radius: 50,
                                        child: Icon(
                                        Icons.person
                                        ),
                                        // backgroundImage: FileImage(File(state.avatarPath)),
                                    ) : 
                                    // check jika web build gunakan network image
                                    kIsWeb ? 
                                    CircleAvatar(
                                        radius: 50,
                                        backgroundImage: NetworkImage(imagePath!),
                                    ) : 
                                    // jika mobile build gunakan file image
                                    CircleAvatar(
                                        radius: 50,
                                        // tambahkan .image di akhir statement untuk mengubah ke bentuk class image
                                        backgroundImage: Image.file(File(imagePath!)).image,
                                    ),
                                    TextButton(
                                        onPressed: () { _showImageSourceActionSheet(); },
                                        child: Text('Change Avatar'),
                                    )
                                ],
                            ),
                        ),
                        Padding(
                            padding: EdgeInsets.only(top: 20),
                        ),
                        Text('Name'),
                        TextField(
                            controller: nameController,
                        ),
                        Padding(
                            padding: EdgeInsets.only(top: 20),
                        ),
                        Text('Address'),
                        TextField(
                            controller: addressController,
                        ),
                        TextButton(
                            onPressed: () async { 
                                await getLocation().then((value) async {
                                    var address = await getAddress(value?.latitude, value?.longitude);
                                    addressController.text = address!;
                                });
                                },
                            child: Text('get current location'),
                        ),
                        Padding(
                            padding: EdgeInsets.only(top: 20),
                        ),
                        Text('Phone'),
                        TextField(
                            controller: phoneController,
                        )
                    ],
                ),
            )
        );
    }

    // fungsi untuk menampilkan pilihan list source image
    void _showImageSourceActionSheet() {
        showModalBottomSheet(
            context: context,
            builder: (context) => Wrap(children: [
                ListTile(
                    leading: Icon(Icons.camera_alt),
                    title: Text('Camera'),
                    onTap: () { GetImage(true); },
                ),
                ListTile(
                    leading: Icon(Icons.photo_album),
                    title: Text('Gallery'),
                    onTap: () { GetImage(false); },
                ),
            ]),
       );
    }

}