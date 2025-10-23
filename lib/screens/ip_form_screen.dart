import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/ip_address.dart';
import '../providers/ip_addresses_provider.dart';
import '../utils/category_classifier.dart';

class IpFormScreen extends StatefulWidget {
  final IpAddress? editing;
  const IpFormScreen({super.key, this.editing});

  @override
  State<IpFormScreen> createState() => _IpFormScreenState();
}

class _IpFormScreenState extends State<IpFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _labelCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _gatewayCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final _prefixCtrl = TextEditingController();

  String _version = 'IPv4';
  bool _favorite = false;
  String _category = 'Unknown';

  @override
  void initState() {
    super.initState();
    final e = widget.editing;
    if (e != null) {
      _labelCtrl.text = e.label;
      _addressCtrl.text = e.address;
      _gatewayCtrl.text = e.gateway ?? '';
      _notesCtrl.text = e.notes ?? '';
      _version = e.version;
      _prefixCtrl.text = e.prefix.toString();
      _favorite = e.isFavorite;
      _category = e.category;
    } else {
      _prefixCtrl.text = '24';
    }
    _labelCtrl.addListener(_reclassify);
    _notesCtrl.addListener(_reclassify);
  }

  void _reclassify() {
    final text = '${_labelCtrl.text} ${_notesCtrl.text}';
    setState(() => _category = CategoryClassifier.classify(text));
  }

  @override
  void dispose() {
    _labelCtrl.dispose();
    _addressCtrl.dispose();
    _gatewayCtrl.dispose();
    _notesCtrl.dispose();
    _prefixCtrl.dispose();
    super.dispose();
  }

  String? _validateAddress(String? v) {
    final s = v?.trim() ?? '';
    if (s.isEmpty) return 'ต้องกรอก IP address';
    if (_version == 'IPv4' && !IpAddress.isValidIPv4(s))
      return 'IPv4 ไม่ถูกต้อง';
    if (_version == 'IPv6' && !IpAddress.isValidIPv6(s))
      return 'IPv6 ไม่ถูกต้อง';
    return null;
  }

  String? _validatePrefix(String? v) {
    final n = int.tryParse((v ?? '').trim());
    if (n == null) return 'prefix ต้องเป็นตัวเลข';
    if (_version == 'IPv4' && (n < 0 || n > 32)) return 'IPv4 prefix ต้อง 0–32';
    if (_version == 'IPv6' && (n < 0 || n > 128))
      return 'IPv6 prefix ต้อง 0–128';
    return null;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final now = DateTime.now().millisecondsSinceEpoch;
    final ip = IpAddress(
      id: widget.editing?.id,
      label: _labelCtrl.text.trim(),
      address: _addressCtrl.text.trim(),
      version: _version,
      prefix: int.parse(_prefixCtrl.text.trim()),
      gateway: _gatewayCtrl.text.trim().isEmpty
          ? null
          : _gatewayCtrl.text.trim(),
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      category: _category,
      isFavorite: _favorite,
      createdAt: widget.editing?.createdAt ?? now,
      updatedAt: now,
    );

    final prov = context.read<IpAddressesProvider>();
    if (widget.editing == null) {
      await prov.add(ip);
    } else {
      await prov.update(ip);
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.editing == null ? 'เพิ่ม IP' : 'แก้ไข IP'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _labelCtrl,
                decoration: const InputDecoration(labelText: 'Label *'),
                validator: (v) => v!.trim().isEmpty ? 'ต้องกรอก label' : null,
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _version,
                items: const [
                  DropdownMenuItem(value: 'IPv4', child: Text('IPv4')),
                  DropdownMenuItem(value: 'IPv6', child: Text('IPv6')),
                ],
                onChanged: (v) => setState(() {
                  _version = v!;
                  _prefixCtrl.text = _version == 'IPv4' ? '24' : '64';
                }),
                decoration: const InputDecoration(labelText: 'Version *'),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _addressCtrl,
                decoration: const InputDecoration(labelText: 'Address *'),
                validator: _validateAddress,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _prefixCtrl,
                decoration: const InputDecoration(labelText: 'Prefix * (CIDR)'),
                keyboardType: TextInputType.number,
                validator: _validatePrefix,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _gatewayCtrl,
                decoration: const InputDecoration(
                  labelText: 'Gateway (optional)',
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _notesCtrl,
                decoration: const InputDecoration(
                  labelText: 'Notes (optional)',
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: Icon(CategoryClassifier.iconFor(_category)),
                title: Text('เดาหมวด: $_category'),
                subtitle: const Text('อัปเดตตาม Label/Notes อัตโนมัติ'),
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                title: const Text('Favorite'),
                value: _favorite,
                onChanged: (v) => setState(() => _favorite = v),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: const Text('บันทึก'),
                onPressed: _save,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
