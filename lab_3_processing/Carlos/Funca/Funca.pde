//Laboratorio 3
//Integrantes del grupo:
// Bastian Loyola 
// Carlos Retamales
// Fabian Sepulveda

// Estudiar la modelación de grupos de agentes con comportamiento de tipo 
// "flocking" (bandadas de aves, cardúmenes de peces, etc.) y su aplicación
// con la leyes de conducción basada fuerzas de alineación, repulsión y separación.

// Elementos de la simulación:
// - Agentes: Personas
// - Entorno: Paredes y pilares
// - Comportamiento: Leyes de conducción basada en fuerzas de alineación, repulsión y separación

ArrayList<Person> people;
ArrayList<Pillar> pillars;
ArrayList<Wall> walls;

//Constantes de la simulación

float A_i = 25.0; // Alineación
float B_i = 0.08; // Alineación
int k = 750; // Separación
int kappa = 3000; // Separación
float v_0 = 5.0; // Magnitud de la velocidad deseada
float tau = 0.5; // Tiempo de reacción

//Restriccion sistema Reynolds
float v_max = 2.0; // Velocidad máxima
float f_max = 10.0; // Fuerza máxima

//Modelacion de fuerzas
// m_i * dv_i/dt = m_i * v^0_i * e^0_i - v_i / τ_i + Σ[f_ij]_(j≠i) + Σ[f_iw] + Σ[f_ip] 
// donde:
// m_i es la masa de la persona i
// v_i es la velocidad de la persona i
// v^0_i es la velocidad deseada de la persona i
// e^0_i es la dirección deseada de desplazamiento de la persona i
// τ_i es el tiempo caracteristico de movimiento de la persona i
// f_ij es la fuerza ejercida por la persona j sobre la persona i
// f_iw es la fuerza ejercida por la pared w sobre la persona i
// f_ip es la fuerza ejercida por el pilar p sobre la persona i

//Variables

// Paredes
// Pared superior
int position_iniWtopx;
int position_iniWtopy;
int position_finWtopx;
int position_finWtopy;
// Pared inferior
int position_iniWbotx;
int position_iniWboty;
int position_finWbotx;
int position_finWboty;

// Pilares
// Pilar grande
int position_pBx;
int position_pBy;
int radio_pB;
// Pilar pequeño
int position_pSx;
int position_pSy;
int radio_pS;
// Pilar por defecto
int radio_p;

// Personas
// Velocidad inicial de las personas
float person_initV;
// Masa de las personas (se asume que es 1 y no se utiliza)
float personMass;
// Diametro de las personas
int personDiameter;
// Tiempo de creación de una persona
int creationTime;
// X de creación de una persona
int creationX;
// Rango Y de creación de una persona
int creationRange_iniY;
int creationRange_finY;

// Tiempo en milisegundos desde el último ingreso de una persona
float lastPersonTime = 0;

// Posición objetivo (salida) 
PVector target;
PVector target_top;
PVector target_bot;
int target_topx;
int target_topy;
int target_botx;
int target_boty;

// Seteo de la simulación
void setup() {
  
  // Tamaño de la sala de simulación
  size(700, 500);

  // Paredes
  position_iniWtopx = 0;
  position_iniWtopy = 0;
  position_finWtopx = 600;
  position_finWtopy = 216;
  position_iniWbotx = 600;
  position_iniWboty = 284;
  position_finWbotx = 0;
  position_finWboty = 500;

  // Pilares
  position_pBx = 200;
  position_pBy = 200;
  radio_pB = 25;
  position_pSx = 380;
  position_pSy = 280;
  radio_pS = 15;
  radio_p = 20;

  // Personas
  person_initV = 0; // Velocidad inicial de las personas
  personMass = 1;
  personDiameter = 15;
  creationTime = 20;
  creationX = 5;
  creationRange_iniY = 15;
  creationRange_finY = 485;

  //Target (salida) top y bot
  target_topx = 600;
  target_topy = 224;
  target_botx = 600;
  target_boty = 276;


  // Inicializar la lista de personas
  people = new ArrayList<Person>();

  // Inicializar los pilares y las paredes
  pillars = new ArrayList<Pillar>();
  pillars.add(new Pillar(new PVector(position_pBx, position_pBy), radio_pB));
  pillars.add(new Pillar(new PVector(position_pSx, position_pSy), radio_pS));

  walls = new ArrayList<Wall>();
  walls.add(new Wall(new PVector(position_iniWtopx, position_iniWtopy), new PVector(position_finWtopx, position_finWtopy)));
  walls.add(new Wall(new PVector(position_iniWbotx, position_iniWboty), new PVector(position_finWbotx, position_finWboty)));

  // Definir la posición objetivo (salida)
  target_top = new PVector(target_topx, target_topy);
  target_bot = new PVector(target_botx, target_boty);
}

