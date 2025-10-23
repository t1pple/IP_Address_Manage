import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';

import '../providers/ip_addresses_provider.dart';
import '../providers/settings_provider.dart';
import '../models/ip_address.dart';
import '../utils/category_classifier.dart';
import 'ip_form_screen.dart';

class IpListScreen extends StatelessWidget {
  const IpListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<IpAddressesProvider>();
    final s = context.watch<SettingsProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('IP Address Manager'),
        actions: [
          // Toggle favorite
          IconButton(
            tooltip: prov.favoriteOnly ? 'แสดงทั้งหมด' : 'เฉพาะรายการโปรด',
            icon: Icon(prov.favoriteOnly ? Icons.star : Icons.star_border),
            onPressed: () =>
                context.read<IpAddressesProvider>().toggleFavoriteOnly(),
          ),
          // Version filter
          PopupMenuButton<String?>(
            onSelected: (v) => context
                .read<IpAddressesProvider>()
                .setVersionFilter(v == 'All' ? null : v),
            itemBuilder: (ctx) => const [
              PopupMenuItem(value: 'All', child: Text('All')),
              PopupMenuItem(value: 'IPv4', child: Text('IPv4')),
              PopupMenuItem(value: 'IPv6', child: Text('IPv6')),
            ],
            icon: const Icon(Icons.filter_list),
          ),
          // Theme & Text size (ไม่หาย)
          PopupMenuButton<String>(
            tooltip: 'Theme / Text size',
            onSelected: (v) {
              final sp = context.read<SettingsProvider>();
              switch (v) {
                case 'light':
                  sp.setThemeMode(ThemeMode.light);
                  break;
                case 'dark':
                  sp.setThemeMode(ThemeMode.dark);
                  break;
                case 'system':
                  sp.setThemeMode(ThemeMode.system);
                  break;
                case 'textUp':
                  sp.setTextScale(s.textScale + 0.1);
                  break;
                case 'textDown':
                  sp.setTextScale(s.textScale - 0.1);
                  break;
              }
            },
            itemBuilder: (ctx) => const [
              PopupMenuItem(value: 'light', child: Text('Light theme')),
              PopupMenuItem(value: 'dark', child: Text('Dark theme')),
              PopupMenuItem(value: 'system', child: Text('System default')),
              PopupMenuDivider(),
              PopupMenuItem(value: 'textUp', child: Text('Text +')),
              PopupMenuItem(value: 'textDown', child: Text('Text -')),
            ],
            icon: const Icon(Icons.color_lens),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'ค้นหา label / address / notes',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (s) =>
                  context.read<IpAddressesProvider>().setSearch(s),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => context.read<IpAddressesProvider>().load(),
              child: ListView.builder(
                itemCount: prov.items.length,
                itemBuilder: (ctx, i) {
                  final ip = prov.items[i];
                  return _IpTile(ip: ip);
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const IpFormScreen()),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _IpTile extends StatelessWidget {
  const _IpTile({required this.ip});
  final IpAddress ip;

  Future<bool?> _confirm(BuildContext context, String msg) {
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('ยืนยันการลบ'),
        content: Text(msg),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('ยกเลิก')),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('ลบ')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ไอคอนจาก classifier (ไม่มีทางหาย เพราะอยู่ใน leading เสมอ)
    final icon =
        CategoryClassifier.iconFromText('${ip.label} ${ip.notes ?? ''}');

    return Slidable(
      key: ValueKey(ip.id ?? ip.address),
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        children: [
          SlidableAction(
            onPressed: (_) => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => IpFormScreen(editing: ip)),
            ),
            icon: Icons.edit,
            label: 'แก้ไข',
          ),
          SlidableAction(
            onPressed: (_) async {
              final ok = await _confirm(
                  context, 'ลบ ${ip.label} (${ip.address}/${ip.prefix}) ?');
              if (ok == true) {
                await context.read<IpAddressesProvider>().remove(ip.id!);
              }
            },
            icon: Icons.delete,
            backgroundColor: Colors.red,
            label: 'ลบ',
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(icon),
        title: Text('${ip.label}  ${ip.isFavorite ? "★" : ""}'),
        subtitle: Text('${ip.address}/${ip.prefix} • ${ip.version}'),
        // ปุ่มลบใน trailing (ไอคอนไม่หาย เพราะไม่ยุ่งกับ leading)
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: ip.isFavorite ? 'เอาออกจากโปรด' : 'ทำเป็นโปรด',
              icon: Icon(ip.isFavorite ? Icons.star : Icons.star_border),
              onPressed: () {
                context.read<IpAddressesProvider>().update(
                      ip.copyWith(isFavorite: !ip.isFavorite),
                    );
              },
            ),
            IconButton(
              tooltip: 'ลบรายการนี้',
              icon: const Icon(Icons.delete_outline),
              color: Colors.red,
              onPressed: () async {
                final ok = await _confirm(
                    context, 'ลบ ${ip.label} (${ip.address}/${ip.prefix}) ?');
                if (ok == true) {
                  await context.read<IpAddressesProvider>().remove(ip.id!);
                }
              },
            ),
          ],
        ),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => IpFormScreen(editing: ip)),
        ),
      ),
    );
  }
}
