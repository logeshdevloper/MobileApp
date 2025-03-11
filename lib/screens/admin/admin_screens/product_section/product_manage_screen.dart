import 'dart:convert'; // Add this to handle JSON decoding
import 'package:flutter/material.dart';
import '../../../../utilis/constant.dart';
import '../product_manage/edit_product.dart';
import 'product_cards.dart';
import 'package:http/http.dart' as http;
import '../product_manage/add_product.dart'; // Import your product card widget

class ProductManagementScreen extends StatefulWidget {
  const ProductManagementScreen({Key? key}) : super(key: key);

  @override
  State<ProductManagementScreen> createState() =>
      _ProductManagementScreenState();
}

class _ProductManagementScreenState extends State<ProductManagementScreen> {
  List<Map<String, dynamic>> products = [];

  // Handle Add Product
  void _addProduct() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => Addproduct()));
  }

  // Handle Edit Product
  void _editProduct(int index) {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => EditProduct(index: index)));
  }

  // Handle Delete Product
  Future<void> _confirmDeleteProduct(int id) async {
    final bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content: const Text('Are you sure you want to delete this product?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmDelete == true) {
      deleteProduct(id);
    }
  }

  Future<void> deleteProduct(index) async {
    try {
      final res = await http.delete(Uri.parse('$rOOT/delete_product/$index'));

      if (res.statusCode == 200) {
        getproducts();
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    getproducts(); // Fetch products when the screen loads
  }

  // Fetch products from the API
  Future<void> getproducts() async {
    try {
      final res = await http.get(Uri.parse('${rOOT}get_product'));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body); // Parse the JSON response

        setState(() {
          products =
              List<Map<String, dynamic>>.from(data['products'].map((product) {
            return {
              'name': product['name'] ?? 'No Name',
              'price': product['price'].toString() ?? '0.0',
              'id':
                  product['id'] ?? 0, // Assuming 'id' is a part of the product
              // Add any other fields you need here
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Management'),
        automaticallyImplyLeading: false,
      ),
      body: products.isEmpty
          ? const Center(
              child:
                  CircularProgressIndicator()) // Show loading while fetching data
          : ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                return ProductCard(
                  name: products[index]['name']!,
                  price: products[index]['price']!,
                  onEdit: () => _editProduct(products[index]['id']),
                  onDelete: () => _confirmDeleteProduct(products[index]['id']),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addProduct,
        child: const Icon(Icons.add),
        tooltip: 'Add Product',
      ),
    );
  }
}
