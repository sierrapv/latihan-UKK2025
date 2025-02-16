import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:latihankasirapp/components/bottombar.dart';
import 'package:latihankasirapp/pages/theme.dart';

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
      body: Column(
        children: [
          AppBar(
            title: Text('E-RECEIPT', style: TextStyle(color: Colors.white)),
            backgroundColor: secondaryColor,
            centerTitle: true,
            leading: IconButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => BottomBar(initialIndex: 1)),
                  );
                },
                icon: Icon(
                  Icons.chevron_left,
                  color: whiteColor,
                )),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 20),
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 9)],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text('WARMINDO',
                        style: secondTextStyle.copyWith(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black)),
                    SizedBox(height: 10),
                    Text('DARI SEMANGKUK MIE, LAHIR RIBUAN CERITA DAN TAWA',
                        style: nineTextStyle, textAlign: TextAlign.center),
                    Text('DITENGAH MALAM CURHATAN PANJANG ANTAR TEMAN',
                        style: nineTextStyle, textAlign: TextAlign.center),
                    Text('HINGGA RENCANA BESAR YANG DIMULAI DARI',
                        style: nineTextStyle, textAlign: TextAlign.center),
                    Text('OBROLAN SEDERHANA DI MEJA WARMINDO',
                        style: nineTextStyle, textAlign: TextAlign.center),
                    SizedBox(height: 8),
                    Text('STRUK INI DIBUAT DENGAN SEMESTINYA OLEH PIHAK KAMI',
                        style: nineTextStyle, textAlign: TextAlign.center),
                    Text('TERIMA KASIH JANGAN LUPA KEMBALI',
                        style: nineTextStyle, textAlign: TextAlign.center),
                    Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('No. Transaksi: ${widget.transactionId}'),
                        Text('Petugas: ${widget.cashier}'),
                      ],
                    ),
                    Divider(),
                    ...widget.items.map((item) => buildItemRow(
                        item['name'],
                        item['jumlah'].toString(),
                        formatRupiah(item['price']).toString())),
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
                    SizedBox(height: MediaQuery.of(context).size.height * 0.5),
                  ],
                ),
              ),
            ),
          ),
        ],
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
