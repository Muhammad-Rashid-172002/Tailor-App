import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class CustomersScreen extends StatefulWidget {
  const CustomersScreen({super.key});

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  final User? currentUser = FirebaseAuth.instance.currentUser;
  String searchQuery = "";

  @override
  Widget build(BuildContext context) {
    if (currentUser == null) {
      return const Scaffold(
        body: Center(
          child: Text("Not logged in", style: TextStyle(color: Colors.white)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Customers", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.black,
      ),
      body: Column(
        children: [
          // 🔍 Search bar outside AppBar
          Container(
            color: Colors.grey[850],
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  searchQuery = value.trim().toLowerCase();
                });
              },
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Search by name or email...",
                hintStyle: const TextStyle(color: Colors.white70),
                filled: true,
                fillColor: Colors.grey[800],
                prefixIcon: const Icon(Icons.search, color: Colors.white70),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // 📌 Customer list
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(currentUser!.uid)
                  .collection('customers')
                  .orderBy('fullName')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(
                    child: Text(
                      'Something went wrong',
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final customers = snapshot.data!.docs;

                // 🔍 Apply search filter
                final filteredCustomers = customers.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final fullName = (data['fullName'] ?? '')
                      .toString()
                      .toLowerCase();
                  final email = (data['email'] ?? '').toString().toLowerCase();

                  return fullName.contains(searchQuery) ||
                      email.contains(searchQuery);
                }).toList();

                if (filteredCustomers.isEmpty) {
                  return const Center(
                    child: Text(
                      'No customers found.',
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  itemCount: filteredCustomers.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final customer =
                        filteredCustomers[index].data() as Map<String, dynamic>;
                    final docId = filteredCustomers[index].id;

                    return Slidable(
                      key: ValueKey(docId),
                      endActionPane: ActionPane(
                        motion: const ScrollMotion(),
                        children: [
                          SlidableAction(
                            onPressed: (context) =>
                                _showEditCustomerDialog(customer, docId),
                            backgroundColor: Colors.teal,
                            foregroundColor: Colors.white,
                            icon: Icons.edit,
                            label: 'Edit',
                          ),
                          SlidableAction(
                            onPressed: (context) =>
                                _confirmDelete(context, docId),
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            icon: Icons.delete,
                            label: 'Delete',
                          ),
                        ],
                      ),
                      child: Card(
                        color: Colors.grey[850],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(color: Colors.white12),
                        ),
                        elevation: 2,
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          leading: CircleAvatar(
                            backgroundColor: Colors.blueGrey[700],
                            child: const Icon(
                              Icons.person,
                              color: Colors.white,
                            ),
                          ),
                          title: Text(
                            customer['fullName'] ?? 'Unnamed',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                          subtitle: Text(
                            "${customer['email'] ?? 'No email'}\nCloth: ${customer['cloth'] ?? 'Not specified'}",
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddCustomerDialog(context);
        },
        backgroundColor: Colors.blueGrey[800],
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  /// ✅ Add Customer Dialog
  void _showAddCustomerDialog(BuildContext context) {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    String selectedCloth = "Shirt";

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setState) {
            return AlertDialog(
              backgroundColor: Colors.grey[850],
              shape: RoundedRectangleBorder(
                side: const BorderSide(color: Colors.white, width: 2),
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Text(
                "Add Customer",
                style: TextStyle(color: Colors.white),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: "Full Name",
                        labelStyle: TextStyle(color: Colors.white70),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: emailController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: "Email",
                        labelStyle: TextStyle(color: Colors.white70),
                      ),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      dropdownColor: Colors.grey[900],
                      value: selectedCloth,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: "Cloth Type",
                        labelStyle: TextStyle(color: Colors.white70),
                      ),
                      items: ["Shirt", "Pant", "Suit", "Kurta", "Blouse"]
                          .map(
                            (cloth) => DropdownMenuItem(
                              value: cloth,
                              child: Text(cloth),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => selectedCloth = value);
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text(
                    "Cancel",
                    style: TextStyle(color: Colors.blueAccent),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (nameController.text.trim().isEmpty ||
                        emailController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Please fill all fields")),
                      );
                      return;
                    }

                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(currentUser!.uid)
                        .collection('customers')
                        .add({
                          "fullName": nameController.text.trim(),
                          "email": emailController.text.trim(),
                          "cloth": selectedCloth,
                          "createdAt": FieldValue.serverTimestamp(),
                        });

                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Customer added")),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: const Text("Add"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// ✏ Edit Customer Dialog
  void _showEditCustomerDialog(Map<String, dynamic> customer, String docId) {
    final nameController = TextEditingController(text: customer['fullName']);
    final emailController = TextEditingController(text: customer['email']);
    String selectedCloth = customer['cloth'] ?? "Shirt";

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setState) {
            return AlertDialog(
              backgroundColor: Colors.grey[850],
              shape: RoundedRectangleBorder(
                side: const BorderSide(color: Colors.white, width: 2),
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Text(
                "Edit Customer",
                style: TextStyle(color: Colors.white),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: "Full Name",
                        labelStyle: TextStyle(color: Colors.white70),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: emailController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: "Email",
                        labelStyle: TextStyle(color: Colors.white70),
                      ),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      dropdownColor: Colors.grey[900],
                      value: selectedCloth,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: "Cloth Type",
                        labelStyle: TextStyle(color: Colors.white70),
                      ),
                      items: ["Shirt", "Pant", "Suit", "Kurta", "Blouse"]
                          .map(
                            (cloth) => DropdownMenuItem(
                              value: cloth,
                              child: Text(cloth),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => selectedCloth = value);
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text(
                    "Cancel",
                    style: TextStyle(color: Colors.blueAccent),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (nameController.text.trim().isEmpty ||
                        emailController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Please fill all fields")),
                      );
                      return;
                    }

                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(currentUser!.uid)
                        .collection('customers')
                        .doc(docId)
                        .update({
                          "fullName": nameController.text.trim(),
                          "email": emailController.text.trim(),
                          "cloth": selectedCloth,
                        });

                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Customer updated")),
                    );
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                  child: const Text("Save"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  ///  Confirm Delete
  void _confirmDelete(BuildContext context, String docId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.grey[850],
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: Colors.white, width: 2),
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          "Delete Customer",
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          "Are you sure you want to delete this customer?",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              "Cancel",
              style: TextStyle(color: Colors.blueAccent),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(currentUser!.uid)
                  .collection('customers')
                  .doc(docId)
                  .delete();
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text("Customer deleted")));
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }
}
