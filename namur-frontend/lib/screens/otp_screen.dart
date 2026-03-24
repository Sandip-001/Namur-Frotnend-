import 'package:flutter/material.dart';
import 'package:the_namur_frontend/screens/home_screen.dart';

// import 'package:provider/provider.dart';
// import '../provider/auth_provider.dart';

class OTPScreen extends StatefulWidget {
  const OTPScreen({super.key});

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  final List<TextEditingController> _otpCtrls = List.generate(
    4,
    (_) => TextEditingController(),
  );

  @override
  void dispose() {
    for (final c in _otpCtrls) {
      c.dispose();
    }
    super.dispose();
  }

  String getOtp() => _otpCtrls.map((c) => c.text).join();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/farm_background.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 28),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 24,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                        color: Colors.black.withOpacity(0.25),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Enter OTP Code',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E7A3F),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(4, (i) => _otpField(i)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: () async {
                    /*
                    final otp = getOtp();

                    if (otp.length != 4) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Enter valid 4-digit OTP"),
                        ),
                      );
                      return;
                    }

                    final auth = Provider.of<AuthProvider>(
                      context,
                      listen: false,
                    );

                    bool isValid = await auth.verifyOtp(otp);

                    if (!isValid) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Invalid OTP! Try again")),
                      );
                      return;
                    }
                    */

                    // OTP success → Navigate
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => HomeScreen()),
                    );
                  },

                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    minimumSize: const Size(140, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Verify',
                    style: TextStyle(fontSize: 16, color: Color(0xFF1E7A3F)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _otpField(int index) {
    return Container(
      width: 50,
      height: 55,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey),
      ),
      child: TextField(
        controller: _otpCtrls[index],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        decoration: const InputDecoration(
          counterText: '',
          border: InputBorder.none,
        ),
        onChanged: (v) {
          if (v.length == 1 && index < 3) FocusScope.of(context).nextFocus();
          if (v.isEmpty && index > 0) FocusScope.of(context).previousFocus();
        },
      ),
    );
  }
}
