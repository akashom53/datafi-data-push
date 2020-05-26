class FieldModel {
  String name;
  String type;
  String options;

  String get typeKey => TYPE_KEY[type];

  bool get isEmpty {
    return (name == null || name.length == 0) &&
        (type == null || type.length == 0);
  }

  bool get isValid {
    bool valid =
        name != null && name.length > 0 && type != null && type.length > 0;

    return type == "dropdown"
        ? valid && (options != null && options.length > 0)
        : valid;
  }



  static const List<String> TYPES = [
    "text",
    "chekcbox",
    "dropdown",
    "image",
    "video",
    "signature",
    "ratings",
    "location",
    "date",
    "time",
  ];

  static const Map<String, String> TYPE_KEY = {
    "text": "text_field",
    "chekcbox": "checkbox",
    "dropdown": "multiple",
    "image": "image",
    "video": "video",
    "signature": "signature",
    "ratings": "ratings",
    "location": "location",
    "date": "date_field",
    "time": "time_field",
  };
}

class SectionModel {
  String name;
  List<FieldModel> fields = [];

  bool get isEmpty => (name == null || name.length == 0) && fields.length == 0;
}
