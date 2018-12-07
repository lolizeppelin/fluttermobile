var now = DateTime.now();

void main() {
  const Map<String, String> loli = {'aaa': 'bbb'};

  var b = Map<String, String>.from(loli);
  b.addAll({'c': 'ddd'});
  print(b);
}