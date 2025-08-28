import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CustomersScreen extends StatelessWidget {
  const CustomersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Customers',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blueGrey,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('customers').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError)
            return const Center(child: Text('Something went wrong'));
          if (snapshot.connectionState == ConnectionState.waiting)
            return const Center(child: CircularProgressIndicator());

          final customers = snapshot.data!.docs;

          if (customers.isEmpty) {
            return const Center(child: Text('No customers added yet.'));
          }

          return ListView.builder(
            itemCount: customers.length,
            itemBuilder: (context, index) {
              final customer = customers[index].data() as Map<String, dynamic>;
              return ListTile(
                leading: const Icon(Icons.person, color: Colors.blueGrey),
                title: Text(customer['fullName'] ?? 'Unnamed'),
                subtitle: Text(customer['phone'] ?? ''),
                trailing: PopupMenuButton(
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'view', child: Text('View')),
                    const PopupMenuItem(value: 'edit', child: Text('Edit')),
                    const PopupMenuItem(value: 'delete', child: Text('Delete')),
                  ],
                  onSelected: (value) {
                    if (value == 'view') {
                      // TODO: View customer details
                    } else if (value == 'edit') {
                      // TODO: Edit customer
                    } else if (value == 'delete') {
                      FirebaseFirestore.instance
                          .collection('customers')
                          .doc(customers[index].id)
                          .delete();
                    }
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueGrey,
        onPressed: () {
          // TODO: Navigate to add customer screen
        },
        child: const Icon(
          Icons.add,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
