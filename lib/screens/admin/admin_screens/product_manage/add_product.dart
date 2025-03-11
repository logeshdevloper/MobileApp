import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

import '../../../../utilis/constant.dart';

class Addproduct extends StatefulWidget {
  const Addproduct({super.key});

  @override
  State<Addproduct> createState() => _AddproductState();
}

class _AddproductState extends State<Addproduct> {
  final _formKey = GlobalKey<FormState>();
  final _originalPriceKey = GlobalKey<FormFieldState>();
  final _categoryFormKey = GlobalKey<FormState>();
  final _categoryController = TextEditingController();

  String? _name,
      _price,
      _discountPrice,
      _category,
      _description,
      _stock,
      _image,
      _deliveryTime;
  bool isLoading = false;
  List<String> categories = [];

  final List<String> deliveryTimes = [
    '1-2 days',
    '2-3 days',
    '3-4 days',
    '4-5 days',
    '5-7 days',
    '7-10 days',
    '10-15 days',
    '15-20 days',
    '20-30 days',
    '30+ days'
  ];

  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    try {
      final response = await http.get(Uri.parse('${rOOT}get_categories'));

      print(jsonDecode(response.body));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['categories'] != null) {
          setState(() {
            categories = List<String>.from(data['categories']
                .map((category) => category['name'].toString()));
          });
        } else {
          print('Categories data is null');
          setState(() {
            categories = [];
          });
        }
      }
    } catch (e) {
      print('Error fetching categories: $e');
      setState(() {
        categories = [];
      });
    }
  }

  Future<void> addCategory() async {
    if (!_categoryFormKey.currentState!.validate()) return;

    try {
      final response = await http.post(
        Uri.parse('${rOOT}add_category'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'category': _categoryController.text,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Category added successfully')),
        );
        _categoryController.clear();
        Navigator.pop(context);
        fetchCategories();
      } else {
        throw Exception('Failed to add category');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _showAddCategoryDialog() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Category'),
        content: Form(
          key: _categoryFormKey,
          child: TextFormField(
            controller: _categoryController,
            decoration: const InputDecoration(
              labelText: 'Category Name',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter a category name';
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: addCategory,
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _uploadImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _image = pickedFile.path);
    }
  }

  Widget _buildInputField({
    required String label,
    required String hint,
    required Function(String?) onSaved,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    GlobalKey<FormFieldState>? key,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
          maxLines: maxLines,
          keyboardType: keyboardType,
          onSaved: onSaved,
          validator: validator ??
              (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'This field is required';
                }
                return null;
              },
          key: key,
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildCategoryField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Category',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            TextButton.icon(
              onPressed: _showAddCategoryDialog,
              icon: const Icon(Icons.add),
              label: const Text('Add Category'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _category,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
          hint: const Text('Select category'),
          items: categories.map((String category) {
            return DropdownMenuItem<String>(
              value: category,
              child: Text(category),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              _category = newValue;
            });
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select a category';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildDeliveryTimeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Delivery Time',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _deliveryTime,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
          hint: const Text('Select delivery time'),
          items: deliveryTimes.map((String time) {
            return DropdownMenuItem<String>(
              value: time,
              child: Text(time),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              _deliveryTime = newValue;
            });
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select delivery time';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      _formKey.currentState!.save();

      final imageBytes = await File(_image!).readAsBytes();
      final base64Image = base64Encode(imageBytes);

      final response = await http.post(
        Uri.parse('${rOOT}add-product'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': _name,
          'price': _price,
          'sell_price': _discountPrice,
          'category': _category,
          'stock': _stock,
          'description': _description,
          'image': base64Image,
          'delivery_time': _deliveryTime,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Product added successfully")));

        _formKey.currentState!.reset();
        setState(() {
          _image = null;
          _name = _price = _discountPrice =
              _category = _stock = _description = _deliveryTime = '';
        });
      } else {
        throw Exception('Failed to add product');
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Product"),
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInputField(
                        label: 'Product Name',
                        hint: 'Enter product name',
                        onSaved: (val) => _name = val,
                      ),
                      _buildInputField(
                        key: _originalPriceKey,
                        label: 'Original Price',
                        hint: 'Enter original price',
                        onSaved: (val) => _price = val,
                        keyboardType: TextInputType.number,
                        validator: (val) {
                          if (val == null || val.isEmpty) {
                            return 'Required field';
                          }
                          if (double.tryParse(val) == null) {
                            return 'Please enter a valid number';
                          }
                          return null;
                        },
                      ),
                      _buildInputField(
                        label: 'Discount Price',
                        hint: 'Enter discount price',
                        onSaved: (val) => _discountPrice = val,
                        keyboardType: TextInputType.number,
                        validator: (val) {
                          if (val == null || val.isEmpty)
                            return 'Required field';
                          if (double.tryParse(val) == null)
                            return 'Please enter a valid number';

                          final originalPrice =
                              _originalPriceKey.currentState?.value as String?;

                          if (originalPrice != null &&
                              double.tryParse(originalPrice) != null &&
                              double.parse(val) >=
                                  double.parse(originalPrice)) {
                            return 'Discount price must be less than original price';
                          }
                          return null;
                        },
                      ),
                      _buildCategoryField(),
                      _buildDeliveryTimeField(),
                      _buildInputField(
                        label: 'Stock',
                        hint: 'Enter stock quantity',
                        onSaved: (val) => _stock = val,
                        keyboardType: TextInputType.number,
                      ),
                      _buildInputField(
                        label: 'Description',
                        hint: 'Enter product description',
                        onSaved: (val) => _description = val,
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: Column(
                          children: [
                            if (_image != null)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(
                                  File(_image!),
                                  height: 200,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: _uploadImage,
                              icon: const Icon(Icons.upload),
                              label: Text(_image == null
                                  ? 'Upload Image'
                                  : 'Change Image'),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _submitForm,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Add Product',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
