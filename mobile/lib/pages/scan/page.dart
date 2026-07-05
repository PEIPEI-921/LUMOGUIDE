import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  late final MobileScannerController _scannerController;
  bool _handled = false;

  @override
  void initState() {
    super.initState();
    _scannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
      torchEnabled: false,
    );
  }

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  void _onBarcodeDetected(BarcodeCapture capture) {
    if (_handled) return;
    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;
    final raw = barcodes.first.rawValue;
    if (raw == null || raw.isEmpty) return;
    final content = raw.trim();
    if (content.isEmpty) return;
    _handled = true;
    Get.back(result: content);
  }

  Future<void> _pickImageAndScan() async {
    final path = await ImagePickerUtil.selectImageFromGallery(
      context,
      canEdit: false,
    );
    if (path.isEmpty || !mounted) return;
    final capture = await _scannerController.analyzeImage(path);
    if (!mounted) return;
    if (capture == null || capture.barcodes.isEmpty) {
      Loading.error('未識別到群二維碼'.tr);
      return;
    }
    final raw = capture.barcodes.first.rawValue;
    if (raw == null || raw.isEmpty) {
      Loading.error('未識別到群二維碼'.tr);
      return;
    }
    final content = raw.trim();
    if (content.isEmpty) return;
    if (!mounted) return;
    Get.back(result: content);
  }

  Rect _scanWindow(BoxConstraints constraints) {
    final size = constraints.biggest;
    final side = (size.shortestSide * 0.7).clamp(200.0, 320.0);
    return Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: side,
      height: side,
    );
  }

  Widget _buildScanOverlay(BuildContext context, BoxConstraints constraints) {
    final rect = _scanWindow(constraints);
    return IgnorePointer(
      child: CustomPaint(
        size: constraints.biggest,
        painter: _ScanFramePainter(
          scanRect: rect,
          borderColor: Colors.white,
          overlayColor: Colors.black54,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return IScaffold(
      appBar: IAppBar(
        title: '掃一掃'.tr,
        actions: [
          IconButton(
            icon: Icon(Icons.photo_library_outlined, size: 24.w),
            onPressed: _pickImageAndScan,
            tooltip: '從相冊選擇'.tr,
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(
            controller: _scannerController,
            onDetect: _onBarcodeDetected,
            scanWindow: null,
            overlayBuilder: (context, constraints) =>
                _buildScanOverlay(context, constraints),
          ),
        ],
      ),
    );
  }
}

class _ScanFramePainter extends CustomPainter {
  _ScanFramePainter({
    required this.scanRect,
    this.borderColor = Colors.white,
    this.overlayColor = const Color(0x8A000000),
  });

  final Rect scanRect;
  final Color borderColor;
  final Color overlayColor;

  static const double _borderWidth = 2.0;
  static const double _borderRadius = 12.0;

  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPath = Path()..addRect(Offset.zero & size);
    final cutoutRRect = RRect.fromRectAndRadius(
      scanRect,
      const Radius.circular(_borderRadius),
    );
    final cutoutPath = Path()..addRRect(cutoutRRect);
    final overlayPath = Path.combine(
      PathOperation.difference,
      backgroundPath,
      cutoutPath,
    );
    canvas
      ..drawPath(overlayPath, Paint()..color = overlayColor)
      ..drawRRect(
        cutoutRRect,
        Paint()
          ..color = borderColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = _borderWidth,
      );
  }

  @override
  bool shouldRepaint(covariant _ScanFramePainter oldDelegate) {
    return oldDelegate.scanRect != scanRect;
  }
}
