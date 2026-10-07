import 'package:flutter/material.dart';

class CategoriaCard extends StatelessWidget {
  final String nombre;
  final String emoji;
  final bool seleccionada;
  final VoidCallback onTap;

  const CategoriaCard({
    super.key,
    required this.nombre,
    required this.emoji,
    required this.seleccionada,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: seleccionada
              ? const Color(0xFFF47745)
              : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFFF47745),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Text(
              emoji,
              style: const TextStyle(
                fontSize: 20,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              nombre,
              style: TextStyle(
                color: seleccionada
                    ? Colors.white
                    : const Color(0xFF4A2C20),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}