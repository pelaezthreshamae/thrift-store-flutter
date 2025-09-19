// lib/pages/add_item_page.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../services/supabase_service.dart';
import '../../widgets/custom_input_field.dart';

class AddItemPage extends StatefulWidget {
  const AddItemPage({super.key});
  @override
  AddItemPageState createState() => AddItemPageState();
}

class AddItemPageState extends State<AddItemPage> {
  final _nameCtrl    = TextEditingController();
  final _titleCtrl   = TextEditingController();
  final _descCtrl    = TextEditingController();
  final _priceCtrl   = TextEditingController();
  final _contactCtrl = TextEditingController();
  File? _image;
  final picker = ImagePicker();
  bool _uploading = false;

  Future<void> pickImage() async {
    final XFile? img = await picker.pickImage(source: ImageSource.gallery);
    if (img != null) setState(() => _image = File(img.path));
  }

  Future<void> _handleUpload() async {
    if (_nameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your name')),
      );
      return;
    }
    if (_image == null) return;

    setState(() => _uploading = true);
    final svc = Provider.of<SupabaseService>(context, listen: false);

    await svc.addItem(
      title:        _titleCtrl.text.trim(),
      desc:         _descCtrl.text.trim(),
      price:        double.tryParse(_priceCtrl.text) ?? 0,
      contact:      _contactCtrl.text.trim(),
      uploaderName: _nameCtrl.text.trim(),
      image:        _image!,
    );

    setState(() => _uploading = false);
    if (svc.error == null) {
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${svc.error}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final canUpload = _image != null && !_uploading;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF7F00FF), Color(0xFFE100FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        extendBody: true,

        appBar: AppBar(
          backgroundColor: Colors.deepPurple.withOpacity(0.9),
          elevation: 6,
          title: Text(
            '🛍 Add Your Thrift',
            style: GoogleFonts.lato(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          centerTitle: true,
        ),

        body: SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [

                CustomInputField(
                  controller: _titleCtrl,
                  label: 'Item Title',
                  icon: Icons.label_outline,
                ),
                const SizedBox(height: 16),


                CustomInputField(
                  controller: _descCtrl,
                  label: 'Description',
                  icon: Icons.description_outlined,
                  maxLines: 3,
                ),
                const SizedBox(height: 16),


                CustomInputField(
                  controller: _priceCtrl,
                  label: 'Price (Php)',
                  icon: Icons.attach_money,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),


                CustomInputField(
                  controller: _nameCtrl,
                  label: 'Your Display Name',
                  icon: Icons.person_outline,
                ),
                const SizedBox(height: 16),


                CustomInputField(
                  controller: _contactCtrl,
                  label: 'Contact Email',
                  icon: Icons.contact_mail_outlined,
                ),
                const SizedBox(height: 24),


                _image == null
                    ? ElevatedButton.icon(
                  icon: const Icon(Icons.photo_library, size: 24, color: Colors.white),
                  label: Text(
                    'Choose Photo',
                    style: GoogleFonts.lato(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pinkAccent,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: pickImage,
                )
                    : Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(_image!, height: 180, fit: BoxFit.cover),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => setState(() => _image = null),
                      child: Text(
                        'Re-pick Image',
                        style: GoogleFonts.lato(color: Colors.yellowAccent),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),


                ElevatedButton(
                  onPressed: canUpload ? _handleUpload : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 8,
                  ),
                  child: _uploading
                      ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                      : Text(
                    'Upload Item',
                    style: GoogleFonts.lato(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
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
}
