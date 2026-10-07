import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'registro_screen.dart';
import 'catalogo_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController correoController =
      TextEditingController();

  final TextEditingController contrasenaController =
      TextEditingController();

  bool ocultarContrasena = true;

  Future<void> iniciarSesion() async {
    final correo = correoController.text.trim();
    final contrasena = contrasenaController.text.trim();

    if (correo.isEmpty || contrasena.isEmpty) {
      mostrarAlerta(
        'Datos incompletos',
        'Ingresa tu correo y contraseña.',
      );
      return;
    }

    try {
      await Supabase.instance.client.auth.signInWithPassword(
        email: correo,
        password: contrasena,
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const CatalogoScreen(),
        ),
      );
    } on AuthException catch (error) {
      if (!mounted) return;

      mostrarAlerta(
        'Error de inicio de sesión',
        error.message,
      );
    } catch (error) {
      if (!mounted) return;

      mostrarAlerta(
        'Error',
        'Ocurrió un error inesperado.',
      );
    }
  }

  void mostrarAlerta(String titulo, String mensaje) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(titulo),
          content: Text(mensaje),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Aceptar'),
            ),
          ],
        );
      },
    );
  }

  void irARegistro() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const RegistroScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF1DC),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: 35,
            vertical: 30,
          ),
          child: Column(
            children: [
              const SizedBox(height: 35),

              Image.asset(
                'assets/images/logo_pizzalicious.png',
                width: 220,
              ),

              const SizedBox(height: 35),

              TextField(
                controller: correoController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'Correo electrónico',
                  hintStyle: const TextStyle(
                    color: Color(0xFF8A6655),
                  ),
                  prefixIcon: const Icon(
                    Icons.email_outlined,
                    color: Color(0xFFF47745),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 15,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: const BorderSide(
                      color: Color(0xFFF47745),
                      width: 2,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 18),

              TextField(
                controller: contrasenaController,
                obscureText: ocultarContrasena,
                decoration: InputDecoration(
                  hintText: 'Contraseña',
                  hintStyle: const TextStyle(
                    color: Color(0xFF8A6655),
                  ),
                  prefixIcon: const Icon(
                    Icons.lock_outline,
                    color: Color(0xFFF47745),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 15,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: const BorderSide(
                      color: Color(0xFFF47745),
                      width: 2,
                    ),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      ocultarContrasena
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: const Color(0xFF8A6655),
                    ),
                    onPressed: () {
                      setState(() {
                        ocultarContrasena =
                            !ocultarContrasena;
                      });
                    },
                  ),
                ),
              ),

              const SizedBox(height: 25),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: iniciarSesion,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF47745),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text(
                    'Iniciar sesión',
                    style: TextStyle(
                      fontSize: 19,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              const Text(
                '¿No tienes cuenta?',
                style: TextStyle(
                  fontSize: 11,
                  color: Color(0xFF4A2C20),
                ),
              ),

              const SizedBox(height: 5),

              TextButton(
                onPressed: irARegistro,
                child: const Text(
                  'Crear cuenta',
                  style: TextStyle(
                    color: Color(0xFF4A2C20),
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    correoController.dispose();
    contrasenaController.dispose();
    super.dispose();
  }
}