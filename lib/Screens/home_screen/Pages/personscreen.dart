import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/Screens/Auth_module/signIn_Screen.dart';
import 'package:flutter_application_1/Screens/home_screen/onboarding_screen/onboarding_Screens.dart';
import 'package:image_picker/image_picker.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final _auth = FirebaseAuth.instance;
  String? profileImageUrl;

  @override
  void initState() {
    super.initState();
    _loadProfileImage();
  }

  Future<void> _loadProfileImage() async {
    final user = _auth.currentUser;
    if (user != null) {
      final snapshot = await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .get();

      setState(() {
        profileImageUrl = snapshot.data()?['profileImage'];
      });
    }
  }

  Future<void> _pickImage(bool fromCamera) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: fromCamera ? ImageSource.camera : ImageSource.gallery,
      imageQuality: 75,
    );

    if (pickedFile != null) {
      File file = File(pickedFile.path);
      await _uploadImage(file);
    }
  }

  Future<void> _uploadImage(File imageFile) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child("profile_images")
          .child("${user.uid}.jpg");

      await ref.putFile(imageFile);
      final url = await ref.getDownloadURL();

      await FirebaseFirestore.instance.collection("users").doc(user.uid).update(
        {"profileImage": url},
      );

      setState(() {
        profileImageUrl = url;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Profile picture updated")));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error uploading image: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;

    return Scaffold(
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Profile',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.amber),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Color(0xFFFFF8E1)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(height: 40),

                // Profile Image
                Center(
                  child: Stack(
                    children: [
                      Container(
                        height: 120,
                        width: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.teal[100],
                          image: profileImageUrl != null
                              ? DecorationImage(
                                  image: NetworkImage(profileImageUrl!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: profileImageUrl == null
                            ? const Icon(
                                Icons.person,
                                size: 60,
                                color: Colors.white,
                              )
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: InkWell(
                          onTap: () {
                            _showImagePickerOptions();
                          },
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: Colors.teal,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // User Email
                Text(
                  user?.email ?? 'No email available',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Tailor Account',
                  style: TextStyle(
                    color: Colors.grey[800],
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 30),

                // Account Info Card
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                  color: Colors.white,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.teal[100],
                      child: const Icon(Icons.email, color: Colors.teal),
                    ),
                    title: const Text(
                      "Account Info",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    subtitle: Text(
                      user?.email ?? 'Not available',
                      style: const TextStyle(color: Colors.black54),
                    ),
                    trailing: const Icon(Icons.edit, color: Colors.teal),
                    onTap: () {
                      _showEditProfileDialog(context, user);
                    },
                  ),
                ),
                const SizedBox(height: 170),

                // Logout Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.logout, color: Colors.white),
                    label: const Text(
                      'Logout',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                    onPressed: () {
                      _showLogoutDialog(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange[700],
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Delete Account Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.delete_forever, color: Colors.white),
                    label: const Text(
                      'Delete Account',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                    onPressed: () {
                      _showDeleteAccountDialog(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[600],
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
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

  /// Logout Confirmation Dialog
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text(
          "Logout",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text("Are you sure you want to log out?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            onPressed: () async {
              Navigator.pop(ctx); // close dialog
              await _auth.signOut();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => SigninScreen()),
                (route) => false,
              );
            },
            child: const Text("Logout", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => Wrap(
        children: [
          ListTile(
            leading: const Icon(Icons.photo, color: Colors.black),
            title: const Text(
              "Pick from Gallery",
              style: TextStyle(color: Colors.black),
            ),
            onTap: () {
              Navigator.pop(ctx);
              _pickImage(false);
            },
          ),
          ListTile(
            leading: const Icon(Icons.camera_alt, color: Colors.black),
            title: const Text(
              "Take a Picture",
              style: TextStyle(color: Colors.black),
            ),
            onTap: () {
              Navigator.pop(ctx);
              _pickImage(true);
            },
          ),
        ],
      ),
    );
  }

  /// Delete Confirmation Dialog
  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text(
          "Delete Account",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          "Are you sure you want to permanently delete your account? This action cannot be undone.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await _auth.currentUser?.delete();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => OnboardingScreen()),
                );
              } catch (e) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text("Error: $e")));
              }
            },
            child: const Text("Delete", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  /// Edit Profile Dialog (light theme)
  void _showEditProfileDialog(BuildContext context, User? user) {
    final TextEditingController nameController = TextEditingController(
      text: user?.displayName ?? "",
    );
    final TextEditingController emailController = TextEditingController(
      text: user?.email ?? "",
    );
    final TextEditingController passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.8,
              ),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.white, Color(0xFFFFF8E1)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 20,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Edit Profile",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: nameController,
                      style: const TextStyle(color: Colors.black),
                      decoration: const InputDecoration(
                        labelText: "Name",
                        labelStyle: TextStyle(color: Colors.black54),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black54),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.teal),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: emailController,
                      style: const TextStyle(color: Colors.black),
                      decoration: const InputDecoration(
                        labelText: "Email",
                        labelStyle: TextStyle(color: Colors.black54),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black54),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.teal),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: passwordController,
                      obscureText: true,
                      style: const TextStyle(color: Colors.black),
                      decoration: const InputDecoration(
                        labelText: "Password (for security)",
                        labelStyle: TextStyle(color: Colors.black54),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black54),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.teal),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text(
                            "Cancel",
                            style: TextStyle(color: Colors.black54),
                          ),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                          ),
                          onPressed: () async {
                            final newName = nameController.text.trim();
                            final newEmail = emailController.text.trim();

                            if (newName.isNotEmpty || newEmail.isNotEmpty) {
                              if (newName.isNotEmpty) {
                                await user?.updateDisplayName(newName);
                              }
                              if (newEmail.isNotEmpty &&
                                  newEmail != user?.email) {
                                await (newEmail);
                              }

                              await FirebaseFirestore.instance
                                  .collection("users")
                                  .doc(user?.uid)
                                  .update({
                                    "fullName": newName,
                                    "email": newEmail,
                                  });
                            }

                            Navigator.pop(ctx);
                            setState(() {});
                          },
                          child: const Text(
                            "Save",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
