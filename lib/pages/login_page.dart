import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:recycle_app/models/login_model.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
  }

  void _login() async {
    final loginModel = context.read<LoginModel>();
    final success = await loginModel.login();
    if (success) {
      if (mounted) {
        Navigator.pushNamed(context, "/dashboard");
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    final loginModel = context.watch<LoginModel>();

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: width * 0.9,
            height: height * 0.85,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: const [
                BoxShadow(
                  blurRadius: 30,
                  color: Colors.black12,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              children: [
                // Partie visuelle EcoVision
                Expanded(
                  flex: 5,
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(24),
                        bottomLeft: Radius.circular(24),
                      ),
                      color: Colors.white,
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
                                gradient: LinearGradient(
                                  colors: [Color(0xFF2E7D32), Colors.green],
                                  begin: Alignment(1, -1),
                                  end: Alignment(-1, 1),
                                ),
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.eco_rounded,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'GreenMachine',
                              style: GoogleFonts.readexPro(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color:  Color(0xFF2E7D32),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),

                        // Texte descriptif
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Supervision Intelligente',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.readexPro(
                                fontSize: 28,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF1B5E20),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Optimisez vos machines de recyclage avec notre plateforme de monitoring avancée',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                color: const Color(0xFF4A5568),
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),

                        // Image de fond avec overlay
                        Flexible(
                          child: Container(
                            width: double.infinity,
                            height:
                                MediaQuery.of(context).size.height *
                                0.4, // 40% de la hauteur
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F5F0),
                              borderRadius: BorderRadius.circular(16),
                              image: const DecorationImage(
                                fit: BoxFit.cover,
                                image: NetworkImage(
                                  'https://images.unsplash.com/photo-1687380386775-e41dd5df0358?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w0NTYyMDF8MHwxfHJhbmRvbXx8fHx8fHx8fDE3NjQwMjQzNDZ8&ixlib=rb-4.1.0&q=80&w=1080',
                                ),
                              ),
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0x002E7D32),
                                    Color(0x4D2E7D32),
                                  ],
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
                                    'Surveillance en temps réel',
                                    style: GoogleFonts.inter(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Contrôlez l\'efficacité de vos équipements',
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      color: const Color(0xCCFFFFFF),
                                      height: 1.4,
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
                    padding: const EdgeInsets.all(48),
                    child: Center(
                      child: SingleChildScrollView(
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'Connexion',
                                style: GoogleFonts.readexPro(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF1B5E20),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Accédez à votre tableau de bord',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  color: const Color(0xFF718096),
                                ),
                              ),
                              const SizedBox(height: 24),

                              // Email
                              TextFormField(
                                controller: loginModel.emailController,
                                keyboardType: TextInputType.emailAddress,
                                decoration: InputDecoration(
                                  labelText: 'Adresse email',
                                  hintText: 'votre.email@entreprise.com',
                                  prefixIcon: const Icon(
                                    Icons.email_outlined,
                                    size: 20,
                                  ),
                                  filled: true,
                                  fillColor: const Color(0xFFF7FAFC),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: Color(0xFFE2E8F0),
                                      width: 2,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: Color(0xFF38A169),
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Mot de passe
                              TextFormField(
                                controller: loginModel.passwordController,
                                obscureText: !loginModel.showPassword,
                                decoration: InputDecoration(
                                  labelText: 'Mot de passe',
                                  hintText: 'Votre mot de passe sécurisé',
                                  prefixIcon: const Icon(
                                    Icons.lock_outlined,
                                    size: 20,
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      loginModel.showPassword
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                    ),
                                    onPressed: () {
                                      loginModel.togglePassword();
                                    },
                                  ),
                                  filled: true,

                                  fillColor: const Color(0xFFF7FAFC),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: Color(0xFFE2E8F0),
                                      width: 2,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: Color(0xFF38A169),
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),

                              // Bouton
                              SizedBox(
                                width: double.infinity,
                                height: 56,
                                child: ElevatedButton.icon(
                                  onPressed: loginModel.isLoading ? null : _login,
                                  icon: loginModel.isLoading 
                                    ? const SizedBox(
                                        width: 20, height: 20, 
                                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                                      )
                                    : const Icon(
                                        Icons.login_rounded,
                                        size: 20,
                                      ),
                                  label: Text(
                                    loginModel.isLoading ? 'Connexion...' : 'Se connecter',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green[700],
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Mot de passe oublié
                              TextButton(
                                onPressed: () {},
                                child: const Text(
                                  'Mot de passe oublié ?',
                                  style: TextStyle(color: Color(0xFF38A169)),
                                ),
                              ),

                              // Message d'erreur
                              if (loginModel.errorMessage != null)
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF7FAFC),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: const Color(0xFFE2E8F0),
                                      width: 2,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.error_outline_rounded,
                                        color: Color(0xFFE53E3E),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          loginModel.errorMessage!,
                                          style: const TextStyle(
                                            color: Color(0xFFE53E3E),
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
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
}
