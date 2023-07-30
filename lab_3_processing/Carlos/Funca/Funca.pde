ArrayList<Person> people;
ArrayList<Pillar> pillars;
ArrayList<Wall> walls;
float lastPersonTime = 0;
PVector target;

void setup() {
  size(700, 500);

  // Inicializar la lista de personas
  people = new ArrayList<Person>();

  // Inicializar los pilares y las paredes
  pillars = new ArrayList<Pillar>();
  pillars.add(new Pillar(new PVector(200, 200), 25));
  pillars.add(new Pillar(new PVector(380, 280), 15));

  walls = new ArrayList<Wall>();
  walls.add(new Wall(new PVector(0, 0), new PVector(600, 216)));
  walls.add(new Wall(new PVector(0, 500), new PVector(600, 284)));

  // Definir la posición objetivo (salida)
  target = new PVector(600, 250);
}

void draw() {
  background(255);

  // Dibujar los pilares y paredes
  for (Pillar pillar : pillars) {
    pillar.display();
  }
  
  for (Wall wall : walls) {
    wall.display();
  }

  // Generar una nueva persona cada 2 segundos
  if (millis() - lastPersonTime > 500) {
    float personY = random(15, 485);
    // Añadir una nueva persona a la lista de personas
    people.add(new Person(new PVector(5, personY), random(1, 3), target, pillars, walls, people));
    lastPersonTime = millis();
  }

  // Actualizar y dibujar todas las personas
  for (int i = people.size() - 1; i >= 0; i--) {
    Person person = people.get(i);
    person.update();
    person.display();

    // Verificar si la persona ha llegado a la salida y eliminarla si es el caso
    if (person.position.dist(target) < 10 || person.position.x > width) {
      people.remove(i);
    }
  }
}

class Person {
  PVector position;  // Posición de la persona
  float speed;  // Velocidad de movimiento de la persona
  PVector target;  // Posición objetivo (salida)
  ArrayList<Pillar> pillars;
  ArrayList<Wall> walls;
  ArrayList<Person> people;

  Person(PVector position, float speed, PVector target, ArrayList<Pillar> pillars, ArrayList<Wall> walls, ArrayList<Person> people) {
    this.position = position;
    this.speed = speed;
    this.target = target;
    this.pillars = pillars;
    this.walls = walls;
    this.people = people;
  }

  void update() {
    // Calcula la dirección hacia la salida
    PVector direction = PVector.sub(target, position);
    direction.normalize();

    // Verifica si la persona está chocando con un pilar o una pared
    for (Pillar pillar : pillars) {
      if (isCollidingWithPillar(pillar)) {
        direction = adjustDirectionForCollision(direction);
      }
    }
    
    for (Wall wall : walls) {
      if (isCollidingWithWall(wall)) {
        direction = adjustDirectionForCollision(direction);
      }
    }

    // Verifica si la persona está chocando con otra persona
    for (Person other : people) {
      if (other != this && isCollidingWithPerson(other)) {
        direction = adjustDirectionForCollision(direction);
      }
    }

    // Actualiza la posición de la persona en la dirección hacia la salida
    position.add(PVector.mult(direction, speed));
  }

  void display() {
    fill(255, 0, 0);  // Establece el color de relleno a rojo
    ellipse(position.x, position.y, 15, 15);  // Dibuja la persona
  }

  boolean isCollidingWithPillar(Pillar pillar) {
    // Calcula la distancia entre la posición de la persona y la posición del pilar
    float distance = position.dist(pillar.position);

    // Verifica si la distancia es menor o igual al radio del pilar
    return distance <= pillar.radius;
  }
  
  boolean isCollidingWithWall(Wall wall) {
    return wall.isPointOnWall(position);
  }

  boolean isCollidingWithPerson(Person other) {
    // Calcula la distancia entre la posición de esta persona y la otra
    float distance = position.dist(other.position);

    // Verifica si la distancia es menor o igual a la suma de los radios de las dos personas
    return distance <= 7.5 + 7.5;  // Asumiendo que el radio de una persona es 7.5
  }

  PVector adjustDirectionForCollision(PVector direction) {
    // Calcula la dirección hacia el punto opuesto al objeto con el que se chocó
    PVector oppositeDirection = PVector.sub(position, direction);
    oppositeDirection.normalize();

    // Calcula la dirección perpendicular a la colisión
    PVector perpendicularDirection = new PVector(-oppositeDirection.y, oppositeDirection.x);
    perpendicularDirection.normalize();

    // Combina la dirección hacia el punto opuesto y la dirección perpendicular
    PVector modifiedDirection = PVector.add(oppositeDirection.mult(0.8), perpendicularDirection.mult(0.2));
    modifiedDirection.normalize();

    return modifiedDirection;
  }
}

class Pillar {
  PVector position;  // Posición del pilar
  float radius;  // Radio del pilar

  Pillar(PVector position, float radius) {
    this.position = position;
    this.radius = radius;
  }

  void display() {
    fill(150);  // Establece el color de relleno a gris
    ellipse(position.x, position.y, radius*2, radius*2);  // Dibuja el pilar
  }
}

class Wall {
  PVector start;  // Punto inicial de la pared
  PVector end;  // Punto final de la pared

  Wall(PVector start, PVector end) {
    this.start = start;
    this.end = end;
  }

  void display() {
    stroke(0);  // Establece el color del trazo a negro
    line(start.x, start.y, end.x, end.y);  // Dibuja la pared
  }

  boolean isPointOnWall(PVector point) {
    // Usa la ecuación de la línea para verificar si el punto está en la línea
    float m = (end.y - start.y) / (end.x - start.x);
    float b = start.y - m * start.x;

    return abs(point.y - (m * point.x + b)) < 1.0;
  }
}
