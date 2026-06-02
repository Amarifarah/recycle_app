import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:recycle_app/models/login_model.dart';
import '../providers/settings_provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  void _login() async {
    if (!_formKey.currentState!.validate()) return;
    
    final loginModel = context.read<LoginModel>();
    final success = await loginModel.login();
    if (success) {
      if (mounted) {
        Navigator.pushReplacementNamed(context, "/dashboard");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    final loginModel = context.watch<LoginModel>();
    final settings = context.watch<SettingsProvider>();
    final isDark = settings.isDarkMode;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: width * 0.9,
            height: height * 0.85,
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  blurRadius: 30,
                  color: isDark ? Colors.black54 : Colors.black12,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              children: [
                // Partie visuelle EcoVision (Desktop/Large Screen style)
                if (width > 800)
                  Expanded(
                    flex: 5,
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(24),
                          bottomLeft: Radius.circular(24),
                        ),
                        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE8F5F0),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Logo
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xFF16A34A),
                                ),
                                child: const Icon(Icons.recycling, color: Colors.white, size: 30),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'GreenMachine',
                                style: GoogleFonts.outfit(
                                  fontSize: 34,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF15803D),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Texte descriptif
                          Text(
                            settings.translate('intelligent_supervision'),
                            textAlign: TextAlign.center,
                            style: GoogleFonts.readexPro(
                              fontSize: 28,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.green[400] : const Color(0xFF1B5E20),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            settings.translate('login_descriptor'),
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: isDark ? Colors.grey[400] : const Color(0xFF4A5568),
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 32),

                          // Image de fond avec overlay
                          Flexible(
                            child: Container(
                              width: double.infinity,
                              height: height * 0.4,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                image: const DecorationImage(
                                  fit: BoxFit.cover,
                                  image: NetworkImage(
                                    'https://images.unsplash.com/photo-1687380386775-e41dd5df0358?crop=entropy&cs=tinysrgb&fit=max&fm=jpg',
                                  ),
                                ),
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  gradient: const LinearGradient(
                                    colors: [Color(0x002E7D32), Color(0x6D2E7D32)],
                                    begin: Alignment(1, 1),
                                    end: Alignment(-1, -1),
                                  ),
                                ),
                                padding: const EdgeInsets.all(24),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      settings.translate('real_time_monitoring'),
                                      style: GoogleFonts.inter(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      settings.translate('control_efficiency'),
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        color: const Color(0xCCFFFFFF),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Partie formulaire de connexion
                Expanded(
                  flex: 5,
                  child: Container(
                    padding: EdgeInsets.all(width > 600 ? 48 : 24),
                    child: Center(
                      child: SingleChildScrollView(
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              if (width <= 800) ...[
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 36,
                                      height: 36,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Color(0xFF16A34A),
                                      ),
                                      child: const Icon(Icons.recycling, color: Colors.white, size: 22),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'GreenMachine',
                                      style: GoogleFonts.outfit(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF15803D),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                              ],
                              Text(
                                settings.translate('login'),
                                style: GoogleFonts.readexPro(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : const Color(0xFF1B5E20),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                settings.translate('login_subtitle'),
                                textAlign: TextAlign.center,
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: Colors.grey[500],
                                ),
                              ),
                              const SizedBox(height: 32),

                              // Email
                              _buildTextField(
                                context,
                                controller: loginModel.emailController,
                                label: settings.translate('email_address'),
                                icon: Icons.email_outlined,
                                isDark: isDark,
                                validator: (v) {
                                  if (v == null || v.isEmpty) return 'L\'email est requis';
                                  if (!v.contains('@')) return 'Format d\'email invalide';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),

                              // Mot de passe
                              _buildTextField(
                                context,
                                controller: loginModel.passwordController,
                                label: settings.translate('password'),
                                icon: Icons.lock_outlined,
                                obscure: !loginModel.showPassword,
                                isDark: isDark,
                                validator: (v) {
                                  if (v == null || v.isEmpty) return 'Le mot de passe est requis';
                                  return null;
                                },
                                suffix: IconButton(
                                  icon: Icon(
                                    loginModel.showPassword
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                    size: 18,
                                    color: Colors.grey,
                                  ),
                                  onPressed: () => loginModel.togglePassword(),
                                ),
                              ),
                              const SizedBox(height: 24),

                              // Bouton
                              SizedBox(
                                width: double.infinity,
                                height: 52,
                                child: ElevatedButton(
                                  onPressed: loginModel.isLoading ? null : _login,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green[700],
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: loginModel.isLoading 
                                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                    : Text(
                                        settings.translate('login'),
                                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                      ),
                                ),
                              ),
                              const SizedBox(height: 16),

                              TextButton(
                                onPressed: () => _showForgotPasswordDialog(context),
                                child: Text(
                                  settings.translate('forgot_password'),
                                  style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w600),
                                ),
                              ),

                              if (loginModel.errorMessage != null) ...[
                                const SizedBox(height: 16),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.red.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.red.withOpacity(0.3)),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.error_outline, color: Colors.red, size: 20),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          loginModel.errorMessage!,
                                          style: const TextStyle(color: Colors.red, fontSize: 13),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showForgotPasswordDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const _ForgotPasswordDialog(),
    );
  }

  Widget _buildTextField(BuildContext context, {
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isDark,
    bool obscure = false,
    Widget? suffix,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      validator: validator,
      style: TextStyle(color: isDark ? Colors.white : Colors.black87),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey[600], fontSize: 14),
        prefixIcon: Icon(icon, size: 20, color: Colors.green),
        suffixIcon: suffix,
        filled: true,
        fillColor: isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFF7FAFC),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: isDark ? Colors.white10 : const Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.green, width: 2),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
//  DIALOG : MOT DE PASSE OUBLIÉ (2 Étapes)
// ─────────────────────────────────────────

class _ForgotPasswordDialog extends StatefulWidget {
  const _ForgotPasswordDialog();

  @override
  State<_ForgotPasswordDialog> createState() => _ForgotPasswordDialogState();
}

class _ForgotPasswordDialogState extends State<_ForgotPasswordDialog> {
  int _step = 1; // Étape 1 = saisie email, Étape 2 = saisie code + nouveau mdp
  bool _showNewPassword = false;
  bool _showConfirmPassword = false;
  String _email = '';

  final _emailCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();
  final _newPassCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();
  final _formKey1 = GlobalKey<FormState>();
  final _formKey2 = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _codeCtrl.dispose();
    _newPassCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loginModel = context.watch<LoginModel>();
    final isDark = context.watch<SettingsProvider>().isDarkMode;

    return AlertDialog(
      backgroundColor: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), shape: BoxShape.circle),
                child: const Icon(Icons.lock_reset_outlined, color: Colors.green, size: 20),
              ),
              const SizedBox(width: 12),
              Text('Mot de passe oublié',
                  style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          // Indicateur d'étape
          Row(
            children: [
              _StepIndicator(step: 1, currentStep: _step, label: 'Email'),
              Expanded(child: Container(height: 2, color: _step >= 2 ? Colors.green : Colors.grey[300])),
              _StepIndicator(step: 2, currentStep: _step, label: 'Code & MDP'),
            ],
          ),
        ],
      ),
      content: SizedBox(
        width: 380,
        child: _step == 1 ? _buildStep1(loginModel, isDark) : _buildStep2(loginModel, isDark),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Annuler', style: TextStyle(color: Colors.grey[600])),
        ),
        ElevatedButton(
          onPressed: loginModel.isLoading ? null : () => _step == 1 ? _submitStep1() : _submitStep2(),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: loginModel.isLoading
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : Text(_step == 1 ? 'Envoyer le code' : 'Réinitialiser', style: const TextStyle(fontSize: 13)),
        ),
      ],
    );
  }

  Widget _buildStep1(LoginModel loginModel, bool isDark) {
    return Form(
      key: _formKey1,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Entrez votre adresse email. Vous recevrez un code de vérification.',
            style: TextStyle(fontSize: 13, color: Colors.grey[500], height: 1.5),
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _emailCtrl,
            keyboardType: TextInputType.emailAddress,
            style: TextStyle(color: isDark ? Colors.white : Colors.black87),
            validator: (v) {
              if (v == null || v.isEmpty) return 'L\'email est requis';
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v)) return 'Format d\'email invalide';
              return null;
            },
            decoration: _fieldDecoration('Adresse email', Icons.email_outlined, isDark),
          ),
          if (loginModel.errorMessage != null) ...[
            const SizedBox(height: 12),
            _ErrorMessage(message: loginModel.errorMessage!),
          ],
        ],
      ),
    );
  }

  Widget _buildStep2(LoginModel loginModel, bool isDark) {
    return Form(
      key: _formKey2,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.green.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle_outline, color: Colors.green, size: 18),
                const SizedBox(width: 8),
                Expanded(child: Text('Code envoyé à $_email', style: const TextStyle(fontSize: 12, color: Colors.green))),
              ],
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _codeCtrl,
            keyboardType: TextInputType.number,
            style: TextStyle(color: isDark ? Colors.white : Colors.black87, letterSpacing: 4, fontSize: 18),
            textAlign: TextAlign.center,
            maxLength: 6,
            validator: (v) {
              if (v == null || v.isEmpty) return 'Le code est requis';
              if (v.length < 4) return 'Code trop court';
              return null;
            },
            decoration: _fieldDecoration('Code de vérification', Icons.pin_outlined, isDark).copyWith(counterText: ''),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _newPassCtrl,
            obscureText: !_showNewPassword,
            style: TextStyle(color: isDark ? Colors.white : Colors.black87),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Mot de passe requis';
              if (v.length < 3) return 'Trop court (min. 3 caractères)';
              return null;
            },
            decoration: _fieldDecoration('Nouveau mot de passe', Icons.lock_outlined, isDark).copyWith(
              suffixIcon: IconButton(
                icon: Icon(_showNewPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined, size: 18, color: Colors.grey),
                onPressed: () => setState(() => _showNewPassword = !_showNewPassword),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _confirmPassCtrl,
            obscureText: !_showConfirmPassword,
            style: TextStyle(color: isDark ? Colors.white : Colors.black87),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Confirmation requise';
              if (v != _newPassCtrl.text) return 'Les mots de passe ne correspondent pas';
              return null;
            },
            decoration: _fieldDecoration('Confirmer le mot de passe', Icons.lock_outlined, isDark).copyWith(
              suffixIcon: IconButton(
                icon: Icon(_showConfirmPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined, size: 18, color: Colors.grey),
                onPressed: () => setState(() => _showConfirmPassword = !_showConfirmPassword),
              ),
            ),
          ),
          if (loginModel.errorMessage != null) ...[
            const SizedBox(height: 12),
            _ErrorMessage(message: loginModel.errorMessage!),
          ],
        ],
      ),
    );
  }

  Future<void> _submitStep1() async {
    if (!_formKey1.currentState!.validate()) return;
    _email = _emailCtrl.text.trim();
    final success = await context.read<LoginModel>().forgotPassword(_email);
    if (success && mounted) {
      setState(() => _step = 2);
    }
  }

  Future<void> _submitStep2() async {
    if (!_formKey2.currentState!.validate()) return;
    final success = await context.read<LoginModel>().resetPassword(
      _email,
      _codeCtrl.text.trim(),
      _newPassCtrl.text,
    );
    if (success && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Mot de passe réinitialisé avec succès ! Connectez-vous.'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  InputDecoration _fieldDecoration(String label, IconData icon, bool isDark) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.grey[600], fontSize: 13),
      prefixIcon: Icon(icon, size: 20, color: Colors.green),
      filled: true,
      fillColor: isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFF7FAFC),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: isDark ? Colors.white10 : const Color(0xFFE2E8F0))),
      focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.green, width: 2)),
      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.red)),
      focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.red, width: 2)),
    );
  }
}

// ─────────────────────────────────────────
//  WIDGETS HELPERS
// ─────────────────────────────────────────

class _StepIndicator extends StatelessWidget {
  final int step, currentStep;
  final String label;

  const _StepIndicator({required this.step, required this.currentStep, required this.label});

  @override
  Widget build(BuildContext context) {
    final isDone = currentStep > step;
    final isActive = currentStep >= step;
    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 30, height: 30,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDone ? Colors.green : isActive ? Colors.green : Colors.grey[300],
          ),
          child: Center(
            child: isDone
                ? const Icon(Icons.check, color: Colors.white, size: 16)
                : Text('$step', style: TextStyle(color: isActive ? Colors.white : Colors.grey[600], fontSize: 13, fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(fontSize: 10, color: isActive ? Colors.green : Colors.grey[500])),
      ],
    );
  }
}

class _ErrorMessage extends StatelessWidget {
  final String message;
  const _ErrorMessage({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 16),
          const SizedBox(width: 8),
          Expanded(child: Text(message, style: const TextStyle(color: Colors.red, fontSize: 12))),
        ],
      ),
    );
  }
}
