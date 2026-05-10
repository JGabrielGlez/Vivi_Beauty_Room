import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../shared/models/clienta.dart';
import '../../../shared/models/servicio.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../shared/widgets/search_bar_widget.dart';

const String _baseUrl = 'http://localhost:3000';

class EditarCitaModal extends StatefulWidget {
  const EditarCitaModal({super.key});

  @override
  State<EditarCitaModal> createState() => _EditarCitaModalState();
}

class _EditarCitaModalState extends State<EditarCitaModal> {
  // ID de la cita a editar — reemplazar por el real cuando se integre con la pantalla
  final String _citaId = '2886625eccce26bc';

  int _tiempoExtra = 0;
  List<Servicio> _servicios = [];
  String? _servicioSeleccionadoId;
  bool _cargando = true;
  String? _errorServicios;

  DateTime? _fechaSeleccionada;
  TimeOfDay? _horaSeleccionada;
  String? _errorFechaHora;
  String? _errorSolapamiento;
  bool _verificandoSolapamiento = false;

  final TextEditingController _anticipoController = TextEditingController();
  String? _errorAnticipo;

  final TextEditingController _notasController = TextEditingController();
  bool _guardando = false;
  String? _errorGuardar;

  // Estado de carga inicial de la cita
  bool _cargandoCita = true;
  String? _errorCarga;

