import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vivi_room/core/services/api_client.dart';
import 'package:vivi_room/features/auth/providers/auth_provider.dart';
import 'package:vivi_room/shared/widgets/app_bottom_nav_bar.dart';
import 'package:vivi_room/shared/widgets/app_text_field.dart';
import 'package:vivi_room/shared/widgets/cliente_avatar.dart';
import 'package:vivi_room/shared/widgets/primary_button.dart';
import 'package:vivi_room/shared/widgets/status_badge.dart';
import '../../../shared/widgets/fab_button.dart';
import '../../../shared/widgets/search_bar_widget.dart';
import '../screens/detalle_cita_screen.dart';
import '../../citas/widgets/nueva_cita_modal.dart';
import 'dart:developer' as _logger;
import 'dart:convert';
import 'package:http/http.dart' as http;

String token="";
Map<String,String> header = {'Content-Type': 'application/json','Authorization': 'Bearer $token'};

class AgendaScreen extends StatefulWidget {
  const AgendaScreen({super.key});

  @override
  State<AgendaScreen> createState() => _AgendaScreenState();
}

class _AgendaScreenState extends State<AgendaScreen> {
    // Genera la lista de días para la agenda
    List<Map<String, String>> _generateDays(DateTime currentDate) {
      final List<Map<String, String>> result = [];
      for (int i = -2; i <= 4; i++) {
        final date = currentDate.add(Duration(days: i));
        final isToday = i == 0;
        result.add({
          'day': _weekdayShort(date.weekday),
          'date': date.day.toString().padLeft(2, '0'),
          'isToday': isToday ? 'true' : 'false',
          'fullDate': date.toIso8601String(),
        });
      }
      return result;
    }
  // Configuración de la URL base del backend
  static String backendBaseUrl = const String.fromEnvironment('BACKEND_URL', defaultValue: 'http://localhost:3000');
  int index = 0;
  int selectedDayIndex = 0;
  late List<Map<String, String>> days = [];
  @override
  void initState() {
    super.initState();
    days = _generateDays(DateTime.now());
    selectedDayIndex = days.indexWhere((d) => d['isToday'] == 'true');
    if (selectedDayIndex == -1) selectedDayIndex = 0;
    fetchAppointmentsForDay(DateTime.now());
  }
  Map<String,String>monts={
    '01':'Enero',
    '02':'Febrero',
    '03':'Marzo',
    '04':'Abril',
    '05':'Mayo',
    '06':'Junio',
    '07':'Julio',
    '08':'Agosto',
    '09':'Septiembre',
    '10':'Octubre',
    '11':'Noviembre',
    '12':'Diciembre',
  };
  // Lista de citas obtenidas del backend
  List<Map<String, dynamic>> appointments = [];
  bool isLoading = false;
  String? errorMsg;

