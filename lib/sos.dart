import 'dart:math';

import 'package:flutter/material.dart';
import 'package:sos_app/quote/custom.dart';
import 'package:sos_app/quote/womenquote.dart';
import 'package:sos_app/safehome.dart';
import 'package:sos_app/lifestate.dart';
import 'package:flutter_direct_caller_plugin/flutter_direct_caller_plugin.dart';
import 'package:sos_app/savecontact.dart';

class SOSApp extends StatefulWidget {
  const SOSApp({super.key});

  @override
  State<SOSApp> createState() => _SOSAppState();
}

class _SOSAppState extends State<SOSApp> {
  String? emergencyNumber;
  String currentQuote = "";
  @override
  void initState() {
    super.initState();
    _changeQuote();
    _loadEmergencyNumber();
  }

  void _changeQuote() {
    setState(() {
      currentQuote = quotes[Random().nextInt(quotes.length)];
    });
  }

  // Future<void> _loadEmergencyNumber() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   setState(() {
  //     emergencyNumber = prefs.getString('emergencyNumber') ?? '';
  //   });
  // }

  // Future<void> _setEmergencyNumber(String number) async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   await prefs.setString('emergencyNumber', number);
  //   _loadEmergencyNumber();
  // }
  Future<void> _loadEmergencyNumber() async {
    String? number = await EmergencyNumberHelper.getEmergencyNumber();
    setState(() {
      emergencyNumber = number ?? '';
    });
  }

  Future<void> _setEmergencyNumber(String number) async {
    await EmergencyNumberHelper.saveEmergencyNumber(number);
    _loadEmergencyNumber();
  }

  void _makeCall(String number) async {
    if (number.isNotEmpty) {
      await FlutterDirectCallerPlugin.callNumber('+91$number');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No emergency contact set!')),
      );
    }
  }

  void _showEmergencyNumberDialog() {
    TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Set Emergency Contact'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.phone,
            decoration:
                const InputDecoration(hintText: 'Enter emergency number'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _setEmergencyNumber(controller.text);
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 198, 192, 192),
          flexibleSpace: const Center(
            child: Text(
              'SOS Emergency App',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        //body: Center(
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                ///////change quote
                padding: const EdgeInsets.only(top: 10),
                child: GestureDetector(
                  onTap: _changeQuote,
                  child: Container(
                    margin: const EdgeInsets.all(3),
                    width: MediaQuery.of(context).size.width,
                    height: 80,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(5),
                        child: Text(
                          currentQuote,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: CustomCarouel(),
              ),
              Padding(
                  padding: const EdgeInsets.all(0),
                  child: Text(
                    "Explore Lifesafe",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  )),
              lifesafe(),
              // ElevatedButton(
              //   //onPressed: _handleSOS,
              //   onPressed: () {
              //     launch('tel:100');
              //   },

              //   style: ElevatedButton.styleFrom(
              //       backgroundColor: Colors.red,
              //       padding: const EdgeInsets.symmetric(
              //           vertical: 20, horizontal: 40)),
              //   child: const Text(
              //     'SOS',
              //     style: TextStyle(color: Colors.white, fontSize: 20),
              //   ),
              // ),
              ElevatedButton(
                onPressed: () async {
                  await FlutterDirectCallerPlugin.callNumber("100");
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding:
                      const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
                ),
                child: const Text(
                  'SOS',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ),
              const SizedBox(height: 18),
              ElevatedButton(
                onPressed: () => _makeCall(emergencyNumber ?? ''),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(
                        vertical: 15, horizontal: 30)),
                child: const Text(
                  'Call Emergency Contact',
                  style: TextStyle(color: Color.fromRGBO(220, 255, 255, 1)),
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: _showEmergencyNumberDialog,
                child: const Text('Set Emergency Contact'),
              ),
              safehome(),
            ],
          ),
        ),
      ),
    );
  }
}
