class DesignShape {
  final String id;
  final String type;
  final double x;
  final double y;
  final double width;
  final double height;
  final Map<String, dynamic> raw;

  const DesignShape({
    required this.id,
    required this.type,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.raw,
  });

  factory DesignShape.fromJson(Map<String, dynamic> json) {
    return DesignShape(
      id: json['id']?.toString() ?? '',
      type: json['type']?.toString() ?? 'unknown',
      x: (json['x'] as num?)?.toDouble() ?? 0,
      y: (json['y'] as num?)?.toDouble() ?? 0,
      width: (json['width'] as num?)?.toDouble() ?? 50,
      height: (json['height'] as num?)?.toDouble() ?? 50,
      raw: Map<String, dynamic>.from(json),
    );
  }
}

class DesignMetadata {
  final String name;
  final int shapeCount;
  final String? version;

  const DesignMetadata({required this.name, required this.shapeCount, this.version});

  factory DesignMetadata.fromJson(Map<String, dynamic> json) {
    return DesignMetadata(
      name: json['name']?.toString() ?? 'Untitled Design',
      shapeCount: (json['shapeCount'] as num?)?.toInt() ?? 0,
      version: json['version']?.toString(),
    );
  }
}

class DesignUploadResponse {
  final String designId;
  final DesignMetadata metadata;
  final List<DesignShape> shapes;
  final List<String> parseWarnings;

  const DesignUploadResponse({
    required this.designId,
    required this.metadata,
    required this.shapes,
    required this.parseWarnings,
  });

  factory DesignUploadResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;
    return DesignUploadResponse(
      designId: data['designId']?.toString() ?? '',
      metadata: DesignMetadata.fromJson(data['metadata'] ?? {}),
      shapes: (data['shapes'] as List<dynamic>? ?? [])
          .map((s) => DesignShape.fromJson(s as Map<String, dynamic>))
          .toList(),
      parseWarnings: List<String>.from(data['parseWarnings'] ?? []),
    );
  }
}
