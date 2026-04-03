// lib/core/helpers/network_helper.dart
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkHelper {
  static Future<bool> isServerReachable(String ip, int port) async {
    try {
      print('🔌 Testing connection to $ip:$port...');
      final socket = await Socket.connect(ip, port, timeout: const Duration(seconds: 5));
      socket.destroy();
      print('✅ Successfully connected to $ip:$port');
      return true;
    } on SocketException catch (e) {
      print('❌ Cannot connect to $ip:$port: ${e.message}');
      return false;
    } catch (e) {
      print('❌ Error connecting to $ip:$port: $e');
      return false;
    }
  }

  static Future<String> getLocalIpAddress() async {
    try {
      for (var interface in await NetworkInterface.list()) {
        for (var addr in interface.addresses) {
          if (addr.type == InternetAddressType.IPv4 && 
              !addr.address.startsWith('127.') &&
              !addr.address.startsWith('169.254')) {
            print('📱 Found device IP: ${addr.address}');
            return addr.address;
          }
        }
      }
    } catch (e) {
      print('Error getting IP: $e');
    }
    return '192.168.56.1';
  }

  static Future<bool> hasInternetConnection() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    final hasConnection = connectivityResult != ConnectivityResult.none;
    print('📶 Internet connection: $hasConnection');
    return hasConnection;
  }

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
}