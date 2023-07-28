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

  // Verifica si la persona está chocando con alguno de los pilares
  if (isCollidingWithPillar(new PVector(200, 200), 30) || isCollidingWithPillar(new PVector(380, 280), 15)) {
    // Calcula la dirección hacia el punto opuesto al pilar
    PVector oppositeDirection = PVector.sub(position, target);
    oppositeDirection.normalize();

    // Calcula la dirección perpendicular a la colisión
    PVector perpendicularDirection = new PVector(-oppositeDirection.y, oppositeDirection.x);
    perpendicularDirection.normalize();

    // Combina la dirección hacia el punto opuesto al pilar y la dirección perpendicular
    PVector modifiedDirection = PVector.add(oppositeDirection.mult(0.8), perpendicularDirection.mult(0.2));
    modifiedDirection.normalize();

    // Modifica la dirección de la persona
    direction = modifiedDirection;
  }

  // Actualiza la posición de la persona en la dirección hacia la salida
  position.add(PVector.mult(direction, speed));
}


  void display() {
    fill(255, 0, 0);  // Establece el color de relleno a rojo
    ellipse(position.x, position.y, 15, 15);  // Dibuja la persona
  }

  boolean isCollidingWithPillar(PVector pillarPosition, float pillarRadius) {
    // Calcula la distancia entre la posición de la persona y la posición del pilar
    float distance = position.dist(pillarPosition);

    // Verifica si la distancia es menor o igual al radio del pilar
    if (distance <= pillarRadius) {
      return true;  // Hay colisión
    } else {
      return false; // No hay colisión
    }
  }
}
