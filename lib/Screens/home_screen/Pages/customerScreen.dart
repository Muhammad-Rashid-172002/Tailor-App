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

  //  Premium Luxury Color Palette
  final Color premiumPrimary = const Color(0xFFFFB300); // Amber / Golden Yellow
  final Color premiumSecondary = const Color(0xFF37474F); // Blue Grey 800
  final Color premiumAccent = const Color(0xFFF57C00); // Deep Orange

  @override
  Widget build(BuildContext context) {
    if (currentUser == null) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.white, Color(0xFFFFF8E1)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: const Center(
            child: Text(
              "Not logged in",
              style: TextStyle(color: Colors.black, fontSize: 18),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          "Customers",
          style: TextStyle(color: premiumPrimary, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 4,
        backgroundColor: Colors.transparent, // Transparent so gradient shows
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.white, Color(0xFFFFF8E1)], // soft white → cream
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),

      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Color(0xFFFFF8E1)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            // 🔍 Search bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    searchQuery = value.trim().toLowerCase();
                  });
                },
                style: const TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  hintText: "Search by name or email...",
                  hintStyle: TextStyle(color: Colors.black.withOpacity(0.6)),
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: Icon(Icons.search, color: premiumPrimary),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: premiumPrimary.withOpacity(0.3),
                    ),
                  ),
                ),
              ),
            ),

            //  Customer list
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
                        style: TextStyle(color: Colors.black),
                      ),
                    );
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final customers = snapshot.data!.docs;

                  final filteredCustomers = customers.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final fullName = (data['fullName'] ?? '')
                        .toString()
                        .toLowerCase();
                    final email = (data['email'] ?? '')
                        .toString()
                        .toLowerCase();

                    return fullName.contains(searchQuery) ||
                        email.contains(searchQuery);
                  }).toList();

                  if (filteredCustomers.isEmpty) {
                    return const Center(
                      child: Text(
                        'No customers found.',
                        style: TextStyle(color: Colors.black54),
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
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final customer =
                          filteredCustomers[index].data()
                              as Map<String, dynamic>;
                      final docId = filteredCustomers[index].id;

                      return Slidable(
                        key: ValueKey(docId),
                        endActionPane: ActionPane(
                          motion: const ScrollMotion(),
                          children: [
                            SlidableAction(
                              onPressed: (context) =>
                                  _showEditCustomerDialog(customer, docId),
                              backgroundColor: premiumAccent,
                              foregroundColor: Colors.white,
                              icon: Icons.edit,
                              label: 'Edit',
                            ),
                            SlidableAction(
                              onPressed: (context) =>
                                  _confirmDelete(context, docId),
                              backgroundColor: Colors.redAccent,
                              foregroundColor: Colors.white,
                              icon: Icons.delete,
                              label: 'Delete',
                            ),
                          ],
                        ),
                        child: Card(
                          color: premiumSecondary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                            side: BorderSide(
                              color: premiumPrimary.withOpacity(0.3),
                            ),
                          ),
                          elevation: 4,
                          shadowColor: premiumPrimary.withOpacity(0.3),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Colors.white, // Background base
                                  Color(0xFFFFF8E1), // Soft amber tint
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: premiumPrimary.withOpacity(0.3),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: premiumPrimary.withOpacity(0.2),
                                  blurRadius: 6,
                                  offset: const Offset(2, 3),
                                ),
                              ],
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              leading: CircleAvatar(
                                backgroundColor: premiumPrimary,
                                child: const Icon(
                                  Icons.person,
                                  color: Colors.white,
                                  size: 22,
                                ),
                              ),
                              title: Text(
                                customer['fullName'] ?? 'Unnamed',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: premiumPrimary,
                                ),
                              ),
                              subtitle: Text(
                                "${customer['email'] ?? 'No email'}\nCloth: ${customer['cloth'] ?? 'Not specified'}",
                                style: TextStyle(
                                  color: premiumSecondary.withOpacity(0.7),
                                ),
                              ),
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
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddCustomerDialog(context),
        backgroundColor: premiumPrimary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  /// Add Customer Dialog
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
              backgroundColor: premiumSecondary,
              shape: RoundedRectangleBorder(
                side: BorderSide(color: premiumPrimary, width: 2),
                borderRadius: BorderRadius.circular(18),
              ),
              title: Text(
                "Add Customer",
                style: TextStyle(
                  color: premiumPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildTextField("Full Name", nameController),
                    const SizedBox(height: 10),
                    _buildTextField("Email", emailController),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      dropdownColor: Colors.white,
                      value: selectedCloth,
                      style: const TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                        labelText: "Cloth Type",
                        labelStyle: TextStyle(color: premiumPrimary),
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
                  child: Text("Cancel", style: TextStyle(color: premiumAccent)),
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
                    backgroundColor: premiumAccent,
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

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, //  makes it full height when needed
      backgroundColor: Colors.transparent, //  so gradient/rounded corners show
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setState) {
            return Container(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom:
                    MediaQuery.of(ctx).viewInsets.bottom + 20, //  keyboard safe
              ),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.white, Color(0xFFFFF8E1)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 12,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 5,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.grey[400],
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    Text(
                      "Edit Customer",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: premiumPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),

                    _buildTextField("Full Name", nameController),
                    const SizedBox(height: 12),
                    _buildTextField("Email", emailController),
                    const SizedBox(height: 12),

                    DropdownButtonFormField<String>(
                      dropdownColor: Colors.white,
                      value: selectedCloth,
                      style: const TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                        labelText: "Cloth Type",
                        labelStyle: TextStyle(color: premiumPrimary),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
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
                    const SizedBox(height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: Text(
                            "Cancel",
                            style: TextStyle(color: premiumAccent),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () async {
                            if (nameController.text.trim().isEmpty ||
                                emailController.text.trim().isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Please fill all fields"),
                                ),
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
                          style: ElevatedButton.styleFrom(
                            backgroundColor: premiumAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text("Save"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
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
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(
          side: BorderSide(color: premiumPrimary, width: 2),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Colors.white, Color(0xFFFFF8E1)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Delete Customer",
                style: TextStyle(
                  color: premiumPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "Are you sure you want to delete this customer?",
                style: TextStyle(color: Colors.black87),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: Text(
                      "Cancel",
                      style: TextStyle(color: premiumAccent),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(ctx);
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(currentUser!.uid)
                          .collection('customers')
                          .doc(docId)
                          .delete();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Customer deleted")),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text("Delete"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  ///  Helper for Premium text fields
  Widget _buildTextField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: premiumPrimary),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: premiumPrimary.withOpacity(0.5)),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: premiumPrimary),
        ),
      ),
    );
  }
}
