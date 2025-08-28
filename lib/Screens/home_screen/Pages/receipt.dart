import 'package:flutter/material.dart';

class Receiptscreen extends StatefulWidget {
  const Receiptscreen({super.key});

  @override
  State<Receiptscreen> createState() => _ReceiptscreenState();
}

class _ReceiptscreenState extends State<Receiptscreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text("Receipt Page")));
  }
}
