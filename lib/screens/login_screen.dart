import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/firebase_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLogin = true;
  bool _loading = false;
  bool _obscurePassword = true;

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    if (email.isEmpty || password.isEmpty) return;

    setState(() => _loading = true);
    try {
      if (_isLogin) {
        await FirebaseService.signIn(email: email, password: password);
      } else {
        await FirebaseService.signUp(email: email, password: password);
      }

      if (mounted) {
        // Check if returning user has roadmap
        final roadmap = await FirebaseService.getRoadmap();
        if (roadmap != null && roadmap.isNotEmpty) {
          context.go('/home', extra: {});
        } else {
          context.go('/onboarding');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: const Color(0xFFE24B4A),
          ),
        );
      }
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 700;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FF),
      body: isWide ? _buildWideLayout() : _buildNarrowLayout(),
    );
  }

  // ─── WIDE LAYOUT (desktop/tablet) ────────────────────────────────────────
  Widget _buildWideLayout() {
    return Row(
      children: [
        // Left panel — branding
        Expanded(
          flex: 5,
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF5B52C8), Color(0xFF7F77DD), Color(0xFF9B94E8)],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(48),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Logo
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.auto_awesome,
                        color: Colors.white, size: 28),
                  ),
                  const SizedBox(height: 16),
                  const Text('SkillPath AI',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold)),
                  const Spacer(),
                  // Hero text
                  const Text('Learn smarter,\nnot harder.',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          height: 1.2)),
                  const SizedBox(height: 16),
                  const Text(
                      'AI-powered personalized learning paths\ntailored to your goals and pace.',
                      style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                          height: 1.5)),
                  const SizedBox(height: 48),
                  // Feature pills
                  _featurePill(Icons.auto_awesome, 'AI Roadmap Generation'),
                  const SizedBox(height: 12),
                  _featurePill(Icons.quiz_outlined, 'Adaptive Quiz System'),
                  const SizedBox(height: 12),
                  _featurePill(Icons.chat_outlined, 'Personal AI Tutor'),
                  const Spacer(),
                ],
              ),
            ),
          ),
        ),
        // Right panel — form
        Expanded(
          flex: 4,
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(48),
              child: _buildFormContent(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _featurePill(IconData icon, String label) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.white, size: 16),
        ),
        const SizedBox(width: 12),
        Text(label,
            style: const TextStyle(color: Colors.white, fontSize: 14)),
      ],
    );
  }

  // ─── NARROW LAYOUT (mobile) ───────────────────────────────────────────────
  Widget _buildNarrowLayout() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Top gradient banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 60, 24, 40),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF5B52C8), Color(0xFF7F77DD), Color(0xFF9B94E8)],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.auto_awesome,
                          color: Colors.white, size: 22),
                    ),
                    const SizedBox(width: 10),
                    const Text('SkillPath AI',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 24),
                const Text('Learn smarter,\nnot harder.',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        height: 1.2)),
                const SizedBox(height: 8),
                const Text('AI-powered personalized learning paths.',
                    style: TextStyle(color: Colors.white70, fontSize: 14)),
              ],
            ),
          ),
          // Form
          Padding(
            padding: const EdgeInsets.all(24),
            child: _buildFormContent(),
          ),
        ],
      ),
    );
  }

  // ─── SHARED FORM CONTENT ─────────────────────────────────────────────────
  Widget _buildFormContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _isLogin ? 'Welcome back 👋' : 'Create account ✨',
          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        Text(
          _isLogin
              ? 'Sign in to continue your learning journey'
              : 'Start your personalized AI learning path',
          style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
        ),
        const SizedBox(height: 32),
        _inputField(
          controller: _emailController,
          label: 'Email address',
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        _inputField(
          controller: _passwordController,
          label: 'Password',
          icon: Icons.lock_outline,
          obscure: _obscurePassword,
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
              color: Colors.grey,
              size: 20,
            ),
            onPressed: () =>
                setState(() => _obscurePassword = !_obscurePassword),
          ),
        ),
        if (_isLogin) ...[
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: Text('Forgot password?',
                style: TextStyle(
                    color: const Color(0xFF7F77DD).withValues(alpha: 0.8),
                    fontSize: 13,
                    fontWeight: FontWeight.w500)),
          ),
        ],
        const SizedBox(height: 24),
        // Submit button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _loading ? null : _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7F77DD),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 2,
              shadowColor: const Color(0xFF7F77DD).withValues(alpha: 0.4),
            ),
            child: _loading
                ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                  color: Colors.white, strokeWidth: 2),
            )
                : Text(
              _isLogin ? 'Sign in' : 'Create account',
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        const SizedBox(height: 24),
        // Divider
        Row(
          children: [
            Expanded(child: Divider(color: Colors.grey.shade300)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text('or',
                  style: TextStyle(color: Colors.grey.shade400, fontSize: 13)),
            ),
            Expanded(child: Divider(color: Colors.grey.shade300)),
          ],
        ),
        const SizedBox(height: 24),
        // Toggle
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _isLogin
                  ? "Don't have an account? "
                  : 'Already have an account? ',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),
            GestureDetector(
              onTap: () => setState(() => _isLogin = !_isLogin),
              child: Text(
                _isLogin ? 'Sign up' : 'Sign in',
                style: const TextStyle(
                  color: Color(0xFF7F77DD),
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscure = false,
    TextInputType? keyboardType,
    Widget? suffixIcon,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
        prefixIcon: Icon(icon, color: const Color(0xFF7F77DD), size: 20),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF7F77DD), width: 2),
        ),
      ),
    );
  }
}