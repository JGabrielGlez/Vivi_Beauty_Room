import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../shared/models/clienta.dart';
import '../../../shared/models/servicio.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../shared/widgets/search_bar_widget.dart';

// URL base del backend. En emulador Android usar 10.0.2.2, en desktop/web usar localhost.
const String _baseUrl = 'http://localhost:3000';

class NuevaCitaModal extends StatefulWidget {
  const NuevaCitaModal({super.key});

  @override
  State<NuevaCitaModal> createState() => _NuevaCitaModalState();
}

class _NuevaCitaModalState extends State<NuevaCitaModal> {
  // Minutos extra sobre la duración del servicio (incrementa de 30 en 30)
  int _tiempoExtra = 0;

  // Lista de servicios cargados desde la API
  List<Servicio> _servicios = [];

  // ID del servicio actualmente seleccionado
  String? _servicioSeleccionadoId;

  // Controla si se está cargando la lista de servicios
  bool _cargando = true;

  // Mensaje de error si la petición falla
  String? _errorServicios;

  // Fecha seleccionada en el date picker (null = no seleccionada)
  DateTime? _fechaSeleccionada;

  // Hora seleccionada en el time picker (null = no seleccionada)
  TimeOfDay? _horaSeleccionada;

  // Mensaje de error si la fecha+hora combinada no es futura
  String? _errorFechaHora;

  // Mensaje de error si la nueva cita se solapa con una existente
  String? _errorSolapamiento;
  bool _verificandoSolapamiento = false;

  final TextEditingController _anticipoController = TextEditingController();
  String? _errorAnticipo;

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
    _anticipoController.dispose();
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

