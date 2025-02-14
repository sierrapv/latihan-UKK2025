import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:latihankasirapp/pages/theme.dart';
import 'package:latihankasirapp/pages/homeappbar.dart';
import 'package:latihankasirapp/pages/struk.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TransaksiPage extends StatefulWidget {
  const TransaksiPage({super.key});

  @override
  _TransaksiPageState createState() => _TransaksiPageState();
}

class _TransaksiPageState extends State<TransaksiPage> {
  String? selectedCustomer;
  Map<String, dynamic>? selectedProduct;
  List<Map<String, dynamic>> customers = [];
  List<Map<String, dynamic>> products = [];
  List<Map<String, dynamic>> cartItems = [];
  final supabase = Supabase.instance.client;
  String? username;
  final TextEditingController _paymentController = TextEditingController();

  Future fetchCustomers() async {
    final response = await supabase.from('pelanggan').select();
    setState(() {
      customers = List<Map<String, dynamic>>.from(response);
    });
  }

  Future fetchProducts() async {
    final response = await supabase.from('products').select();
    setState(() {
      products = List<Map<String, dynamic>>.from(response);
    });
  }

  @override
  void initState() {
    super.initState();
    fetchCustomers();
    fetchProducts();
    getUsername();
  }

  void _addProductToCart(Map<String, dynamic> product) {
    setState(() {
      // Cek apakah produk sudah ada di keranjang
      bool productExists = false;
      for (var item in cartItems) {
        if (item['id'] == product['id']) {
          // Jika produk sudah ada, tambahkan jumlahnya
          item['jumlah'] += 1;
          productExists = true;
          break;
        }
      }

      // Jika produk belum ada, tambahkan produk baru dengan jumlah 1
      if (!productExists) {
        cartItems.add({
          'id': product['id'],
          'name': product['name'],
          'price': product['price'],
          'jumlah': 1,
        });
      }
    });
  }

  void _incrementQuantity(int index) {
    setState(() {
      cartItems[index]['jumlah']++;
    });
  }

  void _decrementQuantity(int index) {
    setState(() {
      if (cartItems[index]['jumlah'] > 1) {
        cartItems[index]['jumlah']--;
      }
    });
  }

  void _removeProductFromCart(int index) {
    setState(() {
      cartItems.removeAt(index);
    });
  }

  // Fungsi untuk menghitung total transaksi
  double _calculateTotal() {
    double total = 0;
    for (var item in cartItems) {
      total += item['jumlah'] * item['price'];
    }
    return total;
  }

  Future getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id');
    final response = await supabase
        .from('users')
        .select('username')
        .eq('id', userId as Object)
        .maybeSingle();

