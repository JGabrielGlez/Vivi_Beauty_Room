import 'package:flutter/material.dart';
// Importación de componentes creados por otros compañeros (se reutilizan para mantener el diseño)
import '../../../shared/widgets/primary_button.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/search_bar_widget.dart'; 

// Definimos un StatefulWidget porque necesitamos que la pantalla cambie (reaccione) 
// cuando el usuario seleccione una duración diferente.
class NuevaCitaModal extends StatefulWidget {
  const NuevaCitaModal({super.key});

  @override
  State<NuevaCitaModal> createState() => _NuevaCitaModalState();
}

class _NuevaCitaModalState extends State<NuevaCitaModal> {
  // Variable para guardar cuál botón de tiempo (30, 45, 60 min) está seleccionado.
  String duracionSeleccionada = '60 MIN';

  @override
  Widget build(BuildContext context) {
    return Container(
      // Configuración del espacio interno y ajuste para que el teclado no tape el contenido
      padding: EdgeInsets.only(
        top: 12, left: 20, right: 20,
        // MediaQuery ayuda a saber cuánto mide el teclado para empujar el modal hacia arriba
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      // Diseño del fondo blanco con esquinas redondeadas solo arriba
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      // SingleChildScrollView permite hacer scroll si el contenido es más largo que la pantalla
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min, // El modal solo ocupa el espacio que necesita
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // El "palito" gris decorativo que indica que el modal se puede arrastrar hacia abajo
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 20),

            // FILA DE CABECERA: Título y botón de cerrar (X)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Nueva Cita', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
                IconButton(
                  onPressed: () => Navigator.pop(context), // Cierra el modal
                  icon: const Icon(Icons.cancel, color: Color(0xFFE0E7FF), size: 30),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // SECCIÓN: Búsqueda de cliente
            _buildLabel('SELECCIONAR CLIENTE'),
            const SizedBox(height: 8),
            const SearchBarWidget(hintText: 'Buscar por nombre...'),

            const SizedBox(height: 20),

            // SECCIÓN: Chips de tipo de servicio (Botones con icono)
            _buildLabel('TIPO DE SERVICIO'),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildServiceChip('Pedicura', Icons.edit_note, true),
                const SizedBox(width: 12),
                _buildServiceChip('Peinado', Icons.content_cut, false),
              ],
            ),

            const SizedBox(height: 20),

            // SECCIÓN: Fecha y Horario (Divididos en dos columnas iguales)
            Row(
              children: [
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('FECHA'),
                    const SizedBox(height: 8),
                    // Usamos el componente de José Luis (AppTextField)
                    const AppTextField(label: '25 Feb 2026'), 
                  ],
                )),
                const SizedBox(width: 15),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('HORARIO'),
                    const SizedBox(height: 8),
                    const AppTextField(label: '10:00 AM'), 
                  ],
                )),
              ],
            ),

            const SizedBox(height: 20),

            // SECCIÓN: Selector de Duración
            _buildLabel('DURACIÓN'),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              // .map convierte nuestra lista de textos en botones visuales automáticamente
              children: ['30 MIN', '45 MIN', '60 MIN', '90 MIN'].map((t) => _buildDuracionTab(t)).toList(),
            ),

            const SizedBox(height: 20),

            // SECCIÓN: Costos (Dinero)
            Row(
              children: [
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('COSTO TOTAL'),
                    const SizedBox(height: 8),
                    const AppTextField(label: '\$ 0.00'),
                  ],
                )),
                const SizedBox(width: 15),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('ANTICIPO'),
                    const SizedBox(height: 8),
                    const AppTextField(label: '\$ 0.00'),
                  ],
                )),
              ],
            ),

            const SizedBox(height: 30),

            // BOTÓN FINAL: Reutiliza el PrimaryButton rosa del equipo
            PrimaryButton(
              text: 'Guardar Cita',
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  // --- MÉTODOS AUXILIARES (Para no repetir código de diseño) ---

  // Crea los textos grises en mayúsculas de cada sección
  Widget _buildLabel(String text) {
    return Text(text, style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold, letterSpacing: 1.1, fontFamily: 'Poppins'));
  }

  // Crea los botones de servicio (como "Pedicura") con su icono y color rosa si está seleccionado
  Widget _buildServiceChip(String label, IconData icon, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFD4748F).withOpacity(0.6) : const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: isSelected ? Colors.white : Colors.grey),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(color: isSelected ? Colors.white : Colors.grey, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  // Crea los botones de tiempo (30 min, 60 min). 
  // Al hacer clic, actualiza la variable 'duracionSeleccionada' y refresca la pantalla.
  Widget _buildDuracionTab(String label) {
    bool isSelected = duracionSeleccionada == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          duracionSeleccionada = label; // Cambia el estado
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(10),
          border: isSelected ? Border.all(color: const Color(0xFFD4748F).withOpacity(0.2)) : null,
          boxShadow: isSelected ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)] : null,
        ),
        child: Text(label, style: TextStyle(color: isSelected ? const Color(0xFFD4748F) : Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
      ),
    );
  }
}