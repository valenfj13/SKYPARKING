#include <Servo.h>

// Pines del sensor de color TCS3200
#define S2 4
#define S3 5
#define OUT 6

// Pines del relé y servo
#define RELAY_PIN 8    // Relé que controla el motor
#define SERVO_PIN 10   // Servo que controla la puerta

// Umbrales para los colores
const int RED_THRESHOLD = 30;
const int GREEN_THRESHOLD = 50;
const int BLUE_THRESHOLD = 70;

// Códigos para los colores
const int COLOR_BLACK = 0;
const int COLOR_RED = 1;
const int COLOR_GREEN = 2;
const int COLOR_BLUE = 3;
const int COLOR_UNKNOWN = -1;

// Variables globales
Servo servo;                   // Control del servo
int detectedColor = COLOR_UNKNOWN; // Último color detectado
bool doorOpen = false;         // Estado de la puerta
bool motorRunning = false;     // Estado del motor

void setup() {
  // Configuración de pines
  pinMode(S2, OUTPUT);
  pinMode(S3, OUTPUT);
  pinMode(OUT, INPUT);
  pinMode(RELAY_PIN, OUTPUT);

  // Relé apagado al inicio
  digitalWrite(RELAY_PIN, HIGH);

  // Inicializar el servo
  servo.attach(SERVO_PIN);
  servo.write(0);  // Puerta cerrada al inicio

  // Inicializar comunicación serial
  Serial.begin(9600);
  Serial.println("Arduino listo para recibir comandos.");
}

void loop() {
  // Verificar si hay comandos disponibles desde Python
  if (Serial.available() > 0) {
    char command = Serial.read();  // Leer comando enviado por Python

    switch (command) {
      case '1':  // Abrir la puerta
        openDoor();
        break;
      case '2':  // Encender el motor
        startMotor();
        break;
      case '3':  // Detener el motor
        stopMotor();
        break;
      case 'C':  // Detectar color
        detectedColor = readColor();
        sendColorToPython();
        break;
      case '0':  // Cerrar la puerta
        closeDoor();
        break;
      default:
        Serial.println("Comando desconocido recibido.");
    }
  }
}

// Función para abrir la puerta
void openDoor() {
  if (!doorOpen) {
    servo.write(180);  // Abrir la puerta
    doorOpen = true;
    Serial.println("Puerta abierta.");
  }
}

// Función para cerrar la puerta
void closeDoor() {
  if (doorOpen) {
    servo.write(0);  // Cerrar la puerta
    doorOpen = false;
    Serial.println("Puerta cerrada.");
  }
}

// Función para encender el motor
void startMotor() {
  if (!motorRunning) {
    digitalWrite(RELAY_PIN, LOW);  // Activar el relé
    motorRunning = true;
    Serial.println("Motor encendido.");
  }
}

// Función para detener el motor
void stopMotor() {
  if (motorRunning) {
    digitalWrite(RELAY_PIN, HIGH);  // Desactivar el relé
    motorRunning = false;
    Serial.println("Motor detenido.");
  }
}

// Función para leer el color detectado
int readColor() {
  int red, green, blue;

  // Leer el rojo
  digitalWrite(S2, LOW);
  digitalWrite(S3, LOW);
  red = pulseIn(OUT, LOW);

  // Leer el verde
  digitalWrite(S2, HIGH);
  digitalWrite(S3, HIGH);
  green = pulseIn(OUT, LOW);

  // Leer el azul
  digitalWrite(S2, LOW);
  digitalWrite(S3, HIGH);
  blue = pulseIn(OUT, LOW);

  // Determinar el color detectado
  if (red < green && red < blue && red < RED_THRESHOLD) {
    return COLOR_RED;
  }
  if (green < red && green < blue && green < GREEN_THRESHOLD) {
    return COLOR_GREEN;
  }
  if (blue < red && blue < green && blue < BLUE_THRESHOLD) {
    return COLOR_BLUE;
  }
  if (red > RED_THRESHOLD && green < GREEN_THRESHOLD && blue < BLUE_THRESHOLD) {
    return COLOR_BLACK;  // Asumir negro para frecuencias altas
  }
  return COLOR_UNKNOWN;  // Ningún color claro detectado
}

// Función para enviar el color detectado a Python
void sendColorToPython() {
  switch (detectedColor) {
    case COLOR_BLACK:
      Serial.println("Negro");
      break;
    case COLOR_RED:
      Serial.println("Rojo");
      break;
    case COLOR_GREEN:
      Serial.println("Verde");
      break;
    case COLOR_BLUE:
      Serial.println("Azul");
      break;
    default:
      Serial.println("Desconocido");
      break;
  }
}
