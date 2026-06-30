import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ecommerce_app_api_26/features/home/presentation/widgets/product_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final CollectionReference<Map<String, dynamic>> productRefrence;
  initState() {
    getProducts();
    super.initState();
  }

  void getProducts() {
    productRefrence = FirebaseFirestore.instance.collection('products');
  }

  String orderByField = 'name';

  TextEditingController searchController = TextEditingController();
  TextEditingController nameController = TextEditingController(),
      descriptionController = TextEditingController(),
      priceController = TextEditingController(),
      quantityController = TextEditingController(),
      imageUrlController = TextEditingController();

  void updateQuantity(DocumentReference documentReference) async {
    try {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final snapshot = await transaction.get(documentReference);
        double quantity = snapshot['quantity'];
        if (quantity <= 0) {
          throw Exception("Out of stock");
        }
        transaction.update(documentReference, {'quantity': quantity - 1});
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // final List<Map<String, dynamic>> dummyProducts = List.generate(
    //   10,
    //   (index) => {
    //     'id': index,
    //     'title': 'Product ${index + 1}',
    //     'description': 'Modern design for daily life',
    //     'price': (index + 1) * 20.0,
    //     'image': 'https://via.placeholder.com/150',
    //   },
    // );

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                spacing: 10,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(labelText: 'Name'),
                  ),
                  TextField(
                    controller: descriptionController,
                    decoration: InputDecoration(labelText: 'Description'),
                  ),
                  TextField(
                    controller: priceController,
                    decoration: InputDecoration(labelText: 'Price'),
                  ),
                  TextField(
                    controller: quantityController,
                    decoration: InputDecoration(labelText: 'quantity'),
                  ),
                  TextField(
                    controller: imageUrlController,
                    decoration: InputDecoration(labelText: 'Image Url'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      await productRefrence.doc(nameController.text).set({
                        'name': nameController.text,
                        'desc': descriptionController.text,
                        'price': double.parse(priceController.text),
                        'image': imageUrlController.text,
                        'quantity': double.parse(quantityController.text),
                      });
                      Navigator.pop(context);
                    },
                    child: Text("Add Product"),
                  ),
                ],
              ),
            ),
          );
        },
      ),

      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 80,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome,',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                ),
                const Text(
                  'Our Shop',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: const Icon(Icons.notifications_none, color: Colors.blue),
                onPressed: () {},
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  // Search
                  Expanded(
                    flex: 3,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: TextFormField(
                        controller: searchController,
                        onChanged: (_) => setState(() {}),
                        decoration: const InputDecoration(
                          hintText: 'Search products...',
                          border: InputBorder.none,
                          icon: Icon(Icons.search, color: Colors.blue),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  // Sort
                  Expanded(
                    flex: 2,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: orderByField,
                          isExpanded: true,
                          icon: const Icon(Icons.keyboard_arrow_down),
                          items: const [
                            DropdownMenuItem(
                              value: 'name',
                              child: Text('Name'),
                            ),
                            DropdownMenuItem(
                              value: 'price',
                              child: Text('Price'),
                            ),
                            DropdownMenuItem(
                              value: 'desc',
                              child: Text('Description'),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              orderByField = value!;
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Categories
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: ['All', 'Shoes', 'Shirts', 'Tech', 'Home'].map((cat) {
                  bool isAll = cat == 'All';
                  return Container(
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isAll ? Colors.blue : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        if (!isAll)
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 5,
                          ),
                      ],
                    ),
                    child: Text(
                      cat,
                      style: TextStyle(
                        color: isAll ? Colors.white : Colors.grey.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            // Products Grid
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: StreamBuilder(
                stream: productRefrence
                    .orderBy(orderByField, descending: false)
                    .snapshots(),
                builder: (context, asyncSnapshot) {
                  if (!asyncSnapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final docs = asyncSnapshot.data!.docs;
                  final filteredProducts = docs.where((doc) {
                    final product = doc.data();
                    return product['name'].toString().toLowerCase().contains(
                          searchController.text.toLowerCase(),
                        ) ||
                        product['desc'].toString().toLowerCase().contains(
                          searchController.text.toLowerCase(),
                        ) ||
                        product['price'].toString().contains(
                          searchController.text,
                        );
                  }).toList();

                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.7,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                    // itemCount: asyncSnapshot.data!.docs.length,
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) {
                      // final product = asyncSnapshot.data!.docs[index].data();
                      final product = filteredProducts[index].data();
                      return ProductCard(
                        id: filteredProducts[index].id,
                        title: product['name'],
                        price: (product['price'] as num).toDouble(),
                        quantity: (product['quantity'] as num).toInt(),
                        description: product['desc'],
                        image: product['image'],
                        onAdd: () {
                          updateQuantity(filteredProducts[index].reference);
                        },
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
