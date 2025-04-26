import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

// Replace the API config with direct URL for now
// We'll use a constant URL since the config file might not exist in user's workspace
const String API_BASE_URL = 'https://your-api-url.com/api';

class AddProductPage extends StatefulWidget {
  const AddProductPage({Key? key}) : super(key: key);

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final List<bool> _isExpanded = [true, true, false, true];
  bool _addVariants = false;
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;

  // TextEditingControllers for all input fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _variantNameController = TextEditingController();
  final TextEditingController _variantOptionsController =
      TextEditingController();
  final TextEditingController _deliveryTimeController = TextEditingController();
  final TextEditingController _returnableController = TextEditingController();
  final TextEditingController _deliveryChargeController =
      TextEditingController();
  final TextEditingController _tagsController = TextEditingController();

  // Category dropdown
  List<Map<String, dynamic>> _categories = [];
  Map<String, dynamic>? _selectedCategory;
  bool _isCategoriesLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    setState(() {
      _isCategoriesLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse('$API_BASE_URL/categories'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _categories = List<Map<String, dynamic>>.from(data['data']);
          _isCategoriesLoading = false;
        });
      } else {
        setState(() {
          _isCategoriesLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load categories')),
        );
      }
    } catch (e) {
      setState(() {
        _isCategoriesLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  Future<void> _submitProduct() async {
    // Validate required fields
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product name is required')),
      );
      return;
    }

    if (_descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Description is required')),
      );
      return;
    }

    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category')),
      );
      return;
    }

    if (_priceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Price is required')),
      );
      return;
    }

    // Validate price format
    double? price;
    try {
      price = double.parse(_priceController.text);
      if (price <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Price must be greater than zero')),
        );
        return;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid price')),
      );
      return;
    }

    // Validate delivery charge if present
    double? deliveryCharge;
    if (_deliveryChargeController.text.isNotEmpty) {
      try {
        deliveryCharge = double.parse(_deliveryChargeController.text);
        if (deliveryCharge < 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Delivery charge cannot be negative')),
          );
          return;
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a valid delivery charge')),
        );
        return;
      }
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Prepare payload
      final Map<String, dynamic> payload = {
        'name': _nameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'category_id': _selectedCategory!['id'],
        'price': price,
      };

      // Add optional fields if they have values
      if (_brandController.text.isNotEmpty) {
        payload['brand'] = _brandController.text.trim();
      }

      if (_deliveryTimeController.text.isNotEmpty) {
        payload['delivery_time'] = _deliveryTimeController.text.trim();
      }

      if (_returnableController.text.isNotEmpty) {
        payload['returnable'] =
            _returnableController.text.toLowerCase() == 'yes';
      }

      if (deliveryCharge != null) {
        payload['delivery_charge'] = deliveryCharge;
      }

      if (_tagsController.text.isNotEmpty) {
        payload['tags'] = _tagsController.text
            .split(',')
            .map((tag) => tag.trim())
            .where((tag) => tag.isNotEmpty)
            .toList();
      }

      // Add variants if enabled
      if (_addVariants &&
          _variantNameController.text.isNotEmpty &&
          _variantOptionsController.text.isNotEmpty) {
        final List<String> options = _variantOptionsController.text
            .split(',')
            .map((option) => option.trim())
            .where((option) => option.isNotEmpty)
            .toList();

        if (options.isNotEmpty) {
          payload['variants'] = [
            {
              'name': _variantNameController.text.trim(),
              'options': options,
            }
          ];
        }
      }

      // Make API call
      final response = await http.post(
        Uri.parse('$API_BASE_URL/products'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        // Success - refresh product list
        await _refreshProducts();

        // Show success message and navigate back
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Product added successfully')),
          );
          Navigator.pop(context, true); // Pass true to indicate success
        }
      } else {
        // Error handling
        Map<String, dynamic> errorData = {};
        try {
          errorData = jsonDecode(response.body);
        } catch (e) {
          // If response body isn't valid JSON
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Error: ${errorData['message'] ?? 'Failed to add product. Status code: ${response.statusCode}'}'),
              duration: const Duration(seconds: 5),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _refreshProducts() async {
    try {
      await http.get(
        Uri.parse('$API_BASE_URL/products'),
        headers: {'Content-Type': 'application/json'},
      );
      // The product list should be refreshed in the products page automatically
      // when we navigate back with a success result
    } catch (e) {
      // Silently handle error, since this is just a refresh operation
      print('Error refreshing products: ${e.toString()}');
    }
  }

  @override
  void dispose() {
    // Dispose all controllers
    _nameController.dispose();
    _descriptionController.dispose();
    _brandController.dispose();
    _priceController.dispose();
    _variantNameController.dispose();
    _variantOptionsController.dispose();
    _deliveryTimeController.dispose();
    _returnableController.dispose();
    _deliveryChargeController.dispose();
    _tagsController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add Product',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: Stack(
        children: [
          Padding(
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
                      _buildTextField(
                        label: "Product Name",
                        hint: "Enter product name",
                        controller: _nameController,
                        required: true,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        label: "Description",
                        hint: "Enter product description",
                        controller: _descriptionController,
                        maxLines: 5,
                        required: true,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildCategoryDropdown(),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildTextField(
                              label: "Brand Name",
                              hint: "Enter brand name",
                              controller: _brandController,
                            ),
                          ),
                        ],
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
                        Row(
                          children: [
                            Expanded(
                              child: _buildTextField(
                                label: "Variant Name",
                                hint: "Size, Color, etc.",
                                controller: _variantNameController,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildTextField(
                                label: "Options",
                                hint: "S,M,L or Red,Blue",
                                controller: _variantOptionsController,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                      ],
                      _buildTextField(
                        label: "Price per",
                        hint: "Enter price",
                        keyboardType: TextInputType.number,
                        controller: _priceController,
                        required: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _buildSection(
                  index: 2,
                  title: "Step 4: Images",
                  child: _buildImageUploader(),
                ),
                const SizedBox(height: 16),
                _buildSection(
                  index: 3,
                  title: "Step 5: Delivery & Others",
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              label: "Delivery Time Estimate",
                              hint: "e.g., 2-3 days",
                              controller: _deliveryTimeController,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildTextField(
                              label: "Is Returnable?",
                              hint: "Yes/No",
                              controller: _returnableController,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              label: "Delivery Charge",
                              hint: "Enter amount",
                              keyboardType: TextInputType.number,
                              controller: _deliveryChargeController,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildTextField(
                              label: "Tags",
                              hint: "Separate with commas",
                              controller: _tagsController,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 80),
              ],
            ),
          ),
          _buildBottomButtons(),
        ],
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: DropdownButtonFormField<Map<String, dynamic>>(
        value: _selectedCategory,
        decoration: InputDecoration(
          labelText: "Category *",
          floatingLabelBehavior: FloatingLabelBehavior.auto,
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                BorderSide(color: Theme.of(context).primaryColor, width: 1.5),
          ),
        ),
        hint: Text(_isCategoriesLoading ? "Loading..." : "Select category"),
        isExpanded: true,
        items: _categories.map((category) {
          return DropdownMenuItem<Map<String, dynamic>>(
            value: category,
            child: Text(category['name']),
          );
        }).toList(),
        onChanged: _isCategoriesLoading
            ? null
            : (value) {
                setState(() {
                  _selectedCategory = value;
                });
              },
      ),
    );
  }

  Widget _buildSection({
    required int index,
    required String title,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
          colorScheme: ColorScheme.light(
            primary: Theme.of(context).primaryColor,
          ),
        ),
        child: ExpansionTile(
          initiallyExpanded: _isExpanded[index],
          onExpansionChanged: (expanded) {
            setState(() {
              _isExpanded[index] = expanded;
            });
          },
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          title: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          children: [child],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    bool required = false,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: required ? "$label *" : label,
        hintText: hint,
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              BorderSide(color: Theme.of(context).primaryColor, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildImageUploader() {
    return DottedBorder(
      borderType: BorderType.RRect,
      radius: const Radius.circular(12),
      color: Colors.grey.shade400,
      strokeWidth: 2,
      dashPattern: const [8, 4],
      child: Container(
        height: 180,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey.shade50,
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.cloud_upload_outlined,
                size: 48,
                color: Colors.grey,
              ),
              SizedBox(height: 12),
              Text(
                "Drag and drop images here, or upload",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomButtons() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _isLoading ? null : () {},
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: BorderSide(color: Theme.of(context).primaryColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Save as Draft",
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitProduct,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        "Save Product",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton(
                onPressed: _isLoading
                    ? null
                    : () {
                        Navigator.pop(context);
                      },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: const BorderSide(color: Colors.red),
                  foregroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Cancel",
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
