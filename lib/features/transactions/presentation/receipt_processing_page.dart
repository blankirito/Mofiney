import 'dart:io';

import 'package:flutter/material.dart';

import 'review_receipt_page.dart';

import '../data/receipt_ocr_service.dart';
import '../domain/receipt_ocr_draft.dart';

import 'package:image_picker/image_picker.dart';

class ReceiptProcessingPage extends StatefulWidget {
  final String imagePath;

  const ReceiptProcessingPage({super.key, required this.imagePath});

  @override
  State<ReceiptProcessingPage> createState() => _ReceiptProcessingPageState();
}

class _ReceiptProcessingPageState extends State<ReceiptProcessingPage> {
  int _currentStep = 0;

  final ImagePicker _imagePicker = ImagePicker();

  String? _errorMessage;

  final List<String> _steps = [
    'Preparing receipt image',
    'Reading receipt text',
    'Finding merchant and date',
    'Finding total amount',
    'Preparing review',
  ];

  @override
  void initState() {
    super.initState();

    _startProcessing();
  }

  Future<void> _startProcessing() async {
    try {
      final recognition = ReceiptOcrService().recognize(widget.imagePath);

      for (var index = 0; index < _steps.length - 1; index++) {
        await Future.delayed(const Duration(milliseconds: 350));

        if (!mounted) {
          return;
        }

        setState(() {
          _currentStep = index + 1;
        });
      }

      final ReceiptOcrDraft draft = await recognition;

      if (!mounted) {
        return;
      }

      setState(() {
        _currentStep = _steps.length;
      });

      await Future.delayed(const Duration(milliseconds: 500));

      if (!mounted) {
        return;
      }

      final savedTransaction = await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) =>
              ReviewReceiptPage(imagePath: widget.imagePath, draft: draft),
        ),
      );

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop(savedTransaction);
    } on ReceiptOcrException catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _errorMessage = error.message;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _errorMessage =
            'Could not read this receipt. Please try another photo.';
      });
    }
  }

  Future<void> _pickReplacementReceipt(ImageSource source) async {
    final image = await _imagePicker.pickImage(
      source: source,
      imageQuality: 90,
    );

    if (image == null || !mounted) {
      return;
    }

    final savedTransaction = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ReceiptProcessingPage(imagePath: image.path),
      ),
    );

    if (!mounted || savedTransaction == null) {
      return;
    }

    Navigator.of(context).pop(savedTransaction);
  }

  Widget _buildErrorCard(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.errorContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(
            Icons.receipt_long_outlined,
            color: colors.onErrorContainer,
            size: 32,
          ),
          const SizedBox(height: 10),
          Text(
            'We could not read this receipt',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: colors.onErrorContainer,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _errorMessage ?? 'Please try another photo.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              height: 1.4,
              color: colors.onErrorContainer,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    _pickReplacementReceipt(ImageSource.camera);
                  },
                  icon: const Icon(Icons.camera_alt_outlined),
                  label: const Text('Retake'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () {
                    _pickReplacementReceipt(ImageSource.gallery);
                  },
                  icon: const Icon(Icons.photo_library_outlined),
                  label: const Text('Choose from Gallery'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        backgroundColor: colors.surface,
        elevation: 0,
        title: const Text('Scan Receipt'),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.close_rounded),
        ),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          child: Column(
            children: [
              _buildReceiptPreview(context),

              const SizedBox(height: 20),

              _buildTitle(context),

              const SizedBox(height: 24),

              _buildProgressCard(context),

              const SizedBox(height: 16),

              _buildTipCard(context),

              const SizedBox(height: 24),

              _buildSecurityFooter(context),
              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                _buildErrorCard(context),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReceiptPreview(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: 170,
          height: 220,
          decoration: BoxDecoration(
            color: colors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12),
          ),
          clipBehavior: Clip.antiAlias,
          child: Image.file(File(widget.imagePath), fit: BoxFit.cover),
        ),
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Column(
      children: [
        Text(
          _currentStep >= _steps.length
              ? 'Receipt processed!'
              : 'Reading your receipt...',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24,
            height: 1.25,
            fontWeight: FontWeight.w600,
            color: colors.onSurface,
          ),
        ),

        const SizedBox(height: 8),

        Text(
          _currentStep >= _steps.length
              ? 'Your receipt is ready for review.'
              : 'Mofiney is reading receipt text, merchant details and totals.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            height: 1.5,
            color: colors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressCard(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'EXTRACTION PROGRESS',
                style: TextStyle(
                  fontSize: 11,
                  letterSpacing: 0.8,
                  fontWeight: FontWeight.w600,
                  color: colors.onSurfaceVariant,
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: colors.primaryFixed,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '$_currentStep of ${_steps.length} done',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: colors.onPrimaryFixedVariant,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          for (int i = 0; i < _steps.length; i++) ...[
            _buildProgressStep(context, index: i, label: _steps[i]),

            if (i != _steps.length - 1) _buildConnector(context, i),
          ],
        ],
      ),
    );
  }

  Widget _buildProgressStep(
    BuildContext context, {
    required int index,
    required String label,
  }) {
    final colors = Theme.of(context).colorScheme;

    final bool completed = index < _currentStep;

    final bool active = index == _currentStep && _currentStep < _steps.length;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: active ? colors.surfaceContainerLow : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: completed
                  ? colors.primaryContainer
                  : active
                  ? colors.primary
                  : colors.surfaceContainer,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: completed
                  ? Icon(
                      Icons.check_rounded,
                      size: 17,
                      color: colors.onPrimaryContainer,
                    )
                  : active
                  ? SizedBox(
                      width: 15,
                      height: 15,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: colors.onPrimary,
                      ),
                    )
                  : Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: colors.onSurfaceVariant,
                        shape: BoxShape.circle,
                      ),
                    ),
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: active ? 16 : 14,
                fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                color: completed || active
                    ? colors.onSurface
                    : colors.onSurfaceVariant,
              ),
            ),
          ),

          if (completed)
            Text(
              'Done',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: colors.tertiary,
              ),
            )
          else if (active)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
              decoration: BoxDecoration(
                color: colors.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                'Processing',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: colors.onSurfaceVariant,
                ),
              ),
            )
          else
            Text(
              'Pending',
              style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant),
            ),
        ],
      ),
    );
  }

  Widget _buildConnector(BuildContext context, int index) {
    final colors = Theme.of(context).colorScheme;

    final bool completed = index < _currentStep - 1;

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(left: 22),
        width: 2,
        height: 10,
        color: completed
            ? colors.primaryFixedDim
            : colors.surfaceContainerHighest,
      ),
    );
  }

  Widget _buildTipCard(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: colors.secondaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.lightbulb_outline_rounded,
              size: 19,
              color: colors.onSecondaryContainer,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'HELPFUL TIP',
                  style: TextStyle(
                    fontSize: 11,
                    letterSpacing: 0.8,
                    fontWeight: FontWeight.w600,
                    color: colors.onSecondaryContainer,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  'You\'ll be able to review and edit the merchant, date and amount on the next screen.',
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.5,
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityFooter(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.lock_outline_rounded,
          size: 15,
          color: colors.onSurfaceVariant,
        ),

        const SizedBox(width: 6),

        Text(
          'Secure on-device receipt processing',
          style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant),
        ),
      ],
    );
  }
}
