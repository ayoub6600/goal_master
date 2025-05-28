class Slide {
  final int id;
  final String name;
  final String image;
  final String status;
  final String description;
  final String url;

  Slide({
    required this.id,
    required this.name,
    required this.image,
    required this.status,
    required this.description,
    required this.url,
  });

  factory Slide.fromJson(Map<String, dynamic> json) {
    return Slide(
      id: json['id'],
      name: json['name'],
      image: json['image'],
      status: json['status'],
      description: json['description'],
      url: json['url'],
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

  SlideData({
    required this.data,
  });

  factory SlideData.fromJson(Map<String, dynamic> json) {
    var list = json['data'] as List;
    List<Slide> slides = list.map((i) => Slide.fromJson(i)).toList();

    return SlideData(
      data: slides,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data.map((slide) => slide.toJson()).toList(),
    };
  }
}
