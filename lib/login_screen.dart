import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth/google_sign_in.dart';
import 'auth/facebook_signin.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _loading = false;

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _loading = true);
      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      Navigator.pushReplacementNamed(context, '/home');

      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? 'Login failed')),
        );
      } finally {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder(),),
                validator: (val) =>
                    val!.isEmpty ? 'Please enter your email' : null,
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder(),),
                obscureText: true,
                validator: (val) =>
                    val!.isEmpty ? 'Please enter your password' : null,
              ),
              SizedBox(height: 20),
              _loading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _login,
                      style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,          
                      minimumSize: Size(double.infinity, 48), 
                      shape: RoundedRectangleBorder(          
                        borderRadius: BorderRadius.circular(8),
                      ),
                      ),
                      child: const Text('Login', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/register');
                },
                child: Text('Don\'t have an account? Register',),
              ),
              SizedBox(height: 20,),
              ElevatedButton.icon(
                onPressed: () async {
                  final user = await GoogleAuthService.signInWithGoogle();
                  if (user != null) {
                    Navigator.pushReplacementNamed(context, '/home');
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Google Sign-In failed')),
                    );
                  }
                },
                icon: const Icon(Icons.login),
                label: const Text('Sign in with Google'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
              ),
              SizedBox(height: 20,),
              ElevatedButton.icon(
                onPressed: () async {
                  final user = await FacebookAuthService.signInWithFacebook();
                  if (user != null) {
                    Navigator.pushReplacementNamed(context, '/home');
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Facebook Sign-In failed')),
                    );
                  }
                },
                icon: const Icon(Icons.facebook),
                label: const Text('Sign in with Facebook'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
              ),

            ],
          ),
        ),
      ),
    );
  }
}
