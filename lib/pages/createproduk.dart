import 'package:flutter/material.dart';
import 'package:latihankasirapp/pages/theme.dart';
import 'package:latihankasirapp/pages/homepage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:latihankasirapp/components/bottombar.dart';

class CreateProductPage extends StatefulWidget {
  const CreateProductPage({super.key, required this.onProductCreated});
  final VoidCallback onProductCreated;

  @override
  _CreateProductPageState createState() => _CreateProductPageState();
}

class _CreateProductPageState extends State<CreateProductPage> {
  final supabase = Supabase.instance.client;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();

  Future _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text;
    final priceString = _priceController.text;
    final stockString = _stockController.text;

    final price = double.tryParse(priceString);
    final stock = int.tryParse(stockString);

    // Simpan produk ke database
    final response = await supabase.from('products').insert({
      'name': name,
      'price': price,
      'stock': stock,
    });

    if (response != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Kesalahan saat menyimpan produk')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Produk berhasil ditambahkan!')),
      );
      widget.onProductCreated();
      // Setelah sukses, tutup modal
      Navigator.pop(context, true); // Tutup modal setelah update
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8), // Tambahkan padding agar tidak terlalu penuh
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField(_nameController, "Nama Produk"),
              SizedBox(height: 10),
              _buildTextField(_stockController, "Stok Produk", isNumber: true),
              SizedBox(height: 10),
              _buildTextField(_priceController, "Harga Produk", isNumber: true),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text("Batal", style: TextStyle(color: Colors.red)),
                  ),
                  ElevatedButton(
                    onPressed: _saveProduct,
                    child: Text("Simpan Produk"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {bool isNumber = false}) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      validator: (value) => value!.isEmpty ? "$label tidak boleh kosong" : null,
    );
  }
}
