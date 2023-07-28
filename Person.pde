class Person {
  PVector position;  // Posición de la persona
  float speed;  // Velocidad de movimiento de la persona
  PVector target;  // Posición objetivo (salida)

  Person(PVector position, float speed, PVector target) {
    this.position = position;
    this.speed = speed;
    this.target = target;
  }

  void update() {
    // Calcula la dirección hacia la salida
    PVector direction = PVector.sub(target, position);
    direction.normalize();

    // Actualiza la posición de la persona en la dirección hacia la salida
    position.add(PVector.mult(direction, speed));
  }

  void display() {
    fill(255, 0, 0);  // Establece el color de relleno a rojo
    ellipse(position.x, position.y, 15, 15);  // Dibuja la persona
  }
}
