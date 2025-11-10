import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'styles/app_theme.dart';
import 'styles/styles.dart';
import 'dashboard_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final userCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  bool obscured = true;
  bool loading = false;

  /// ✅ ฟังก์ชันเชื่อม backend ตรวจ username / password
  Future<void> _login() async {
    final username = userCtrl.text.trim();
    final password = passCtrl.text.trim();

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter both username and password')),
      );
      return;
    }

    setState(() => loading = true);
    try {
      final res = await http.post(
        Uri.parse('http://localhost:8080/api/chats/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'name': username, 'password': password}),
      );

      if (res.statusCode == 200) {
        final user = jsonDecode(res.body);
        // ✅ ล็อกอินสำเร็จ → ไปหน้า Dashboard
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => DashboardPage(currentUser: user['name']),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login failed: ${res.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cannot connect to server: $e')),
      );
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        // ---------- Top branding ----------
        Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.only(top: 120),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                _GlowShield(),
                SizedBox(height: 18),
                Text(
                  'Poliz System',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                ),
                SizedBox(height: 8),
                Text(
                  'Secure Law Enforcement Portal',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ),

        // ---------- Login form ----------
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
            child: DarkCard(
              padding: const EdgeInsets.fromLTRB(24, 22, 24, 24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 680),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Username',
                        style: TextStyle(
                            fontWeight: FontWeight.w700, color: Colors.white)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: userCtrl,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: 'Enter your ID',
                        hintStyle: TextStyle(color: Colors.white70),
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text('Password',
                        style: TextStyle(
                            fontWeight: FontWeight.w700, color: Colors.white)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: passCtrl,
                      obscureText: obscured,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Enter your password',
                        hintStyle: const TextStyle(color: Colors.white70),
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscured ? Icons.visibility_off : Icons.visibility,
                            color: Colors.white70,
                          ),
                          onPressed: () =>
                              setState(() => obscured = !obscured),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ---------- Login button ----------
                    SizedBox(
                      height: 48,
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: loading ? null : _login,
                        child: loading
                            ? const CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2)
                            : const Text('Access System'),
                      ),
                    ),

                    const SizedBox(height: 16),
                    const Center(
                      child: Text(
                        'Authorized personnel only',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ]),
    );
  }
}

class _GlowShield extends StatelessWidget {
  const _GlowShield();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 92,
      height: 92,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [Color(0xFF60A5FA), Colors.transparent],
          radius: .8,
        ),
      ),
      child: const Center(
        child: CircleAvatar(
          radius: 36,
          backgroundColor: Color(0xFF1E3A8A),
          child: Icon(Icons.shield_outlined, size: 38, color: Colors.white),
        ),
      ),
    );
  }
}
