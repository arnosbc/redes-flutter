import 'dart:async';

import 'package:flutter/material.dart';

import '../models/post.dart';
import '../services/api_service.dart';
import '../services/connectivity_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _conectividad = ConnectivityService();
  final _api = ApiService();

  StreamSubscription<bool>? _suscripcion;

  bool _hayRed = true;
  String _tipoRed = 'Verificando...';
  bool _cargando = false;
  String? _error;
  List<Post> _posts = [];

  @override
  void initState() {
    super.initState();
    _iniciarConectividad();
  }

  /// Lee el estado inicial y se suscribe a los cambios en tiempo real.
  Future<void> _iniciarConectividad() async {
    await _actualizarEstadoRed();

    _suscripcion = _conectividad.cambios.listen((_) {
      _actualizarEstadoRed();
    });
  }

  Future<void> _actualizarEstadoRed() async {
    final hayRed = await _conectividad.hayConexion();
    final tipo = await _conectividad.tipoDeRed();
    if (!mounted) return; // la pantalla pudo cerrarse mientras esperábamos
    setState(() {
      _hayRed = hayRed;
      _tipoRed = tipo;
    });
  }

  /// Carga las publicaciones manejando todos los casos de error.
  Future<void> _cargarPosts() async {
    // 1) Si ya sabemos que no hay red, ni intentamos la petición.
    if (!await _conectividad.hayConexion()) {
      setState(() {
        _error = 'Sin conexión a la red. Actívala e intenta de nuevo.';
        _posts = [];
      });
      return;
    }

    setState(() {
      _cargando = true;
      _error = null;
    });

    // 2) Aunque haya red, la petición puede fallar (timeout, servidor, etc.)
    try {
      final posts = await _api.obtenerPosts();
      if (!mounted) return;
      setState(() => _posts = posts);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.mensaje;
        _posts = [];
      });
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  void dispose() {
    _suscripcion?.cancel(); // evita fugas de memoria
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Redes: API REST y conectividad')),
      body: Column(
        children: [
          _BannerRed(hayRed: _hayRed, tipo: _tipoRed),
          Expanded(child: _contenido()),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _cargando ? null : _cargarPosts,
        icon: const Icon(Icons.cloud_download),
        label: const Text('Cargar datos'),
      ),
    );
  }

  Widget _contenido() {
    if (_cargando) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.wifi_off, size: 64, color: Colors.redAccent),
              const SizedBox(height: 12),
              Text(_error!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _cargarPosts,
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    if (_posts.isEmpty) {
      return const Center(
        child: Text('Pulsa "Cargar datos" para consultar la API'),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 90),
      itemCount: _posts.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final post = _posts[index];
        return ListTile(
          leading: CircleAvatar(child: Text('${post.id}')),
          title: Text(
            post.titulo,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            post.cuerpo,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        );
      },
    );
  }
}

/// Franja superior que muestra el estado de la red en tiempo real.
class _BannerRed extends StatelessWidget {
  const _BannerRed({required this.hayRed, required this.tipo});

  final bool hayRed;
  final String tipo;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      color: hayRed ? Colors.green.shade600 : Colors.red.shade600,
      child: Row(
        children: [
          Icon(hayRed ? Icons.wifi : Icons.wifi_off, color: Colors.white),
          const SizedBox(width: 10),
          Text(
            hayRed ? 'Conectado: $tipo' : 'Sin conexión',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
