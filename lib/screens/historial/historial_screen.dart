import 'package:flutter/material.dart';
import '../../models/historial_clinico.dart';
import '../../repositories/historial_repository.dart';
import 'historial_detalle_screen.dart';
import 'historial_form_screen.dart';

class HistorialScreen extends StatefulWidget {
  const HistorialScreen({super.key});

  @override
  State<HistorialScreen> createState() => _HistorialScreenState();
}

class _HistorialScreenState extends State<HistorialScreen> {
  final _repo = HistorialRepository();
  final _buscarCtrl = TextEditingController();
  late Future<List<HistorialClinico>> _futuro;
  bool _buscando = false;

  @override
  void initState() {
    super.initState();
    _cargarTodos();
  }

  @override
  void dispose() {
    _buscarCtrl.dispose();
    super.dispose();
  }

  void _cargarTodos() {
    setState(() {
      _buscando = false;
      _futuro = _repo.listarTodos();
    });
  }

  void _buscarPorId() {
    final id = _buscarCtrl.text.trim();
    if (id.isEmpty) {
      _cargarTodos();
      return;
    }
    setState(() {
      _buscando = true;
      _futuro = _repo.buscarPorPacienteId(id).then((h) => h != null ? [h] : []);
    });
  }

  void _mostrarSnackbar(String mensaje, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: error ? Colors.red : Colors.deepPurple,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _abrirFormulario() async {
    final resultado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const HistorialFormScreen()),
    );
    if (resultado == true) {
      _mostrarSnackbar('Historial creado correctamente');
      _cargarTodos();
    }
  }

  Future<void> _verDetalle(HistorialClinico historial) async {
    final resultado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => HistorialDetalleScreen(historial: historial),
      ),
    );
    if (resultado == true) {
      _mostrarSnackbar('Consulta agregada correctamente');
      _cargarTodos();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial Clínico'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          if (_buscando)
            IconButton(
              icon: const Icon(Icons.clear),
              tooltip: 'Limpiar búsqueda',
              onPressed: () {
                _buscarCtrl.clear();
                _cargarTodos();
              },
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _abrirFormulario,
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Column(
        children: [
          // Buscador por ID de paciente
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _buscarCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'Buscar por ID de paciente...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 12,
                      ),
                    ),
                    onSubmitted: (_) => _buscarPorId(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _buscarPorId,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: 14, horizontal: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Buscar'),
                ),
              ],
            ),
          ),

          // Lista de historiales
          Expanded(
            child: FutureBuilder<List<HistorialClinico>>(
              future: _futuro,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline,
                            size: 60, color: Colors.red),
                        const SizedBox(height: 12),
                        Text(
                          snapshot.error.toString(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.red),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: _cargarTodos,
                          child: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  );
                }

                final historiales = snapshot.data ?? [];
                if (historiales.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.history,
                            size: 80, color: Colors.grey),
                        const SizedBox(height: 12),
                        Text(
                          _buscando
                              ? 'No se encontró historial para ese ID'
                              : 'No hay historiales registrados',
                          style: const TextStyle(
                              color: Colors.grey, fontSize: 16),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: historiales.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final h = historiales[index];
                    return Card(
                      elevation: 2,
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.deepPurple,
                          child: Text(
                            h.nombrePaciente[0].toUpperCase(),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text(
                          h.nombrePaciente,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          'ID: ${h.pacienteId}  •  ${h.consultas.length} consulta(s)',
                        ),
                        trailing: const Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: Colors.deepPurple,
                        ),
                        onTap: () => _verDetalle(h),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}