// Dibujar la simulación
void draw() {
  
  //Color de las personas
  fill(0, 0, 255);

  // Fondo blanco
  background(255);

  // Dibujar los pilares y paredes
  for (Pillar pillar : pillars) {
    pillar.display();
  }
  
  for (Wall wall : walls) {
    wall.display();
  }

  // Generar una nueva persona cada cierto tiempo
  if (millis() - lastPersonTime > creationTime) {
    float personY = random(creationRange_iniY, creationRange_finY);
    // Verificar su posicion en Y para definir su target
    if (personY < position_finWtopy) {
      target = target_top;
    } else {
      if (personY > position_iniWboty) {
        target = target_bot;
      }
      else {
        target = new PVector((target_top.x+target_bot.x)/2, (target_top.y+target_bot.y)/2);
      }
    }

    // Añadir una nueva persona a la lista de personas
    people.add(new Person(new PVector(creationX, personY), person_initV, personMass, personDiameter, target, pillars, walls, people));
    lastPersonTime = millis();
  }

  // Actualizar y dibujar todas las personas
  for (int i = people.size() - 1; i >= 0; i--) {
    Person person = people.get(i);
    person.update();
    person.display();

    // Verificar si la persona ha llegado a la salida y eliminarla si es el caso
    if (person.position.dist(target) < 5 || person.position.x > width || person.position.y > height || person.position.y < 0 || person.position.x > max(target_topx, target_botx)) {
      people.remove(i);
    }
  }
}

// Añadir un nuevo pilar al hacer click derecho
void mousePressed() {
  // Verificar si se ha presionado el botón derecho del ratón
  if (mouseButton == RIGHT) {
    // Añadir un nuevo pilar en la posición del ratón
    pillars.add(new Pillar(new PVector(mouseX, mouseY), radio_p));
  }
}

// Clase Persona
class Person {
  PVector position;  // Posición de la persona
  float speed;  // Velocidad de movimiento de la persona
  float mass;  // Masa de la persona
  int diameter;  // Diámetro de la persona
  PVector target;  // Posición objetivo (salida)
  ArrayList<Pillar> pillars;
  ArrayList<Wall> walls;
  ArrayList<Person> people;

  Person(PVector position, float speed, float mass, int diameter, PVector target, ArrayList<Pillar> pillars, ArrayList<Wall> walls, ArrayList<Person> people) {
    this.position = position;
    this.speed = speed;
    this.mass = mass;
    this.diameter = diameter;
    this.target = target;
    this.pillars = pillars;
    this.walls = walls;
    this.people = people;
  }

  // Dibujar la persona
  void update() {
    // Calcular la dirección hacia la salida
    PVector direction = PVector.sub(target, position);
    direction.normalize();

    // Verificar si la persona está chocando con algún pilar
    for (Pillar pillar : pillars) {
      if (isCollidingWithPillar(pillar)) {
        // Calcular la dirección opuesta al pilar
        PVector oppositeDirection = PVector.sub(position, pillar.position);
        oppositeDirection.normalize();

        // Calcular la dirección perpendicular a la colisión
        PVector perpendicularDirection = new PVector(-oppositeDirection.y, oppositeDirection.x);
        perpendicularDirection.normalize();

        // Si la persona está a la izquierda del pilar, invertir la dirección perpendicular
        if (position.x < pillar.position.x) {
          perpendicularDirection.mult(-1);
        }

        // Combinar la dirección opuesta al pilar y la dirección perpendicular
        PVector modifiedDirection = PVector.add(oppositeDirection.mult(0.8), perpendicularDirection.mult(0.2));
        modifiedDirection.normalize();

        // Modificar la dirección de la persona
        direction = modifiedDirection;
      }
    }

    // Verificar si la persona está chocando con alguna otra persona
    for (Person other : people) {
      if (other != this && isCollidingWithPerson(other)) {
        // Calcular la dirección opuesta a la otra persona
        PVector oppositeDirection = PVector.sub(position, other.position);
        oppositeDirection.normalize();

        // Ajustar la dirección de la persona para alejarse de la otra persona
        direction.add(oppositeDirection);
        direction.normalize();
      }
    }

    //Calcular la direccion deseada de desplazamiento
    PVector e_0 = PVector.sub(target, position);
    e_0.normalize();
    
    //Calcular la suma de las fuerzas ejercidas por las otras persona, paredes y pilares
    PVector sumForces = new PVector(0, 0);
    for (Person other : people) {
      if (other != this) {
        sumForces.add(calculateForceWithPerson(other));
      }
    }
    for (Wall wall : walls) {
      sumForces.add(calculateForceWithWall(wall));
    }
    for (Pillar pillar : pillars) {
      sumForces.add(calculateForceWithPillar(pillar));
    }

    //Calcular la aceleracion en base a la ecuacion de fuerza
    PVector acceleration = PVector.mult(e_0, v_0);
    PVector subtractedVector = new PVector(speed / tau, speed / tau);
    acceleration.sub(subtractedVector);
    acceleration.add(sumForces);

    // Actualizar la velocidad de la persona
    speed += acceleration.mag() * tau;
    speed = constrain(speed, 0, v_max);  // Limitamos la velocidad entre 0 y v_max

    // Actualizar la posición de la persona en la dirección hacia la salida
    position.add(PVector.mult(direction, speed));
  }

