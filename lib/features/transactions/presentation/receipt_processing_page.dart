import 'dart:io';

import 'package:flutter/material.dart';

import 'review_receipt_page.dart';

class ReceiptProcessingPage extends StatefulWidget {
  final String imagePath;

  const ReceiptProcessingPage({
    super.key,
    required this.imagePath,
  });

  @override
  State<ReceiptProcessingPage> createState() =>
      _ReceiptProcessingPageState();
}

class _ReceiptProcessingPageState
    extends State<ReceiptProcessingPage> {
  int _currentStep = 0;

  final List<String> _steps = [
    'Detecting receipt',
    'Reading merchant and date',
    'Extracting items',
    'Finding total',
    'Suggesting category',
  ];

  @override
  void initState() {
    super.initState();

    _startFakeProcessing();
  }

  Future<void> _startFakeProcessing() async {
    for (int i = 0; i < _steps.length; i++) {
      await Future.delayed(
        const Duration(milliseconds: 900),
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _currentStep = i + 1;
      });
    }

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Receipt processing completed.',
        ),
      ),
    );

    // 让用户看到一下 5/5 + Receipt processed!
    await Future.delayed(
      const Duration(milliseconds: 700),
    );

    if (!mounted) {
      return;
    }

    // Processing Page 完成后，进入 Review Receipt
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ReviewReceiptPage(
          imagePath: widget.imagePath,
        ),
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
        title: const Text(
          'Scan Receipt',
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.close_rounded,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            16,
            8,
            16,
            32,
          ),
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
            color: Colors.black.withValues(
              alpha: 0.04,
            ),
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
          child: Image.file(
            File(widget.imagePath),
            fit: BoxFit.cover,
          ),
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
              : 'Mofiney is extracting line items, merchant details and totals.',
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
            color: Colors.black.withValues(
              alpha: 0.04,
            ),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
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
                  borderRadius:
                      BorderRadius.circular(999),
                ),
                child: Text(
                  '$_currentStep of ${_steps.length} done',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color:
                        colors.onPrimaryFixedVariant,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          for (int i = 0; i < _steps.length; i++) ...[
            _buildProgressStep(
              context,
              index: i,
              label: _steps[i],
            ),

            if (i != _steps.length - 1)
              _buildConnector(context, i),
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

    final bool active =
        index == _currentStep &&
        _currentStep < _steps.length;

    return AnimatedContainer(
      duration: const Duration(
        milliseconds: 250,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: active
            ? colors.surfaceContainerLow
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(
              milliseconds: 250,
            ),
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
                      color:
                          colors.onPrimaryContainer,
                    )
                  : active
                      ? SizedBox(
                          width: 15,
                          height: 15,
                          child:
                              CircularProgressIndicator(
                            strokeWidth: 2,
                            color: colors.onPrimary,
                          ),
                        )
                      : Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color:
                                colors.onSurfaceVariant,
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
                fontWeight: active
                    ? FontWeight.w600
                    : FontWeight.w500,
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
              padding: const EdgeInsets.symmetric(
                horizontal: 9,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color:
                    colors.surfaceContainerHighest,
                borderRadius:
                    BorderRadius.circular(999),
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
              style: TextStyle(
                fontSize: 12,
                color: colors.onSurfaceVariant,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildConnector(
    BuildContext context,
    int index,
  ) {
    final colors = Theme.of(context).colorScheme;

    final bool completed =
        index < _currentStep - 1;

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(
          left: 22,
        ),
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
        crossAxisAlignment:
            CrossAxisAlignment.start,
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
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'HELPFUL TIP',
                  style: TextStyle(
                    fontSize: 11,
                    letterSpacing: 0.8,
                    fontWeight: FontWeight.w600,
                    color:
                        colors.onSecondaryContainer,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  'You\'ll be able to review and edit every line item and amount on the next screen.',
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.5,
                    color:
                        colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityFooter(
    BuildContext context,
  ) {
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
          style: TextStyle(
            fontSize: 12,
            color: colors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}