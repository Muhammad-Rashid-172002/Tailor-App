import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class Receiptscreen extends StatefulWidget {
  final String customerId;
  const Receiptscreen({super.key, required this.customerId});

  @override
  State<Receiptscreen> createState() => _ReceiptscreenState();
}

class _ReceiptscreenState extends State<Receiptscreen> {
  final TextEditingController _sizeController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  String _selectedCloth = "Shirt";
  bool _isPaid = false;
  String _searchQuery = "";

  // Premium Luxury Color Palette
  final Color premiumPrimary = const Color(0xFFFFB300); // Amber
  final Color premiumSecondary = const Color(0xFF37474F); // Blue Grey 800
  final Color premiumBackground = const Color(0xFFFFFFFF); // White
  final Color premiumAccent = const Color(0xFFF57C00); // Deep Orange

  @override
  void dispose() {
    _sizeController.dispose();
    _quantityController.dispose();
    _amountController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  ///  Show Add/Edit Receipt Form
  void _showReceiptForm({String? docId, Map<String, dynamic>? data}) {
    if (data != null) {
      _sizeController.text = data['size'] ?? '';
      _quantityController.text = (data['quantity'] ?? '').toString();
      _amountController.text = (data['amount'] ?? '').toString();
      _selectedCloth = data['clothType'] ?? 'Shirt';
      _isPaid = data['isPaid'] ?? false;
      _nameController.text = data['customerName'] ?? '';
      _phoneController.text = data['customerPhone'] ?? '';
    } else {
      _sizeController.clear();
      _quantityController.clear();
      _amountController.clear();
      _nameController.clear();
      _phoneController.clear();
      _selectedCloth = "Shirt";
      _isPaid = false;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent, //  Transparent so gradient shows
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Color(0xFFFFF8E1)], // soft gradient
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header bar
                Center(
                  child: Container(
                    width: 50,
                    height: 5,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: premiumPrimary.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                Text(
                  docId == null ? "Add New Receipt" : "Update Receipt",
                  style: TextStyle(
                    color: premiumPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),

                // Form fields
                _buildTextField("Customer Name", _nameController),
                const SizedBox(height: 14),
                _buildTextField(
                  "Phone No",
                  _phoneController,
                  keyboard: TextInputType.phone,
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  dropdownColor: premiumSecondary,
                  value: _selectedCloth,
                  style: const TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    labelText: "Cloth Type",
                    labelStyle: TextStyle(color: premiumPrimary),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: premiumPrimary.withOpacity(0.6),
                      ),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: premiumAccent, width: 2),
                    ),
                  ),
                  items: const ["Shirt", "Pant", "Suit", "Kurta", "Blouse"]
                      .map(
                        (cloth) => DropdownMenuItem(
                          value: cloth,
                          child: Text(
                            cloth,
                            style: const TextStyle(color: Colors.black),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedCloth = val);
                  },
                ),
                const SizedBox(height: 14),
                _buildTextField("Size", _sizeController),
                const SizedBox(height: 14),
                _buildTextField(
                  "Quantity",
                  _quantityController,
                  keyboard: TextInputType.number,
                ),
                const SizedBox(height: 14),
                _buildTextField(
                  "Amount",
                  _amountController,
                  keyboard: TextInputType.number,
                ),
                const SizedBox(height: 10),
                SwitchListTile(
                  value: _isPaid,
                  onChanged: (val) => setState(() => _isPaid = val),
                  activeColor: premiumAccent,
                  contentPadding: EdgeInsets.zero,
                  title: const Text(
                    "Paid",
                    style: TextStyle(color: Colors.black87),
                  ),
                ),

                const SizedBox(height: 24),

                // Action button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: premiumAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 4,
                    ),
                    onPressed: () async {
                      final user = FirebaseAuth.instance.currentUser;
                      if (user == null) return;

                      final qty = int.tryParse(_quantityController.text.trim());
                      final amt = double.tryParse(
                        _amountController.text.trim(),
                      );
                      if (qty == null || amt == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text("Enter valid numbers"),
                            backgroundColor: Colors.redAccent,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        );
                        return;
                      }

                      final orderData = {
                        "customerName": _nameController.text.trim(),
                        "customerPhone": _phoneController.text.trim(),
                        "clothType": _selectedCloth,
                        "size": _sizeController.text.trim(),
                        "quantity": qty,
                        "amount": amt,
                        "isPaid": _isPaid,
                        "createdAt": FieldValue.serverTimestamp(),
                      };

                      final ordersRef = FirebaseFirestore.instance
                          .collection("users")
                          .doc(user.uid)
                          .collection("customers")
                          .doc(widget.customerId)
                          .collection("orders");

                      if (docId == null) {
                        await ordersRef.add(orderData);
                      } else {
                        await ordersRef.doc(docId).update(orderData);
                      }

                      Navigator.of(ctx).pop();
                    },
                    child: Text(
                      docId == null ? "Add Receipt" : "Update Receipt",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
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

  ///  Delete Receipt
  Future<void> _deleteReceipt(String docId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .collection("customers")
        .doc(widget.customerId)
        .collection("orders")
        .doc(docId)
        .delete();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          "Receipts",
          style: TextStyle(color: premiumPrimary, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.black),
              onChanged: (val) {
                setState(() => _searchQuery = val.toLowerCase());
              },
              decoration: InputDecoration(
                hintText: "Search by Name or Phone",
                hintStyle: const TextStyle(color: Colors.black54),
                filled: true,
                fillColor: premiumBackground,
                prefixIcon: Icon(Icons.search, color: premiumPrimary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: premiumPrimary.withOpacity(0.5),
                  ),
                ),
              ),
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
        child: user == null
            ? const Center(child: Text("Not logged in"))
            : StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection("users")
                    .doc(user.uid)
                    .collection("customers")
                    .doc(widget.customerId)
                    .collection("orders")
                    .orderBy("createdAt", descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final receipts = snapshot.data!.docs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final name = (data['customerName'] ?? '')
                        .toString()
                        .toLowerCase();
                    final phone = (data['customerPhone'] ?? '')
                        .toString()
                        .toLowerCase();
                    return name.contains(_searchQuery) ||
                        phone.contains(_searchQuery);
                  }).toList();

