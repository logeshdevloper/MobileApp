import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:dotted_border/dotted_border.dart';

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

  // Add TextEditingControllers for all form fields
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _discountPriceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _stockController = TextEditingController();
  final _brandNameController = TextEditingController();
  final _isReturnableController = TextEditingController();
  final _deliveryChargeController = TextEditingController();
  final _tagsController = TextEditingController();
  final _variantNameController = TextEditingController();
  final _variantOptionsController = TextEditingController();
  final _materialController = TextEditingController();
  final _weightController = TextEditingController();
  final _dimensionsController = TextEditingController();
  final _countryOfOriginController = TextEditingController();
  final _returnPolicyController = TextEditingController();

  final List<bool> _isExpanded = [true, true, false, true];

  String? _name,
      _price,
      _discountPrice,
      _description,
      _stock,
      _image,
      _brandName,
      _isReturnable = "No",
      _deliveryCharge,
      _tags,
      _variantName,
      _variantOptions;
  int? _deliveryTimeInMinutes;
  String? _categoryId;
  String? _categoryName; // For display purposes only
  bool isLoading = false;
  bool isRefreshing = false;
  bool _addVariants = false;
  List<Map<String, dynamic>> categories = [];
  List<Map<String, dynamic>> products = [];

  // Add a field to track if at least one product detail is filled
  bool _hasProductDetail = false;

  // Add additional fields for product details
  String? _material, _weight, _dimensions, _countryOfOrigin;

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

    // Set default category
    if (categories.isNotEmpty) {
      _categoryId = categories[0]['id'];
      _categoryName = categories[0]['name'];
      _categoryController.text = _categoryName ?? '';
    }

    fetchCategories();
    fetchProducts();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _categoryController.dispose();
    _deliveryTimeController.dispose();

    // Dispose all TextEditingControllers
    _nameController.dispose();
    _priceController.dispose();
    _discountPriceController.dispose();
    _descriptionController.dispose();
    _stockController.dispose();
    _brandNameController.dispose();
    _isReturnableController.dispose();
    _deliveryChargeController.dispose();
    _tagsController.dispose();
    _variantNameController.dispose();
    _variantOptionsController.dispose();
    _materialController.dispose();
    _weightController.dispose();
    _dimensionsController.dispose();
    _countryOfOriginController.dispose();
    _returnPolicyController.dispose();

    super.dispose();
  }

  Future<void> fetchCategories() async {
    try {
      final response = await http.get(Uri.parse('${rOOT}get_categories'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['categories'] != null) {
          final apiCategories =
              List<Map<String, dynamic>>.from(data['categories']);

          // Extract current category names to avoid duplicates
          final Set<String> existingCategoryNames = {};
          for (var category in categories) {
            existingCategoryNames
                .add((category['name'] ?? '').toString().toLowerCase());
          }

          // Add non-duplicate categories from API
          for (var apiCategory in apiCategories) {
            final name = (apiCategory['name'] ?? '').toString().toLowerCase();
            if (name.isNotEmpty && !existingCategoryNames.contains(name)) {
              categories.add(apiCategory);
            }
          }

          setState(() {
            // Sort categories alphabetically
            categories.sort((a, b) => (a['name'] ?? '')
                .toString()
                .compareTo((b['name'] ?? '').toString()));
          });
        }
      }
    } catch (e) {
      print('Failed to load categories: $e');
      // Keep using default categories if API fails
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
        // Try to extract the category ID from the response
        String? newCategoryId;
        try {
          final data = jsonDecode(response.body);
          if (data['id'] != null) {
            newCategoryId = data['id'].toString();
          } else if (data['category'] != null &&
              data['category']['id'] != null) {
            newCategoryId = data['category']['id'].toString();
          }
        } catch (_) {
          // If we can't extract ID from response, generate a temporary one
          newCategoryId = 'temp_${DateTime.now().millisecondsSinceEpoch}';
        }

        // Add the new category to our local list
        final newCategory = {
          'id': newCategoryId,
          'name': _categoryController.text,
        };

        setState(() {
          categories.add(newCategory);
          // Select the newly created category
          _categoryName = newCategory['name'];
          _categoryId = newCategory['id'];
        });

        _showSuccessSnackBar('Category added successfully');
        _categoryController.clear();
        Navigator.pop(context);
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
            color: Colors.black,
            fontWeight: FontWeight.normal,
            fontSize: 16,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2),
          child: Container(
            height: 2,
            color: Colors.teal,
            width: MediaQuery.of(context).size.width * 0.2,
            margin: EdgeInsets.only(
              left: MediaQuery.of(context).size.width * 0.1,
            ),
          ),
        ),
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
                  _buildBasicSection(
                    title: "Step 1: Basic Info",
                    isExpanded: _isExpanded[0],
                    onExpansionChanged: (expanded) {
                      setState(() {
                        _isExpanded[0] = expanded;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildBasicSection(
                    title: "Step 2: Price & Stock",
                    isExpanded: _isExpanded[1],
                    onExpansionChanged: (expanded) {
                      setState(() {
                        _isExpanded[1] = expanded;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildBasicSection(
                    title: "Step 3: Product Details",
                    isExpanded: _isExpanded[2],
                    onExpansionChanged: (expanded) {
                      setState(() {
                        _isExpanded[2] = expanded;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildBasicSection(
                    title: "Step 4: Images",
                    isExpanded: _isExpanded[3],
                    onExpansionChanged: (expanded) {
                      setState(() {
                        _isExpanded[3] = expanded;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildBasicSection(
                    title: "Step 5: Delivery & Others",
                    isExpanded: _isExpanded.length > 4 ? _isExpanded[4] : false,
                    onExpansionChanged: (expanded) {
                      if (_isExpanded.length <= 4) {
                        _isExpanded.add(expanded);
                      } else {
                        setState(() {
                          _isExpanded[4] = expanded;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
          _buildBasicBottomButtons(),
        ],
      ),
    );
  }

  Widget _buildBasicSection({
    required String title,
    required bool isExpanded,
    required Function(bool) onExpansionChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: ListTileTheme(
        dense: false,
        child: ExpansionTile(
          initiallyExpanded: isExpanded,
          onExpansionChanged: onExpansionChanged,
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          tilePadding:
              const EdgeInsets.only(left: 16, right: 8, top: 8, bottom: 8),
          title: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 16,
                color: Colors.black,
              ),
            ),
          ),
          trailing: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              color: Colors.black54,
              size: 24,
            ),
          ),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (title == "Step 1: Basic Info") _buildBasicInfoContent(),
                  if (title == "Step 2: Price & Stock")
                    _buildPriceStockContent(),
                  if (title == "Step 3: Product Details")
                    _buildProductDetailsContent(),
                  if (title == "Step 4: Images") _buildImagesContent(),
                  if (title == "Step 5: Delivery & Others")
                    _buildDeliveryContent(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicBottomButtons() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        height: 64,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(
              color: Color(0xFFEEEEEE),
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed: () {
                  _showSuccessSnackBar('Product saved as draft');
                },
                style: TextButton.styleFrom(
                  backgroundColor: Colors.grey.shade100,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                child: const Text(
                  "Save as Draft",
                  style: TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 13,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton(
                onPressed: isLoading ? null : addProduct,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5040B2), // Deep purple
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  elevation: 0,
                ),
                child: isLoading
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        "Save Product",
                        style: TextStyle(
                          fontWeight: FontWeight.normal,
                          fontSize: 13,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                child: Text(
                  "Cancel",
                  style: TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 13,
                    color: Colors.red.shade600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoContent() {
    return Column(
      children: [
        _buildCleanField(
          label: "Product Name",
          hint: "Enter product name",
          onSaved: (value) => _name = value,
          controller: _nameController,
        ),
        _buildCleanField(
          label: "Description",
          hint: "Enter product description",
          onSaved: (value) => _description = value,
          maxLines: 5,
          controller: _descriptionController,
        ),
        _buildCleanCategorySelector(),
        _buildCleanField(
          label: "Brand Name",
          hint: "Enter brand name",
          onSaved: (value) => _brandName = value,
          controller: _brandNameController,
        ),
      ],
    );
  }

  Widget _buildPriceStockContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
                activeColor: Colors.teal,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              "Add Variants?",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        if (_addVariants) ...[
          _buildCleanField(
            label: "Variant Name",
            hint: "Size, Color, etc.",
            onSaved: (value) => _variantName = value,
            controller: _variantNameController,
          ),
          _buildCleanField(
            label: "Options",
            hint: "S,M,L or Red,Blue",
            onSaved: (value) => _variantOptions = value,
            controller: _variantOptionsController,
          ),
        ],
        _buildCleanField(
          label: "Price",
          hint: "Enter price",
          keyboardType: TextInputType.number,
          onSaved: (value) => _price = value,
          controller: _priceController,
          prefix: '\$',
        ),
        _buildCleanField(
          label: "Original Price",
          hint: "Enter original price",
          keyboardType: TextInputType.number,
          onSaved: (value) => _price = value,
          controller: _priceController,
          prefix: '\$',
        ),
        _buildCleanField(
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
          controller: _discountPriceController,
          prefix: '\$',
        ),
        _buildCleanField(
          label: "Stock Quantity",
          hint: "Enter quantity",
          keyboardType: TextInputType.number,
          onSaved: (value) => _stock = value,
          controller: _stockController,
          suffix: 'units',
        ),
      ],
    );
  }

  Widget _buildProductDetailsContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCleanField(
          label: "Material",
          hint: "Enter material",
          onSaved: (value) {
            _material = value;
            if (value != null && value.isNotEmpty) {
              _hasProductDetail = true;
            }
          },
          validator: (value) => null, // Optional field
          controller: _materialController,
        ),
        _buildCleanField(
          label: "Weight",
          hint: "Enter weight",
          keyboardType: TextInputType.number,
          onSaved: (value) {
            _weight = value;
            if (value != null && value.isNotEmpty) {
              _hasProductDetail = true;
            }
          },
          validator: (value) => null, // Optional field
          controller: _weightController,
          suffix: 'g',
        ),
        _buildCleanField(
          label: "Dimensions",
          hint: "Length x Width x Height",
          onSaved: (value) {
            _dimensions = value;
            if (value != null && value.isNotEmpty) {
              _hasProductDetail = true;
            }
          },
          validator: (value) => null, // Optional field
          controller: _dimensionsController,
          suffix: 'cm',
        ),
        _buildCleanField(
          label: "Country of Origin",
          hint: "Enter country",
          onSaved: (value) {
            _countryOfOrigin = value;
            if (value != null && value.isNotEmpty) {
              _hasProductDetail = true;
            }
          },
          validator: (value) => null, // Optional field
          controller: _countryOfOriginController,
        ),
      ],
    );
  }

  Widget _buildImagesContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: _uploadImage,
          child: Container(
            height: 160,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.grey.shade300, width: 1),
            ),
            child: _image != null
                ? Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Image.file(
                          File(_image!),
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _image = null;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close,
                                size: 14, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  )
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_photo_alternate_outlined,
                          size: 32,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Tap to upload image",
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildDeliveryContent() {
    return Column(
      children: [
        _buildCleanField(
          label: "Delivery Time Estimate",
          hint: "e.g., 2-3 days",
          onSaved: (value) {},
          controller: _deliveryTimeController,
        ),
        _buildCleanReturnableSelector(),
        if (_isReturnable == "Yes")
          _buildCleanField(
            label: "Return Policy",
            hint: "Enter return policy details",
            maxLines: 2,
            onSaved: (value) {},
            controller: _returnPolicyController,
          ),
        _buildCleanField(
          label: "Delivery Charge",
          hint: "Enter amount",
          keyboardType: TextInputType.number,
          onSaved: (value) => _deliveryCharge = value,
          controller: _deliveryChargeController,
          prefix: '\$',
        ),
        _buildCleanField(
          label: "Tags",
          hint: "Separate with commas",
          onSaved: (value) => _tags = value,
          controller: _tagsController,
        ),
      ],
    );
  }

  Widget _buildCleanField({
    required String label,
    required String hint,
    required Function(String?) onSaved,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    TextEditingController? controller,
    String? suffix,
    String? prefix,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.normal,
                color: Colors.black87,
              ),
            ),
          ),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 16),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: BorderSide(color: Colors.grey.shade400),
            ),
            filled: true,
            fillColor: Colors.white,
            suffixText: suffix,
            prefixText: prefix,
            suffixStyle: const TextStyle(
              color: Colors.black54,
              fontWeight: FontWeight.normal,
              fontSize: 16,
            ),
            prefixStyle: const TextStyle(
              color: Colors.black54,
              fontWeight: FontWeight.normal,
              fontSize: 16,
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
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildCleanCategorySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 10),
          child: Text(
            "Category",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.normal,
              color: Colors.black87,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              border: InputBorder.none,
            ),
            hint: Text("Select category",
                style: TextStyle(color: Colors.grey.shade400, fontSize: 16)),
            value: _categoryName,
            isExpanded: true,
            icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select a category';
              }
              // Also validate that we have a valid category ID
              if (value != "add_new" &&
                  (_categoryId == null || _categoryId!.isEmpty)) {
                return 'Invalid category selected';
              }
              return null;
            },
            items: [
              ...categories.map((category) {
                return DropdownMenuItem<String>(
                  value: category['name'] ?? '',
                  child: Text(
                    category['name'] ?? '',
                    style: const TextStyle(fontSize: 16),
                  ),
                );
              }).toList(),
              const DropdownMenuItem<String>(
                value: "add_new",
                child: Row(
                  children: [
                    Icon(Icons.add, color: Colors.grey, size: 18),
                    SizedBox(width: 8),
                    Text("Add New Category",
                        style: TextStyle(color: Colors.black87, fontSize: 16)),
                  ],
                ),
              ),
            ],
            onChanged: (value) {
              setState(() {
                if (value == "add_new") {
                  _showAddCategoryDialog();
                  _categoryName = null;
                  _categoryId = null;
                } else {
                  _categoryName = value;
                  // Find and store the category ID
                  final selectedCategory = categories.firstWhere(
                    (cat) => cat['name'] == value,
                    orElse: () => {'id': '', 'name': ''},
                  );
                  _categoryId = selectedCategory['id'].toString();
                  _categoryController.text = value ?? '';
                }
              });
            },
            onSaved: (value) {
              _categoryName = value;
              if (value != null && value != "add_new") {
                final selectedCategory = categories.firstWhere(
                  (cat) => cat['name'] == value,
                  orElse: () => {'id': '', 'name': ''},
                );
                _categoryId = selectedCategory['id'];
              }
              _categoryController.text = value ?? '';
            },
            dropdownColor: Colors.white,
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildCleanReturnableSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 10),
          child: Text(
            "Is Returnable?",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.normal,
              color: Colors.black87,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              border: InputBorder.none,
            ),
            value: _isReturnable,
            isExpanded: true,
            icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
            items: [
              DropdownMenuItem<String>(
                value: "Yes",
                child: Row(
                  children: [
                    Icon(Icons.check_circle,
                        color: Colors.green.shade600, size: 18),
                    const SizedBox(width: 8),
                    const Text("Yes", style: TextStyle(fontSize: 16)),
                  ],
                ),
              ),
              DropdownMenuItem<String>(
                value: "No",
                child: Row(
                  children: [
                    Icon(Icons.cancel, color: Colors.red.shade400, size: 18),
                    const SizedBox(width: 8),
                    const Text("No", style: TextStyle(fontSize: 16)),
                  ],
                ),
              ),
            ],
            onChanged: (value) {
              setState(() {
                _isReturnable = value;
                _isReturnableController.text = value ?? 'No';
              });
            },
            onSaved: (value) {
              _isReturnable = value;
              _isReturnableController.text = value ?? 'No';
            },
            dropdownColor: Colors.white,
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Future<void> addProduct() async {
    if (!_formKey.currentState!.validate()) {
      _showErrorSnackBar('Please fill all required fields');
      return;
    }

    _formKey.currentState!.save();

    // Check if we have at least one product detail
    _hasProductDetail = _materialController.text.isNotEmpty ||
        _weightController.text.isNotEmpty ||
        _dimensionsController.text.isNotEmpty ||
        _countryOfOriginController.text.isNotEmpty;

    if (!_hasProductDetail) {
      _showErrorSnackBar(
          'Please fill at least one field in Product Details section');

      // Auto-expand the product details section
      setState(() {
        _isExpanded[2] = true;
      });

      // Scroll to the product details section
      _scrollController.animateTo(
        300, // Approximate position of the product details section
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );

      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // Create product data using a Map that will be converted to JSON
      final Map<String, dynamic> productData = {
        'name': _nameController.text,
        'price': _priceController.text,
        'category_id': _categoryId,
        'description': _descriptionController.text,
        'stock': _stockController.text,
      };

      // Add optional fields with null checks
      if (_discountPriceController.text.isNotEmpty) {
        productData['discountPrice'] = _discountPriceController.text;
      }

      if (_brandNameController.text.isNotEmpty) {
        productData['brandName'] = _brandNameController.text;
      }

      // Add product details if they exist
      if (_materialController.text.isNotEmpty) {
        productData['material'] = _materialController.text;
      }

      if (_weightController.text.isNotEmpty) {
        productData['weight'] = _weightController.text;
      }

      if (_dimensionsController.text.isNotEmpty) {
        productData['dimensions'] = _dimensionsController.text;
      }

      if (_countryOfOriginController.text.isNotEmpty) {
        productData['countryOfOrigin'] = _countryOfOriginController.text;
      }

      // Add delivery and other details
      if (_isReturnableController.text.isNotEmpty) {
        productData['isReturnable'] = _isReturnableController.text;
      }

      if (_deliveryChargeController.text.isNotEmpty) {
        productData['deliveryCharge'] = _deliveryChargeController.text;
      }

      if (_tagsController.text.isNotEmpty) {
        productData['tags'] = _tagsController.text;
      }

      // Add variants if they exist
      if (_addVariants &&
          _variantNameController.text.isNotEmpty &&
          _variantOptionsController.text.isNotEmpty) {
        productData['variantName'] = _variantNameController.text;
        productData['variantOptions'] = _variantOptionsController.text;
      }

      print('Sending data to API: ${jsonEncode(productData)}');

      // Send the request with proper content type headers
      final response = await http.post(
        Uri.parse('${rOOT}add-product'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(productData),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        _showSuccessSnackBar(
            'Product added successfully and available on the customer home page');

        // Refresh products
        await fetchProducts();

        Navigator.pop(context);
      } else {
        String errorMessage =
            'Failed to add product: Status ${response.statusCode}';
        try {
          final errorData = jsonDecode(response.body);
          if (errorData['message'] != null) {
            errorMessage = errorData['message'];
          } else if (errorData['error'] != null) {
            errorMessage = errorData['error'];
          }
        } catch (e) {
          errorMessage = 'Error: ${response.body}';
        }

        _showErrorSnackBar(errorMessage);
      }
    } catch (e) {
      print('Error in addProduct: $e');
      _showErrorSnackBar(e.toString());
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Helper method to check if a step is completed
  bool _stepCompleted(int index) {
    switch (index) {
      case 0:
        return _nameController.text.isNotEmpty &&
            _categoryId != null &&
            _categoryId!.isNotEmpty;
      case 1:
        return _priceController.text.isNotEmpty &&
            _stockController.text.isNotEmpty;
      case 2:
        return _materialController.text.isNotEmpty ||
            _weightController.text.isNotEmpty ||
            _dimensionsController.text.isNotEmpty ||
            _countryOfOriginController.text.isNotEmpty;
      case 3:
        return _image != null;
      case 4:
        return true; // Optional section
      default:
        return false;
    }
  }
}
