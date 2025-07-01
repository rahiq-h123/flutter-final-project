import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _loading = false;

  Future<void> _register() async {
  if (_formKey.currentState!.validate()) {
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      await userCredential.user!
          .updateDisplayName(_nameController.text.trim());
      await userCredential.user!.reload();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account created successfully!')),
      );
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Registration failed')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Register")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Full Name',
                 border: OutlineInputBorder(),),
                validator: (val) => val!.isEmpty ? 'Enter your name' : null,
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder(),),
                validator: (val) =>
                    val!.isEmpty ? 'Enter your email' : null,
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Phone', border: OutlineInputBorder(),),
                keyboardType: TextInputType.phone,
                validator: (val) =>
                    val!.isEmpty ? 'Enter your phone number' : null,
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder(),),
                obscureText: true,
                validator: (val) =>
                    val!.length < 6 ? 'Minimum 6 characters' : null,
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _confirmPasswordController,
                decoration:
                    const InputDecoration(labelText: 'Confirm Password', border: OutlineInputBorder(),),
                obscureText: true,
                validator: (val) =>
                    val!.isEmpty ? 'Confirm your password' : null,
              ),
              SizedBox(height: 20),
              _loading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _register,
                      style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,          
                      minimumSize: Size(double.infinity, 48), 
                      shape: RoundedRectangleBorder(          
                        borderRadius: BorderRadius.circular(8),
                      ),
                      ),
                      child: const Text('Register', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
                    ),
                    TextButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/login');
                },
                child: Text('Do you have an account? login',),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
