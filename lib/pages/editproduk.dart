import 'package:flutter/material.dart';
import 'package:latihankasirapp/components/bottombar.dart';
// import 'package:google_fonts/google_fonts.dart';
import 'package:latihankasirapp/pages/theme.dart';
import 'package:latihankasirapp/pages/homepage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditProductPage extends StatefulWidget {
  final Map<String, dynamic> product;
  final VoidCallback onProductUpdated;

  const EditProductPage({super.key, required this.product, required this.onProductUpdated});

  @override
  _EditProductPageState createState() => _EditProductPageState();
}

class _EditProductPageState extends State<EditProductPage> {
  final supabase = Supabase.instance.client;
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController = TextEditingController();
  late TextEditingController _priceController = TextEditingController();
  late TextEditingController _stockController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product['name']);
    _priceController = TextEditingController(text: widget.product['price'].toString());
    _stockController = TextEditingController(text: widget.product['stock'].toString());
  }

  Future _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text;
    final price = double.tryParse(_priceController.text);
    final stock = int.tryParse(_stockController.text);

    final response = await supabase
        .from('products')
        .update({
          'name': name,
          'price': price,
          'stock': stock,
        })
        .eq('id', widget.product['id'])
        .select()
        .maybeSingle();

    if (response == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Kesalahan saat menyimpan produk')),
      );
    } else {
      widget.onProductUpdated();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Produk berhasil diperbarui!')),
      );
      Navigator.pop(context, true); // Tutup modal setelah update
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Edit Produk", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
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
                    child: Text("Simpan"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {bool isNumber = false}) {
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