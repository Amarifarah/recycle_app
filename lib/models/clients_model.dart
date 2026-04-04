// lib/models/clients_model.dart
class Client {
  final String id;
  final String name;
  final String email;
  final String phone;
  final int bottles;
  final double weight;
  final int points;
  final String registrationDate;
  final String status;

  Client({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.bottles,
    required this.weight,
    required this.points,
    required this.registrationDate,
    required this.status,
  });
}

// Liste mock de clients
final List<Client> clientsMock = [
  Client(
    id: "001",
    name: "Jean Dupont",
    email: "jean@mail.com",
    phone: "0601020304",
    bottles: 145,
    weight: 12.5,
    points: 1450,
    registrationDate: "12/01/2024",
    status: "Actif",
  ),
  Client(
    id: "002",
    name: "Marie Curie",
    email: "marie@science.fr",
    phone: "0611223344",
    bottles: 89,
    weight: 7.2,
    points: 890,
    registrationDate: "05/02/2024",
    status: "Actif",
  ),
  Client(
    id: "003",
    name: "Luc Lucas",
    email: "luc@sky.com",
    phone: "0788990011",
    bottles: 12,
    weight: 1.1,
    points: 120,
    registrationDate: "10/02/2024",
    status: "Inactif",
  ),
  Client(
    id: "004",
    name: "Sophie Martin",
    email: "s.martin@web.com",
    phone: "0645454545",
    bottles: 340,
    weight: 28.0,
    points: 3400,
    registrationDate: "01/12/2023",
    status: "Actif",
  ),
  Client(
    id: "005",
    name: "Thomas Durand",
    email: "t.durand@mail.com",
    phone: "0699887766",
    bottles: 5,
    weight: 0.4,
    points: 50,
    registrationDate: "14/02/2024",
    status: "Suspendu",
  ),
  Client(
    id: "006",
    name: "Léa Bernard",
    email: "lea.b@service.fr",
    phone: "0712345678",
    bottles: 210,
    weight: 18.5,
    points: 2100,
    registrationDate: "20/01/2024",
    status: "Actif",
  ),
  Client(
    id: "007",
    name: "Paul Lefebvre",
    email: "paul.l@orange.fr",
    phone: "0600112233",
    bottles: 0,
    weight: 0.0,
    points: 0,
    registrationDate: "15/02/2024",
    status: "Actif",
  ),
  Client(
    id: "008",
    name: "Julie Morel",
    email: "julie.m@yahoo.fr",
    phone: "0677889900",
    bottles: 45,
    weight: 3.8,
    points: 450,
    registrationDate: "10/01/2024",
    status: "Inactif",
  ),
];
