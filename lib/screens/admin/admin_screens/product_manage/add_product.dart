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
  final _deliveryTimeController = TextEditingController();
  final _scrollController = ScrollController();

  String? _name,
      _price,
      _discountPrice,
      _category,
      _description,
      _stock,
      _image;
  int? _deliveryTimeInMinutes;
  String? _categoryId;
  bool isLoading = false;
  bool isRefreshing = false;
  List<Map<String, dynamic>> categories = [];
  List<Map<String, dynamic>> products = [];

  final List<Map<String, dynamic>> deliveryTimes = [
    {'label': '30 minutes', 'minutes': 30},
    {'label': '1 hour', 'minutes': 60},
    {'label': '2 hours', 'minutes': 120},
    {'label': '3 hours', 'minutes': 180},
    {'label': '4 hours', 'minutes': 240},
    {'label': '6 hours', 'minutes': 360},
    {'label': '8 hours', 'minutes': 480},
    {'label': '12 hours', 'minutes': 720},
    {'label': '24 hours', 'minutes': 1440},
    {'label': '36 hours', 'minutes': 2160},
    {'label': '48 hours', 'minutes': 2880},
  ];

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade400,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green.shade400,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    fetchCategories();
    fetchProducts();
  }

  Future<void> fetchCategories() async {
    try {
      final response = await http.get(Uri.parse('${rOOT}get_categories'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['categories'] != null) {
          setState(() {
            categories = List<Map<String, dynamic>>.from(data['categories']);
          });
        }
      }
    } catch (e) {
      _showErrorSnackBar('Failed to load categories');
    }
  }

  Future<void> fetchProducts() async {
    try {
      setState(() {
        isRefreshing = true;
      });

      final response = await http.get(Uri.parse('${rOOT}get_product'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['products'] != null) {
          setState(() {
            products = List<Map<String, dynamic>>.from(data['products']);
          });
        }
      } else {
        throw Exception('Failed to load products');
      }
    } catch (e) {
      _showErrorSnackBar('Failed to load products');
    } finally {
      setState(() {
        isRefreshing = false;
      });
    }
  }

  Future<void> _onRefresh() async {
    await Future.wait([
      fetchCategories(),
      fetchProducts(),
    ]);
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
        _showSuccessSnackBar('Category added successfully');
        _categoryController.clear();
        Navigator.pop(context);
        fetchCategories();
      } else {
        throw Exception('Failed to add category');
      }
    } catch (e) {
      _showErrorSnackBar('Failed to add category');
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
          value: _categoryId,
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
          items: categories.map((category) {
            return DropdownMenuItem<String>(
              value: category['id'].toString(),
              child: Text(category['name'].toString()),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              _categoryId = newValue;
              _category = categories
                  .firstWhere((cat) => cat['id'].toString() == newValue)['name']
                  .toString();
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
        DropdownButtonFormField<int>(
          value: _deliveryTimeInMinutes,
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
          items: deliveryTimes.map((time) {
            return DropdownMenuItem<int>(
              value: time['minutes'] as int,
              child: Text(time['label'] as String),
            );
          }).toList(),
          onChanged: (int? newValue) {
            print(newValue);
            setState(() {
              _deliveryTimeInMinutes = newValue;
            });
          },
          validator: (value) {
            if (value == null) {
              return 'Please select delivery time';
            }
            if (value < 30) {
              return 'Minimum delivery time is 30 minutes';
            }
            if (value > 2880) {
              return 'Maximum delivery time is 48 hours';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      _showErrorSnackBar('Please fill all required fields');
      return;
    }

    setState(() => isLoading = true);

    try {
      _formKey.currentState!.save();

      if (_image == null) {
        _showErrorSnackBar('Please select an image');
        setState(() => isLoading = false);
        return;
      }

      if (_deliveryTimeInMinutes == null) {
        _showErrorSnackBar('Please select delivery time');
        setState(() => isLoading = false);
        return;
      }

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
          'category_id': _categoryId,
          'stock': _stock,
          'description': _description,
          'image': base64Image,
          'delivery_time': _deliveryTimeInMinutes
        }),
      );

      if (response.statusCode == 200) {
        _showSuccessSnackBar('Product added successfully');
        _formKey.currentState!.reset();
        setState(() {
          _image = null;
          _name =
              _price = _discountPrice = _category = _stock = _description = '';
          _categoryId = null;
          _deliveryTimeInMinutes = null;
        });
      } else {
        throw Exception('Failed to add product');
      }
    } catch (e) {
      _showErrorSnackBar('Failed to add product');
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
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _onRefresh,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : GestureDetector(
                onTap: () => FocusScope.of(context).unfocus(),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Form(
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

                                final originalPrice = _originalPriceKey
                                    .currentState?.value as String?;

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
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
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
                      if (products.isNotEmpty) ...[
                        const SizedBox(height: 32),
                        const Text(
                          'Recent Products',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: products.length > 5 ? 5 : products.length,
                          itemBuilder: (context, index) {
                            final product = products[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: ListTile(
                                leading: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    product['image_url'] ?? '',
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            Container(
                                      width: 50,
                                      height: 50,
                                      color: Colors.grey[200],
                                      child: const Icon(Icons.image),
                                    ),
                                  ),
                                ),
                                title: Text(
                                  product['name'] ?? 'No name',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(
                                  'Price: \$${product['price'] ?? '0.00'}\nStock: ${product['stock'] ?? '0'}',
                                ),
                                trailing: Text(
                                  product['category'] ?? 'No category',
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
