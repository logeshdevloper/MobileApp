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

  final List<bool> _isExpanded = [true, true, false, true];

  String? _name,
      _price,
      _discountPrice,
      _category,
      _description,
      _stock,
      _image,
      _brandName,
      _isReturnable,
      _deliveryCharge,
      _tags,
      _variantName,
      _variantOptions;
  int? _deliveryTimeInMinutes;
  String? _categoryId;
  bool isLoading = false;
  bool isRefreshing = false;
  bool _addVariants = false;
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

  @override
  void dispose() {
    _scrollController.dispose();
    _categoryController.dispose();
    _deliveryTimeController.dispose();
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Add Product',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w500,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: Stack(
        children: [
          Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 80),
              child: ListView(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                children: [
                  _buildSection(
                    index: 0,
                    title: "Step 1: Basic Info",
                    child: Column(
                      children: [
                        const SizedBox(height: 16),
                        _buildInputField(
                          label: "Product Name",
                          hint: "Enter product name",
                          onSaved: (value) => _name = value,
                        ),
                        _buildInputField(
                          label: "Description",
                          hint: "Enter product description",
                          onSaved: (value) => _description = value,
                          maxLines: 5,
                        ),
                        _buildInputField(
                          label: "Category",
                          hint: "Select category",
                          onSaved: (value) => _category = value,
                        ),
                        _buildInputField(
                          label: "Brand Name",
                          hint: "Enter brand name",
                          onSaved: (value) => _brandName = value,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildSection(
                    index: 1,
                    title: "Step 2: Price & Stock",
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            SizedBox(
                              width: 24,
                              height: 24,
                              child: Checkbox(
                                value: _addVariants,
                                onChanged: (value) {
                                  setState(() {
                                    _addVariants = value ?? false;
                                  });
                                },
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                side: BorderSide(
                                  color: Colors.grey.shade400,
                                  width: 1.5,
                                ),
                                activeColor: Theme.of(context).primaryColor,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              "Add Variants?",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        if (_addVariants) ...[
                          _buildInputField(
                            label: "Variant Name",
                            hint: "Size, Color, etc.",
                            onSaved: (value) => _variantName = value,
                          ),
                          _buildInputField(
                            label: "Options",
                            hint: "S,M,L or Red,Blue",
                            onSaved: (value) => _variantOptions = value,
                          ),
                        ],
                        _buildInputField(
                          label: "Price per",
                          hint: "Enter price",
                          keyboardType: TextInputType.number,
                          onSaved: (value) => _price = value,
                        ),
                        _buildInputField(
                          label: "Original Price",
                          hint: "Enter original price",
                          keyboardType: TextInputType.number,
                          onSaved: (value) => _price = value,
                          key: _originalPriceKey,
                        ),
                        _buildInputField(
                          label: "Discounted Price",
                          hint: "Enter discounted price (optional)",
                          keyboardType: TextInputType.number,
                          onSaved: (value) => _discountPrice = value,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return null; // Optional field
                            }
                            return null;
                          },
                        ),
                        _buildInputField(
                          label: "Stock Quantity",
                          hint: "Enter quantity",
                          keyboardType: TextInputType.number,
                          onSaved: (value) => _stock = value,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildSection(
                    index: 2,
                    title: "Step 3: Product Details",
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        _buildInputField(
                          label: "Material",
                          hint: "Enter material",
                          onSaved: (value) {},
                        ),
                        _buildInputField(
                          label: "Weight",
                          hint: "Enter weight",
                          keyboardType: TextInputType.number,
                          onSaved: (value) {},
                        ),
                        _buildInputField(
                          label: "Dimensions",
                          hint: "Length x Width x Height",
                          onSaved: (value) {},
                        ),
                        _buildInputField(
                          label: "Country of Origin",
                          hint: "Enter country",
                          onSaved: (value) {},
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildSection(
                    index: 3,
                    title: "Step 4: Images",
                    child: _buildImageUploader(),
                  ),
                  const SizedBox(height: 16),
                  _buildSection(
                    index: 4,
                    title: "Step 5: Delivery & Others",
                    child: Column(
                      children: [
                        const SizedBox(height: 16),
                        _buildInputField(
                          label: "Delivery Time Estimate",
                          hint: "e.g., 2-3 days",
                          onSaved: (value) {},
                        ),
                        _buildInputField(
                          label: "Is Returnable?",
                          hint: "Yes/No",
                          onSaved: (value) => _isReturnable = value,
                        ),
                        _buildInputField(
                          label: "Return Policy",
                          hint: "Enter return policy details",
                          maxLines: 2,
                          onSaved: (value) {},
                        ),
                        _buildInputField(
                          label: "Delivery Charge",
                          hint: "Enter amount",
                          keyboardType: TextInputType.number,
                          onSaved: (value) => _deliveryCharge = value,
                        ),
                        _buildInputField(
                          label: "Tags",
                          hint: "Separate with commas",
                          onSaved: (value) => _tags = value,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
          _buildBottomButtons(),
        ],
      ),
    );
  }

  Widget _buildSection({
    required int index,
    required String title,
    required Widget child,
  }) {
    if (_isExpanded.length <= index) {
      final int additionalItems = index - _isExpanded.length + 1;
      _isExpanded.addAll(List.generate(additionalItems, (_) => false));
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300, width: 1),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
        ),
        child: ExpansionTile(
          initiallyExpanded: _isExpanded[index],
          onExpansionChanged: (expanded) {
            setState(() {
              _isExpanded[index] = expanded;
            });
          },
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          title: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          children: [child],
        ),
      ),
    );
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
        if (label.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
        TextFormField(
          decoration: InputDecoration(
            hintText: hint,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade500, width: 1.5),
            ),
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

  Widget _buildCategorySelector() {
    return _buildInputField(
      label: "Category",
      hint: "Select category",
      onSaved: (value) => _category = value,
    );
  }

  Widget _buildImageUploader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        GestureDetector(
          onTap: _uploadImage,
          child: Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300, width: 1),
            ),
            child: _image != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      File(_image!),
                      fit: BoxFit.cover,
                    ),
                  )
                : const Center(
                    child: Text(
                      "Tap to upload image",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomButtons() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  // Save as draft logic
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.transparent,
                  side: BorderSide(color: Colors.grey.shade300, width: 1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  foregroundColor: Colors.black87,
                ),
                child: const Text(
                  "Save as Draft",
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton(
                onPressed: isLoading ? null : addProduct,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.transparent,
                  side: BorderSide(color: Colors.grey.shade300, width: 1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  foregroundColor: Colors.black87,
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.black54,
                        ),
                      )
                    : const Text(
                        "Save Product",
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.transparent,
                  side: BorderSide(color: Colors.grey.shade300, width: 1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  foregroundColor: Colors.red,
                ),
                child: const Text(
                  "Cancel",
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                    color: Colors.red,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> addProduct() async {
    if (!_formKey.currentState!.validate()) return;

    _formKey.currentState!.save();

    if (_image == null) {
      _showErrorSnackBar('Please select an image');
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final request =
          http.MultipartRequest('POST', Uri.parse('${rOOT}add_product'));

      // Add text fields
      request.fields['name'] = _name!;
      request.fields['price'] = _price!;
      if (_discountPrice != null && _discountPrice!.isNotEmpty) {
        request.fields['discountPrice'] = _discountPrice!;
      }
      request.fields['category'] = _category!;
      request.fields['description'] = _description!;
      request.fields['stock'] = _stock!;
      request.fields['deliveryTimeInMinutes'] =
          _deliveryTimeInMinutes.toString();

      // Add image
      final file = await http.MultipartFile.fromPath('image', _image!);
      request.files.add(file);

      final response = await request.send();
      final responseData = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        _showSuccessSnackBar('Product added successfully');
        Navigator.pop(context);
      } else {
        final errorData = jsonDecode(responseData);
        throw Exception(errorData['message'] ?? 'Failed to add product');
      }
    } catch (e) {
      _showErrorSnackBar(e.toString());
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }
}