                  if (receipts.isEmpty) {
                    return const Center(
                      child: Text(
                        "No receipts found",
                        style: TextStyle(color: Colors.black54),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: receipts.length,
                    itemBuilder: (context, index) {
                      final doc = receipts[index];
                      final data = doc.data() as Map<String, dynamic>;

                      return Slidable(
                        key: ValueKey(doc.id),
                        endActionPane: ActionPane(
                          motion: const DrawerMotion(),
                          children: [
                            SlidableAction(
                              onPressed: (_) =>
                                  _showReceiptForm(docId: doc.id, data: data),
                              backgroundColor: premiumAccent,
                              foregroundColor: Colors.white,
                              icon: Icons.edit,
                              label: 'Edit',
                            ),
                            SlidableAction(
                              onPressed: (_) => _confirmDelete(context, doc.id),
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              icon: Icons.delete,
                              label: 'Delete',
                            ),
                          ],
                        ),
                        child: Card(
                          color: premiumBackground,
                          margin: const EdgeInsets.symmetric(
                            vertical: 6,
                            horizontal: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: premiumPrimary.withOpacity(0.3),
                            ),
                          ),
                          elevation: 3,
                          child: ListTile(
                            title: Text(
                              "${data['customerName'] ?? 'Unknown'} (${data['customerPhone'] ?? 'N/A'})",
                              style: TextStyle(
                                color: premiumPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              "${data['clothType']} - Size: ${data['size']}\nQty: ${data['quantity']} | Rs ${data['amount']}",
                              style: TextStyle(
                                color: premiumSecondary.withOpacity(0.8),
                              ),
                            ),
                            trailing: Icon(
                              data['isPaid']
                                  ? Icons.check_circle
                                  : Icons.pending,
                              color: data['isPaid']
                                  ? premiumAccent
                                  : Colors.red,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showReceiptForm(),
        backgroundColor: premiumPrimary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  ///  Confirm Delete Receipt
  void _confirmDelete(BuildContext context, String docId) {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent accidental dismiss
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.transparent, //  Transparent so gradient shows
        shape: RoundedRectangleBorder(
          side: BorderSide(color: premiumPrimary, width: 2),
          borderRadius: BorderRadius.circular(20),
        ),
        contentPadding: EdgeInsets.zero, //  so gradient fills entire dialog
        content: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.white, Color(0xFFFFF8E1)], // soft gradient
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title row
                Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: premiumPrimary,
                      size: 28,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Confirm Deletion',
                      style: TextStyle(
                        color: premiumPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Content text
                const Text(
                  'This action cannot be undone.\nAre you sure you want to delete this receipt?',
                  style: TextStyle(color: Colors.black87, fontSize: 15),
                ),
                const SizedBox(height: 20),

                // Actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: premiumAccent, width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => Navigator.pop(ctx),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: premiumAccent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 10,
                        ),
                      ),
                      onPressed: () async {
                        Navigator.pop(ctx);
                        await _deleteReceipt(docId);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Receipt deleted'),
                            backgroundColor: premiumAccent,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        );
                      },
                      child: const Text(
                        'Delete',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  ///  Reusable text field builder
  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    TextInputType keyboard = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboard,
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
