import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'receipt_processing_page.dart';

class ScanReceiptPage extends StatefulWidget {
  const ScanReceiptPage({super.key});

  @override
  State<ScanReceiptPage> createState() => _ScanReceiptPageState();
}

class _ScanReceiptPageState extends State<ScanReceiptPage> {
  final ImagePicker _imagePicker = ImagePicker();

  XFile? _capturedImage;
  bool _isAutoMode = true;
  bool _flashEnabled = false;

  Future<void> _captureReceipt() async {
    final image = await _imagePicker.pickImage(
      source: ImageSource.camera,
      imageQuality: 90,
    );

    if (image == null) {
      return;
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _capturedImage = image;
    });
  }

  Future<void> _importReceipt() async {
    final image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
    );

    if (image == null) {
      return;
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _capturedImage = image;
    });
  }

  void _retake() {
    setState(() {
      _capturedImage = null;
    });
  }

  void _usePhoto() {
    if (_capturedImage == null) {
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ReceiptProcessingPage(imagePath: _capturedImage!.path),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colors.inverseSurface,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(context),

            Expanded(child: _buildScannerArea(context)),

            _buildBottomControls(context),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: colors.inverseSurface,
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.close_rounded, color: colors.onInverseSurface),
          ),

          Expanded(
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildModeButton(
                      context,
                      label: 'AUTO',
                      selected: _isAutoMode,
                      onTap: () {
                        setState(() {
                          _isAutoMode = true;
                        });
                      },
                    ),
                    _buildModeButton(
                      context,
                      label: 'MANUAL',
                      selected: !_isAutoMode,
                      onTap: () {
                        setState(() {
                          _isAutoMode = false;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),

          IconButton(
            onPressed: () {
              setState(() {
                _flashEnabled = !_flashEnabled;
              });
            },
            icon: Icon(
              _flashEnabled ? Icons.flash_on_rounded : Icons.flash_off_rounded,
              color: colors.onInverseSurface,
            ),
          ),

          IconButton(
            onPressed: _importReceipt,
            icon: Icon(
              Icons.photo_library_outlined,
              color: colors.onInverseSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeButton(
    BuildContext context, {
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    final colors = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? colors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: selected
                ? colors.onPrimary
                : colors.onInverseSurface.withValues(alpha: 0.7),
          ),
        ),
      ),
    );
  }

  Widget _buildScannerArea(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      color: colors.inverseSurface,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (_capturedImage != null)
            Positioned.fill(
              child: Image.file(File(_capturedImage!.path), fit: BoxFit.cover),
            )
          else
            Positioned.fill(
              child: Container(color: Colors.black.withValues(alpha: 0.18)),
            ),

          Container(
            width: 280,
            height: 410,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: colors.primaryFixedDim, width: 2),
            ),
          ),

          if (_capturedImage == null)
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.document_scanner_outlined,
                  size: 48,
                  color: colors.primaryFixedDim,
                ),

                const SizedBox(height: 14),

                Text(
                  'Position receipt inside the frame',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: colors.onInverseSurface,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  'Ensure good lighting · Keep edges visible',
                  style: TextStyle(
                    fontSize: 12,
                    color: colors.onInverseSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildBottomControls(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 22),
      color: colors.surface,
      child: _capturedImage == null
          ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSmallAction(
                  context,
                  icon: Icons.photo_library_outlined,
                  label: 'Import',
                  onTap: _importReceipt,
                ),

                InkWell(
                  onTap: _captureReceipt,
                  borderRadius: BorderRadius.circular(999),
                  child: Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      color: colors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: colors.primaryContainer,
                        width: 6,
                      ),
                    ),
                    child: Icon(
                      Icons.photo_camera_rounded,
                      size: 32,
                      color: colors.onPrimary,
                    ),
                  ),
                ),

                _buildSmallAction(
                  context,
                  icon: Icons.layers_outlined,
                  label: 'Batch',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Batch scanning will be added later.'),
                      ),
                    );
                  },
                ),
              ],
            )
          : Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _retake,
                    icon: const Icon(Icons.replay_rounded),
                    label: const Text('Retake'),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: FilledButton.icon(
                    onPressed: _usePhoto,
                    icon: const Icon(Icons.check_circle_outline_rounded),
                    label: const Text('Use Photo'),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildSmallAction(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final colors = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: colors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: colors.onSurfaceVariant),
            ),

            const SizedBox(height: 5),

            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
