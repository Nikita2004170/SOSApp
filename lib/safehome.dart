import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sos_app/sos.dart';
import 'package:shared_preferences/shared_preferences.dart';

class safehome extends StatefulWidget {
  const safehome({super.key});

  @override
  State<safehome> createState() => _safehomeState();
}

class _safehomeState extends State<safehome> {
  Position? _currentPosition;
  String? _currentAddress;

  // Request SMS permission
  Future<void> _getPermission() async {
    await Permission.sms.request();
  }

  Future<bool> _isPermissionGranted() async {
    return await Permission.sms.isGranted;
  }

  Future<void> _sendSms(String phoneNumber, String message) async {
    // Add SMS sending functionality
  }

  Future<void> _getCurrentLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Fluttertoast.showToast(msg: "Location permission is denied");
        return;
      }
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        forceAndroidLocationManager: true,
      );

      setState(() {
        _currentPosition = position;
      });

      // Get address after getting the location
      _getAddressFromLatLon();
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  Future<void> _getAddressFromLatLon() async {
    if (_currentPosition == null) {
      Fluttertoast.showToast(msg: "Location not available");
      return;
    }

    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];

        setState(() {
          _currentAddress =
              "${place.locality ?? "Unknown Locality"}, ${place.postalCode ?? "Unknown Postal Code"}, ${place.street ?? "Unknown Street"}";
        });
      }
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  String? emergencyNumber; // Store emergency number
  Future<void> _loadEmergencyNumber() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      emergencyNumber = prefs.getString('emergencyNumber') ?? '';
    });
  }

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _loadEmergencyNumber(); // Load the stored number when screen opens
  }

  showmodel(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return Container(
              height: MediaQuery.of(context).size.height / 0.5,
              decoration: BoxDecoration(
                  color: const Color.fromARGB(100, 101, 95, 95),
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30))),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.all(10),
                    child: Text(
                      "SEND YOUR CURRENT LOCATION IMMEDIATELY TO YOUR EMERGENCY CONTACTS",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20),
                    ),
                  ),
                  if (_currentPosition != null) Text(_currentAddress!),
                  // Text(_currentAddress ?? "Fetching address..."),

                  ElevatedButton(
                      onPressed: () {
                        _getCurrentLocation();
                      },
                      child: Text("GET LOCATION")),
                  ElevatedButton(
                      onPressed: () async {
                        await _loadEmergencyNumber(); // Ensure latest emergency number is loaded

                        if (emergencyNumber == null ||
                            emergencyNumber!.isEmpty) {
                          Fluttertoast.showToast(
                              msg: "No emergency contact set!");
                          return;
                        }

                        if (_currentPosition == null) {
                          Fluttertoast.showToast(
                              msg: "Location not available!");
                          return;
                        }

                        // Generate Google Maps link
                        String mapsLink =
                            "https://www.google.com/maps?q=${_currentPosition!.latitude},${_currentPosition!.longitude}";

                        // Construct SMS body
                        String message = "I need help! My location: $mapsLink";

                        // Open SMS intent
                        final Uri smsUri = Uri.parse(
                            "sms:$emergencyNumber?body=${Uri.encodeComponent(message)}");

                        if (await canLaunchUrl(smsUri)) {
                          await launchUrl(smsUri);
                        } else {
                          Fluttertoast.showToast(msg: "Could not send SMS");
                        }
                      },
                      child: Text("SEND LOCATION")),
                ],
              ));
        });
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        showmodel(context);
      },
      child: Card(
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            height: 150,
            width: MediaQuery.of(context).size.width * 0.9,
            decoration: BoxDecoration(),
            child: Row(
              children: [
                Expanded(
                    child: Column(
                  children: [
                    ListTile(
                      title: Text("Send Location"),
                      subtitle: Text("Share Location"),
                    )
                  ],
                )),
                ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset('images/route.jpeg'))
              ],
            ),
          )),
    );
  }
}
