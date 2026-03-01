import 'package:flutter/material.dart';
import 'package:vivi_room/shared/widgets/app_bottom_nav_bar.dart';
import 'package:vivi_room/shared/widgets/app_text_field.dart';
import 'package:vivi_room/shared/widgets/cliente_avatar.dart';
import 'package:vivi_room/shared/widgets/primary_button.dart';
import 'package:vivi_room/shared/widgets/status_badge.dart';
import '../../../shared/widgets/fab_button.dart';
import '../../../shared/widgets/search_bar_widget.dart';
import 'dart:developer' as _logger;

class AgendaScreen extends StatefulWidget {
  const AgendaScreen({super.key});

  @override
  State<AgendaScreen> createState() => _AgendaScreenState();
}

class _AgendaScreenState extends State<AgendaScreen> {
  int index = 1;
  int selectedDayIndex = 0;
  late final List<Map<String, String>> days;

  // Agrega la lista de citas (appointments)
  List<Map<String, dynamic>> appointments = [
    {
      'time': '09:00',
      'nombre': 'Mariana Rodriguez',
      'servicio': 'Pedicura',
      'duracion': 60,
      'status': 'CONFIRMADA',
    },
    {
      'time': '11:00',
      'nombre': 'Rocio Vazquez',
      'servicio': 'Peinado',
      'duracion': 45,
      'status': 'PENDIENTE',
    },
    {
      'time': '13:00',
      'nombre': 'Viviana Landaverde',
      'servicio': '',
      'duracion': '',
      'status': 'CONFIRMADA',
    },
  ];

  @override
  void initState() {
    super.initState();
    days = _generateDays(DateTime.now());
    selectedDayIndex = days.indexWhere((d) => d['isToday'] == 'true');
    if (selectedDayIndex == -1) selectedDayIndex = 0;
  }

  List<Map<String, String>> _generateDays(DateTime currentDate) {
    final List<Map<String, String>> result = [];
    for (int i = -2; i <= 4; i++) {
      final date = currentDate.add(Duration(days: i));
      final isToday = i == 0;
      result.add({
        'day': _weekdayShort(date.weekday),
        'date': date.day.toString().padLeft(2, '0'),
        'isToday': isToday ? 'true' : 'false',
      });
    }
    return result;
  }

