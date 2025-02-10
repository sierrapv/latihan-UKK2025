import 'package:flutter/material.dart';
import 'package:latihankasirapp/pages/theme.dart';
import 'package:latihankasirapp/pages/homeappbar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class PelangganPage extends StatefulWidget {
  const PelangganPage({super.key});

  @override
  _PelangganPageState createState() => _PelangganPageState();
}

class _PelangganPageState extends State<PelangganPage> {
  List<Map<String, dynamic>> pelanggans = [];
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    fetchPelanggan();
  }

  Future fetchPelanggan() async {
    final response = await supabase
        .from('pelanggan')
        .select()
        .order('created_at', ascending: false);
    setState(() {
      pelanggans = List<Map<String, dynamic>>.from(response);
    });
  }

  // Add a new customer
  void _tambahPelanggan() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        TextEditingController namaController = TextEditingController();
        TextEditingController alamatController = TextEditingController();
        TextEditingController kontakController = TextEditingController();

        Future _addPelanggan() async {
          final nama = namaController.text;
          final alamat = alamatController.text;
          final kontak = kontakController.text;

          final response = await supabase.from('pelanggan').insert({
            'nama': nama,
            'alamat': alamat,
            'noTelp': kontak,
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Pelanggan berhasil ditambahkan!')),
          );

          fetchPelanggan();
          Navigator.pop(context);
        }

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          title:
              Text("Tambah Pelanggan", style: TextStyle(color: secondaryColor)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: namaController,
                decoration: InputDecoration(
                    labelText: "Nama Pelanggan",
                    labelStyle: TextStyle(color: secondaryColor)),
              ),
              TextField(
                controller: alamatController,
                decoration: InputDecoration(
                    labelText: "Alamat",
                    labelStyle: TextStyle(color: secondaryColor)),
              ),
              TextField(
                controller: kontakController,
                decoration: InputDecoration(
                    labelText: "No. Telepon",
                    labelStyle: TextStyle(color: secondaryColor)),
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Batal", style: TextStyle(color: secondaryColor)),
            ),
            TextButton(
              onPressed: _addPelanggan,
              child: Text("Simpan",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: secondaryColor)),
            ),
          ],
        );
      },
    );
  }

  void _editPelanggan(Map<String, dynamic> pelanggan) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        TextEditingController namaController =
            TextEditingController(text: pelanggan['nama']);
        TextEditingController alamatController =
            TextEditingController(text: pelanggan['alamat']);
        TextEditingController kontakController =
            TextEditingController(text: pelanggan['noTelp']);

        Future _updatePelanggan() async {
          final nama = namaController.text;
          final alamat = alamatController.text;
          final kontak = kontakController.text;

          final response = await supabase
              .from('pelanggan')
              .update({
                'nama': nama,
                'alamat': alamat,
                'noTelp': kontak,
              })
              .eq('id', pelanggan['id'])
              .select()
              .maybeSingle();

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Pelanggan berhasil diperbarui!')),
          );

          fetchPelanggan();
          Navigator.pop(context);
        }

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          title:
              Text("Edit Pelanggan", style: TextStyle(color: secondaryColor)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: namaController,
                decoration: InputDecoration(
                    labelText: "Nama Pelanggan",
                    labelStyle: TextStyle(color: secondaryColor)),
              ),
              TextField(
                controller: alamatController,
                decoration: InputDecoration(
                    labelText: "Alamat",
                    labelStyle: TextStyle(color: secondaryColor)),
              ),
              TextField(
                controller: kontakController,
                decoration: InputDecoration(
                    labelText: "No. Telepon",
                    labelStyle: TextStyle(color: secondaryColor)),
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Batal", style: TextStyle(color: secondaryColor)),
            ),
            TextButton(
              onPressed: _updatePelanggan,
              child: Text("Simpan",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: secondaryColor)),
            ),
          ],
        );
      },
    );
  }

  void _deletePelanggan(Map<String, dynamic> pelanggan) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        Future _destroyPelanggan(int pelangganId) async {
          final response = await supabase
              .from('pelanggan')
              .delete()
              .match({'id': pelangganId});

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Pelanggan berhasil dihapus!')),
          );

          fetchPelanggan();
          Navigator.pop(context);
        }

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          title:
              Text("Edit Pelanggan", style: TextStyle(color: secondaryColor)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [Text("Anda yakin ingin menghapus pelanggan ini?")],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Batal", style: TextStyle(color: secondaryColor)),
            ),
            TextButton(
              onPressed: () => _destroyPelanggan(pelanggan['id']),
              child: Text("Hapus",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: secondaryColor)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredPelangggan = pelanggans.where((pelanggan) {
      final namaPelanggan = pelanggan['nama'].toLowerCase() ?? '';
      return namaPelanggan.contains(searchQuery);
    }).toList();

    return Scaffold(
      // child: Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(100), // Adjust the height
        child: Homeappbar(), // Your custom app bar
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Ketik untuk cari...",
                prefixIcon: Icon(Icons.search, color: secondaryColor),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Daftar Pelanggan",
                  style: sixTextStyle.copyWith(
                    fontSize: 18,
                    color: secondaryColor,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.add_circle, color: secondaryColor, size: 28),
                  onPressed: _tambahPelanggan,
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredPelangggan.length,
              itemBuilder: (context, index) {
                final pelanggan = filteredPelangggan[index];
                if (!pelanggan['nama'].toLowerCase().contains(searchQuery)) {
                  return SizedBox.shrink();
                }
                return Container(
                  margin: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 5,
                      ),
                    ],
                  ),
                  child: ListTile(
                    title: Text(
                      pelanggan['nama'],
                      style: sevenTextStyle.copyWith(
                          fontWeight: FontWeight.bold, color: secondaryColor),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Alamat: ${pelanggan['alamat']}",
                            style:
                                sevenTextStyle.copyWith(color: secondaryColor)),
                        Text("No. Telepon: ${pelanggan['noTelp']}",
                            style:
                                sevenTextStyle.copyWith(color: secondaryColor)),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.blue[900]),
                          onPressed: () => _editPelanggan(pelanggan),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red[900]),
                          onPressed: () => _deletePelanggan(pelanggan),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      backgroundColor: backgroundPageColor,
      // ),
    );
  }
}
