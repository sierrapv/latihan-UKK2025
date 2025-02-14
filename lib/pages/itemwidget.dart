import 'package:flutter/material.dart';
import 'package:latihankasirapp/pages/editproduk.dart';
import 'package:latihankasirapp/pages/theme.dart';
import 'package:latihankasirapp/pages/transaksi.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:latihankasirapp/pages/createproduk.dart';
import 'package:intl/intl.dart';

final supabase = Supabase.instance.client;

class ItemWidget extends StatefulWidget {
  const ItemWidget({super.key, required this.searchQuery});

  final String searchQuery;

  @override
  ItemWidgetState createState() => ItemWidgetState();
}

String formatRupiah(num number) {
  final formatCurrency =
      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
  return formatCurrency.format(number);
}

class ItemWidgetState extends State<ItemWidget> {
  List<Map<String, dynamic>> products = [];

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future fetchProducts() async {
    final response = await supabase
        .from('products')
        .select()
        .order('created_at', ascending: false);
    setState(() {
      products = List<Map<String, dynamic>>.from(response);
    });
  }

  void deleteProduct(int productId) async {
    await supabase.from('products').delete().match({'id': productId});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Produk berhasil dihapus!')),
    );
    Navigator.pop(context);
    fetchProducts();
  }

  void showEditDialog(BuildContext context, Map<String, dynamic> product) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Edit Produk',
            textAlign: TextAlign.center,
            style: secondTextStyle.copyWith(
                fontSize: 18, fontWeight: FontWeight.bold),
          ),
          content: EditProductPage(
              product: product, onProductUpdated: fetchProducts),
        );
      },
    );
  }

  void showDeleteDialog(BuildContext context, Map<String, dynamic> product) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Hapus Produk',
            textAlign: TextAlign.center,
            style: secondTextStyle.copyWith(
                fontSize: 18, fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    "Anda yakin ingin menghapus produk ini?",
                    textAlign: TextAlign.center,
                    style: sevenTextStyle,
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      SizedBox(
                        width: 80, // Lebar tetap
                        height: 40, // Tinggi tetap
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.indigo[900],
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15)),
                          ),
                          child: Text("Tidak",
                              style:
                                  TextStyle(color: whiteColor, fontSize: 14)),
                        ),
                      ),
                      SizedBox(
                        width: 80, // Lebar tetap
                        height: 40, // Tinggi tetap
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red[900],
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15)),
                          ),
                          onPressed: () => deleteProduct(product['id']),
                          child: Text("Iya",
                              style:
                                  TextStyle(color: whiteColor, fontSize: 14)),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredProducts = products.where((product) {
      final productName = product['name'].toLowerCase() ?? '';
      return productName.contains(widget.searchQuery);
    }).toList();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          fit: FlexFit.loose,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: filteredProducts.length,
            itemBuilder: (context, index) {
              final product = filteredProducts[index];
              final productId = product['id'];

              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: Offset(0, 3),
                      ),
                    ],
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(product['name'], style: thirdTextStyle),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Harga: ${formatRupiah(product['price'])}",
                                    style: fiveTextStyle),
                                SizedBox(height: 6),
                                Text("Stok: ${product['stock']}",
                                    style: fiveTextStyle),
                              ],
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.edit),
                                    color: Colors.blue[900],
                                    onPressed: () =>
                                        showEditDialog(context, product),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete),
                                    color: Colors.red[900],
                                    onPressed: () =>
                                        showDeleteDialog(context, product),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
