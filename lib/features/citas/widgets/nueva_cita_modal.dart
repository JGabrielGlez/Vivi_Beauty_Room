import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../shared/models/clienta.dart';
import '../../../shared/models/servicio.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/search_bar_widget.dart';

// URL base del backend. En emulador Android usar 10.0.2.2, en desktop/web usar localhost.
const String _baseUrl = 'http://localhost:3000';

class NuevaCitaModal extends StatefulWidget {
  const NuevaCitaModal({super.key});

  @override
  State<NuevaCitaModal> createState() => _NuevaCitaModalState();
}

class _NuevaCitaModalState extends State<NuevaCitaModal> {
  // Duración seleccionada en los chips de minutos
  String duracionSeleccionada = '60 MIN';

  // Lista de servicios cargados desde la API
  List<Servicio> _servicios = [];

  // ID del servicio actualmente seleccionado
  String? _servicioSeleccionadoId;

  // Controla si se está cargando la lista de servicios
  bool _cargando = true;

  // Mensaje de error si la petición falla
  String? _errorServicios;

  // Fecha seleccionada en el date picker (inicia en hoy)
  DateTime _fechaSeleccionada = DateTime.now();

  // Hora seleccionada en el time picker (inicia en 10:00 AM)
  TimeOfDay _horaSeleccionada = const TimeOfDay(hour: 10, minute: 0);

  // Mensaje de error si la fecha+hora combinada no es futura
  String? _errorFechaHora;