    setState(() {
      username = response?['username'] as String?;
    });
  }

  String formatRupiah(num number) {
    final formatCurrency =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return formatCurrency.format(number);
  }

  Future<void> _simpanTransaksi() async {
    // Pastikan pelanggan dipilih sebelum menyimpan
    if (selectedCustomer == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Pilih pelanggan terlebih dahulu!'),
      ));
      return;
    }

    // Menyimpan data ke tabel penjualan
    final responsePenjualan = await supabase.from('penjualan').insert([
      {
        'tanggalPenjualan':
            DateTime.now().toIso8601String(), // Tanggal sekarang
        'totalHarga': _calculateTotal(), // Total harga dari keranjang
        'pelangganId': customers.firstWhere(
            (customer) => customer['nama'] == selectedCustomer)['id'],
      }
    ]);

    if (responsePenjualan != null) {
      // Jika gagal menyimpan data penjualan
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Gagal menyimpan transaksi: $responsePenjualan'),
      ));
      return;
    }

    final responsePenjualanId = await supabase
        .from('penjualan')
        .select('id') // Ambil hanya kolom 'id'
        .eq(
            'tanggalPenjualan',
            DateTime.now()
                .toIso8601String()) // Cari berdasarkan tanggal transaksi
        .order('id',
            ascending:
                false) // Urutkan berdasarkan ID, yang terakhir akan menjadi yang baru
        .limit(1) // Ambil hanya satu data terakhir
        .single(); // Ambil satu data saja, karena hanya ada satu data yang diinsert

    // Dapatkan id penjualan yang baru disimpan
    final penjualanId = responsePenjualanId['id'];

    // Menyimpan data ke tabel detailpenjualan
    for (var item in cartItems) {
      final produkId = item['id'];
      final jumlahProduk = item['jumlah'];
      final subTotal = item['jumlah'] * item['price'];

      final responseDetail = await supabase.from('detailPenjualan').insert([
        {
          'penjualanId': penjualanId,
          'produkId': produkId,
          'jumlahProduk': jumlahProduk,
          'subTotal': subTotal,
        }
      ]);

      if (responseDetail != null) {
        // Jika gagal menyimpan detail penjualan
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Gagal menyimpan detail produk: $responseDetail'),
        ));
        return;
      }

      // **Update Stock**
      final productResponse = await supabase
          .from('products')
          .select('stock')
          .eq('id', produkId)
          .single();

      if (productResponse != null) {
        final currentStock = productResponse['stock'];
        final newStock = currentStock - jumlahProduk;

        // Update stock in the products table
        await supabase
            .from('products')
            .update({'stock': newStock}).eq('id', produkId);
      }
    }

    // Ambil nilai pembayaran dari input
    double paymentAmount = double.tryParse(_paymentController.text) ?? 0.0;
    double totalAmount = _calculateTotal();
    double changeAmount = paymentAmount - totalAmount;

    if (paymentAmount < totalAmount) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Uang kurang! Masukkan jumlah yang cukup.")),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReceiptPage(
          transactionId: penjualanId.toString(),
          cashier: username ?? "Kasir",
          customer: selectedCustomer ?? "Pelanggan",
          items: cartItems,
          totalAmount: totalAmount,
          payment: paymentAmount,
          change: changeAmount,
        ),
      ),
    );
  }

  TableRow _buildTableRow(List<String> values, {bool isHeader = false}) {
    return TableRow(
      children: values.map((value) {
        return Padding(
          padding: EdgeInsets.all(8),
          child: Text(
            value,
            style: TextStyle(
              fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
              fontSize: 14,
            ),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(100),
        child: Homeappbar(), // Your custom app bar
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Judul halaman
            Text("Transaksi",
                style:
                    sixTextStyle.copyWith(fontSize: 18, color: secondaryColor)),
            SizedBox(height: 16),

            // Customer Dropdown
            Text("Nama Pelanggan", style: eightTextStyle),
            SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: selectedCustomer,
              items: customers.map((customer) {
                return DropdownMenuItem<String>(
                  value: customer['nama'],
                  child: Text(customer['nama']),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  selectedCustomer = newValue;
                });
              },
              decoration: InputDecoration(
                hintText: "Pilih pelanggan",
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0)),
              ),
            ),
            SizedBox(height: 16),

            // Form untuk menambah produk
            Text("Pilih Produk", style: eightTextStyle),
            SizedBox(height: 8),
            DropdownButtonFormField<Map<String, dynamic>>(
              value: selectedProduct,
              hint: Text("Pilih produk"),
              items: products.map((product) {
                return DropdownMenuItem<Map<String, dynamic>>(
                  value: product,
                  child: Text(product['name']),
                );
              }).toList(),
              onChanged: (newValue) {
                if (newValue != null) {
                  _addProductToCart(newValue);
                }
                selectedProduct = newValue;
              },
              decoration: InputDecoration(
                hintText: "Pilih produk",
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0)),
              ),
            ),
            SizedBox(height: 16),

            // Form untuk menambah produk
            Text("Cash", style: eightTextStyle),
            SizedBox(height: 8),
            TextField(
              controller: _paymentController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                hintText: "Nominal Pembayaran",
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0)),
              ),
            ),
            SizedBox(height: 16),

            // Menampilkan tulisan "Tambah Produk" dan Total di sebelah kanan
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Rincian Pesanan", style: eightTextStyle),
                Row(
                  children: [
                    Text("Total: ", style: eightTextStyle),
                    Text(
                      formatRupiah(_calculateTotal()),
                      style: eightTextStyle.copyWith(color: Colors.redAccent),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: cartItems.length,
                itemBuilder: (context, index) {
                  final product = cartItems[index];
                  return ListTile(
                    title: Text(product['name']),
                    subtitle: Text(
                        'Jumlah: ${product['jumlah']} - Sub Total: ${formatRupiah(product['jumlah'] * product['price'])}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.remove, color: Colors.red),
                          onPressed: () => _decrementQuantity(index),
                        ),
                        IconButton(
                          icon: Icon(Icons.add, color: Colors.green),
                          onPressed: () => _incrementQuantity(index),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.blue),
                          onPressed: () => _removeProductFromCart(index),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Print Receipt Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: secondaryColor,
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: _simpanTransaksi,
                child: Text('Cetak Struk',
                    style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
