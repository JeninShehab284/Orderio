import 'package:flutter/material.dart';
import 'package:orderio/loading.dart';
import 'package:orderio/shopping_screen.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth/error_codes.dart' as auth_error;
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  final FlutterSecureStorage secureStorage = FlutterSecureStorage();

  void _login() async {
    if (_formKey.currentState!.validate()) {
      String? savedUsername = await secureStorage.read(key: 'username');
      String? savedPassword = await secureStorage.read(key: 'password');

      if (savedUsername == null || savedPassword == null) {
        savedUsername = usernameController.text;
        savedPassword = passwordController.text;
      }
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('useBiometrics', _enableBiometric);

      if (usernameController.text == savedUsername &&
          passwordController.text == savedPassword) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Log in successfully')),
        );
        Navigator.push(
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
  void initState() {
    super.initState();
    if (widget.clearFields) {
      usernameController.clear();
      passwordController.clear();
    }
  }

  bool _isLoading = false;
  String _value = 'English';
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

                  Navigator.pop(context); // إغلاق مؤشر التحميل

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
                  onChanged: (bool? value) {
                    setState(() {
                      _enableBiometric = value ?? false;
                    });
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
                            try {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Icon(
                                  Icons.check_box,
                                  color: Colors.green,
                                )),
                              );
                              final bool didAuthenticate =
                                  await auth.authenticate(
                                localizedReason:
                                    'Please authenticate to open your account.',
                                options: const AuthenticationOptions(
                                    useErrorDialogs: false),
                              );

                              bool canCheckBiometrics =
                                  await auth.canCheckBiometrics;
                              List<BiometricType> availableBiometrics =
                                  await auth.getAvailableBiometrics();

                              if (!canCheckBiometrics ||
                                  availableBiometrics.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          'لا توجد بصمة مسجّلة على الجهاز')),
                                );
                                return;
                              }
                              final bool isDeviceSupported =
                                  await auth.isDeviceSupported();
                              if (!canCheckBiometrics || !isDeviceSupported) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Not supported')),
                                );
                                return;
                              }
                              if (didAuthenticate) {
                                String? savedUsername =
                                    await secureStorage.read(key: 'username');
                                String? savedPassword =
                                    await secureStorage.read(key: 'password');
                                if (savedUsername != null &&
                                    savedPassword != null) {
                                  usernameController.text = savedUsername;
                                  passwordController.text = savedPassword;
                                  _login();
                                }
                              }
                            } on PlatformException catch (e) {
                              if (e.code == 'NotAvailable' ||
                                  e.code == 'SecurityCredentialsNotAvailable') {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          'لا توجد بيانات بصمة أو أمان مفعّلة على الجهاز')),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          'خطأ أثناء التحقق: ${e.message}')),
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
