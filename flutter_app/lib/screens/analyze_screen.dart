import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/user_profile.dart';
import '../services/api_service.dart';
import '../models/meal.dart';
import 'result_screen.dart';

class AnalyzeScreen extends StatefulWidget {
  final UserProfile profile;
  final VoidCallback onMealSaved; // ← called by ResultScreen after save

  const AnalyzeScreen(
      {super.key, required this.profile, required this.onMealSaved});

  @override
  State<AnalyzeScreen> createState() => _AnalyzeScreenState();
}

class _AnalyzeScreenState extends State<AnalyzeScreen> {
  Uint8List? _imageBytes;
  String? _imageName;
  bool _isLoading = false;
  final _picker = ImagePicker();

  Future<void> _pick(ImageSource source) async {
    final f = await _picker.pickImage(
        source: source, imageQuality: 85, maxWidth: 800);
    if (f != null) {
      final bytes = await f.readAsBytes();
      setState(() {
        _imageBytes = bytes;
        _imageName = f.name;
      });
    }
  }

  Future<void> _analyze() async {
    if (_imageBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Please select an image first.')));
      return;
    }
    setState(() => _isLoading = true);
    try {
      final result = await ApiService.predictFood(
          _imageBytes!, _imageName ?? 'food.jpg');
      final meal =
          Meal.fromPrediction(result, widget.profile.uid);
      final confidence =
          (result['confidence'] as num).toDouble();
      if (!mounted) return;
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ResultScreen(
            meal: meal,
            imageBytes: _imageBytes!,
            confidence: confidence,
            profile: widget.profile,
            onMealSaved: widget.onMealSaved, // ← pass callback down
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red.shade700));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FBF8),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2D6A4F),
        automaticallyImplyLeading: false,
        title: const Text('Analyze Food',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(children: [
          const SizedBox(height: 8),
          const Text(
            'Snap your meal,\nknow your nutrition.',
            style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1B4332),
                height: 1.3),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            'Powered by AI · 101 food categories',
            style: TextStyle(
                fontSize: 13, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 28),

          // Image preview
          GestureDetector(
            onTap: _showSheet,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: double.infinity,
              height: 250,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: _imageBytes != null
                      ? const Color(0xFF2D6A4F)
                      : Colors.grey.shade300,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                      color:
                          Colors.black.withValues(alpha: 0.05),
                      blurRadius: 12,
                      offset: const Offset(0, 4))
                ],
              ),
              child: _imageBytes != null
                  ? ClipRRect(
                      borderRadius:
                          BorderRadius.circular(20),
                      child: Image.memory(_imageBytes!,
                          fit: BoxFit.cover))
                  : Column(
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      children: [
                        Icon(
                            Icons
                                .add_photo_alternate_outlined,
                            size: 52,
                            color: Colors.grey.shade400),
                        const SizedBox(height: 10),
                        Text(
                          'Tap to select a food image',
                          style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 14),
                        ),
                      ],
                    ),
            ),
          ),

          const SizedBox(height: 20),

          Row(children: [
            Expanded(
                child: _SrcBtn(Icons.camera_alt_outlined,
                    'Camera', () => _pick(ImageSource.camera))),
            const SizedBox(width: 12),
            Expanded(
                child: _SrcBtn(
                    Icons.photo_library_outlined,
                    'Gallery',
                    () => _pick(ImageSource.gallery))),
          ]),

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _analyze,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2D6A4F),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5))
                  : const Text('Analyze Food',
                      style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold)),
            ),
          ),

          const SizedBox(height: 24),

          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(12),
              border:
                  Border.all(color: Colors.amber.shade200),
            ),
            child: Row(children: [
              Icon(Icons.info_outline,
                  color: Colors.amber.shade700, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Nutrition values are AI estimates and not medically accurate.',
                  style: TextStyle(
                      fontSize: 12,
                      color: Colors.amber.shade900),
                ),
              ),
            ]),
          ),
        ]),
      ),
    );
  }

  void _showSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take a photo'),
              onTap: () {
                Navigator.pop(context);
                _pick(ImageSource.camera);
              }),
          ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from gallery'),
              onTap: () {
                Navigator.pop(context);
                _pick(ImageSource.gallery);
              }),
        ]),
      ),
    );
  }
}

class _SrcBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _SrcBtn(this.icon, this.label, this.onTap);
  @override
  Widget build(BuildContext context) =>
      OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 18),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          padding:
              const EdgeInsets.symmetric(vertical: 13),
          foregroundColor: const Color(0xFF2D6A4F),
          side: const BorderSide(
              color: Color(0xFF2D6A4F)),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
        ),
      );
}