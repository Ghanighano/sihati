class Doctor {
  Doctor({
    required this.id,
    required this.name,
    required this.specialty,
    required this.wilaya,
    required this.commune,
    required this.address,
    required this.phone,
    required this.approved,
    this.rating = 0,
    this.ratingCount = 0,
  });

  final String id;
  final String name;
  final String specialty;
  final String wilaya;
  final String commune;
  final String address;
  final String phone;
  final bool approved;

  final double rating;
  final int ratingCount;
}
