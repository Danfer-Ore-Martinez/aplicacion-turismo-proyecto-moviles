import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../core/app_dark_colors.dart';
import '../core/text_styles.dart';
import '../models/destination_model.dart';
import '../models/itinerario_model.dart';
import '../services/api_service.dart';
import '../services/itinerario_local_service.dart';

// Modulo Mi viaje: crea itinerarios locales, agrega destinos por dia
// y muestra un presupuesto estimado. No requiere inicio de sesion.
class MiViajeScreen extends StatefulWidget {
  const MiViajeScreen({super.key});

  @override
  State<MiViajeScreen> createState() => _MiViajeScreenState();
}

class _MiViajeScreenState extends State<MiViajeScreen> {
  final ItinerarioLocalService _service = ItinerarioLocalService();

  List<Itinerario> _itinerarios = [];
  List<Destination> _destinos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() => _isLoading = true);
    final itinerarios = await _service.cargar();
    // Los destinos se toman de la API; si no responde, ApiService usa datos locales.
    final destinos = await ApiService.getDestinos();
    if (!mounted) return;
    setState(() {
      _itinerarios = itinerarios;
      _destinos = destinos;
      _isLoading = false;
    });
  }

  Future<void> _persistir() async {
    await _service.guardar(_itinerarios);
  }

  // ---------- Crear / eliminar itinerario ----------

  Future<void> _crearItinerario() async {
    final datos = await showDialog<_NuevoItinerarioDatos>(
      context: context,
      builder: (_) => const _CrearItinerarioDialog(),
    );
    if (datos == null) return;

    final itinerario = Itinerario(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      nombre: datos.nombre,
      fechaInicio: datos.fechaInicio,
      fechaFin: datos.fechaFin,
      presupuestoEstimado: datos.presupuestoEstimado,
    );

    setState(() => _itinerarios = [..._itinerarios, itinerario]);
    await _persistir();
  }

  Future<void> _eliminarItinerario(Itinerario itinerario) async {
    setState(
      () => _itinerarios = _itinerarios
          .where((e) => e.id != itinerario.id)
          .toList(),
    );
    await _persistir();
  }

  // ---------- Agregar / quitar destino ----------

  Future<void> _agregarDestino(Itinerario itinerario) async {
    if (_destinos.isEmpty) return;
    final datos = await showDialog<_NuevoDetalleDatos>(
      context: context,
      builder: (_) => _AgregarDestinoDialog(
        destinos: _destinos,
        fechaMinima: itinerario.fechaInicio,
        fechaMaxima: itinerario.fechaFin,
      ),
    );
    if (datos == null) return;

    final detalle = DetalleViaje(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      idDestino: datos.destino.idDestino,
      nombreDestino: datos.destino.nombre,
      actividad: datos.actividad ?? datos.destino.actividad,
      precioEntrada: datos.destino.precioEntrada,
      fechaVisita: datos.fechaVisita,
      horaVisita: datos.horaVisita,
    );

    setState(() {
      _itinerarios = _itinerarios.map((e) {
        if (e.id == itinerario.id) {
          return e.copyWith(detalles: [...e.detalles, detalle]);
        }
        return e;
      }).toList();
    });
    await _persistir();
  }

  Future<void> _quitarDestino(
    Itinerario itinerario,
    DetalleViaje detalle,
  ) async {
    setState(() {
      _itinerarios = _itinerarios.map((e) {
        if (e.id == itinerario.id) {
          return e.copyWith(
            detalles: e.detalles.where((d) => d.id != detalle.id).toList(),
          );
        }
        return e;
      }).toList();
    });
    await _persistir();
  }

  // ---------- Build ----------

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark
        ? AppDarkColors.textPrimary
        : AppColors.textPrimary;
    final surface = isDark ? AppDarkColors.surface : AppColors.surface;
    final secondary = isDark ? AppDarkColors.secondary : AppColors.secondary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
          child: Text(
            'Mi viaje',
            style: AppTextStyles.titleSection.copyWith(color: textPrimary),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: _crearItinerario,
              icon: const Icon(Icons.add, size: 20),
              label: Text(
                'Nuevo itinerario',
                style: AppTextStyles.titleCard.copyWith(
                  color: AppColors.surface,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.surface,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                )
              : _itinerarios.isEmpty
              ? _buildVacio(isDark, secondary, textPrimary)
              : ListView.builder(
                  padding: const EdgeInsets.only(top: 4, bottom: 16),
                  itemCount: _itinerarios.length,
                  itemBuilder: (context, index) {
                    return _buildItinerarioCard(
                      _itinerarios[index],
                      isDark: isDark,
                      surface: surface,
                      textPrimary: textPrimary,
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildVacio(bool isDark, Color secondary, Color textPrimary) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.map_outlined,
              size: 64,
              color: secondary.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 16),
            Text(
              'No tienes itinerarios todavia',
              style: AppTextStyles.titleCard.copyWith(
                color: textPrimary.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Crea un itinerario y agrega destinos para organizar tu viaje',
              style: AppTextStyles.secondaryText.copyWith(
                color: isDark
                    ? AppDarkColors.textSecondary
                    : textPrimary.withValues(alpha: 0.5),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItinerarioCard(
    Itinerario itinerario, {
    required bool isDark,
    required Color surface,
    required Color textPrimary,
  }) {
    final secondaryTextColor = isDark
        ? AppDarkColors.textSecondary
        : textPrimary.withValues(alpha: 0.6);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: (isDark ? AppDarkColors.shadow : Colors.black).withValues(
              alpha: 0.08,
            ),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          iconColor: AppColors.primary,
          collapsedIconColor: secondaryTextColor,
          title: Text(
            itinerario.nombre,
            style: AppTextStyles.titleCard.copyWith(color: textPrimary),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              '${_formatFecha(itinerario.fechaInicio)} - ${_formatFecha(itinerario.fechaFin)}',
              style: AppTextStyles.secondaryText.copyWith(
                color: secondaryTextColor,
              ),
            ),
          ),
          children: [
            _buildResumen(itinerario, secondaryTextColor),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _agregarDestino(itinerario),
                icon: const Icon(Icons.add_location_alt_outlined, size: 18),
                label: const Text('Agregar destino'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            _buildDetalles(
              itinerario,
              isDark: isDark,
              textPrimary: textPrimary,
              secondaryTextColor: secondaryTextColor,
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => _eliminarItinerario(itinerario),
                icon: const Icon(Icons.delete_outline, size: 18),
                label: const Text('Eliminar itinerario'),
                style: TextButton.styleFrom(foregroundColor: AppColors.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResumen(Itinerario itinerario, Color secondaryTextColor) {
    final porDia = itinerario.porDia;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${itinerario.detalles.length} destinos  -  ${porDia.length} dias con plan',
          style: AppTextStyles.secondaryText.copyWith(
            color: secondaryTextColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Presupuesto estimado: S/ ${itinerario.presupuestoTotal.toStringAsFixed(2)}',
          style: AppTextStyles.bodyText.copyWith(fontWeight: FontWeight.w600),
        ),
        Text(
          'Incluye entradas registradas + presupuesto manual',
          style: AppTextStyles.secondaryText.copyWith(
            color: secondaryTextColor,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildDetalles(
    Itinerario itinerario, {
    required bool isDark,
    required Color textPrimary,
    required Color secondaryTextColor,
  }) {
    final porDia = itinerario.porDia;
    if (porDia.isEmpty) {
      return Text(
        'Sin destinos todavia. Agrega uno a cada dia.',
        style: AppTextStyles.secondaryText.copyWith(color: secondaryTextColor),
      );
    }

    final children = <Widget>[];
    porDia.forEach((dia, lista) {
      children.add(
        Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 4),
          child: Text(
            _formatFecha(dia),
            style: AppTextStyles.titleCard.copyWith(
              color: AppColors.primary,
              fontSize: 14,
            ),
          ),
        ),
      );
      for (final d in lista) {
        children.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.place_outlined, size: 18, color: AppColors.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        d.nombreDestino,
                        style: AppTextStyles.bodyText.copyWith(
                          color: textPrimary,
                        ),
                      ),
                      if (d.horaVisita != null)
                        Text(
                          d.horaVisita!,
                          style: AppTextStyles.secondaryText.copyWith(
                            color: secondaryTextColor,
                          ),
                        ),
                      if ((d.actividad ?? '').isNotEmpty)
                        Text(
                          d.actividad!,
                          style: AppTextStyles.secondaryText.copyWith(
                            color: secondaryTextColor,
                          ),
                        ),
                      if (d.precioEntrada > 0)
                        Text(
                          'Entrada: S/ ${d.precioEntrada.toStringAsFixed(2)}',
                          style: AppTextStyles.secondaryText.copyWith(
                            color: secondaryTextColor,
                          ),
                        ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  color: secondaryTextColor,
                  tooltip: 'Quitar',
                  onPressed: () => _quitarDestino(itinerario, d),
                ),
              ],
            ),
          ),
        );
      }
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }
}

// ---------- Dialogos ----------

class _NuevoItinerarioDatos {
  final String nombre;
  final DateTime fechaInicio;
  final DateTime fechaFin;
  final double presupuestoEstimado;

  const _NuevoItinerarioDatos({
    required this.nombre,
    required this.fechaInicio,
    required this.fechaFin,
    required this.presupuestoEstimado,
  });
}

class _CrearItinerarioDialog extends StatefulWidget {
  const _CrearItinerarioDialog();

  @override
  State<_CrearItinerarioDialog> createState() => _CrearItinerarioDialogState();
}

class _CrearItinerarioDialogState extends State<_CrearItinerarioDialog> {
  final _nombreController = TextEditingController();
  final _presupuestoController = TextEditingController(text: '0');
  final _formKey = GlobalKey<FormState>();

  late DateTime _inicio = _soloFecha(DateTime.now());
  late DateTime _fin = _soloFecha(DateTime.now().add(const Duration(days: 3)));

  DateTime _soloFecha(DateTime d) => DateTime(d.year, d.month, d.day);

  @override
  void dispose() {
    _nombreController.dispose();
    _presupuestoController.dispose();
    super.dispose();
  }

  Future<void> _elegirFecha(bool esInicio) async {
    final base = esInicio ? _inicio : _fin;
    final elegida = await showDatePicker(
      context: context,
      initialDate: base,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (elegida == null) return;
    setState(() {
      if (esInicio) {
        _inicio = elegida;
        if (_fin.isBefore(_inicio)) _fin = _inicio;
      } else {
        _fin = elegida;
        if (_fin.isBefore(_inicio)) _inicio = _fin;
      }
    });
  }

  void _guardar() {
    if (!_formKey.currentState!.validate()) return;
    final presupuesto =
        double.tryParse(_presupuestoController.text.replaceAll(',', '.')) ?? 0;
    Navigator.of(context).pop(
      _NuevoItinerarioDatos(
        nombre: _nombreController.text.trim(),
        fechaInicio: _inicio,
        fechaFin: _fin,
        presupuestoEstimado: presupuesto < 0 ? 0 : presupuesto,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Nuevo itinerario'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nombreController,
                decoration: _input(
                  'Nombre del itinerario',
                  Icons.edit_outlined,
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Ingresa un nombre'
                    : null,
              ),
              const SizedBox(height: 12),
              _fechaTile('Fecha de inicio', _inicio, () => _elegirFecha(true)),
              const SizedBox(height: 8),
              _fechaTile('Fecha de fin', _fin, () => _elegirFecha(false)),
              const SizedBox(height: 12),
              TextFormField(
                controller: _presupuestoController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: _input(
                  'Presupuesto estimado (S/)',
                  Icons.attach_money,
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return null;
                  final n = double.tryParse(v.replaceAll(',', '.'));
                  if (n == null || n < 0) return 'Ingresa un numero valido';
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _guardar,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text('Crear'),
        ),
      ],
    );
  }

  Widget _fechaTile(String label, DateTime valor, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.secondary.withValues(alpha: 0.4)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_outlined, size: 18),
            const SizedBox(width: 10),
            Expanded(child: Text(label, style: AppTextStyles.secondaryText)),
            Text(
              _formatFecha(valor),
              style: AppTextStyles.bodyText.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _input(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, size: 20),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
    );
  }
}

class _NuevoDetalleDatos {
  final Destination destino;
  final DateTime fechaVisita;
  final String? horaVisita;
  final String? actividad;

  const _NuevoDetalleDatos({
    required this.destino,
    required this.fechaVisita,
    this.horaVisita,
    this.actividad,
  });
}

class _AgregarDestinoDialog extends StatefulWidget {
  final List<Destination> destinos;
  final DateTime fechaMinima;
  final DateTime fechaMaxima;

  const _AgregarDestinoDialog({
    required this.destinos,
    required this.fechaMinima,
    required this.fechaMaxima,
  });

  @override
  State<_AgregarDestinoDialog> createState() => _AgregarDestinoDialogState();
}

class _AgregarDestinoDialogState extends State<_AgregarDestinoDialog> {
  final _actividadController = TextEditingController();

  Destination? _destino;
  late DateTime _fecha;
  TimeOfDay? _hora;

  @override
  void initState() {
    super.initState();
    _destino = widget.destinos.isNotEmpty ? widget.destinos.first : null;
    final min = _soloFecha(widget.fechaMinima);
    final max = _soloFecha(widget.fechaMaxima);
    _fecha = DateTime.now().isBefore(min)
        ? min
        : (DateTime.now().isAfter(max) ? max : _soloFecha(DateTime.now()));
  }

  DateTime _soloFecha(DateTime d) => DateTime(d.year, d.month, d.day);

  @override
  void dispose() {
    _actividadController.dispose();
    super.dispose();
  }

  Future<void> _elegirFecha() async {
    final elegida = await showDatePicker(
      context: context,
      initialDate: _fecha,
      firstDate: _soloFecha(widget.fechaMinima),
      lastDate: _soloFecha(widget.fechaMaxima),
    );
    if (elegida != null) setState(() => _fecha = elegida);
  }

  Future<void> _elegirHora() async {
    final elegida = await showTimePicker(
      context: context,
      initialTime: _hora ?? TimeOfDay.now(),
    );
    if (elegida != null) setState(() => _hora = elegida);
  }

  String? _horaTexto() {
    if (_hora == null) return null;
    final h = _hora!.hour.toString().padLeft(2, '0');
    final m = _hora!.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  void _guardar() {
    if (_destino == null) return;
    Navigator.of(context).pop(
      _NuevoDetalleDatos(
        destino: _destino!,
        fechaVisita: _fecha,
        horaVisita: _horaTexto(),
        actividad: _actividadController.text.trim().isEmpty
            ? null
            : _actividadController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Agregar destino'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<Destination>(
              initialValue: _destino,
              decoration: InputDecoration(
                labelText: 'Destino',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              isExpanded: true,
              items: widget.destinos
                  .map(
                    (d) => DropdownMenuItem<Destination>(
                      value: d,
                      child: Text(d.nombre, overflow: TextOverflow.ellipsis),
                    ),
                  )
                  .toList(),
              onChanged: (d) => setState(() => _destino = d),
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: _elegirFecha,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppColors.secondary.withValues(alpha: 0.4),
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined, size: 18),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Dia de la visita',
                        style: AppTextStyles.secondaryText,
                      ),
                    ),
                    Text(
                      _formatFecha(_fecha),
                      style: AppTextStyles.bodyText.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: _elegirHora,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppColors.secondary.withValues(alpha: 0.4),
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.access_time, size: 18),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Hora (opcional)',
                        style: AppTextStyles.secondaryText,
                      ),
                    ),
                    Text(
                      _horaTexto() ?? '--:--',
                      style: AppTextStyles.bodyText.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _actividadController,
              decoration: InputDecoration(
                labelText: 'Actividad (opcional)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _guardar,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text('Agregar'),
        ),
      ],
    );
  }
}

// ---------- Utilidades ----------

String _formatFecha(DateTime d) {
  final dd = d.day.toString().padLeft(2, '0');
  final mm = d.month.toString().padLeft(2, '0');
  final yyyy = d.year.toString();
  return '$dd/$mm/$yyyy';
}
