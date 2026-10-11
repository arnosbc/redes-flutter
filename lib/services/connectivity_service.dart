import 'package:connectivity_plus/connectivity_plus.dart';

/// Envuelve `connectivity_plus` para que el resto de la app no dependa
/// directamente del paquete.
///
/// IMPORTANTE: connectivity_plus solo dice si el dispositivo está conectado a
/// una red (WiFi, datos...). NO garantiza que haya internet de verdad. Por eso
/// además manejamos los errores de la petición HTTP en [ApiService].
class ConnectivityService {
  final Connectivity _connectivity = Connectivity();

  /// En la versión 6.x el resultado es una lista (el dispositivo puede estar
  /// conectado a varias redes a la vez, por ejemplo WiFi + VPN).
  bool _hayRed(List<ConnectivityResult> resultados) {
    return resultados.any((r) => r != ConnectivityResult.none);
  }

  /// Consulta puntual: ¿hay alguna red activa ahora mismo?
  Future<bool> hayConexion() async {
    final resultados = await _connectivity.checkConnectivity();
    return _hayRed(resultados);
  }

  /// Flujo que emite `true`/`false` cada vez que cambia la conectividad.
  Stream<bool> get cambios => _connectivity.onConnectivityChanged.map(_hayRed);

  /// Texto legible del tipo de red actual (para mostrarlo en pantalla).
  Future<String> tipoDeRed() async {
    final resultados = await _connectivity.checkConnectivity();
    if (!_hayRed(resultados)) return 'Sin conexión';

    final nombres = resultados
        .where((r) => r != ConnectivityResult.none)
        .map(_nombre)
        .toSet();
    return nombres.join(' + ');
  }

  String _nombre(ConnectivityResult r) {
    switch (r) {
      case ConnectivityResult.wifi:
        return 'WiFi';
      case ConnectivityResult.mobile:
        return 'Datos móviles';
      case ConnectivityResult.ethernet:
        return 'Ethernet';
      case ConnectivityResult.vpn:
        return 'VPN';
      case ConnectivityResult.bluetooth:
        return 'Bluetooth';
      case ConnectivityResult.satellite:
        return 'Satélite';
      case ConnectivityResult.other:
        return 'Otra red';
      case ConnectivityResult.none:
        return 'Sin conexión';
    }
  }
}
