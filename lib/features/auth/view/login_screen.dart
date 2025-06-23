import 'package:dreamtix_admin/features/auth/controller/AuthController.dart';
import 'package:dreamtix_admin/features/auth/model/Admin.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final usernameC = TextEditingController();

  final passwordC = TextEditingController();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0D0C2D),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo atau Title
                  Container(
                    margin: EdgeInsets.only(bottom: 50),
                    child: Column(
                      children: [
                        Image.asset(
                          'assets/images/logo.png',
                          width: 100,
                          height: 100,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'DreamTix',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Masuk ke akun Anda',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[400],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Username Field
                  TextField(
                    controller: usernameC,
                    style: TextStyle(color: Colors.white),
                    decoration: _inputDecoration(
                      "Masukkan Username",
                      Icons.person_outline,
                    ),
                  ),
                  SizedBox(height: 20),

                  // Password Field
                  Obx(
                    () => TextField(
                      controller: passwordC,
                      obscureText: !authController.isPasswordVisible.value,
                      style: TextStyle(color: Colors.white),
                      decoration:
                          _inputDecoration(
                            "Masukkan Password",
                            Icons.lock_outline,
                          ).copyWith(
                            suffixIcon: IconButton(
                              icon: Icon(
                                authController.isPasswordVisible.value
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Colors.grey[400],
                              ),
                              onPressed: authController.togglePassword,
                            ),
                          ),
                    ),
                  ),

                  // Forgot Password
                  Container(
                    width: double.infinity,
                    margin: EdgeInsets.only(top: 12),
                    child: TextButton(
                      onPressed: () {
                        // Navigate to forgot password screen
                        // Get.toNamed(AppRoute.forgotPassword);
                        Get.snackbar(
                          'Info',
                          'Fitur lupa password akan segera tersedia',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.blue.withOpacity(0.8),
                          colorText: Colors.white,
                        );
                      },
                      style: TextButton.styleFrom(
                        alignment: Alignment.centerRight,
                        padding: EdgeInsets.zero,
                      ),
                      child: Text(
                        'Lupa Password?',
                        style: TextStyle(color: Colors.red, fontSize: 14),
                      ),
                    ),
                  ),

                  SizedBox(height: 30),

                  // Login Button
                  Container(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (usernameC.text.isEmpty || passwordC.text.isEmpty) {
                          Get.snackbar(
                            'Error',
                            'Username dan Password tidak boleh kosong',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.red.withOpacity(0.8),
                            colorText: Colors.white,
                          );
                          return;
                        }

                        authController.loginAdmin(
                          usernameC.text.toString(),
                          passwordC.text.toString(),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 16),
                        elevation: 3,
                      ),
                      child: Text(
                        "Masuk",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      filled: true,
      fillColor: Color(0xFF1B1A47),
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey[400]),
      prefixIcon: Icon(icon, color: Colors.grey[400]),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.red, width: 2),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }
}
