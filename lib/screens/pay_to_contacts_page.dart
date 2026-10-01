import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'payment_details_screen.dart';

class PayToContactsPage extends StatefulWidget {
  const PayToContactsPage({super.key, String? initialRecipient, String? initialAmount});

  @override
  State<PayToContactsPage> createState() => _PayToContactsPageState();
}

class _PayToContactsPageState extends State<PayToContactsPage> {
  List<Contact> contacts = [];
  List<Contact> filteredContacts = [];
  bool isLoading = true;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchContacts(); // Initial load without requesting permission
  }

  // Request contacts permission when needed
  Future<void> _requestContactsPermission(Contact contact) async {
    if (kIsWeb) {
      _navigateToPayment(contact);
      return;
    }

    var status = await Permission.contacts.status;

    if (status.isGranted) {
      _navigateToPayment(
          contact); // Proceed directly if permission is already granted
    } else if (status.isDenied || status.isPermanentlyDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              const Text("Contacts permission denied. Enable from settings."),
          action: SnackBarAction(
            label: "Open Settings",
            onPressed: () {
              openAppSettings();
            },
          ),
        ),
      );
    } else {
      // Request permission if not yet granted
      var newStatus = await Permission.contacts.request();
      if (newStatus.isGranted) {
        _navigateToPayment(contact);
      }
    }
  }

  // Fetch contacts with proper permission handling
  Future<void> _fetchContacts() async {
    if (kIsWeb) {
      setState(() {
        contacts = [
          Contact(displayName: "Rahul Sharma", phones: [Phone("9876543210")]),
          Contact(displayName: "Priya Patel", phones: [Phone("9123456780")]),
          Contact(displayName: "Aditya Verma", phones: [Phone("9988776655")]),
          Contact(displayName: "Aman Gupta", phones: [Phone("9811223344")]),
        ];
        filteredContacts = contacts;
        isLoading = false;
      });
      return;
    }

    var status = await Permission.contacts.status;

    if (!status.isGranted) {
      var newStatus = await Permission.contacts.request();
      if (!newStatus.isGranted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Contacts permission is required.")),
        );
        return;
      }
    }

    try {
      List<Contact> deviceContacts = await FlutterContacts.getContacts(
        withProperties: true,
        withPhoto: false,
      );

      setState(() {
        contacts = deviceContacts;
        filteredContacts = contacts;
        isLoading = false;
      });

      debugPrint("Fetched ${contacts.length} contacts ✅");
    } catch (e) {
      debugPrint("Error fetching contacts: $e ❌");
      setState(() => isLoading = false);
    }
  }

  // Filter contacts based on search input
  void _filterContacts(String query) {
    setState(() {
      filteredContacts = contacts
          .where((contact) =>
              contact.displayName.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  // Navigate to Payment Details Page on Tap
  void _navigateToPayment(Contact contact) {
    if (contact.phones.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("This contact has no phone number.")),
      );
      return;
    }

    // Clean the phone number (strip spaces, dashes)
    final rawPhone = contact.phones.first.number.replaceAll(RegExp(r'[\s\-]'), '');
    // Remove country code prefix if present, keep last 10 digits
    final cleanPhone = rawPhone.length > 10
        ? rawPhone.substring(rawPhone.length - 10)
        : rawPhone;

    final upiId = "$cleanPhone@upi";

    Map<String, String> paymentDetails = {
      "upi_id": upiId,
      "name": contact.displayName,
      "amount": "0.00",
      "currency": "INR",
    };

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentDetailsScreen(
          paymentDetails: paymentDetails,
          upiId: upiId,
          amount: '0.00',
          phoneNumber: "+91 $cleanPhone",
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white, // Google Pay-style clean UI
      appBar: AppBar(
        title: Text(
          "Pay To Contacts",
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
      body: GestureDetector(
        behavior: HitTestBehavior.opaque, // Ensures tap is detected anywhere
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus(); // Unfocus the keyboard
        },
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: TextField(
                controller: searchController,
                onChanged: _filterContacts,
                decoration: InputDecoration(
                  hintText: "Search Contacts",
                  hintStyle: TextStyle(color: Colors.grey.shade600),
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  filled: true,
                  fillColor: Colors.white, // White background for contrast
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none, // Removes the default border
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide:
                        BorderSide(color: Colors.grey.shade300, width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: const BorderSide(
                        color: Colors.black, width: 2), // Highlight focus
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear, color: Colors.grey),
                    onPressed: () {
                      searchController.clear();
                    },
                  ),
                ),
              ),
            ),

            // Loading indicator
            if (isLoading)
              const Expanded(
                child: Center(
                    child: CircularProgressIndicator(color: Color(0xFF6F66A8))),
              )
            else if (filteredContacts.isEmpty)
              const Expanded(
                child: Center(
                  child: Text(
                    "No contacts found",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ),
              )
            else
              // Contacts List (Tap to Pay)
              Expanded(
                child: ListView.builder(
                  itemCount: filteredContacts.length,
                  itemBuilder: (context, index) {
                    Contact contact = filteredContacts[index];
                    return ListTile(
                      onTap: () => _requestContactsPermission(contact),
                      leading: CircleAvatar(
                        backgroundColor: Color(0xFF6F66A8),
                        child: Text(
                          contact.displayName.isNotEmpty
                              ? contact.displayName[0].toUpperCase()
                              : "?",
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text(
                        contact.displayName,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                      subtitle: contact.phones.isNotEmpty
                          ? Text(contact.phones.first.number)
                          : const Text("No phone number"),
                      trailing: const Icon(Icons.arrow_forward_ios,
                          size: 18, color: Colors.grey),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
