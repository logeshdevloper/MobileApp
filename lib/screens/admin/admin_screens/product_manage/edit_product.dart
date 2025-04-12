import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import '../../../../utilis/constant.dart';

class EditProduct extends StatefulWidget {
  final int index;
  const EditProduct({Key? key, required this.index}) : super(key: key);

  @override
  _EditProductState createState() => _EditProductState();
}

class _EditProductState extends State<EditProduct> {
  final _formKey = GlobalKey<FormState>();
  final _originalPriceKey = GlobalKey<FormFieldState>();
  final _scrollController = ScrollController();
  bool isLoading = false;

  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _discountPriceController = TextEditingController();
  final _categoryController = TextEditingController();
  final _stockController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _deliveryTimeController = TextEditingController();

  String? _image;
  String? _imageFile;
  String? _categoryId;

  List<Map<String, dynamic>> categories = [];
  List<Map<String, dynamic>> deliveryTimes = [
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
  int? _deliveryTimeInMinutes;

  @override
  void initState() {
    super.initState();
    // Important: First fetch categories, then load product details
    fetchCategories().then((_) => _loadProduct());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _discountPriceController.dispose();
    _categoryController.dispose();
    _stockController.dispose();
    _descriptionController.dispose();
    _deliveryTimeController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

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

  Future<void> _loadProduct() async {
    setState(() => isLoading = true);
    try {
      final response =
          await http.get(Uri.parse('$rOOT/edit-product/${widget.index}'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['product'];
        setState(() {
          _nameController.text = data['name'] ?? '';
          _priceController.text = data['price']?.toString() ?? '';
          _discountPriceController.text = data['sell_price']?.toString() ?? '';

          // Set category information
          final categoryName = data['category'] ?? '';
          _categoryController.text = categoryName;

          // Try to find category ID from category name
          if (categories.isNotEmpty) {
            final categoryMatch = categories.firstWhere(
              (cat) => cat['name'] == categoryName,
              orElse: () => {'id': null, 'name': categoryName},
            );
            _categoryId = categoryMatch['id']?.toString();
          } else {
            // If categories aren't loaded yet, store the ID directly
            _categoryId = data['category_id']?.toString();
          }

          _stockController.text = data['stock']?.toString() ?? '';
          _descriptionController.text = data['description'] ?? '';

          // Handle delivery time
          if (data['delivery_time'] != null) {
            _deliveryTimeInMinutes =
                int.tryParse(data['delivery_time'].toString());
            // Find matching delivery time label
            final deliveryTime = deliveryTimes.firstWhere(
              (time) => time['minutes'] == _deliveryTimeInMinutes,
              orElse: () =>
                  {'label': 'Custom', 'minutes': _deliveryTimeInMinutes},
            );
            _deliveryTimeController.text = deliveryTime['label'].toString();
          }

          _image = data['img_url'];
        });
      } else {
        throw Exception('Failed to load product');
      }
    } catch (e) {
      _showErrorSnackBar('Failed to load product details');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (pickedFile != null) {
        setState(() => _imageFile = pickedFile.path);
      }
    } catch (e) {
      _showErrorSnackBar('Failed to pick image');
    }
  }

  Future<void> _updateProduct() async {
    if (!_formKey.currentState!.validate()) {
      _showErrorSnackBar('Please fill all required fields');
      return;
    }

    setState(() => isLoading = true);

    try {
      String? base64Image;
      if (_imageFile != null) {
        final imageBytes = await File(_imageFile!).readAsBytes();
        base64Image = base64Encode(imageBytes);
      }

      final response = await http.post(
        Uri.parse('$rOOT/edit-product/${widget.index}'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "name": _nameController.text,
          "price": _priceController.text,
          "sell_price": _discountPriceController.text,
          "category": _categoryController.text,
          "category_id": _categoryId,
          "stock": _stockController.text,
          "description": _descriptionController.text,
          "delivery_time": _deliveryTimeInMinutes,
          "image": base64Image ?? _image,
        }),
      );

      if (response.statusCode == 200) {
        _showSuccessSnackBar('Product updated successfully');
        Navigator.pop(context, true);
      } else {
        throw Exception('Failed to update product');
      }
    } catch (e) {
      _showErrorSnackBar('Failed to update product: ${e.toString()}');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required String hint,
    bool isNumber = false,
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
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Theme.of(context).primaryColor),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
          maxLines: maxLines,
          keyboardType: keyboardType ??
              (isNumber ? TextInputType.number : TextInputType.text),
          key: key,
          validator: validator ??
              (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'This field is required';
                }
                if (isNumber && double.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                return null;
              },
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
          ],
        ),
        const SizedBox(height: 8),
        // Only show the dropdown if categories have been loaded
        categories.isEmpty
            ? TextFormField(
                controller: _categoryController,
                decoration: InputDecoration(
                  hintText: 'Category name',
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        BorderSide(color: Theme.of(context).primaryColor),
                  ),
                  contentPadding: const EdgeInsets.all(16),
                  prefixIcon: const Icon(Icons.category),
                  suffixIcon:
                      const Icon(Icons.error_outline, color: Colors.orange),
                ),
                readOnly: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Category is required';
                  }
                  return null;
                },
              )
            : DropdownButtonFormField<String>(
                value: _categoryId,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        BorderSide(color: Theme.of(context).primaryColor),
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
                  if (newValue != null) {
                    setState(() {
                      _categoryId = newValue;
                      final selectedCategory = categories.firstWhere(
                        (cat) => cat['id'].toString() == newValue,
                        orElse: () => {'name': ''},
                      );
                      _categoryController.text =
                          selectedCategory['name'].toString();
                    });
                  }
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
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Theme.of(context).primaryColor),
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
            setState(() {
              _deliveryTimeInMinutes = newValue;
              final deliveryTime = deliveryTimes.firstWhere(
                (time) => time['minutes'] == newValue,
                orElse: () => {'label': 'Custom', 'minutes': newValue},
              );
              _deliveryTimeController.text = deliveryTime['label'].toString();
            });
          },
          validator: (value) {
            if (value == null) {
              return 'Please select delivery time';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Product'),
        elevation: 1,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: Scrollbar(
                controller: _scrollController,
                child: SingleChildScrollView(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Product Information',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                _buildInputField(
                                  label: 'Product Name',
                                  controller: _nameController,
                                  hint: 'Enter product name',
                                ),
                                _buildInputField(
                                  label: 'Original Price',
                                  controller: _priceController,
                                  hint: 'Enter original price',
                                  isNumber: true,
                                  key: _originalPriceKey,
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
                                  controller: _discountPriceController,
                                  hint: 'Enter discount price',
                                  isNumber: true,
                                  keyboardType: TextInputType.number,
                                  validator: (val) {
                                    if (val == null || val.isEmpty)
                                      return 'Required field';
                                    if (double.tryParse(val) == null)
                                      return 'Please enter a valid number';

                                    final originalPrice = _priceController.text;
                                    if (originalPrice.isNotEmpty &&
                                        double.tryParse(originalPrice) !=
                                            null &&
                                        double.parse(val) >=
                                            double.parse(originalPrice)) {
                                      return 'Discount price must be less than original price';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Category & Delivery',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                _buildCategoryField(),
                                _buildDeliveryTimeField(),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Stock & Description',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                _buildInputField(
                                  label: 'Stock',
                                  controller: _stockController,
                                  hint: 'Enter stock quantity',
                                  isNumber: true,
                                ),
                                _buildInputField(
                                  label: 'Description',
                                  controller: _descriptionController,
                                  hint: 'Enter product description',
                                  maxLines: 3,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Product Image',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                if (_imageFile != null)
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.file(
                                      File(_imageFile!),
                                      height: 200,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                else if (_image != null && _image!.isNotEmpty)
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.network(
                                      _image!,
                                      height: 200,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      loadingBuilder:
                                          (context, child, loadingProgress) {
                                        if (loadingProgress == null)
                                          return child;
                                        return SizedBox(
                                          height: 200,
                                          child: Center(
                                            child: CircularProgressIndicator(
                                              value: loadingProgress
                                                          .expectedTotalBytes !=
                                                      null
                                                  ? loadingProgress
                                                          .cumulativeBytesLoaded /
                                                      loadingProgress
                                                          .expectedTotalBytes!
                                                  : null,
                                            ),
                                          ),
                                        );
                                      },
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return Container(
                                          height: 200,
                                          width: double.infinity,
                                          color: Colors.grey[200],
                                          child: const Center(
                                            child: Icon(
                                                Icons.image_not_supported,
                                                size: 50),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                const SizedBox(height: 16),
                                Center(
                                  child: ElevatedButton.icon(
                                    onPressed: _pickImage,
                                    icon: const Icon(Icons.upload),
                                    label: const Text('Change Image'),
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 24, vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _updateProduct,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'Update Product',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
