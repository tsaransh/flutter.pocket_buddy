import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final FirebaseAuth firebase = FirebaseAuth.instance;

class UserAuthentication extends StatefulWidget {
  const UserAuthentication({super.key});

  @override
  State<UserAuthentication> createState() => _UserAuthenticationState();
}

class _UserAuthenticationState extends State<UserAuthentication> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLogin = true;
  bool _showPassword = false;
  bool _isLoading = false;

  String? _name;
  late String _email;
  late String _password;
  String? _confirmPassword;
  final _forgotPasswordEmailController = TextEditingController();

  void loadingSpinner() {
    setState(() {
      _isLoading = !_isLoading;
    });
  }

  @override
  void dispose() {
    _forgotPasswordEmailController.dispose();
    super.dispose();
  }

  late UserCredential userCredential;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  void _signInwithGoogle() async {
    try {
      final GoogleSignInAccount? googleSignInAccount =
          await _googleSignIn.signIn();
      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleSignInAuthentication =
            await googleSignInAccount.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken,
        );
        userCredential = await firebase.signInWithCredential(credential);
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to sign in with Google: $error'),
        ),
      );
    }
  }

  void _submitForm() async {
    final isValid = _formKey.currentState!.validate();
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    if (!isValid) return;
    _formKey.currentState!.save();
    if (_confirmPassword != null && _password != _confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password and Confirm Password do not match.'),
        ),
      );
      return;
    }
    loadingSpinner();
    try {
      if (_isLogin) {
        userCredential = await firebase.signInWithEmailAndPassword(
          email: _email,
          password: _password,
        );
      } else {
        userCredential = await firebase.createUserWithEmailAndPassword(
          email: _email,
          password: _password,
        );

        firebase.currentUser!.sendEmailVerification();

        // Save user data into Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set({
          'user_name': _name,
          'user_email': _email,
          'created_At': Timestamp.now(),
        });

        setState(() {
          _isLogin = !_isLogin;
        });
      }
      _formKey.currentState!.reset();
    } on FirebaseAuthException catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.message ?? 'Authentication failed'),
        ),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('An error occurred. Please try again later.'),
        ),
      );
    } finally {
      loadingSpinner();
    }
  }

  void _forgotPassword() {
    showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            title: const Text('Forgot Your Password'),
            actions: <Widget>[
              TextField(
                controller: _forgotPasswordEmailController,
                decoration: const InputDecoration(
                  labelText: 'Enter your email address.',
                  prefixIcon: Icon(
                    Icons.email,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: () {
                  firebase.sendPasswordResetEmail(
                      email: _forgotPasswordEmailController.text);
                  _forgotPasswordEmailController.clear();
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      action: SnackBarAction(
                          label: 'Okay',
                          onPressed: () {
                            ScaffoldMessenger.of(context).clearSnackBars();
                          }),
                      content: Text(
                          'Reset password link send to ${_forgotPasswordEmailController.text}'),
                    ),
                  );
                },
                icon: const Icon(Icons.send),
                label: const Text('Send'),
              )
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Pocket Buddy',
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      color: Colors.teal,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        if (!_isLogin) ...[
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Enter your full name',
                              prefixIcon: Icon(Icons.person),
                            ),
                            validator: (name) {
                              if (name == null || name.trim().isEmpty) {
                                return 'Please enter your name.';
                              }
                              if (name.length > 20) {
                                return 'Name must be shorter than 20 characters.';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _name = value!;
                            },
                          ),
                          const SizedBox(height: 10),
                        ],
                        TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Enter your email',
                            prefixIcon: Icon(Icons.email),
                          ),
                          validator: (email) {
                            if (email == null || email.trim().isEmpty) {
                              return 'Please enter your email.';
                            }
                            if (!email.contains('@')) {
                              return 'Please enter a valid email.';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _email = value!;
                          },
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Enter your password',
                            prefixIcon: const Icon(Icons.lock),
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  _showPassword = !_showPassword;
                                });
                              },
                              icon: Icon(
                                _showPassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                            ),
                          ),
                          obscureText: !_showPassword,
                          onSaved: (value) {
                            _password = value!;
                          },
                        ),
                        if (!_isLogin) ...[
                          const SizedBox(height: 10),
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Confirm your password',
                              prefixIcon: Icon(Icons.lock),
                            ),
                            obscureText: !_showPassword,
                            onSaved: (value) {
                              _confirmPassword = value!;
                            },
                          ),
                        ],
                        const SizedBox(height: 24),
                        ElevatedButton(
                          style: const ButtonStyle(
                              backgroundColor:
                                  MaterialStatePropertyAll<Color>(Colors.teal)),
                          onPressed: _submitForm,
                          child: !_isLoading
                              ? Text(
                                  _isLogin ? 'Login' : 'Signup',
                                  style: const TextStyle(color: Colors.white),
                                )
                              : const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(),
                                ),
                        ),
                        const SizedBox(height: 12),
                        _isLogin
                            ? TextButton(
                                onPressed: _forgotPassword,
                                child: Text(
                                  'Forgot password?',
                                  style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onBackground,
                                  ),
                                ),
                              )
                            : TextButton(
                                onPressed: () {
                                  setState(() {
                                    _isLogin = !_isLogin;
                                  });
                                },
                                child: Text(
                                  'Already have an account?',
                                  style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onBackground,
                                  ),
                                ),
                              ),
                      ],
                    ),
                  ),
                ),
              ),
              if (_isLogin) ...[
                const SizedBox(height: 16),
                const Text(
                  'OR',
                  style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _signInwithGoogle,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        vertical: 20,
                        horizontal: 36,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: const Text(
                      'Login with Google',
                      style: TextStyle(
                        letterSpacing: 1.05,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
              if (_isLogin) ...[
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      _formKey.currentState!.reset();
                      setState(() {
                        _isLogin = !_isLogin;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      padding: const EdgeInsets.symmetric(
                        vertical: 20,
                        horizontal: 36,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: const Text(
                      'Signup with Email',
                      style: TextStyle(
                        letterSpacing: 1.05,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
