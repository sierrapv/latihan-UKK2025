import 'package:flutter/material.dart';
import 'package:latihankasirapp/components/bottombar.dart';
import 'package:latihankasirapp/pages/theme.dart';
import 'package:latihankasirapp/pages/homeappbar.dart';
import 'package:latihankasirapp/pages/itemwidget.dart';
import 'package:latihankasirapp/pages/createproduk.dart';
import 'package:latihankasirapp/pages/transaksi.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String searchQuery = '';
  final GlobalKey<ItemWidgetState> itemWidgetKey = GlobalKey();
  Map<int, Map<String, dynamic>> cartItems = {};

  void fetchProducts() {
    itemWidgetKey.currentState?.fetchProducts();
  }

  void showCreateProductModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Tambah Produk",
                  style: secondTextStyle.copyWith(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                CreateProductPage(
                  onProductCreated: fetchProducts,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          ListView(
            children: [
              Homeappbar(),
              Container(
                child: Column(
                  children: [
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 15),
                      padding: EdgeInsets.symmetric(horizontal: 15),
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                            color: Colors.grey
                                .shade300), // Tambahkan border agar lebih jelas
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: "Ketik untuk cari...",
                              ),
                              onChanged: (value) {
                                setState(() {
                                  searchQuery = value.toLowerCase();
                                });
                              },
                            ),
                          ),
                          Icon(
                            Icons.search,
                            size: 27,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Daftar Produk",
                    style: sixTextStyle.copyWith(
                      fontSize: 18,
                      color: secondaryColor,
                    ),
                    ),
                    IconButton(
                      icon: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: fourthColor,
                        ),
                        padding: EdgeInsets.all(10),
                        child: Icon(Icons.add, color: whiteColor),
                      ),
                      onPressed: () {showCreateProductModal(context);},
                    )
                  ],
                )
              ),
              ItemWidget(
                key: itemWidgetKey,
                searchQuery: searchQuery,
                // onCartUpdated: updateCart,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
