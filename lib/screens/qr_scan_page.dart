import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart' as qr_plus;
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart'
    as mlkit;
import 'package:image_picker/image_picker.dart';
import 'payment_details_screen.dart';

class QrScanPage extends StatefulWidget {
  const QrScanPage({super.key});

  @override
  State<QrScanPage> createState() => _QrScanPageState();
}

class _QrScanPageState extends State<QrScanPage> {
  qr_plus.Barcode? result;
  qr_plus.QRViewController? controller;
  final mlkit.BarcodeScanner _barcodeScanner = mlkit.BarcodeScanner();
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  bool isScanning = true;
  bool isFlashOn = false;
  bool isFrontCamera = false;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _requestCameraPermission();
  }

  Future<void> _requestCameraPermission() async {
    var status = await Permission.camera.request();
    if (!status.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Camera permission is required to scan QR codes")),
      );
      Navigator.pop(context);
    }
  }

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller?.pauseCamera();
    }
    controller?.resumeCamera();
  }

  void _onQRViewCreated(qr_plus.QRViewController controller) {
    setState(() {
      this.controller = controller;
    });

    controller.scannedDataStream.listen((scanData) {
      if (isScanning) {
        isScanning = false;
        controller.pauseCamera();

        if (_isValidPaymentQR(scanData.code)) {
          Map<String, String> paymentDetails = _parseUPIQR(scanData.code!);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => PaymentDetailsScreen(
                paymentDetails: paymentDetails,
                upiId: '',
                amount: '',
                phoneNumber: '',
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Invalid payment QR code!")),
          );
          controller.resumeCamera();
          isScanning = true;
        }
      }
    });
  }

  bool _isValidPaymentQR(String? qrData) {
    if (qrData == null) return false;
    return qrData.contains("upi://pay") || qrData.contains("razorpay.com");
  }

  Map<String, String> _parseUPIQR(String qrData) {
    Uri uri = Uri.parse(qrData);
    return {
      "upi_id": uri.queryParameters["pa"] ?? "Not Available",
      "name": uri.queryParameters["pn"] ?? "Unknown",
      "amount": uri.queryParameters["am"] ?? "0.00",
      "transaction_id": uri.queryParameters["tr"] ?? "N/A",
      "currency": uri.queryParameters["cu"] ?? "INR",
    };
  }

  Future<void> _toggleFlash() async {
    await controller?.toggleFlash();
    bool? flashStatus = await controller?.getFlashStatus();
    setState(() {
      isFlashOn = flashStatus ?? false;
    });
  }

  Future<void> _flipCamera() async {
    await controller?.flipCamera();
    setState(() {
      isFrontCamera = !isFrontCamera;
    });
  }

  Future<void> _pickImageFromGallery() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() => _isProcessing = true);

      final qrData = await _processImage(File(image.path));

      setState(() => _isProcessing = false);

      if (qrData != null && _isValidPaymentQR(qrData)) {
        Map<String, String> paymentDetails = _parseUPIQR(qrData);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentDetailsScreen(
              paymentDetails: paymentDetails,
              upiId: '',
              amount: '',
              phoneNumber: '',
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Invalid payment QR code!")),
        );
      }
    }
  }

  Future<String?> _processImage(File imageFile) async {
    try {
      final inputImage = mlkit.InputImage.fromFile(imageFile);
      final barcodes = await _barcodeScanner.processImage(inputImage);

      for (final barcode in barcodes) {
        if (barcode.displayValue != null) {
          return barcode.displayValue;
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    _barcodeScanner.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Scan Qr Code",
          style: TextStyle(
            fontSize: screenWidth * 0.05,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon:
              const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: const Color(0xFF6F66A8),
        elevation: 0,
        shadowColor: Colors.transparent,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            flex: 5,
            child: Stack(
              alignment: Alignment.center,
              children: [
                qr_plus.QRView(
                  key: qrKey,
                  onQRViewCreated: _onQRViewCreated,
                  overlay: qr_plus.QrScannerOverlayShape(
                    borderColor: Color(0xFF6F66A8),
                    borderRadius: 10,
                    borderLength: 30,
                    borderWidth: 10,
                    cutOutSize: 250,
                  ),
                ),
                Positioned(
                  bottom: 60,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildCircularButton(
                        icon: isFlashOn ? Icons.flash_on : Icons.flash_off,
                        onPressed: _toggleFlash,
                      ),
                      const SizedBox(width: 20),
                      _buildCircularButton(
                        icon: isFrontCamera
                            ? Icons.camera_front
                            : Icons.camera_rear,
                        onPressed: _flipCamera,
                      ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 20,
                  child: const Text(
                    "Align the QR code within the frame",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildActionButton(
                    text: "Rescan QR",
                    onPressed: () {
                      controller?.resumeCamera();
                      isScanning = true;
                    },
                  ),
                  const SizedBox(height: 10),
                  _buildActionButton(
                    text: "Scan QR from Gallery",
                    onPressed: _pickImageFromGallery,
                  ),
                  if (_isProcessing) const CircularProgressIndicator(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircularButton(
      {required IconData icon, required VoidCallback onPressed}) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(30),
      child: SizedBox(
        width: 50,
        height: 50,
        child: Icon(icon, color: Colors.white, size: 28),
      ),
    );
  }

  Widget _buildActionButton({
    required String text,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF6F66A8), Color(0xFF8A77D9)], // Smooth gradient
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 6,
                offset: const Offset(2, 4), // Adds depth
              ),
            ],
          ),
          child: Center(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
