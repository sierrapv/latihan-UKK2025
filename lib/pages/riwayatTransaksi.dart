import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:latihankasirapp/pages/homeappbar.dart';
import 'package:latihankasirapp/pages/theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RiwayatTransaksi extends StatefulWidget {
  @override
  _RiwayatTransaksiState createState() => _RiwayatTransaksiState();
}

String formatRupiah(num number) {
  final formatCurrency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
  return formatCurrency.format(number);
}

class _RiwayatTransaksiState extends State<RiwayatTransaksi> {
  final supabase = Supabase.instance.client;
  List<Transaction> transactions = [];
  int? expandedIndex;

  @override
  void initState() {
    super.initState();
    fetchTransactions();
  }

  Future<void> fetchTransactions() async {
    final response = await supabase.from('penjualan')
        .select('id, tanggalPenjualan, totalHarga, pelangganId')
        .order('id', ascending: false);

    List<Transaction> fetchedTransactions = [];
    for (var transaction in response) {
      final detailsResponse = await supabase.from('detailPenjualan')
          .select('produkId, jumlahProduk, subTotal')
          .eq('penjualanId', transaction['id']);
      
      List<Item> items = [];
      for (var detail in detailsResponse) {
        final productResponse = await supabase.from('products')
            .select('name, price')
            .eq('id', detail['produkId'])
            .maybeSingle();

        items.add(Item(
          name: productResponse?['name'] ?? 'Produk Tidak Diketahui',
          quantity: detail['jumlahProduk'],
          price: productResponse?['price'] ?? 0,
        ));
      }

      fetchedTransactions.add(Transaction(
        id: transaction['id'],
        date: transaction['tanggalPenjualan'].toString().split('T')[0],
        total: transaction['totalHarga'],
        items: items,
      ));
    }

    setState(() {
      transactions = fetchedTransactions;
    });
  }

   // Fungsi untuk menghapus transaksi
  Future<void> deleteTransaction(int id) async {
    final response = await supabase.from('penjualan').delete().eq('id', id);
    final responseDetail =
        await supabase.from('detailPenjualan').delete().eq('penjualanId', id);

    if (response == null && responseDetail == null) {
      setState(() {
        transactions.removeWhere((transaction) => transaction.id == id);
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Transaksi berhasil dihapus')));
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Gagal menghapus transaksi')));
    }
  }

  void showDeleteDialog(BuildContext context, int transactionId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Hapus Transaksi'),
          content: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Text("Anda yakin ingin menghapus riwayat transaksi ini?"),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child:
                            Text("Batal", style: TextStyle(color: Colors.red)),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          deleteTransaction(transactionId);
                          Navigator.pop(context);
                        },
                        child: Text("Hapus"),
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
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(100),
        child: Homeappbar(),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text("Riwayat Transaksi", style: sixTextStyle.copyWith(fontSize: 18, color: secondaryColor)),
          ),
          Expanded(
            child: transactions.isEmpty
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: transactions.length,
                    itemBuilder: (context, index) {
                      return TransactionTile(
                        transaction: transactions[index],
                        isExpanded: expandedIndex == index,
                        onTap: () {
                          setState(() {
                            expandedIndex = expandedIndex == index ? null : index;
                          });
                        },
                        onDelete: () {
                          showDeleteDialog(context, transactions[index].id);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class Transaction {
  final int id;
  final String date;
  final double total;
  final List<Item> items;
  Transaction({required this.id, required this.date, required this.total, required this.items});
}

class Item {
  final String name;
  final int quantity;
  final double price;
  Item({required this.name, required this.quantity, required this.price});
}

class TransactionTile extends StatelessWidget {
  final Transaction transaction;
  final bool isExpanded;
  final VoidCallback onTap;
  final Function onDelete;

  TransactionTile(
    {required this.transaction,
    required this.isExpanded, 
    required this.onTap,
    required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          ListTile(
            title: Text('Transaksi #${transaction.id}', style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Tanggal: ${transaction.date}'),
                Text('Total: ${formatRupiah(transaction.total)}'),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red[900]),
                  onPressed: () => onDelete(),
                ),
                Icon(isExpanded ? Icons.expand_less : Icons.expand_more),
              ],
            ),
            onTap: onTap,
          ),
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Divider(),
                  Text('Pesanan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(flex: 3, child: Text('Nama Barang', style: TextStyle(fontWeight: FontWeight.bold))),
                      Expanded(flex: 2, child: Center(child: Text('Jumlah', style: TextStyle(fontWeight: FontWeight.bold)))),
                      Expanded(flex: 2, child: Align(alignment: Alignment.centerRight, child: Text('Harga', style: TextStyle(fontWeight: FontWeight.bold))),
                    )],
                  ),
                  Column(
                    children: transaction.items.map((item) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(flex: 3, child: Text(item.name)),
                          Expanded(flex: 2, child: Center(child: Text(item.quantity.toString()))),
                          Expanded(flex: 2, child: Align(alignment: Alignment.centerRight, child: Text(formatRupiah(item.price))),
                      )],
                      );
                    }).toList(),
                  ),
                  Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total Pesanan', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(formatRupiah(transaction.total), style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
