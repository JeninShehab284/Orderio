import 'package:flutter/material.dart';
import 'package:orderio/loading.dart';
import 'package:orderio/shopping_screen.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth/error_codes.dart' as auth_error;
import 'package:flutter/services.dart';
import 'package:orderio/db_helper.dart';

class LoginScreen extends StatefulWidget {
  final bool clearFields;
  const LoginScreen({super.key, this.clearFields = false});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _enableBiometric = false;
  final LocalAuthentication auth = LocalAuthentication();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _isLoading = false;
  String _value = 'English';

  @override
  void initState() {
    super.initState();
    _loadBiometricSetting();
    if (widget.clearFields) {
      usernameController.clear();
      passwordController.clear();
    }
  }

  // to clear
  @override
  void dispose() {
    usernameController.dispose();
  }

  void _loadBiometricSetting() async {
    final dbHelper = DBHelper();
    String? value = await dbHelper.getSetting('useBiometrics');
    setState(() {
      _enableBiometric = value == 'true';
    });
  }

  void _login() async {
    if (_formKey.currentState!.validate()) {
      final dbHelper = DBHelper();

      List<Map<String, dynamic>> users =
          await dbHelper.getCustomerByUsernameAndPassword(
        usernameController.text.trim(),
        passwordController.text.trim(),
      );
      if (users.isNotEmpty) {
        final user = users.first;
        await dbHelper.setCurrentUser(user['id']);
        await dbHelper.setSetting(
            'useBiometrics', _enableBiometric ? 'true' : 'false');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Log in successfully')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Shopping()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Invalid username or password')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    TextDirection direction =
        _value == 'Arabic' ? TextDirection.rtl : TextDirection.ltr;
    if (_isLoading == true) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }
    return Directionality(
      textDirection: direction,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xFFCAB7AC),
          title: Text('Login'),
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
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('images/logo.png'),
                SizedBox(height: 15),
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
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your username';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 15),
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
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                ),
                CheckboxListTile(
                  activeColor: Colors.black,
                  title: Text('Remember Me'),
                  value: _enableBiometric,
                  onChanged: (bool? value) async {
                    setState(() {
                      _enableBiometric = value ?? false;
                    });

                    final dbHelper = DBHelper();
                    await dbHelper.setSetting(
                        'useBiometrics', _enableBiometric ? 'true' : 'false');
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                ),
                Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: GestureDetector(
                        onTap: _login,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Color(0xFFCAB7AC),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          height: 50.0,
                          child: Center(
                            child: Text(
                              'Login',
                              style: TextStyle(fontSize: 18),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 5.0,
                    ),
                    Expanded(
                      flex: 1,
                      child: Container(
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFFCAB7AC),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              )),
                          onPressed: () async {
                            final bool didAuthenticate =
                                await auth.authenticate(
                              localizedReason:
                                  'Please authenticate to open your account.',
                              options: const AuthenticationOptions(
                                  useErrorDialogs: false),
                            );
                            if (didAuthenticate) {
                              final dbHelper = DBHelper();
                              String? biometricSetting =
                                  await dbHelper.getSetting('useBiometrics');
                              if (biometricSetting == 'true') {
                                Map<String, dynamic>? currentUser =
                                    await dbHelper.getCurrentUser();
                                if (currentUser != null) {
                                  usernameController.text =
                                      currentUser['username'];
                                  passwordController.text =
                                      currentUser['password'];
                                  _login();
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content:
                                            Text('No activated user found.')),
                                  );
                                }
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          'Please enable the fingerprint option first.')),
                                );
                              }
                            }
                          },
                          child: Icon(
                            Icons.fingerprint,
                            size: 28,
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
