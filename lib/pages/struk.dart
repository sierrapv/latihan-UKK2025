import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Untuk format tanggal
import 'package:latihankasirapp/components/bottombar.dart';
import 'package:latihankasirapp/pages/theme.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';

class ReceiptPage extends StatefulWidget {
  final String transactionId;
  final String cashier;
  final String customer;
  final List<Map<String, dynamic>> items;
  final double totalAmount;
  final double payment;
  final double change;

  ReceiptPage({
    required this.transactionId,
    required this.cashier,
    required this.customer,
    required this.items,
    required this.totalAmount,
    required this.payment,
    required this.change,
  });

  @override
  _ReceiptPageState createState() => _ReceiptPageState();
}

String formatRupiah(num number) {
  final formatCurrency =
      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
  return formatCurrency.format(number);
}

class _ReceiptPageState extends State<ReceiptPage> {
  @override
  Widget build(BuildContext context) {
    String formattedDate =
        DateFormat('dd-MM-yyyy HH:mm:ss').format(DateTime.now());

    int totalItem =
        widget.items.fold(0, (sum, item) => sum + (item['jumlah'] as int));

    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        title: Text('E-RECEIPT', style: TextStyle(color: Colors.white)),
        backgroundColor: secondaryColor,
        centerTitle: true,
        leading: IconButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => BottomBar(
                          initialIndex: 1,
                        )),
              );
            },
            icon: Icon(Icons.chevron_left, color: whiteColor,)),
      ),
      body: Center(
        child: Container(
          width: 400,
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            // borderRadius: BorderRadius.circular(10),
            boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 5)],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              Text('WARMINDO',
                  style: secondTextStyle.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black)),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('DARI SEMANGKUK MIE, LAHIR RIBUAN CERITA DAN TAWA', style: nineTextStyle),
                ]),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('DITENGAH MALAM CURHATAN PANJANG ANTAR TEMAN ', style: nineTextStyle),
                ]),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('HINGGA RENCANA BESAR YANG DIMULAI DARI', style: nineTextStyle),
              ],),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('OBROLAN SEDERHANA DI MEJA WARMINDO', style: nineTextStyle),
              ],),
              SizedBox(height: 8,),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('STRUK INI DIBUAT DENGAN SEMESTINYA OLEH PIHAK KAMI', style: nineTextStyle,),
                ]),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                Text('TERIMA KASIH JANGAN LUPA KEMBALI', style: nineTextStyle),
                ]),
              Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('No. Transaksi: ${widget.transactionId}'),
                  Text('Petugas: ${widget.cashier}'),
                ]),
              Divider(),
              ...widget.items
                  .map((item) => buildItemRow(item['name'],
                      item['jumlah'].toString(), formatRupiah(item['price']).toString()))
                  .toList(),
              Divider(),
              buildTotalRow('Total Item', totalItem.toString(), ''),
              buildTotalRow(
                  'Total Belanja', '', formatRupiah(widget.totalAmount)),
              buildTotalRow('Bayar', '', formatRupiah(widget.payment)),
              buildTotalRow('Kembalian', '', formatRupiah(widget.change)),
              Divider(),
              SizedBox(height: 10),
              Text('Tgl. $formattedDate', style: TextStyle(fontSize: 12)),
              Text('Pelanggan: ${widget.customer}',
                  style: TextStyle(fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildItemRow(String name, String qty, String price) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(name, style: TextStyle(fontSize: 14))),
          Text("$qty x ", style: TextStyle(fontSize: 14)),
          Text(price, style: TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  Widget buildTotalRow(String title, String qty, String amount) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
              child: Text(title,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold))),
          Text(qty,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          Text(amount,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
