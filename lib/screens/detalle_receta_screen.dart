import 'package:flutter/material.dart';
import 'package:recetasapp/data/resenas_db.dart';
import 'package:recetasapp/models/receta.dart';
import 'package:recetasapp/models/resena.dart';

class DetalleRecetaScreen extends StatefulWidget {
  final Receta receta;

  const DetalleRecetaScreen({
    super.key,
    required this.receta,
  });

  @override
  State<DetalleRecetaScreen> createState() =>
      _DetalleRecetaScreenState();
}

class _DetalleRecetaScreenState
    extends State<DetalleRecetaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _resenaCtrl = TextEditingController();

  bool _cargando = true;
  bool _guardando = false;
  bool _errorCarga = false;

  @override
  void initState() {
    super.initState();
    _cargarResena();
  }

  Future<void> _cargarResena() async {
    setState(() {
      _cargando = true;
      _errorCarga = false;
    });

    try {
      final resena = await ResenasDb.instancia.obtenerPorReceta(
        widget.receta.id,
      );

      if (!mounted) return;

      _resenaCtrl.text = resena?.comentario ?? '';
    } catch (_) {
      if (!mounted) return;

      _errorCarga = true;
    } finally {
      if (mounted) {
        setState(() {
          _cargando = false;
        });
      }
    }
  }

  Future<void> _guardarResena() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _guardando = true;
    });

    try {
      final resena = Resena(
        recetaId: widget.receta.id,
        comentario: _resenaCtrl.text.trim(),
      );

      await ResenasDb.instancia.guardar(resena);

      if (!mounted) return;

      FocusScope.of(context).unfocus();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reseña guardada correctamente'),
        ),
      );
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo guardar la reseña'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _guardando = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _resenaCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final receta = widget.receta;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de la receta'),
        backgroundColor: const Color.fromARGB(255, 80, 23, 3),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.network(
              receta.imagenUrl,
              height: 200,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stack) =>
                  Image.asset(
                'assets/images/plato-placeholder.jpg',
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            children: [
              Chip(label: Text('${receta.tiempoTotal} min')),
              Chip(label: Text(receta.dificultad)),
              Chip(label: Text(receta.cocina)),
              Chip(label: Text('${receta.calorias} kcal')),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Ingredientes:',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          ...receta.ingredientes.map(
            (ingrediente) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 7),
                    child: Icon(
                      Icons.circle,
                      size: 6,
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: Text(ingrediente)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Preparación:',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          ...receta.instrucciones.asMap().entries.map(
            (entrada) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: Colors.deepOrange,
                    child: Text(
                      '${entrada.key + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: Text(entrada.value)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 28),
          const Text(
            'Mi Reseña:',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          if (_cargando)
            const Center(
              child: CircularProgressIndicator(),
            )
          else if (_errorCarga)
            Column(
              children: [
                const Text('No se pudo cargar la reseña'),
                TextButton(
                  onPressed: _cargarResena,
                  child: const Text('Reintentar'),
                ),
              ],
            )
          else
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _resenaCtrl,
                    enabled: !_guardando,
                    maxLines: 4,
                    maxLength: 500,
                    textCapitalization:
                        TextCapitalization.sentences,
                    decoration: InputDecoration(
                      hintText:
                          'Escribe aquí alguna nota o comentarios '
                          'sobre la receta...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    validator: (valor) {
                      if (valor == null || valor.trim().isEmpty) {
                        return 'Escribe una reseña';
                      }

                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed:
                        _guardando ? null : _guardarResena,
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.deepOrange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    icon: const Icon(Icons.save),
                    label: Text(
                      _guardando
                          ? 'Guardando...'
                          : 'Guardar Reseña',
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}