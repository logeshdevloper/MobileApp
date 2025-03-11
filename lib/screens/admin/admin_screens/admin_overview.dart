import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pops/common/styles/color.dart';
import '../../../common/widgets/cardUi.dart';
import '../../../utilis/constant.dart';

class AdminOverview extends StatefulWidget {
  const AdminOverview({super.key});

  @override
  State<AdminOverview> createState() => _AdminOverviewState();
}

class _AdminOverviewState extends State<AdminOverview> {
  bool isDark = false;
  List<Map<String, dynamic>> products = [];
  List<String> categories = [];
  String selectedCategory = "All";

  @override
  void initState() {
    super.initState();
    fetchProducts();
    fetchCategories();
  }

  Future<void> fetchProducts() async {
    try {
      final response = await http.get(Uri.parse('$rOOT/get_product'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          products =
              List<Map<String, dynamic>>.from(data['products'].map((product) {
            return {
              'id': product['id']?.toString() ?? '',
              'name': product['name'] ?? '',
              'category': product['category']?.toString() ?? '',
              'price': product['price']?.toString() ?? '0',
              'sell_price': product['sell_price']?.toString() ?? '0',
              'stock': product['stock']?.toString() ?? '0',
              'img_url': product['img_url'] ?? '',
              'description': product['description'] ?? '',
            };
          }));
        });
      } else {
        print('Failed to load products');
      }
    } catch (e) {
      print('Error fetching products: $e');
    }
  }

  Future<void> fetchCategories() async {
    try {
      final response = await http.get(Uri.parse('$rOOT/get_categories'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          categories = ["All", ...List<String>.from(data['categories'])];
        });
      } else {
        print('Failed to load categories');
      }
    } catch (e) {
      print('Error fetching categories: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeData = ThemeData(
      useMaterial3: true,
      brightness: isDark ? Brightness.dark : Brightness.light,
      primaryColor: isDark ? Colors.orangeAccent : primaryColor,
      scaffoldBackgroundColor: isDark ? Colors.black : Colors.white,
      textTheme: TextTheme(
        bodyMedium: TextStyle(color: isDark ? Colors.white : Colors.black),
      ),
    );

    List<Map<String, dynamic>> filteredProducts = selectedCategory == "All"
        ? products
        : products.where((p) => p['category'] == selectedCategory).toList();

    return MaterialApp(
      theme: themeData,
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Text("Home"),
          actions: [
            IconButton(
              icon: Icon(isDark ? Icons.wb_sunny : Icons.nightlight_round),
              onPressed: () {
                setState(() {
                  isDark = !isDark;
                });
              },
            )
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 3.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Bar
              TextField(
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: "Search products...",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              SizedBox(height: 16),
              // Category Horizontal List
              SizedBox(
                height: 50,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: categories.map((category) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: ChoiceChip(
                        label: Text(category),
                        selected: selectedCategory == category,
                        onSelected: (selected) {
                          setState(() {
                            selectedCategory = category;
                          });
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
              SizedBox(height: 16),
              // Products Grid with Independent X and Y Scroll
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: categories.map((category) {
                      if (category == "All") return SizedBox();
                      var categoryProducts = products
                          .where((p) => p['category'] == category)
                          .toList();
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Text(
                              category,
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          ),
                          SizedBox(
                            height: 340, // Increased height to accommodate card
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: categoryProducts.length,
                              itemBuilder: (context, index) {
                                var item = categoryProducts[index];
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: CustomCard(
                                    image: item['img_url'],
                                    title: item['name'],
                                    category: item['category'],
                                    itemsCount: item['stock'],
                                    price: item['price'],
                                    sellPrice: item['sell_price'],
                                  ),
                                );
                              },
                            ),
                          ),
                          SizedBox(
                              height: 8), // Added spacing between categories
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