  Future<void> fetchAppointmentsForDay(DateTime date) async {
    setState(() {
      isLoading = true;
      errorMsg = null;
    });
    final String formattedDate = "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    final url = Uri.parse("$backendBaseUrl/api/agenda/citas/dia?fecha=$formattedDate");

    try {
      final response = await http.get(url,headers: header);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        appointments = data.map((e) => e as Map<String, dynamic>).toList();
      }
      else {
        errorMsg = 'Error al cargar citas: \\${response.statusCode}';
      }
    } catch (e) {
      errorMsg = 'Error de conexión: $e';
    }
    setState(() {
      isLoading = false;
    });
  }
  String extraerHora(String time) {
    final hora = time.split('T')[1];
    return hora.split(':')[0]+":"+hora.split(':')[1];
  }
  Future<String> extraerCliente(String id) async {
    try {
      final response = await http.get(Uri.parse("$backendBaseUrl/api/clientas/$id"),headers: header);
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        // Ajusta el campo según la respuesta real del backend
        return data['nombre'] ?? 'Sin nombre';
      } else {
        return response.body;
      }
    } catch (e) {
      return 'Error';
    }
  }

  Future<String> extraerServicio(String id) async {
    try {
      final response = await http.get(Uri.parse("$backendBaseUrl/api/servicios/$id"));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        // Ajusta el campo según la respuesta real del backend
        return data['nombre'] ?? 'Sin nombre';
      } else {
        return response.body;
      }
    } catch (e) {
      return 'Error';
    }
  }

  String _weekdayShort(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'LUN';
      case DateTime.tuesday:
        return 'MAR';
      case DateTime.wednesday:
        return 'MIE';
      case DateTime.thursday:
        return 'JUE';
      case DateTime.friday:
        return 'VIE';
      case DateTime.saturday:
        return 'SAB';
      case DateTime.sunday:
        return 'DOM';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: FabButton(
        onPressed: () => {
          showModalBottomSheet(
            isScrollControlled: true,
            context: context,
            builder: (context) => const NuevaCitaModal(),
          ),
        },
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        monts[DateTime.now().month.toString().padLeft(2, '0')]!,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        DateTime.now().year.toString().padLeft(2, '0'),
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  PopupMenuButton<String>(
                    icon: const CircleAvatar(
                      backgroundColor: Color(0xFFF5F6FA),
                      child: Icon(Icons.person_outline, color: Color(0xFFD4748F)),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    onSelected: (value) {
                      if (value == 'password') {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (_) => const _CambiarPasswordSheet(),
                        );
                      } else if (value == 'info') {
                        showDialog(
                          context: context,
                          useRootNavigator: false,
                          builder: (ctx) => AlertDialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            title: const Text('Vivi Beauty Room'),
                            content: const Text(
                              'Versión 1.0.0\nAplicación de gestión para salones de belleza.',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(ctx).pop(),
                                child: const Text(
                                  'Cerrar',
                                  style: TextStyle(color: Color(0xFFD4748F)),
                                ),
                              ),
                            ],
                          ),
                        );
                      } else if (value == 'logout') {
                        final authProvider = context.read<AuthProvider>();
                        showDialog(
                          context: context,
                          useRootNavigator: false,
                          builder: (ctx) => AlertDialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            title: const Text('Cerrar sesión'),
                            content: const Text(
                              '¿Estás segura de que deseas cerrar sesión?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(ctx).pop(),
                                child: const Text('Cancelar'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(ctx).pop();
                                  authProvider.signOut();
                                },
                                child: const Text(
                                  'Cerrar sesión',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                    },
                    itemBuilder: (context) {
                      final usuario = context.read<AuthProvider>().usuario;
                      return [
                        PopupMenuItem<String>(
                          enabled: false,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                usuario?.nombre ?? 'Usuario',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                usuario?.rol ?? '',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.black45,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const PopupMenuDivider(),
                        PopupMenuItem<String>(
                          value: 'password',
                          child: Row(
                            children: const [
                              Icon(Icons.lock_outline, size: 18, color: Colors.black54),
                              SizedBox(width: 12),
                              Text('Cambiar contraseña'),
                            ],
                          ),
                        ),
                        PopupMenuItem<String>(
                          value: 'info',
                          child: Row(
                            children: const [
                              Icon(Icons.info_outline, size: 18, color: Colors.black54),
                              SizedBox(width: 12),
                              Text('Información de la app'),
                            ],
                          ),
                        ),
                        const PopupMenuDivider(),
                        PopupMenuItem<String>(
                          value: 'logout',
                          child: Row(
                            children: const [
                              Icon(Icons.logout, size: 18, color: Colors.red),
                              SizedBox(width: 12),
                              Text(
                                'Cerrar sesión',
                                style: TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                      ];
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 60,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: days.length,
                  itemBuilder: (context, i) {
                    final day = days[i];
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedDayIndex = i;
                        });
                        // Usar la fecha exacta del chip seleccionado
                        final selectedDate = DateTime.parse(day['fullDate']!);
                        fetchAppointmentsForDay(selectedDate);
                      },
                      child: _dayChip(
                        day['day']!,
                        day['date']!,
                        selectedDayIndex == i,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : errorMsg != null
                        ? Center(child: Text(errorMsg!))
                        : ListView(
                            children: [
                              //Text(appointments.toString()),
                              for (var i = 0; i < appointments.length; i++)
                                FutureBuilder<String>(
                                  future: appointments[i]['idClienta'] != null
                                      ? extraerCliente(appointments[i]['idClienta'].toString())
                                      : Future.value('Desconocido'),
                                  builder: (context, clienteSnapshot) {
                                    return FutureBuilder<String>(
                                      future: appointments[i]['idServicio'] != null
                                          ? extraerServicio(appointments[i]['idServicio'].toString())
                                          : Future.value('Desconocido'),
                                      builder: (context, servicioSnapshot) {
                                        return GestureDetector(
                                          onTap: () async {
                                            final cliente = clienteSnapshot.data ?? 'Cargando...';
                                            final servicio = servicioSnapshot.data ?? 'Cargando...';
                                            final citaData = {
                                              ...appointments[i],
                                              'nombreClienta': cliente,
                                              'servicio': servicio,
                                              'id': appointments[i]['idCita'] ?? '',
                                            };
                                            await showModalBottomSheet(
                                              context: context,
                                              isScrollControlled: true,
                                              backgroundColor: Colors.transparent,
                                              builder: (context) => DetalleCitaScreen(citaData: citaData),
                                            );
                                          },
                                          child: _agendaCard(
                                            time: extraerHora(appointments[i]['fechaHora']) ?? '',
                                            nombre: clienteSnapshot.data ?? 'Cargando...',
                                            servicio: servicioSnapshot.data ?? 'Cargando...',
                                            duracion: appointments[i]['duracion']?.toString() ?? '',
                                            status: appointments[i]['estado'] ?? appointments[i]['status'] ?? '',
                                          ),
                                        );
                                      },
                                    );
                                  },
                                ),
                              if (appointments.isEmpty)
                                const Center(child: Text('No hay citas para este día.')),
                            ],
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dayChip(String day, String date, bool selected) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: selected
                  ? const Color(0xFFD4748F)
                  : const Color(0xFFF5F6FA),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                Text(
                  day,
                  style: TextStyle(
                    color: selected
                        ? Colors.white
                        : Colors.black.withOpacity(0.5),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  date,
                  style: TextStyle(
                    color: selected ? Colors.white : Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _agendaCard({
    required String time,
    required String nombre,
    required String servicio,
    required String duracion,
    required String status,
    bool leftAccent = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 60,
            child: Text(
              time,
              style: const TextStyle(
                color: Color(0xFFB0B7C3),
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFF0F1F3)),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nombre,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                  if (servicio.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        servicio,
                        style: TextStyle(
                          color: Colors.black.withOpacity(0.6),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  if (duracion.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 16,
                            color: Color(0xFFB0B7C3),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            duracion + " min",
                            style: const TextStyle(
                              color: Color(0xFFB0B7C3),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  Align(
                    alignment: Alignment.topRight,
                    child: StatusBadge(status: status),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _availableSlot(String time) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Text(
              time,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.grey.shade300,
                  style: BorderStyle.solid,
                ),
              ),
              padding: const EdgeInsets.all(16),
              child: Text(
                'Available Slot',
                style: TextStyle(color: Colors.black.withOpacity(0.3)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _lunchBreak(String time) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Text(
              time,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.lunch_dining, color: Colors.grey.shade400),
                  const SizedBox(width: 8),
                  Text(
                    'Lunch Break',
                    style: TextStyle(color: Colors.black.withOpacity(0.4)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AppointmentSheet extends StatefulWidget {
  final Map<String, dynamic>? initial;
  const _AppointmentSheet({this.initial});

  @override
  State<_AppointmentSheet> createState() => _AppointmentSheetState();
}

class _AppointmentSheetState extends State<_AppointmentSheet> {
  late TextEditingController nombreController;
  late TextEditingController costoController;
  late TextEditingController anticipoController;
  String servicio = 'Pedicura';
  int duracion = 60;
  DateTime fecha = DateTime.now();
  TimeOfDay horario = const TimeOfDay(hour: 10, minute: 0);

  @override
  void initState() {
    super.initState();
    nombreController = TextEditingController(
      text: widget.initial?['nombre'] ?? '',
    );
    costoController = TextEditingController(
      text: (widget.initial?['costo'] ?? 0.00).toString(),
    );
    anticipoController = TextEditingController(
      text: (widget.initial?['montoAnticipo'] ?? 0.00).toString(),
    );
    servicio = widget.initial?['servicio'] ?? 'Pedicura';
    duracion = widget.initial?['duracion'] ?? 60;
    fecha = widget.initial?['fecha'] ?? DateTime.now();
    if (widget.initial?['time'] != null) {
      final timeParts = (widget.initial!['time'] as String).split(':');
      if (timeParts.length == 2) {
        horario = TimeOfDay(
          hour: int.parse(timeParts[0]),
          minute: int.parse(timeParts[1]),
        );
      }
    }
  }

  // Creo este es el modal
  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return DetalleCitaScreen();
      },
    );
  }
}

Widget _serviceChip(
  String label,
  bool selected,
  IconData icon,
  VoidCallback onTap,
) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      decoration: BoxDecoration(
        color: selected ? const Color(0xFFD4748F) : const Color(0xFFF5F6FA),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      child: Row(
        children: [
          Icon(icon, color: selected ? Colors.white : const Color(0xFFD4748F)),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : const Color(0xFFD4748F),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _durationChip(int minutes, bool selected, VoidCallback onTap) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      decoration: BoxDecoration(
        color: selected ? const Color(0xFFD4748F) : const Color(0xFFF5F6FA),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      child: Row(
        children: [
          Text(
            '$minutes',
            style: TextStyle(
              color: selected ? Colors.white : const Color(0xFFD4748F),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            'min',
            style: TextStyle(
              color: selected ? Colors.white : const Color(0xFFD4748F),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _dateField(String label, DateTime date, VoidCallback onTap) {
  return Expanded(
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(width: 8),
            Text(
              '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _timeField(String label, TimeOfDay time, VoidCallback onTap) {
  return Expanded(
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(width: 8),
            Text(
              '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    ),
  );
}

class _CambiarPasswordSheet extends StatefulWidget {
  const _CambiarPasswordSheet();

  @override
  State<_CambiarPasswordSheet> createState() => _CambiarPasswordSheetState();
}

class _CambiarPasswordSheetState extends State<_CambiarPasswordSheet> {
  final _actualCtrl = TextEditingController();
  final _nuevaCtrl = TextEditingController();
  final _confirmarCtrl = TextEditingController();
  bool _obscuraActual = true;
  bool _obscuraNueva = true;
  bool _obscuraConfirmar = true;
  bool _guardando = false;
  String? _error;

  @override
  void dispose() {
    _actualCtrl.dispose();
    _nuevaCtrl.dispose();
    _confirmarCtrl.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    final actual = _actualCtrl.text.trim();
    final nueva = _nuevaCtrl.text.trim();
    final confirmar = _confirmarCtrl.text.trim();

    if (actual.isEmpty || nueva.isEmpty || confirmar.isEmpty) {
      setState(() => _error = 'Completa todos los campos');
      return;
    }
    if (nueva.length < 6) {
      setState(() => _error = 'La nueva contraseña debe tener al menos 6 caracteres');
      return;
    }
    if (nueva != confirmar) {
      setState(() => _error = 'Las contraseñas nuevas no coinciden');
      return;
    }

    setState(() {
      _guardando = true;
      _error = null;
    });

    final apiClient = context.read<ApiClient>();
    final result = await apiClient.changePassword(
      passwordActual: actual,
      passwordNueva: nueva,
    );

    if (!mounted) return;

    if (result['success'] == true) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Contraseña actualizada correctamente'),
          backgroundColor: Color(0xFFE8A0B4),
        ),
      );
    } else {
      setState(() {
        _guardando = false;
        _error = result['error'] ?? 'No se pudo cambiar la contraseña';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Cambiar contraseña',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            if (_error != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  border: Border.all(color: Colors.red.shade300),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  _error!,
                  style: TextStyle(color: Colors.red.shade700, fontSize: 13),
                ),
              ),
              const SizedBox(height: 12),
            ],
            _PasswordField(
              label: 'Contraseña actual',
              controller: _actualCtrl,
              obscure: _obscuraActual,
              onToggle: () => setState(() => _obscuraActual = !_obscuraActual),
              enabled: !_guardando,
            ),
            _PasswordField(
              label: 'Nueva contraseña',
              controller: _nuevaCtrl,
              obscure: _obscuraNueva,
              onToggle: () => setState(() => _obscuraNueva = !_obscuraNueva),
              enabled: !_guardando,
            ),
            _PasswordField(
              label: 'Confirmar nueva contraseña',
              controller: _confirmarCtrl,
              obscure: _obscuraConfirmar,
              onToggle: () => setState(() => _obscuraConfirmar = !_obscuraConfirmar),
              enabled: !_guardando,
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _guardando ? null : _guardar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4748F),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  _guardando ? 'Guardando...' : 'Guardar',
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PasswordField extends StatelessWidget {
  const _PasswordField({
    required this.label,
    required this.controller,
    required this.obscure,
    required this.onToggle,
    required this.enabled,
  });

  final String label;
  final TextEditingController controller;
  final bool obscure;
  final VoidCallback onToggle;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            obscureText: obscure,
            enabled: enabled,
            style: const TextStyle(fontSize: 14, color: Color(0xFF1A1A1A)),
            decoration: InputDecoration(
              hintText: '••••••••',
              hintStyle: const TextStyle(fontSize: 14, color: Color(0xFF888888)),
              suffixIcon: IconButton(
                icon: Icon(
                  obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: const Color(0xFF888888),
                  size: 20,
                ),
                onPressed: onToggle,
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFCCCCCC), width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFD4748F), width: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
