// lib/core/helpers/network_helper.dart
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkHelper {
  // Check if server is reachable
  static Future<bool> isServerReachable(String ip, int port) async {
    try {
      final result = await InternetAddress.lookup(ip);
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        final socket = await Socket.connect(ip, port, timeout: Duration(seconds: 3));
        socket.destroy();
        return true;
      }
      return false;
    } catch (e) {
      print('Server not reachable: $e');
      return false;
    }
  }

  // Get local IP address of the device
  static Future<String> getLocalIpAddress() async {
    try {
      for (var interface in await NetworkInterface.list()) {
        for (var addr in interface.addresses) {
          if (addr.type == InternetAddressType.IPv4 && 
              !addr.address.startsWith('127.') &&
              !addr.address.startsWith('169.254')) {
            print('Found device IP: ${addr.address}');
            return addr.address;
          }
        }
      }
    } catch (e) {
      print('Error getting IP: $e');
    }
    return '192.168.29.63'; // Fallback
  }

  // Check internet connectivity
  static Future<bool> hasInternetConnection() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  // Get current connection type
  static Future<String> getConnectionType() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    switch (connectivityResult) {
      case ConnectivityResult.wifi:
        return 'WiFi';
      case ConnectivityResult.mobile:
        return 'Mobile Data';
      case ConnectivityResult.ethernet:
        return 'Ethernet';
      default:
        return 'No Connection';
    }
  }

  // Test if a specific URL is reachable
  static Future<bool> testUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      final client = HttpClient();
      client.connectionTimeout = Duration(seconds: 2);
      final request = await client.getUrl(uri);
      final response = await request.close();
      client.close();
      return response.statusCode == 200;
    } catch (e) {
      print('URL test failed for $url: $e');
      return false;
    }
  }
}