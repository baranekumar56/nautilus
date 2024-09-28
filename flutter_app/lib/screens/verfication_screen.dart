import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() => runApp(MaterialApp(
  theme: ThemeData(
    textTheme: GoogleFonts.poppinsTextTheme(), // Modern Font
    primarySwatch: Colors.blue,
    visualDensity: VisualDensity.adaptivePlatformDensity,
  ),
  home: LoginScreen(),
));

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String username = '';
  String password = '';
  final String correctPassword = "12345"; // Replace with your actual password
  final String correctEmail = "rpojith@gmail.com";   // Replace with your actual email

  void submit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Check if the email and password are correct
      if (username == correctEmail && password == correctPassword) {
        // Navigate to verification or next screen on success
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VerificationScreen(username: username),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Invalid email or password. Please try again.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 200, 179, 179), // Subtle background color
      appBar: AppBar(
        title: Text('Login', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.blueAccent, // Accent color
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Spacer(),
              Text(
                'Welcome Back!',
                style: GoogleFonts.poppins(
                  fontSize: 32,
                  fontWeight: FontWeight.w600,
                  color: Colors.blueAccent,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Please enter your email and password to continue',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 40),

              // Email Field
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: TextStyle(color: Colors.blueAccent),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.blueAccent),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blueAccent),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value!.isEmpty) return 'Please enter your email';
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
                onSaved: (value) => username = value!,
              ),
              SizedBox(height: 20),

              // Password Field
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: TextStyle(color: Colors.blueAccent),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.blueAccent),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blueAccent),
                  ),
                ),
                obscureText: true, // Hide password
                validator: (value) {
                  if (value!.isEmpty) return 'Please enter your password';
                  return null;
                },
                onSaved: (value) => password = value!,
              ),
              SizedBox(height: 20),

              Center(
                child: ElevatedButton(
                  onPressed: submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 5,
                  ),
                  child: Text(
                    'Login',
                    style: GoogleFonts.poppins(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
              Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

class VerificationScreen extends StatelessWidget {
  final String username;

  VerificationScreen({required this.username});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Verification', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.blueAccent,
      ),
      body: Center(
        child: Text(
          'Hello $username! Verification Successful.',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Colors.blueAccent,
          ),
        ),
      ),
    );
  }
}
