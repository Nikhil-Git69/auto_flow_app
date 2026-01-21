class GuidelinesModel {
  final double leftMargin;
  final double rightMargin;
  final double topMargin;
  final double bottomMargin;
  final double spacing;
  final int fontSize;

  GuidelinesModel({
    required this.leftMargin,
    required this.rightMargin,
    required this.topMargin,
    required this.bottomMargin,
    required this.spacing,
    required this.fontSize,
  });

  factory GuidelinesModel.defaults() {
    return GuidelinesModel(
      leftMargin: 1.0,
      rightMargin: 1.0,
      topMargin: 1.0,
      bottomMargin: 1.0,
      spacing: 1.5,
      fontSize: 12,
    );
  }
  Map<String, dynamic> toJson() => {
    "margin_left": leftMargin,
    "margin_right": rightMargin,
    "margin_top": topMargin,
    "margin_bottom": bottomMargin,
    "spacing": spacing,
    "font_size": fontSize,
  };
}