  // Búsqueda de clientas
  final TextEditingController _busquedaController = TextEditingController();
  List<Clienta> _resultadosBusqueda = [];
  Clienta? _clientaSeleccionada;
  bool _buscandoClientas = false;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _cargarServicios();
  }

  @override
  void dispose() {
    _busquedaController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  // Espera 400ms después de que el usuario deja de escribir antes de buscar
  void _onBusquedaChanged(String q) {
    _debounceTimer?.cancel();
    if (q.isEmpty) {
      setState(() {
        _resultadosBusqueda = [];
        _clientaSeleccionada = null;
      });
      return;
    }
    _debounceTimer = Timer(
      const Duration(milliseconds: 400),
      () => _buscarClientas(q),
    );
  }

  // Llama al backend con el texto buscado y muestra los resultados
  Future<void> _buscarClientas(String q) async {
    setState(() => _buscandoClientas = true);
    try {
      final uri = Uri.parse('$_baseUrl/api/clientas')
          .replace(queryParameters: {'q': q});
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _resultadosBusqueda = data.map((e) => Clienta.fromJson(e)).toList();
          _buscandoClientas = false;
        });
      } else {
        setState(() => _buscandoClientas = false);
      }
    } catch (_) {
      setState(() => _buscandoClientas = false);
    }
  }

  // Llama al backend y llena la lista de servicios activos
  Future<void> _cargarServicios() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/api/servicios'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _servicios = data.map((e) => Servicio.fromJson(e)).toList();
          _cargando = false;
        });
      } else {
        setState(() {
          _errorServicios = 'Error ${response.statusCode}';
          _cargando = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorServicios = 'No se pudo conectar al servidor';
        _cargando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: 12,
        left: 20,
        right: 20,
        // MediaQuery empuja el modal hacia arriba cuando aparece el teclado
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Palito gris decorativo para indicar que el modal es arrastrable
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Cabecera: título y botón cerrar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Nueva Cita',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(
                    Icons.cancel,
                    color: Color(0xFFE0E7FF),
                    size: 30,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Búsqueda de cliente con resultados en dropdown
            _buildLabel('SELECCIONAR CLIENTE'),
            const SizedBox(height: 8),
            // Si ya hay una clienta seleccionada, muestra su nombre con opción a cambiar
            if (_clientaSeleccionada != null)
              _buildClientaSeleccionada()
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SearchBarWidget(
                    controller: _busquedaController,
                    hintText: 'Buscar por nombre o teléfono...',
                    onChanged: _onBusquedaChanged,
                  ),
                  // Spinner mientras busca
                  if (_buscandoClientas)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFFD4748F),
                          strokeWidth: 2,
                        ),
                      ),
                    ),
                  // Lista de resultados
                  if (_resultadosBusqueda.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFEEEEEE)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: _resultadosBusqueda.map((clienta) {
                          return InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () {
                              setState(() {
                                _clientaSeleccionada = clienta;
                                _resultadosBusqueda = [];
                                _busquedaController.clear();
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              child: Row(
                                children: [
                                  // Avatar con inicial del nombre
                                  CircleAvatar(
                                    radius: 18,
                                    backgroundColor: const Color(0xFFD4748F)
                                        .withValues(alpha: 0.15),
                                    child: Text(
                                      clienta.nombre[0].toUpperCase(),
                                      style: const TextStyle(
                                        color: Color(0xFFD4748F),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        clienta.nombre,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                      ),
                                      Text(
                                        clienta.telefono,
                                        style: TextStyle(
                                          color: Colors.grey[500],
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                ],
              ),
            const SizedBox(height: 20),

            // Chips de servicios cargados desde la BD
            _buildLabel('TIPO DE SERVICIO'),
            const SizedBox(height: 8),
            _buildListaServicios(),
            const SizedBox(height: 20),

            // Fecha y Horario en dos columnas
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('FECHA'),
                      const SizedBox(height: 8),
                      _buildFechaPicker(),
                    ],
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('HORARIO'),
                      const SizedBox(height: 8),
                      _buildHoraPicker(),
                    ],
                  ),
                ),
              ],
            ),
            // Error si la fecha+hora seleccionada es pasada
            if (_errorFechaHora != null)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  _errorFechaHora!,
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
            const SizedBox(height: 20),

            // Selector de duración
            _buildLabel('DURACIÓN'),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children:
                  ['30 MIN', '45 MIN', '60 MIN', '90 MIN']
                      .map((t) => _buildDuracionTab(t))
                      .toList(),
            ),
            const SizedBox(height: 20),

            // Costos
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('COSTO TOTAL'),
                      const SizedBox(height: 8),
                      const AppTextField(label: '\$ 0.00'),
                    ],
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('ANTICIPO'),
                      const SizedBox(height: 8),
                      const AppTextField(label: '\$ 0.00'),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),

            PrimaryButton(
              text: 'Guardar Cita',
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  // Muestra los chips de servicios, un spinner mientras carga, o un error
  Widget _buildListaServicios() {
    if (_cargando) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: CircularProgressIndicator(color: Color(0xFFD4748F)),
        ),
      );
    }

    if (_errorServicios != null) {
      return Text(
        _errorServicios!,
        style: const TextStyle(color: Colors.red, fontSize: 13),
      );
    }

    // Wrap permite que los chips bajen a la siguiente línea si no caben
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children:
          _servicios
              .map((s) => _buildServiceChip(s))
              .toList(),
    );
  }

  // Chip de servicio individual. Se pone rosa cuando está seleccionado.
  Widget _buildServiceChip(Servicio servicio) {
    final isSelected = _servicioSeleccionadoId == servicio.id;
    return GestureDetector(
      onTap: () {
        setState(() {
          _servicioSeleccionadoId = servicio.id;
          // Auto-seleccionar la duración más cercana a la del servicio
          _autoSeleccionarDuracion(servicio.duracionMin);
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? const Color(0xFFD4748F).withValues(alpha: 0.85)
                  : const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(color: const Color(0xFFD4748F))
              : null,
        ),
        child: Text(
          servicio.nombre,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[700],
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  // Selecciona automáticamente el chip de duración más cercano al del servicio
  void _autoSeleccionarDuracion(int duracionMin) {
    const opciones = [30, 45, 60, 90];
    final cercano = opciones.reduce(
      (a, b) =>
          (a - duracionMin).abs() < (b - duracionMin).abs() ? a : b,
    );
    duracionSeleccionada = '$cercano MIN';
  }

  // Valida que la combinación de fecha + hora sea futura y actualiza el error
  void _validarFechaHora(DateTime fecha, TimeOfDay hora) {
    final dt = DateTime(fecha.year, fecha.month, fecha.day, hora.hour, hora.minute);
    _errorFechaHora = dt.isAfter(DateTime.now())
        ? null
        : 'La fecha y hora deben ser en el futuro';
  }

  // Campo de fecha que abre el date picker nativo de Flutter al tocarlo
  Widget _buildFechaPicker() {
    final texto =
        '${_fechaSeleccionada.day.toString().padLeft(2, '0')} '
        '${_mesCorto(_fechaSeleccionada.month)} '
        '${_fechaSeleccionada.year}';
    final hayError = _errorFechaHora != null;

    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _fechaSeleccionada,
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365)),
          builder: (context, child) => Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(
                primary: Color(0xFFD4748F),
                onPrimary: Colors.white,
                surface: Colors.white,
              ),
            ),
            child: child!,
          ),
        );
        if (picked != null) {
          setState(() {
            _fechaSeleccionada = picked;
            _validarFechaHora(picked, _horaSeleccionada);
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: hayError ? Colors.red : const Color(0xFFCCCCCC),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today_outlined,
                size: 18, color: hayError ? Colors.red : const Color(0xFFD4748F)),
            const SizedBox(width: 10),
            Text(
              texto,
              style: TextStyle(fontSize: 14, color: hayError ? Colors.red : const Color(0xFF1A1A1A)),
            ),
          ],
        ),
      ),
    );
  }

  // Campo de hora que abre un dialog propio con incrementadores.
  // Los minutos solo alternan entre 00 y 30.
  Widget _buildHoraPicker() {
    final h = _horaSeleccionada.hourOfPeriod;
    final hora = (h == 0 ? 12 : h).toString().padLeft(2, '0');
    final minuto = _horaSeleccionada.minute.toString().padLeft(2, '0');
    final periodo = _horaSeleccionada.period == DayPeriod.am ? 'AM' : 'PM';
    final hayError = _errorFechaHora != null;

    return GestureDetector(
      onTap: () async {
        int dialogHour = _horaSeleccionada.hourOfPeriod == 0 ? 12 : _horaSeleccionada.hourOfPeriod;
        int dialogMinute = _horaSeleccionada.minute >= 30 ? 30 : 0;
        DayPeriod dialogPeriod = _horaSeleccionada.period;

        final result = await showDialog<TimeOfDay>(
          context: context,
          builder: (context) => StatefulBuilder(
            builder: (context, setDialogState) {
              return AlertDialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                title: const Text(
                  'Seleccionar hora',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                content: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Horas
                    _buildTimeUnit(
                      value: dialogHour.toString().padLeft(2, '0'),
                      onUp: () => setDialogState(() {
                        dialogHour = dialogHour >= 12 ? 1 : dialogHour + 1;
                      }),
                      onDown: () => setDialogState(() {
                        dialogHour = dialogHour <= 1 ? 12 : dialogHour - 1;
                      }),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 6),
                      child: Text(':', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                    ),
                    // Minutos — solo 00 o 30
                    _buildTimeUnit(
                      value: dialogMinute == 0 ? '00' : '30',
                      onUp: () => setDialogState(() => dialogMinute = dialogMinute == 0 ? 30 : 0),
                      onDown: () => setDialogState(() => dialogMinute = dialogMinute == 0 ? 30 : 0),
                    ),
                    const SizedBox(width: 12),
                    // AM / PM
                    GestureDetector(
                      onTap: () => setDialogState(() {
                        dialogPeriod = dialogPeriod == DayPeriod.am ? DayPeriod.pm : DayPeriod.am;
                      }),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD4748F),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          dialogPeriod == DayPeriod.am ? 'AM' : 'PM',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Cancelar', style: TextStyle(color: Colors.grey[600])),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      final hour24 = (dialogHour % 12) + (dialogPeriod == DayPeriod.pm ? 12 : 0);
                      Navigator.pop(context, TimeOfDay(hour: hour24, minute: dialogMinute));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD4748F),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Aceptar'),
                  ),
                ],
              );
            },
          ),
        );

        if (result != null) {
          setState(() {
            _horaSeleccionada = result;
            _validarFechaHora(_fechaSeleccionada, result);
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: hayError ? Colors.red : const Color(0xFFCCCCCC),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.access_time_outlined,
                size: 18, color: hayError ? Colors.red : const Color(0xFFD4748F)),
            const SizedBox(width: 10),
            Text(
              '$hora:$minuto $periodo',
              style: TextStyle(fontSize: 14, color: hayError ? Colors.red : const Color(0xFF1A1A1A)),
            ),
          ],
        ),
      ),
    );
  }

  // Columna con flechas arriba/abajo y el valor numérico en el centro
  Widget _buildTimeUnit({
    required String value,
    required VoidCallback onUp,
    required VoidCallback onDown,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: onUp,
          icon: const Icon(Icons.keyboard_arrow_up, color: Color(0xFFD4748F), size: 30),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
        Container(
          width: 58,
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFD4748F), width: 1.5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
          ),
        ),
        IconButton(
          onPressed: onDown,
          icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFFD4748F), size: 30),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      ],
    );
  }

  // Devuelve el nombre corto del mes en español
  String _mesCorto(int mes) {
    const meses = [
      '', 'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
      'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic',
    ];
    return meses[mes];
  }

  // Muestra la clienta seleccionada con un botón para cambiarla
  Widget _buildClientaSeleccionada() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFD4748F).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD4748F).withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: const Color(0xFFD4748F).withValues(alpha: 0.2),
            child: Text(
              _clientaSeleccionada!.nombre[0].toUpperCase(),
              style: const TextStyle(
                color: Color(0xFFD4748F),
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _clientaSeleccionada!.nombre,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  _clientaSeleccionada!.telefono,
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
              ],
            ),
          ),
          // Botón para deseleccionar y volver a buscar
          GestureDetector(
            onTap: () => setState(() => _clientaSeleccionada = null),
            child: const Icon(Icons.close, size: 18, color: Color(0xFFD4748F)),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 11,
        color: Colors.grey,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.1,
        fontFamily: 'Poppins',
      ),
    );
  }

  Widget _buildDuracionTab(String label) {
    final isSelected = duracionSeleccionada == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          duracionSeleccionada = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(10),
          border:
              isSelected
                  ? Border.all(color: const Color(0xFFD4748F).withValues(alpha: 0.2))
                  : null,
          boxShadow:
              isSelected
                  ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                    ),
                  ]
                  : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color:
                isSelected ? const Color(0xFFD4748F) : Colors.grey,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
