import 'package:flutter/material.dart';

/// เดาหมวดจากข้อความ (label/notes) แล้วคืน IconData
class CategoryClassifier {
  static const _map = <String, List<String>>{
    'Camera': ['camera', 'cctv', 'ip cam', 'cam', 'กล้อง', 'วงจรปิด'],
    'Router': ['router', 'เราเตอร์', 'gateway', 'gw'],
    'Switch': ['switch', 'สวิตช์', 'sw '],
    'Server': ['server', 'srv', 'vm ', 'virtual', 'vps', 'บริการ'],
    'NAS': ['nas', 'storage', 'synology', 'truenas', 'qnap'],
    'Printer': ['printer', 'พิมพ์', 'hp ', 'canon', 'epson'],
    'PC': ['pc', 'desktop', 'คอม', 'workstation'],
    'Laptop': ['laptop', 'notebook', 'โน้ตบุ๊ก', 'macbook'],
    'TV': ['tv', 'ทีวี', 'monitor', 'android tv'],
    'Access Point': ['ap ', 'access point', 'wifi', 'wireless'],
    'Phone': ['phone', 'มือถือ', 'iphone', 'android'],
    'IoT': ['iot', 'sensor', 'esp32', 'arduino', 'raspberry', 'pi '],
    'Firewall': ['firewall', 'pfsense', 'opnsense', 'fortigate'],
    'Door Lock': ['door', 'lock', 'ประตู', 'กลอน'],
    'Aircon': ['air ', 'แอร์', 'aircon', 'air conditioner'],
    'Smart Plug': ['plug', 'ปลั๊ก', 'smart plug'],
  };

  static String classify(String text) {
    final t = text.toLowerCase();
    for (final e in _map.entries) {
      for (final kw in e.value) {
        if (t.contains(kw)) return e.key;
      }
    }
    return 'Unknown';
  }

  static IconData iconFor(String category) {
    switch (category) {
      case 'Camera':
        return Icons.videocam;
      case 'Router':
        return Icons.router;
      case 'Switch':
        return Icons.dns;
      case 'Server':
        return Icons.dvr;
      case 'NAS':
        return Icons.storage;
      case 'Printer':
        return Icons.print;
      case 'PC':
        return Icons.computer;
      case 'Laptop':
        return Icons.laptop;
      case 'TV':
        return Icons.tv;
      case 'Access Point':
        return Icons.wifi;
      case 'Phone':
        return Icons.phone_android;
      case 'IoT':
        return Icons.sensors;
      case 'Firewall':
        return Icons.security;
      case 'Door Lock':
        return Icons.door_front_door;
      case 'Aircon':
        return Icons.ac_unit;
      case 'Smart Plug':
        return Icons.power_outlined;
      default:
        return Icons.device_unknown;
    }
  }

  /// ส่งข้อความ (label+notes) แล้วได้ไอคอนเลย
  static IconData iconFromText(String text) => iconFor(classify(text));
}
