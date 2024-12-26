class LedProgram {
  final String name;
  final List<int> program;

  LedProgram({required this.name, required this.program});

  factory LedProgram.fromJson(Map<String, dynamic> json) => LedProgram(
        name: json['name'],
        program: json['program'].cast<int>(),
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'program': program,
      };
}
