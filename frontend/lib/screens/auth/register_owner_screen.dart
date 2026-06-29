import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class RegisterOwnerScreen extends StatefulWidget {
  const RegisterOwnerScreen({super.key});

  @override
  State<RegisterOwnerScreen> createState() => _RegisterOwnerScreenState();
}

class _RegisterOwnerScreenState extends State<RegisterOwnerScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // final _businessNameController = TextEditingController();
  // final _cityController = TextEditingController();
  // final _addressController = TextEditingController();
  final _emailController = TextEditingController();

  bool _agreeTerms = false;

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();

    // _businessNameController.dispose();
    // _cityController.dispose();
    // _addressController.dispose();
    _emailController.dispose();

    super.dispose();
  }

  Future<void> _register() async {
    debugPrint("REGISTER BUTTON CLICKED");

    if (!_formKey.currentState!.validate()) return;

    debugPrint("FORM VALID");

    if (!_agreeTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please accept Terms & Conditions"),
        ),
      );
      return;
    }

    final auth = context.read<AuthProvider>();

    final success = await auth.register(
      name: _nameController.text.trim(),
      mobile: _mobileController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Account created successfully"),
        ),
      );

      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.error ?? "Registration Failed"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: const Color(0xffF5F7FB),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              ///========================
              /// HEADER
              ///========================

              Container(
                height: 250,
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xff345CFF),
                      Color(0xff6C63FF),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(40),
                    bottomRight: Radius.circular(40),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: 90,
                      width: 90,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.person_add_alt_1,
                        color: Colors.white,
                        size: 46,
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      "Create Owner Account",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Register your water delivery business",
                      style: TextStyle(
                        color: Colors.white.withOpacity(.9),
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),

              ///========================
              /// FORM CARD
              ///========================

              Transform.translate(
                offset: const Offset(0, -30),
                child: Card(
                  margin: const EdgeInsets.symmetric(horizontal: 22),
                  elevation: 12,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            "Personal Information",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 24),

                          /// FULL NAME

                          TextFormField(
                            controller: _nameController,
                            decoration: InputDecoration(
                              labelText: "Full Name",
                              hintText: "Enter your full name",
                              prefixIcon: const Icon(Icons.person),
                              filled: true,
                              fillColor: Colors.grey.shade100,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(
                                  color: Color(0xff345CFF),
                                  width: 2,
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return "Please enter your name";
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 18),

                          /// MOBILE

                          TextFormField(
                            controller: _mobileController,
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                              labelText: "Mobile Number",
                              hintText: "Enter mobile number",
                              prefixIcon: const Icon(Icons.phone),
                              filled: true,
                              fillColor: Colors.grey.shade100,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(
                                  color: Color(0xff345CFF),
                                  width: 2,
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().length != 10) {
                                return "Enter a valid mobile number";
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 18),

                          /// PASSWORD

                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              labelText: "Password",
                              hintText: "Create password",
                              prefixIcon: const Icon(Icons.lock),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade100,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(
                                  color: Color(0xff345CFF),
                                  width: 2,
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.length < 6) {
                                return "Password must be at least 6 characters";
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 18),

                          /// CONFIRM PASSWORD

                          TextFormField(
                            controller: _confirmPasswordController,
                            obscureText: _obscureConfirmPassword,
                            decoration: InputDecoration(
                              labelText: "Confirm Password",
                              hintText: "Re-enter password",
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureConfirmPassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscureConfirmPassword =
                                        !_obscureConfirmPassword;
                                  });
                                },
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade100,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(
                                  color: Color(0xff345CFF),
                                  width: 2,
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value != _passwordController.text) {
                                return "Passwords do not match";
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 20),

                          const SizedBox(height: 30),

                          const Text(
                            "Business Information",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 20),

                          // /// BUSINESS NAME

                          // TextFormField(
                          //   controller: _businessNameController,
                          //   decoration: InputDecoration(
                          //     labelText: "Business Name",
                          //     hintText: "e.g. Sharma Water Supplier",
                          //     prefixIcon: const Icon(Icons.business),
                          //     filled: true,
                          //     fillColor: Colors.grey.shade100,
                          //     border: OutlineInputBorder(
                          //       borderRadius: BorderRadius.circular(16),
                          //       borderSide: BorderSide.none,
                          //     ),
                          //     enabledBorder: OutlineInputBorder(
                          //       borderRadius: BorderRadius.circular(16),
                          //       borderSide: BorderSide.none,
                          //     ),
                          //     focusedBorder: OutlineInputBorder(
                          //       borderRadius: BorderRadius.circular(16),
                          //       borderSide: const BorderSide(
                          //         color: Color(0xff345CFF),
                          //         width: 2,
                          //       ),
                          //     ),
                          //   ),
                          //   validator: (value) {
                          //     if (value == null || value.trim().isEmpty) {
                          //       return "Enter business name";
                          //     }
                          //     return null;
                          //   },
                          // ),

                          // const SizedBox(height: 18),

                          // /// CITY

                          // TextFormField(
                          //   controller: _cityController,
                          //   decoration: InputDecoration(
                          //     labelText: "City",
                          //     hintText: "Enter your city",
                          //     prefixIcon: const Icon(Icons.location_city),
                          //     filled: true,
                          //     fillColor: Colors.grey.shade100,
                          //     border: OutlineInputBorder(
                          //       borderRadius: BorderRadius.circular(16),
                          //       borderSide: BorderSide.none,
                          //     ),
                          //     enabledBorder: OutlineInputBorder(
                          //       borderRadius: BorderRadius.circular(16),
                          //       borderSide: BorderSide.none,
                          //     ),
                          //     focusedBorder: OutlineInputBorder(
                          //       borderRadius: BorderRadius.circular(16),
                          //       borderSide: const BorderSide(
                          //         color: Color(0xff345CFF),
                          //         width: 2,
                          //       ),
                          //     ),
                          //   ),
                          //   validator: (value) {
                          //     if (value == null || value.trim().isEmpty) {
                          //       return "Enter city";
                          //     }
                          //     return null;
                          //   },
                          // ),

                          // const SizedBox(height: 18),

                          // /// ADDRESS

                          // TextFormField(
                          //   controller: _addressController,
                          //   maxLines: 3,
                          //   decoration: InputDecoration(
                          //     labelText: "Business Address",
                          //     hintText: "Enter complete address",
                          //     prefixIcon: const Padding(
                          //       padding: EdgeInsets.only(bottom: 55),
                          //       child: Icon(Icons.location_on),
                          //     ),
                          //     filled: true,
                          //     fillColor: Colors.grey.shade100,
                          //     border: OutlineInputBorder(
                          //       borderRadius: BorderRadius.circular(16),
                          //       borderSide: BorderSide.none,
                          //     ),
                          //     enabledBorder: OutlineInputBorder(
                          //       borderRadius: BorderRadius.circular(16),
                          //       borderSide: BorderSide.none,
                          //     ),
                          //     focusedBorder: OutlineInputBorder(
                          //       borderRadius: BorderRadius.circular(16),
                          //       borderSide: const BorderSide(
                          //         color: Color(0xff345CFF),
                          //         width: 2,
                          //       ),
                          //     ),
                          //   ),
                          //   validator: (value) {
                          //     if (value == null || value.trim().isEmpty) {
                          //       return "Enter business address";
                          //     }
                          //     return null;
                          //   },
                          // ),

                          // const SizedBox(height: 18),

                          /// EMAIL (OPTIONAL)

                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              labelText: "Email (Optional)",
                              hintText: "example@gmail.com",
                              prefixIcon: const Icon(Icons.email_outlined),
                              filled: true,
                              fillColor: Colors.grey.shade100,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(
                                  color: Color(0xff345CFF),
                                  width: 2,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          CheckboxListTile(
                            value: _agreeTerms,
                            onChanged: (value) {
                              setState(() {
                                _agreeTerms = value ?? false;
                              });
                            },
                            contentPadding: EdgeInsets.zero,
                            controlAffinity: ListTileControlAffinity.leading,
                            title: const Text(
                              "I agree to the Terms & Conditions",
                              style: TextStyle(fontSize: 15),
                            ),
                          ),

                          const SizedBox(height: 20),

                          Container(
                            height: 58,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xff345CFF),
                                  Color(0xff7B61FF),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: ElevatedButton(
                              onPressed: auth.isLoading ? null : _register,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: auth.isLoading
                                  ? const SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text(
                                      "CREATE ACCOUNT",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text("Already have an account?"),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text("Login"),
                              ),
                            ],
                          ),

                          const SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
