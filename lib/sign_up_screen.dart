import 'package:flutter/material.dart';
import 'package:orderio/log_in_screen.dart';
import 'loading.dart';
import 'package:orderio/models/customer.dart';
import 'package:orderio/db_helper.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  void _confirmSignin() async {
    if (_formKey.currentState!.validate()) {
      Customer newCustomer = Customer(
          username: usernameController.text,
          address: addressController.text,
          phone: phoneController.text,
          password: passwordController.text);

      print('Saved username: ${usernameController.text}');
      print('Saved address: ${addressController.text}');
      print('Saved phone: ${phoneController.text}');

      final dbHelper = DBHelper();
      int id = await dbHelper.insertCustomer(newCustomer.toMap());
      print('Customer saved with id: $id');
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    }
  }

  String _value = 'English';
  @override
  Widget build(BuildContext context) {
    TextDirection direction =
        _value == 'Arabic' ? TextDirection.rtl : TextDirection.ltr;
    return Directionality(
      textDirection: direction,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xFFCAB7AC),
          title: Text('Signup'),
          centerTitle: true,
          actions: [
            Container(
              child: DropdownButton(
                value: _value,
                items: ['English', 'Arabic'].map((String language) {
                  return DropdownMenuItem<String>(
                    value: language,
                    child: Text(
                      language,
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  );
                }).toList(),
                onChanged: (val) async {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (_) => const LoadingScreen(),
                  );

                  await Future.delayed(Duration(seconds: 1));

                  Navigator.pop(context);

                  setState(() {
                    _value = val as String;
                  });
                },
                dropdownColor: Color(0xFFCAB7AC),
              ),
            )
          ],
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(15.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: usernameController,
                  style: TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    prefixIcon: Icon(Icons.person, color: Colors.black),
                    hintText: 'UserName',
                    hintStyle: TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0)),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a username';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 15.0),
                TextFormField(
                  controller: addressController,
                  style: TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    prefixIcon: Icon(Icons.location_on, color: Colors.black),
                    hintText: 'Address',
                    hintStyle: TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0)),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your address';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 15.0),
                TextFormField(
                  keyboardType: TextInputType.phone,
                  controller: phoneController,
                  style: TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    prefixIcon: Icon(Icons.phone, color: Colors.black),
                    hintText: 'Phone',
                    hintStyle: TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0)),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your mobile number';
                    }
                    final numericReg = RegExp(r'^[0-9]+$');
                    if (!numericReg.hasMatch(value)) {
                      return 'Please enter only numbers';
                    }
                    if (value.length != 10) {
                      return 'Mobile number must be exactly 10 digits';
                    }
                    if (!value.startsWith('05')) {
                      return 'Mobile number must start with 05';
                    }
                    return null;
                  },
                ),
                SizedBox(
                  height: 15.0,
                ),
                TextFormField(
                  controller: passwordController,
                  obscureText: true,
                  style: TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    prefixIcon: Icon(Icons.lock, color: Colors.black),
                    hintText: 'Password',
                    hintStyle: TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0)),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 15.0),
                TextFormField(
                  controller: confirmPasswordController,
                  obscureText: true,
                  style: TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    prefixIcon: Icon(Icons.lock_outline, color: Colors.black),
                    hintText: 'Password again',
                    hintStyle: TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0)),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    } else if (value != passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 25.0),
                GestureDetector(
                  onTap: _confirmSignin,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Color(0xFFCAB7AC),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    height: 50.0,
                    width: double.infinity,
                    child: Center(
                      child: Text(
                        'Signup',
                        style: TextStyle(fontSize: 16),
                      ),
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
