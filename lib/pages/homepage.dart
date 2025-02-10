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
                padding: EdgeInsets.only(top: 15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(35),
                    topRight: Radius.circular(35),
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 15),
                      padding: EdgeInsets.symmetric(horizontal: 15),
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        children: [
                          Container(
                            margin: EdgeInsets.only(left: 5),
                            height: 50,
                            width: 300,
                            child: TextFormField(
                              decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: "Ketik untuk cari..."),
                              onChanged: (value) {
                                setState(() {
                                  searchQuery = value.toLowerCase();
                                });
                              },
                            ),
                          ),
                          Spacer(),
                          Icon(
                            Icons.search,
                            size: 27,
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
              Container(
                alignment: Alignment.centerLeft,
                margin: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Daftar Produk",
                        style: sixTextStyle.copyWith(fontSize: 18)),
                    ElevatedButton(
                      onPressed: () {
                        showCreateProductModal(context);
                      },
                      style: ElevatedButton.styleFrom(
                        shape: CircleBorder(),
                        padding: EdgeInsets.all(10),
                        backgroundColor: fourthColor,
                      ),
                      child: Icon(
                        Icons.add,
                        color: Colors.white,
                      ),
                    )
                  ],
                ),
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
