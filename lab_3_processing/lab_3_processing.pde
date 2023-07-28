ArrayList<Person> people;
float lastPersonTime = 0;
PVector target;

void setup() {
  size(700, 500);

  // Inicializar la lista de personas
  people = new ArrayList<Person>();

  // Definir la posición objetivo (salida)
  target = new PVector(600, 250);
}

void draw() {
  background(255);

  // Dibujar las paredes y pilares
  stroke(0);
  fill(200);
  line(0, 0, 600, 216);
  line(0, 500, 600, 284);
  fill(150);
  ellipse(200, 200, 50, 50);
  ellipse(380, 280, 30, 30);

  // Generar una nueva persona cada 5 segundos
  if (millis() - lastPersonTime > 2000) {
    float personY = random(15, 485);
    float personY1 = random(15, 485);
    people.add(new Person(new PVector(5, personY), random(1, 3), target));
    people.add(new Person(new PVector(5, personY1), random(1, 3), target));
    lastPersonTime = millis();
  }

  // Actualizar y dibujar todas las personas
  for (int i = people.size() - 1; i >= 0; i--) {
    Person person = people.get(i);
    person.update();
    person.display();

    // Verificar si la persona ha llegado a la salida y eliminarla si es el caso
    if (person.position.dist(target) < 5 || person.position.x > width) {
      people.remove(i);
    }
  }
}