  String _weekdayShort(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'MON';
      case DateTime.tuesday:
        return 'TUE';
      case DateTime.wednesday:
        return 'WED';
      case DateTime.thursday:
        return 'THU';
      case DateTime.friday:
        return 'FRI';
      case DateTime.saturday:
        return 'SAT';
      case DateTime.sunday:
        return 'SUN';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: AppBottomNavBar(currentIndex: index, onTap: (i) {}),
      floatingActionButton: FabButton(
        onPressed: () async {
          final newAppointment = await showModalBottomSheet<Map<String, dynamic>>(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => _AppointmentSheet(),
          );
          if (newAppointment != null) {
            setState(() {
              // Aquí puedes agregar la cita a la lista si lo deseas
            });
          }
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
                    children: const [
                      Text('February', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      Text('2026', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  CircleAvatar(
                    backgroundColor: const Color(0xFFF5F6FA),
                    child: Icon(Icons.person_outline, color: Color(0xFFD4748F)),
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
                      },
                      child: _dayChip(day['day']!, day['date']!, selectedDayIndex == i),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ListView(
                  children: [
                    for (var i = 0; i < appointments.length; i++)
                      GestureDetector(
                        onTap: () async {
                          final edited = await showModalBottomSheet<Map<String, dynamic>>(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (context) => _AppointmentSheet(initial: appointments[i]),
                          );
                          if (edited != null) {
                            setState(() {
                              appointments[i] = edited;
                            });
                          }
                        },
                        child: _agendaCard(
                          time: appointments[i]['time'] ?? '',
                          nombre: appointments[i]['nombre'] ?? '',
                          servicio: appointments[i]['servicio'] ?? '',
                          duracion: appointments[i]['duracion']?.toString() ?? '',
                          status: appointments[i]['status'] ?? '',
                        ),
                      ),
                    _availableSlot('10:00'),
                    _lunchBreak('12:00'),
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
              color: selected ? const Color(0xFFD4748F) : const Color(0xFFF5F6FA),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                Text(day, style: TextStyle(
                  color: selected ? Colors.white : Colors.black.withOpacity(0.5),
                  fontWeight: FontWeight.w500,
                )),
                Text(date, style: TextStyle(
                  color: selected ? Colors.white : Colors.black,
                  fontWeight: FontWeight.bold,
                )),
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
                          Icon(Icons.access_time, size: 16, color: Color(0xFFB0B7C3)),
                          const SizedBox(width: 4),
                          Text(
                            duracion+" min",
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
          SizedBox(width: 60, child: Text(time, style: const TextStyle(fontWeight: FontWeight.bold))),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
              ),
              padding: const EdgeInsets.all(16),
              child: Text('Available Slot', style: TextStyle(color: Colors.black.withOpacity(0.3))),
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
          SizedBox(width: 60, child: Text(time, style: const TextStyle(fontWeight: FontWeight.bold))),
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
                  Text('Lunch Break', style: TextStyle(color: Colors.black.withOpacity(0.4))),
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
      nombreController = TextEditingController(text: widget.initial?['nombre'] ?? '');
      costoController = TextEditingController(text: (widget.initial?['costo'] ?? 0.00).toString());
      anticipoController = TextEditingController(text: (widget.initial?['anticipo'] ?? 0.00).toString());
      servicio = widget.initial?['servicio'] ?? 'Pedicura';
      duracion = widget.initial?['duracion'] ?? 60;
      fecha = widget.initial?['fecha'] ?? DateTime.now();
      if (widget.initial?['time'] != null) {
        final timeParts = (widget.initial!['time'] as String).split(':');
        if (timeParts.length == 2) {
          horario = TimeOfDay(hour: int.parse(timeParts[0]), minute: int.parse(timeParts[1]));
        }
      }
    }

    @override
    Widget build(BuildContext context) {
      return DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 16)],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: SingleChildScrollView(
              controller: scrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Nueva Cita',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text('SELECCIONAR CLIENTE',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: Color(0xFFB0B7C3),
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SearchBarWidget(
                    hintText: 'Buscar por nombre...',
                    controller: nombreController,
                  ),
                  const SizedBox(height: 24),
                  const Text('Tipo de servicio', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _serviceChip('Pedicura', servicio == 'Pedicura', Icons.spa, () {
                        setState(() => servicio = 'Pedicura');
                      }),
                      const SizedBox(width: 12),
                      _serviceChip('Peinado', servicio == 'Peinado', Icons.cut, () {
                        setState(() => servicio = 'Peinado');
                      }),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: _dateField('Fecha', fecha, () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: fecha,
                            firstDate: DateTime.now().subtract(const Duration(days: 365)),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                          );
                          if (picked != null) setState(() => fecha = picked);
                        }),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _timeField('Horario', horario, () async {
                          final picked = await showTimePicker(
                            context: context,
                            initialTime: horario,
                          );
                          if (picked != null) setState(() => horario = picked);
                        }),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text('Duración', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      for (var d in [30, 45, 60, 90])
                        _durationChip(d, duracion == d, () => setState(() => duracion = d)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: AppTextField(label: 'Costo total', controller: costoController),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AppTextField(label: 'Anticipo', controller: anticipoController),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: PrimaryButton(
                      text: 'Guardar Cita',
                      onPressed: () {
                        Navigator.of(context).pop({
                          'nombre': nombreController.text,
                          'servicio': servicio,
                          'duracion': duracion,
                          'costo': double.tryParse(costoController.text) ?? 0.0,
                          'anticipo': double.tryParse(anticipoController.text) ?? 0.0,
                          'fecha': fecha,
                          'time': '${horario.hour.toString().padLeft(2, '0')}:${horario.minute.toString().padLeft(2, '0')}',
                          'status': 'CONFIRMADA',
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }
  }

  Widget _serviceChip(String label, bool selected, IconData icon, VoidCallback onTap) {
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
            Text(label, style: TextStyle(
              color: selected ? Colors.white : const Color(0xFFD4748F),
              fontWeight: FontWeight.w600,
            )),
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
            Text('$minutes', style: TextStyle(
              color: selected ? Colors.white : const Color(0xFFD4748F),
              fontWeight: FontWeight.w600,
            )),
            const SizedBox(width: 4),
            Text('min', style: TextStyle(
              color: selected ? Colors.white : const Color(0xFFD4748F),
              fontWeight: FontWeight.w600,
            )),
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