            // Duración: servicio + tiempo extra
            _buildLabel('DURACIÓN'),
            const SizedBox(height: 8),
            Row(
              children: [
                // Duración del servicio seleccionado
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F9FA),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFEEEEEE)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Servicio', style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                        const SizedBox(height: 4),
                        Text(
                          _duracionServicio(),
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A)),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                // Incrementador de tiempo extra (pasos de 30 min)
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFEEEEEE)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Tiempo extra', style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: () {
                                if (_tiempoExtra > 0) {
                                  setState(() => _tiempoExtra -= 30);
                                  _verificarSolapamiento();
                                }
                              },
                              child: Container(
                                width: 28, height: 28,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFD4748F).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Icon(Icons.remove, size: 16, color: Color(0xFFD4748F)),
                              ),
                            ),
                            Text(
                              '$_tiempoExtra min',
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                            GestureDetector(
                              onTap: () {
                                setState(() => _tiempoExtra += 30);
                                _verificarSolapamiento();
                              },
                              child: Container(
                                width: 28, height: 28,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFD4748F).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Icon(Icons.add, size: 16, color: Color(0xFFD4748F)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            if (_verificandoSolapamiento)
              const Padding(
                padding: EdgeInsets.only(top: 6),
                child: Center(
                  child: SizedBox(
                    width: 14, height: 14,
                    child: CircularProgressIndicator(color: Color(0xFFD4748F), strokeWidth: 2),
                  ),
                ),
              ),
            if (_errorSolapamiento != null && !_verificandoSolapamiento)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  _errorSolapamiento!,
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
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
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8F9FA),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFEEEEEE)),
                        ),
                        child: Text(
                          _precioServicio(),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                      ),
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
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _errorAnticipo != null
                                ? const Color(0xFFD4748F)
                                : const Color(0xFFEEEEEE),
                          ),
                        ),
                        child: Row(
                          children: [
                            Text(
                              '\$',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[500],
                              ),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: TextField(
                                controller: _anticipoController,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                onChanged: _validarAnticipo,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: '0.00',
                                  hintStyle: TextStyle(color: Colors.grey[400]),
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                ),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1A1A1A),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_errorAnticipo != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            _errorAnticipo!,
                            style: const TextStyle(
                              color: Color(0xFFD4748F),
                              fontSize: 11,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ),
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

  // Consulta las citas del día seleccionado y detecta si la nueva cita se solapa
  Future<void> _verificarSolapamiento() async {
    if (_servicioSeleccionadoId == null ||
        _errorFechaHora != null ||
        _fechaSeleccionada == null ||
        _horaSeleccionada == null) {
      setState(() => _errorSolapamiento = null);
      return;
    }

    final servicio = _servicios.firstWhere((s) => s.id == _servicioSeleccionadoId);
    final fecha = _fechaSeleccionada!;
    final hora = _horaSeleccionada!;
    final inicioStr =
        '${fecha.year}-${fecha.month.toString().padLeft(2, '0')}-${fecha.day.toString().padLeft(2, '0')}';

    final newStart = DateTime(
      fecha.year, fecha.month, fecha.day,
      hora.hour, hora.minute,
    );
    // Fin = duración del servicio + tiempo extra + 30 min de buffer
    final newEnd = newStart.add(Duration(minutes: servicio.duracionMin + _tiempoExtra + 30));

    setState(() => _verificandoSolapamiento = true);

    try {
      final uri = Uri.parse('$_baseUrl/api/agenda/citas/semana')
          .replace(queryParameters: {'inicio': inicioStr});
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        String? conflicto;

        for (final cita in data) {
          if (cita['estado'] == 'CANCELADA') continue;

          final existStart = DateTime.parse(cita['fechaHora'] as String);
          if (existStart.year != fecha.year ||
              existStart.month != fecha.month ||
              existStart.day != fecha.day) {
            continue;
          }

          final existEnd = existStart.add(Duration(minutes: cita['duracion'] as int));

          if (newStart.isBefore(existEnd) && newEnd.isAfter(existStart)) {
            final h = existStart.hour.toString().padLeft(2, '0');
            final m = existStart.minute.toString().padLeft(2, '0');
            final duracionTotal = servicio.duracionMin + _tiempoExtra + 30;
            final siguiente = _siguienteDisponible(data, newStart, duracionTotal, fecha);
            conflicto = siguiente != null
                ? 'Se solapa con la cita de las $h:$m. Próximo disponible: $siguiente'
                : 'Se solapa con la cita de las $h:$m';
            break;
          }
        }

        setState(() {
          _errorSolapamiento = conflicto;
          _verificandoSolapamiento = false;
        });
      } else {
        setState(() => _verificandoSolapamiento = false);
      }
    } catch (_) {
      setState(() => _verificandoSolapamiento = false);
    }
  }

  // Busca el siguiente slot libre de 30 min a partir del fin del conflicto (hasta las 21:00)
  String? _siguienteDisponible(
    List<dynamic> citasDelDia,
    DateTime newStart,
    int duracionMin,
    DateTime fecha,
  ) {
    // Intervalos ocupados del día (sin canceladas)
    final intervals = citasDelDia
        .where((c) => c['estado'] != 'CANCELADA')
        .where((c) {
          final s = DateTime.parse(c['fechaHora'] as String);
          return s.year == fecha.year && s.month == fecha.month && s.day == fecha.day;
        })
        .map((c) {
          final s = DateTime.parse(c['fechaHora'] as String);
          return (start: s, end: s.add(Duration(minutes: c['duracion'] as int)));
        })
        .toList();

    // Fin máximo de los conflictos con el slot actual
    DateTime? maxConflictEnd;
    final newEnd = newStart.add(Duration(minutes: duracionMin));
    for (final i in intervals) {
      if (newStart.isBefore(i.end) && newEnd.isAfter(i.start)) {
        if (maxConflictEnd == null || i.end.isAfter(maxConflictEnd)) {
          maxConflictEnd = i.end;
        }
      }
    }
    if (maxConflictEnd == null) return null;

    // Redondear hacia arriba al siguiente slot de 30 min
    final totalMin = maxConflictEnd.hour * 60 + maxConflictEnd.minute;
    int candidateMin = ((totalMin + 29) ~/ 30) * 30;

    // Iterar de 30 en 30 hasta las 21:00
    while (candidateMin < 21 * 60) {
      final cStart = DateTime(fecha.year, fecha.month, fecha.day, candidateMin ~/ 60, candidateMin % 60);
      final cEnd = cStart.add(Duration(minutes: duracionMin));
      final hasConflict = intervals.any((i) => cStart.isBefore(i.end) && cEnd.isAfter(i.start));
      if (!hasConflict) {
        final h = (candidateMin ~/ 60).toString().padLeft(2, '0');
        final m = (candidateMin % 60).toString().padLeft(2, '0');
        return '$h:$m';
      }
      candidateMin += 30;
    }
    return null;
  }

  // Retorna la duración del servicio seleccionado, o '--' si no hay ninguno
  String _duracionServicio() {
    if (_servicioSeleccionadoId == null) return '-- min';
    try {
      final s = _servicios.firstWhere((s) => s.id == _servicioSeleccionadoId);
      return '${s.duracionMin} min';
    } catch (_) {
      return '-- min';
    }
  }

  void _validarAnticipo(String value) {
    final anticipo = double.tryParse(value);
    if (_servicioSeleccionadoId == null) {
      setState(() => _errorAnticipo = null);
      return;
    }
    final s = _servicios.firstWhere((s) => s.id == _servicioSeleccionadoId);
    if (anticipo == null || anticipo < 0) {
      setState(() => _errorAnticipo = 'Monto inválido');
    } else if (anticipo > s.precio) {
      setState(() => _errorAnticipo = 'No puede superar \$${s.precio.toStringAsFixed(2)}');
    } else {
      setState(() => _errorAnticipo = null);
    }
  }

  // Retorna el precio del servicio seleccionado formateado, o '--' si no hay ninguno
  String _precioServicio() {
    if (_servicioSeleccionadoId == null) return '\$ --';
    try {
      final s = _servicios.firstWhere((s) => s.id == _servicioSeleccionadoId);
      return '\$${s.precio.toStringAsFixed(2)}';
    } catch (_) {
      return '\$ --';
    }
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
    final texto = _fechaSeleccionada == null
        ? '-- --- ----'
        : '${_fechaSeleccionada!.day.toString().padLeft(2, '0')} '
          '${_mesCorto(_fechaSeleccionada!.month)} '
          '${_fechaSeleccionada!.year}';
    final hayError = _errorFechaHora != null;

    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _fechaSeleccionada ?? DateTime.now(),
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
            if (_horaSeleccionada != null) {
              _validarFechaHora(picked, _horaSeleccionada!);
            }
          });
          _verificarSolapamiento();
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
    final String textoHora;
    if (_horaSeleccionada == null) {
      textoHora = '--:-- --';
    } else {
      final h = _horaSeleccionada!.hourOfPeriod;
      final hora = (h == 0 ? 12 : h).toString().padLeft(2, '0');
      final minuto = _horaSeleccionada!.minute.toString().padLeft(2, '0');
      final periodo = _horaSeleccionada!.period == DayPeriod.am ? 'AM' : 'PM';
      textoHora = '$hora:$minuto $periodo';
    }
    final hayError = _errorFechaHora != null;

    return GestureDetector(
      onTap: () async {
        final base = _horaSeleccionada;
        int dialogHour = base == null ? 10 : (base.hourOfPeriod == 0 ? 12 : base.hourOfPeriod);
        int dialogMinute = base == null ? 0 : (base.minute >= 30 ? 30 : 0);
        DayPeriod dialogPeriod = base?.period ?? DayPeriod.am;

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
            if (_fechaSeleccionada != null) {
              _validarFechaHora(_fechaSeleccionada!, result);
            }
          });
          _verificarSolapamiento();
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
              textoHora,
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

}
