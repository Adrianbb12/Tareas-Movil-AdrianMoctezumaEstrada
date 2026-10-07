import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegistroScreen extends StatefulWidget {
  const RegistroScreen({super.key});

  @override
  State<RegistroScreen> createState() => _RegistroScreenState();
}

class _RegistroScreenState extends State<RegistroScreen> {
  final TextEditingController correoController =
      TextEditingController();

  final TextEditingController contrasenaController =
      TextEditingController();

  final TextEditingController confirmarController =
      TextEditingController();

  bool ocultarContrasena = true;
  bool ocultarConfirmacion = true;
  bool registrando = false;

  Future<void> registrarUsuario() async {
    final correo = correoController.text.trim();
    final contrasena = contrasenaController.text.trim();
    final confirmar = confirmarController.text.trim();

    if (correo.isEmpty ||
        contrasena.isEmpty ||
        confirmar.isEmpty) {
      mostrarAlerta(
        'Datos incompletos',
        'Completa todos los campos.',
      );
      return;
    }

    if (contrasena.length < 6) {
      mostrarAlerta(
        'Contraseña inválida',
        'La contraseña debe tener al menos 6 caracteres.',
      );
      return;
    }

    if (contrasena != confirmar) {
      mostrarAlerta(
        'Contraseñas diferentes',
        'Las contraseñas no coinciden.',
      );
      return;
    }

    setState(() {
      registrando = true;
    });

    try {
      final respuesta = await Supabase.instance.client.auth.signUp(
        email: correo,
        password: contrasena,
      );

      if (!mounted) return;

      if (respuesta.user != null) {
        mostrarAlerta(
          'Cuenta creada',
          'Tu cuenta se creó correctamente. '
              'Si tu proyecto requiere confirmación por correo, '
              'revisa tu correo antes de iniciar sesión.',
        );
      }
    } on AuthException catch (error) {
      if (!mounted) return;

      mostrarAlerta(
        'Error',
        error.message,
      );
    } catch (error) {
      if (!mounted) return;

      mostrarAlerta(
        'Error',
        'Ocurrió un error inesperado.',
      );
    } finally {
      if (mounted) {
        setState(() {
          registrando = false;
        });
      }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF1DC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: const Color(0xFF4A2C20),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: 35,
            vertical: 10,
          ),
          child: Column(
            children: [
              Image.asset(
                'assets/images/logo_pizzalicious.png',
                width: 190,
              ),

              const SizedBox(height: 10),

              const Text(
                'Crea tu cuenta',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4A2C20),
                ),
              ),

              const SizedBox(height: 30),

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
                  filled: true,
                  fillColor: Colors.white,
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
                controller: confirmarController,
                obscureText: ocultarConfirmacion,
                decoration: InputDecoration(
                  hintText: 'Confirmar contraseña',
                  hintStyle: const TextStyle(
                    color: Color(0xFF8A6655),
                  ),
                  prefixIcon: const Icon(
                    Icons.lock_outline,
                    color: Color(0xFFF47745),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      ocultarConfirmacion
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: const Color(0xFF8A6655),
                    ),
                    onPressed: () {
                      setState(() {
                        ocultarConfirmacion =
                            !ocultarConfirmacion;
                      });
                    },
                  ),
                  filled: true,
                  fillColor: Colors.white,
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

              const SizedBox(height: 25),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed:
                      registrando ? null : registrarUsuario,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF47745),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: registrando
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Registrarse',
                          style: TextStyle(
                            fontSize: 18,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 15),

              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text(
                  'Ya tengo una cuenta',
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
    confirmarController.dispose();
    super.dispose();
  }
}