  // Dibujar la persona
  void display() {
    fill(255, 0, 0);  // Establece el color de relleno a rojo
    ellipse(position.x, position.y, diameter, diameter);  // Dibuja un círculo en la posición de la persona
  }

  // Verificar si la persona está chocando con un pilar
  boolean isCollidingWithPillar(Pillar pillar) {
    // Calcula la distancia entre la posición de la persona y la posición del pilar
    float distance = position.dist(pillar.position);

    // Verifica si la distancia es menor o igual al radio del pilar
    return distance <= pillar.radius;
  }
  
  // Verificar si la persona está chocando con una pared
  boolean isCollidingWithWall(Wall wall) {
    return wall.isPointOnWall(position);
  }

  // Verificar si la persona está chocando con otra persona
  boolean isCollidingWithPerson(Person other) {
    // Calcula la distancia entre la posición de esta persona y la otra
    float distance = position.dist(other.position);

    // Verifica si la distancia es menor o igual a la suma de los radios de las dos personas
    return distance <= diameter / 2 + other.diameter / 2;
  }

  // Ajustar la dirección de la persona por una colisión
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

  //Calcular fuerza entre dos personas
  PVector calculateForceWithPerson(Person other) {
    // Calcular la dirección entre las dos personas
    PVector direction = PVector.sub(other.position, position);
    float distance = direction.mag();
    direction.normalize();

    float forceMagnitude = A_i / (distance + B_i);
    return PVector.mult(direction, forceMagnitude);
  }

  // Calcular la fuerza de repulsión entre la persona y un pilar
  PVector calculateForceWithPillar(Pillar pillar) {
    // Calcular la dirección entre la persona y el pilar
    PVector direction = PVector.sub(pillar.position, position);
    float distance = direction.mag();
    direction.normalize();

    float forceMagnitude = k / (distance + kappa);
    return PVector.mult(direction, forceMagnitude);
  }

    // Calcular la fuerza de repulsión entre la persona y una pared
  PVector calculateForceWithWall(Wall wall) {
    // Calcular la dirección entre la persona y la pared
    PVector direction = wall.getNormal(position);
    direction.normalize();

    // Calcular la distancia entre la persona y la pared
    float distance = wall.getDistance(position);

    // Calcular la fuerza de repulsión
    float forceMagnitude = k / (distance + kappa);

    // Devolver el vector de fuerza resultante
    return PVector.mult(direction, forceMagnitude);
  }


}

// Clase Pilar
class Pillar {
  PVector position;  // Posición del pilar
  float radius;  // Radio del pilar

  Pillar(PVector position, float radius) {
    this.position = position;
    this.radius = radius;
  }

  // Dibujar el pilar
  void display() {
    fill(150);  // Establece el color de relleno a gris
    ellipse(position.x, position.y, radius*2, radius*2);  // Dibuja el pilar
  }
}

// Clase Pared
class Wall {
  PVector start;  // Punto inicial de la pared
  PVector end;  // Punto final de la pared

  Wall(PVector start, PVector end) {
    this.start = start;
    this.end = end;
  }

  // Dibujar la pared
  void display() {
    stroke(0);  // Establece el color del trazo a negro
    line(start.x, start.y, end.x, end.y);  // Dibuja la pared
  }
  // Calcular la normal de la pared
  PVector getNormal(PVector position) {
    PVector wallDirection = PVector.sub(end, start);
    PVector wallToPosition = PVector.sub(position, start);
    
    float dotProduct = wallDirection.dot(wallToPosition);
    
    // Proyección del punto sobre la línea de la pared
    PVector projectedPoint = PVector.add(start, PVector.mult(wallDirection, dotProduct / wallDirection.magSq()));
    
    // Normal desde el punto a la línea de la pared
    PVector normal = PVector.sub(position, projectedPoint);
    
    return normal;
  }
  
  // Calcular la distancia desde el punto hasta la pared
  float getDistance(PVector position) {
    return getNormal(position).mag();
  }

  boolean isPointOnWall(PVector point) {
    // Usa la ecuación de la línea para verificar si el punto está en la línea
    float m = (end.y - start.y) / (end.x - start.x);
    float b = start.y - m * start.x;

    return abs(point.y - (m * point.x + b)) < 1.0;
  }
}
