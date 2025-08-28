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
      // Editing
      _sizeController.text = data['size'] ?? '';
      _quantityController.text = (data['quantity'] ?? '').toString();
      _amountController.text = (data['amount'] ?? '').toString();
      _selectedCloth = data['clothType'] ?? 'Shirt';
      _isPaid = data['isPaid'] ?? false;
      _nameController.text = data['customerName'] ?? '';
      _phoneController.text = data['customerPhone'] ?? '';
    } else {
      // Adding new
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
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: "Customer Name",
                  labelStyle: TextStyle(color: Colors.white70),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: "Phone No",
                  labelStyle: TextStyle(color: Colors.white70),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                dropdownColor: Colors.grey[850],
                value: _selectedCloth,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: "Cloth Type",
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white70),
                  ),
                ),
                items: const ["Shirt", "Pant", "Suit", "Kurta", "Blouse"]
                    .map(
                      (cloth) =>
                          DropdownMenuItem(value: cloth, child: Text(cloth)),
                    )
                    .toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedCloth = val);
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _sizeController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: "Size",
                  labelStyle: TextStyle(color: Colors.white70),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _quantityController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: "Quantity",
                  labelStyle: TextStyle(color: Colors.white70),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: "Amount",
                  labelStyle: TextStyle(color: Colors.white70),
                ),
              ),
              SwitchListTile(
                value: _isPaid,
                onChanged: (val) => setState(() => _isPaid = val),
                title: const Text(
                  "Paid",
                  style: TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                onPressed: () async {
                  final user = FirebaseAuth.instance.currentUser;
                  if (user == null) return;

                  final qty = int.tryParse(_quantityController.text.trim());
                  final amt = double.tryParse(_amountController.text.trim());
                  if (qty == null || amt == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Enter valid numbers")),
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
                    // Add
                    await ordersRef.add(orderData);
                  } else {
                    // Update
                    await ordersRef.doc(docId).update(orderData);
                  }

                  Navigator.of(ctx).pop();
                },
                child: Text(docId == null ? "Add Receipt" : "Update Receipt"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// ✅ Delete Receipt
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
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: const Text("Receipts", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              onChanged: (val) {
                setState(() => _searchQuery = val.toLowerCase());
              },
              decoration: InputDecoration(
                hintText: "Search by Name or Phone",
                hintStyle: const TextStyle(color: Colors.white54),
                filled: true,
                fillColor: Colors.grey[800],
                prefixIcon: const Icon(Icons.search, color: Colors.white),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ),
      ),
      body: user == null
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
                      style: TextStyle(color: Colors.white70),
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
                            backgroundColor: Colors.blue,
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
                        color: Colors.blueGrey[700],
                        margin: const EdgeInsets.symmetric(
                          vertical: 6,
                          horizontal: 12,
                        ),
                        child: ListTile(
                          title: Text(
                            "${data['customerName'] ?? 'Unknown'} (${data['customerPhone'] ?? 'N/A'})",
                            style: const TextStyle(color: Colors.white),
                          ),
                          subtitle: Text(
                            "${data['clothType']} - Size: ${data['size']}\nQty: ${data['quantity']} | Rs ${data['amount']}",
                            style: const TextStyle(color: Colors.white70),
                          ),
                          trailing: Icon(
                            data['isPaid'] ? Icons.check_circle : Icons.pending,
                            color: data['isPaid'] ? Colors.green : Colors.red,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showReceiptForm(),
        backgroundColor: Colors.green,
        child: const Icon(Icons.add),
      ),
    );
  }

  /// ✅ Confirm Delete Receipt
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
          'Delete Receipt',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Are you sure you want to delete this receipt?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.blueAccent),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx); // close dialog
              await _deleteReceipt(docId);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Receipt deleted')));
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
