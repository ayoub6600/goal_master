class Slide {
  final int id;
  final String name;
  final String? image;
  final String? status;
  final String? description;
  final String? url;

  Slide({
    required this.id,
    required this.name,
    this.image,
    this.status,
    this.description,
    this.url,
  });

  factory Slide.fromJson(Map<String, dynamic> json) {
    return Slide(
      id: json['id'],
      name: json['name'],
      image: json.containsKey('image') ? json['image'] as String? : null,
      status: json.containsKey('status') ? json['status'] as String? : null,
      description: json.containsKey('description')
          ? json['description'] as String?
          : null,
      url: json.containsKey('url') ? json['url'] as String? : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image': image,
      'status': status,
      'description': description,
      'url': url,
    };
  }
}

class SlideData {
  final List<Slide> data;

  SlideData({required this.data});

  factory SlideData.fromJson(Map<String, dynamic> json) {
    var list = json['data'] as List? ?? [];
    List<Slide> slides = list.map((item) => Slide.fromJson(item)).toList();
    return SlideData(data: slides);
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data.map((slide) => slide.toJson()).toList(),
    };
  }
}
