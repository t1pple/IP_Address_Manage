class IpAddress {
  final int? id;
  final String label;
  final String address;
  final String version; // 'IPv4' or 'IPv6'
  final int prefix;
  final String? gateway;
  final String? notes;
  final String category; // Camera/Router/...
  final bool isFavorite;
  final int createdAt;
  final int updatedAt;

  IpAddress({
    this.id,
    required this.label,
    required this.address,
    required this.version,
    required this.prefix,
    this.gateway,
    this.notes,
    this.category = 'Unknown',
    required this.isFavorite,
    required this.createdAt,
    required this.updatedAt,
  });

  IpAddress copyWith({
    int? id,
    String? label,
    String? address,
    String? version,
    int? prefix,
    String? gateway,
    String? notes,
    String? category,
    bool? isFavorite,
    int? createdAt,
    int? updatedAt,
  }) {
    return IpAddress(
      id: id ?? this.id,
      label: label ?? this.label,
      address: address ?? this.address,
      version: version ?? this.version,
      prefix: prefix ?? this.prefix,
      gateway: gateway ?? this.gateway,
      notes: notes ?? this.notes,
      category: category ?? this.category,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'label': label,
    'address': address,
    'version': version,
    'prefix': prefix,
    'gateway': gateway,
    'notes': notes,
    'category': category,
    'is_favorite': isFavorite ? 1 : 0,
    'created_at': createdAt,
    'updated_at': updatedAt,
  };

  factory IpAddress.fromMap(Map<String, dynamic> map) => IpAddress(
    id: map['id'] as int?,
    label: map['label'] as String,
    address: map['address'] as String,
    version: map['version'] as String,
    prefix: map['prefix'] as int,
    gateway: map['gateway'] as String?,
    notes: map['notes'] as String?,
    category: (map['category'] as String?) ?? 'Unknown',
    isFavorite: (map['is_favorite'] ?? 0) == 1,
    createdAt: map['created_at'] as int,
    updatedAt: map['updated_at'] as int,
  );

  // Validators
  static bool isValidIPv4(String s) {
    final reg = RegExp(
      r'^((25[0-5]|2[0-4]\d|[01]?\d\d?)\.){3}'
      r'(25[0-5]|2[0-4]\d|[01]?\d\d?)$',
    );
    return reg.hasMatch(s);
  }

  static bool isValidIPv6(String s) {
    final reg = RegExp(
      r'^(([0-9a-fA-F]{1,4}:){7}[0-9a-fA-F]{1,4}|'
      r'([0-9a-fA-F]{1,4}:){1,7}:|'
      r'([0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4}|'
      r'([0-9a-fA-F]{1,4}:){1,5}(:[0-9a-fA-F]{1,4}){1,2}|'
      r'([0-9a-fA-F]{1,4}:){1,4}(:[0-9a-fA-F]{1,4}){1,3}|'
      r'([0-9a-fA-F]{1,4}:){1,3}(:[0-9a-fA-F]{1,4}){1,4}|'
      r'([0-9a-fA-F]{1,4}:){1,2}(:[0-9a-fA-F]{1,4}){1,5}|'
      r'[0-9a-fA-F]{1,4}:((:[0-9a-fA-F]{1,4}){1,6})|'
      r':((:[0-9a-fA-F]{1,4}){1,7}|:))$',
    );
    return reg.hasMatch(s);
  }
}