  final TextEditingController _busquedaController = TextEditingController();
  List<Clienta> _resultadosBusqueda = [];
  Clienta? _clientaSeleccionada;
  bool _buscandoClientas = false;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _cargarTodo();
  }

  @override
  void dispose() {
    _anticipoController.dispose();
    _notasController.dispose();
    _busquedaController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  // Carga servicios primero, luego los datos de la cita
  Future<void> _cargarTodo() async {
    await _cargarServicios();
    await _cargarCita();
  }

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

  // Carga los datos de la cita y pre-llena todos los campos
  Future<void> _cargarCita() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/agenda/citas/$_citaId'),
      );

      if (response.statusCode == 200) {
        final cita = jsonDecode(response.body) as Map<String, dynamic>;

        final dt = DateTime.parse(cita['fechaHora'] as String);
        final idServicio = cita['idServicio'] as String;

        // Calcular tiempo extra: duracion_total - duracion_servicio - 30 buffer
        int tiempoExtra = 0;
        try {
          final servicio = _servicios.firstWhere((s) => s.id == idServicio);
          tiempoExtra = ((cita['duracion'] as int) - servicio.duracionMin - 30)
              .clamp(0, 9999);
        } catch (_) {}

        setState(() {
          _servicioSeleccionadoId = idServicio;
          _fechaSeleccionada = DateTime(dt.year, dt.month, dt.day);
          _horaSeleccionada = TimeOfDay(hour: dt.hour, minute: dt.minute);
          _tiempoExtra = tiempoExtra;
          _cargandoCita = false;
        });

        final monto = cita['montoAnticipo'];
        if (monto != null && monto != 0) {
          _anticipoController.text = (monto as num).toStringAsFixed(2);
        }
        _notasController.text = (cita['notas'] as String?) ?? '';

        final idClienta = cita['idClienta'] as String?;
        if (idClienta != null) {
          await _cargarClientaPorId(idClienta);
        }
      } else {
        setState(() {
          _errorCarga = 'No se pudo cargar la cita';
          _cargandoCita = false;
        });
      }
    } catch (_) {
      setState(() {
        _errorCarga = 'Error de conexión al cargar la cita';
        _cargandoCita = false;
      });
    }
  }

  Future<void> _cargarClientaPorId(String idClienta) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/clientas/$idClienta'),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() => _clientaSeleccionada = Clienta.fromJson(data));
      }
    } catch (_) {}
  }

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

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: 12,
        left: 20,
        right: 20,
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

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Editar Cita',
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

            // Spinner de carga inicial
            if (_cargandoCita)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 60),
                  child: CircularProgressIndicator(color: Color(0xFFD4748F)),
                ),
              )
            else if (_errorCarga != null)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Text(
                    _errorCarga!,
                    style: const TextStyle(color: Colors.red, fontSize: 14),
                  ),
                ),
              )
            else ...[
              _buildLabel('SELECCIONAR CLIENTE'),
              const SizedBox(height: 8),
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

              _buildLabel('TIPO DE SERVICIO'),
              const SizedBox(height: 8),
              _buildListaServicios(),
              const SizedBox(height: 20),

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
              if (_errorFechaHora != null)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    _errorFechaHora!,
                    style: const TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),
              const SizedBox(height: 20),

              _buildLabel('DURACIÓN'),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F9FA),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFEEEEEE)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Servicio',
                              style: TextStyle(
                                  fontSize: 11, color: Colors.grey[500])),
                          const SizedBox(height: 4),
                          Text(
                            _duracionServicio(),
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1A1A1A)),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFEEEEEE)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Tiempo extra',
                              style: TextStyle(
                                  fontSize: 11, color: Colors.grey[500])),
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
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFD4748F)
                                        .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Icon(Icons.remove,
                                      size: 16, color: Color(0xFFD4748F)),
                                ),
                              ),
                              Text(
                                '$_tiempoExtra min',
                                style: const TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.bold),
                              ),
                              GestureDetector(
                                onTap: () {
                                  setState(() => _tiempoExtra += 30);
                                  _verificarSolapamiento();
                                },
                                child: Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFD4748F)
                                        .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Icon(Icons.add,
                                      size: 16, color: Color(0xFFD4748F)),
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
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                          color: Color(0xFFD4748F), strokeWidth: 2),
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
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8F9FA),
                            borderRadius: BorderRadius.circular(12),
                            border:
                                Border.all(color: const Color(0xFFEEEEEE)),
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
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
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
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                          decimal: true),
                                  onChanged: _validarAnticipo,
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: '0.00',
                                    hintStyle:
                                        TextStyle(color: Colors.grey[400]),
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
              const SizedBox(height: 20),

              _buildLabel('NOTAS'),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFEEEEEE)),
                ),
                child: TextField(
                  controller: _notasController,
                  maxLines: 3,
                  maxLength: 200,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Ej. Alérgica al látex, traer referencia...',
                    hintStyle:
                        TextStyle(color: Colors.grey[400], fontSize: 13),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    counterStyle:
                        TextStyle(color: Colors.grey[400], fontSize: 11),
                  ),
                  style: const TextStyle(
                      fontSize: 14, color: Color(0xFF1A1A1A)),
                ),
              ),
              const SizedBox(height: 24),

              if (_errorGuardar != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(
                    _errorGuardar!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red, fontSize: 13),
                  ),
                ),
              PrimaryButton(
                text: _guardando ? 'Guardando...' : 'Guardar Cambios',
                onPressed: _guardando ? null : _guardarCambios,
              ),
            ],
          ],
        ),
      ),
    );
  }

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
      return Text(_errorServicios!,
          style: const TextStyle(color: Colors.red, fontSize: 13));
    }
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: _servicios.map((s) => _buildServiceChip(s)).toList(),
    );
  }

  Widget _buildServiceChip(Servicio servicio) {
    final isSelected = _servicioSeleccionadoId == servicio.id;
    return GestureDetector(
      onTap: () => setState(() => _servicioSeleccionadoId = servicio.id),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
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

  Future<void> _verificarSolapamiento() async {
    if (_servicioSeleccionadoId == null ||
        _errorFechaHora != null ||
        _fechaSeleccionada == null ||
        _horaSeleccionada == null) {
      setState(() => _errorSolapamiento = null);
      return;
    }

    final servicio =
        _servicios.firstWhere((s) => s.id == _servicioSeleccionadoId);
    final fecha = _fechaSeleccionada!;
    final hora = _horaSeleccionada!;
    final inicioStr =
        '${fecha.year}-${fecha.month.toString().padLeft(2, '0')}-${fecha.day.toString().padLeft(2, '0')}';

    final newStart = DateTime(
        fecha.year, fecha.month, fecha.day, hora.hour, hora.minute);
    final newEnd = newStart
        .add(Duration(minutes: servicio.duracionMin + _tiempoExtra + 30));

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
          // Excluir la cita que se está editando para no conflictar consigo misma
          if ((cita['idCita'] as String?) == _citaId) continue;

          final existStart = DateTime.parse(cita['fechaHora'] as String);
          if (existStart.year != fecha.year ||
              existStart.month != fecha.month ||
              existStart.day != fecha.day) {
            continue;
          }

          final existEnd =
              existStart.add(Duration(minutes: cita['duracion'] as int));

          if (newStart.isBefore(existEnd) && newEnd.isAfter(existStart)) {
            final h = existStart.hour.toString().padLeft(2, '0');
            final m = existStart.minute.toString().padLeft(2, '0');
            final duracionTotal = servicio.duracionMin + _tiempoExtra + 30;
            final siguiente =
                _siguienteDisponible(data, newStart, duracionTotal, fecha);
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

  String? _siguienteDisponible(
    List<dynamic> citasDelDia,
    DateTime newStart,
    int duracionMin,
    DateTime fecha,
  ) {
    final intervals = citasDelDia
        .where((c) => c['estado'] != 'CANCELADA')
        .where((c) => (c['idCita'] as String?) != _citaId)
        .where((c) {
          final s = DateTime.parse(c['fechaHora'] as String);
          return s.year == fecha.year &&
              s.month == fecha.month &&
              s.day == fecha.day;
        })
        .map((c) {
          final s = DateTime.parse(c['fechaHora'] as String);
          return (
            start: s,
            end: s.add(Duration(minutes: c['duracion'] as int))
          );
        })
        .toList();

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

    final totalMin = maxConflictEnd.hour * 60 + maxConflictEnd.minute;
    int candidateMin = ((totalMin + 29) ~/ 30) * 30;

    while (candidateMin < 21 * 60) {
      final cStart = DateTime(fecha.year, fecha.month, fecha.day,
          candidateMin ~/ 60, candidateMin % 60);
      final cEnd = cStart.add(Duration(minutes: duracionMin));
      final hasConflict =
          intervals.any((i) => cStart.isBefore(i.end) && cEnd.isAfter(i.start));
      if (!hasConflict) {
        final h = (candidateMin ~/ 60).toString().padLeft(2, '0');
        final m = (candidateMin % 60).toString().padLeft(2, '0');
        return '$h:$m';
      }
      candidateMin += 30;
    }
    return null;
  }

  String _duracionServicio() {
    if (_servicioSeleccionadoId == null) return '-- min';
    try {
      final s = _servicios.firstWhere((s) => s.id == _servicioSeleccionadoId);
      return '${s.duracionMin} min';
    } catch (_) {
      return '-- min';
    }
  }

  String _precioServicio() {
    if (_servicioSeleccionadoId == null) return '\$ --';
    try {
      final s = _servicios.firstWhere((s) => s.id == _servicioSeleccionadoId);
      return '\$${s.precio.toStringAsFixed(2)}';
    } catch (_) {
      return '\$ --';
    }
  }

  Future<void> _guardarCambios() async {
    if (_servicioSeleccionadoId == null ||
        _fechaSeleccionada == null ||
        _horaSeleccionada == null) {
      setState(() => _errorGuardar = 'Completa el servicio, fecha y hora');
      return;
    }
    if (_errorFechaHora != null ||
        _errorSolapamiento != null ||
        _errorAnticipo != null) {
      setState(() => _errorGuardar = 'Corrige los errores antes de guardar');
      return;
    }
    setState(() => _errorGuardar = null);

    final servicio =
        _servicios.firstWhere((s) => s.id == _servicioSeleccionadoId);
    final f = _fechaSeleccionada!;
    final h = _horaSeleccionada!;
    final fechaHora =
        '${f.year}-${f.month.toString().padLeft(2, '0')}-${f.day.toString().padLeft(2, '0')}'
        'T${h.hour.toString().padLeft(2, '0')}:${h.minute.toString().padLeft(2, '0')}:00';
    final duracion = servicio.duracionMin + _tiempoExtra + 30;
    final montoAnticipo = double.tryParse(_anticipoController.text) ?? 0;
    final notas = _notasController.text.trim().isEmpty
        ? null
        : _notasController.text.trim();

    setState(() => _guardando = true);

    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/api/agenda/citas/$_citaId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'idClienta': _clientaSeleccionada?.id,
          'idServicio': _servicioSeleccionadoId,
          'fechaHora': fechaHora,
          'duracion': duracion,
          'montoAnticipo': montoAnticipo,
          'notas': notas,
        }),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        Navigator.pop(context, true);
      } else {
        final body = jsonDecode(response.body);
        setState(() {
          _errorGuardar = body['error'] ?? 'Error al guardar los cambios';
          _guardando = false;
        });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorGuardar = 'No se pudo conectar al servidor';
        _guardando = false;
      });
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
      setState(
          () => _errorAnticipo = 'No puede superar \$${s.precio.toStringAsFixed(2)}');
    } else {
      setState(() => _errorAnticipo = null);
    }
  }

  void _validarFechaHora(DateTime fecha, TimeOfDay hora) {
    final dt =
        DateTime(fecha.year, fecha.month, fecha.day, hora.hour, hora.minute);
    _errorFechaHora = dt.isAfter(DateTime.now())
        ? null
        : 'La fecha y hora deben ser en el futuro';
  }

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
                size: 18,
                color: hayError ? Colors.red : const Color(0xFFD4748F)),
            const SizedBox(width: 10),
            Text(
              texto,
              style: TextStyle(
                  fontSize: 14,
                  color: hayError ? Colors.red : const Color(0xFF1A1A1A)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHoraPicker() {
    final String textoHora;
    if (_horaSeleccionada == null) {
      textoHora = '--:-- --';
    } else {
      final h = _horaSeleccionada!.hourOfPeriod;
      final hora = (h == 0 ? 12 : h).toString().padLeft(2, '0');
      final minuto = _horaSeleccionada!.minute.toString().padLeft(2, '0');
      final periodo =
          _horaSeleccionada!.period == DayPeriod.am ? 'AM' : 'PM';
      textoHora = '$hora:$minuto $periodo';
    }
    final hayError = _errorFechaHora != null;

    return GestureDetector(
      onTap: () async {
        final base = _horaSeleccionada;
        int dialogHour =
            base == null ? 10 : (base.hourOfPeriod == 0 ? 12 : base.hourOfPeriod);
        int dialogMinute = base == null ? 0 : (base.minute >= 30 ? 30 : 0);
        DayPeriod dialogPeriod = base?.period ?? DayPeriod.am;

        final result = await showDialog<TimeOfDay>(
          context: context,
          builder: (context) => StatefulBuilder(
            builder: (context, setDialogState) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                title: const Text(
                  'Seleccionar hora',
                  textAlign: TextAlign.center,
                  style:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                content: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
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
                      child: Text(':',
                          style: TextStyle(
                              fontSize: 32, fontWeight: FontWeight.bold)),
                    ),
                    _buildTimeUnit(
                      value: dialogMinute == 0 ? '00' : '30',
                      onUp: () => setDialogState(
                          () => dialogMinute = dialogMinute == 0 ? 30 : 0),
                      onDown: () => setDialogState(
                          () => dialogMinute = dialogMinute == 0 ? 30 : 0),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () => setDialogState(() {
                        dialogPeriod = dialogPeriod == DayPeriod.am
                            ? DayPeriod.pm
                            : DayPeriod.am;
                      }),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
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
                    child: Text('Cancelar',
                        style: TextStyle(color: Colors.grey[600])),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      final hour24 = (dialogHour % 12) +
                          (dialogPeriod == DayPeriod.pm ? 12 : 0);
                      Navigator.pop(
                          context, TimeOfDay(hour: hour24, minute: dialogMinute));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD4748F),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
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
                size: 18,
                color: hayError ? Colors.red : const Color(0xFFD4748F)),
            const SizedBox(width: 10),
            Text(
              textoHora,
              style: TextStyle(
                  fontSize: 14,
                  color: hayError ? Colors.red : const Color(0xFF1A1A1A)),
            ),
          ],
        ),
      ),
    );
  }

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
          icon: const Icon(Icons.keyboard_arrow_up,
              color: Color(0xFFD4748F), size: 30),
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
          icon: const Icon(Icons.keyboard_arrow_down,
              color: Color(0xFFD4748F), size: 30),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      ],
    );
  }

  String _mesCorto(int mes) {
    const meses = [
      '',
      'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
      'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic',
    ];
    return meses[mes];
  }

  Widget _buildClientaSeleccionada() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFD4748F).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: const Color(0xFFD4748F).withValues(alpha: 0.3)),
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
                      fontWeight: FontWeight.w600, fontSize: 14),
                ),
                Text(
                  _clientaSeleccionada!.telefono,
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
              ],
            ),
          ),
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
