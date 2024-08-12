class AdhkarModel {
  int id;
  int dhikrType;
  String dhikrContent;
  int dhikrRepetition;
  String? dhikrInfo;
  AdhkarModel({
    required this.id,
    required this.dhikrType,
    required this.dhikrContent,
    required this.dhikrRepetition,
    this.dhikrInfo,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'dhikrType': dhikrType,
      'dhikrContent': dhikrContent,
      'dhikrRepetition': dhikrRepetition,
      'dhikrInfo': dhikrInfo,
    };
  }

  factory AdhkarModel.fromMap(Map<String, dynamic> map) {
    return AdhkarModel(
      id: map['id'] as int,
      dhikrType: map['dhikr_type'] as int,
      dhikrContent: map['dhikr_content'] as String,
      dhikrRepetition: map['dhikr_repetition'] as int,
      dhikrInfo: map['dhikr_info'],
    );
  }
}
