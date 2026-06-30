import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce_app_api_26/features/auth/presentation/screens/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProductCard extends StatefulWidget {
  final String title;
  final double price;
  final String description;
  final String? image;
  final String id;
  final VoidCallback onAdd;
  final int quantity;
  final Color? color;

  const ProductCard({
    super.key,
    required this.title,
    required this.price,
    required this.description,
    required this.image,
    required this.quantity,
    required this.onAdd,
    required this.id,
    this.color,
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  // void addToFavorites(BuildContext context) async {
  //   setState(() {
  //     isFavorite = true;
  //   });
  //   final userId = FirebaseAuth.instance.currentUser!.uid;
  //   print("Pressed");
  //   final docRef = FirebaseFirestore.instance
  //       .collection('favorites')
  //       .doc(userId);

  //   final snapshot = await docRef.get();

  //   if (!snapshot.exists) {
  //     await docRef.set({
  //       "favorites": [widget.id],
  //     });

  //     ScaffoldMessenger.of(
  //       context,
  //     ).showSnackBar(const SnackBar(content: Text("Added to favorites")));
  //     return;
  //   }
  //   List<dynamic> favorites =
  //       ((snapshot.data() as Map<String, dynamic>)['favorites'] ?? []);

  //   if (!favorites.contains(widget.id)) {
  //     favorites.add(widget.id);
  //     await docRef.update({'favorites': favorites});
  //   }
  //   print("done");
  //   ScaffoldMessenger.of(
  //     context,
  //   ).showSnackBar(const SnackBar(content: Text("Added to favorites")));
  // }

  Future<void> addFavorite(String productId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      log("User Should login");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
      return;
    }
    DocumentReference favProduct = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('favorites')
        .doc(productId);
     DocumentSnapshot Snapshot = await favProduct.get();
    if (Snapshot.exists) {
      await favProduct.delete();
    } else {
      await favProduct.set({
            'productId': productId,
            'price': widget.price,
            'name': widget.title.toString(),
            'image': widget.image,
            'desc': widget.description,
          }).then((value) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(
          SnackBar(
            content: Text("Added to favorites"),
          ),  
        );
      });
    }
  }

  Future<void> addToCart(String productId) async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      log("User is not logged in");
      return;
    }
    DocumentReference cartProduct = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('cart')
        .doc(productId);
    final DocumentSnapshot Snapshot = await cartProduct.get();
    if (Snapshot.exists == true) {
      await cartProduct.update({'quantity': Snapshot['quantity'] + 1});
    } else {
      await cartProduct
          .set({
            'productId': productId,
            'quantity': 1,
            'price': widget.price,
            'name': widget.title.toString(),
            'image': widget.image,
            'desc': widget.description,
          })
          .then((value) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text("Added to cart")));
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    final product = FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .collection('favorites')
        .doc(widget.id);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade50, Colors.blue.shade100],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              child: Stack(
                children: [
                  Center(
                    child: widget.image == null
                        ? Icon(
                            Icons.shopping_bag_outlined,
                            size: 40,
                            color: Colors.blue,
                          )
                        : Image.network(widget.image!),
                  ),
                  PositionBag(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: StreamBuilder(
                        stream: product.snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return CircularProgressIndicator();
                          }
                          bool isFavorite = snapshot.data!.exists;
                          return IconButton(
                            icon: Icon(
                              isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: isFavorite ? Colors.red : Colors.grey,
                            ),
                            onPressed: () => addFavorite(widget.id),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  widget.description,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '\$${widget.price}',
                      style: const TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),

                    Text(
                      " ${widget.quantity}",
                      style: TextStyle(
                        color: widget.quantity == 0 ? Colors.red : Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.add_shopping_cart,
                        color: Colors.blue,
                      ),
                      onPressed: () async {
                        if (widget.quantity == 0) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Out of stock"),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }
                        widget.onAdd();
                        await addToCart(widget.id);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
       
        ],
      ),
    );
  }
}

class PositionBag extends StatelessWidget {
  final double? top;
  final double? right;
  final Widget child;
  const PositionBag({super.key, this.top, this.right, required this.child});

  @override
  Widget build(BuildContext context) {
    return Positioned(top: top, right: right, child: child);
  }
}
