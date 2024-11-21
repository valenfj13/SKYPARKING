import face_recognition
import cv2
import numpy as np
from flask import Flask, jsonify, request
import serial
import time
from datetime import datetime

app = Flask(__name__)

# Configurar el puerto serial para el Arduino
arduino = serial.Serial(port='COM11', baudrate=9600, timeout=2)  # Cambia 'COM3' por el puerto de tu Arduino
time.sleep(2)  # Esperar a que el puerto serial se inicialice

door_status = "Closed"

# Cargar las imágenes de referencia para el reconocimiento facial
known_face_encodings = []
known_face_data = []

# Lista de usuarios con sus colores asociados
user_data = [
    {
        "image_path": r'C:\Users\VALENTINA\anaconda3\envs\face_recognition_env\Scripts\imagenes\valen.jpg',
        "name": "Valentina Franco Jaramillo",
        "placa": "JQM187",
        "aparque": "A1",
        "color": "Rojo"
    },
    {
        "image_path": r'C:\Users\VALENTINA\anaconda3\envs\face_recognition_env\Scripts\imagenes\dani.jpg',
        "name": "Daniel",
        "placa": "XYZ789",
        "aparque": "B2",
        "color": "Verde"
    },
    {
        "image_path": r'C:\Users\VALENTINA\anaconda3\envs\face_recognition_env\Scripts\imagenes\cris.jpg',
        "name": "Cristian Rodriguez",
        "placa": "FOW676",
        "aparque": "C3",
        "color": "Azul"
    },
    {
        "image_path": r'C:\Users\VALENTINA\anaconda3\envs\face_recognition_env\Scripts\imagenes\eze.jpg',
        "name": "Ezequiel Lopez Perez",
        "placa": "NKO562",
        "aparque": "D2",
        "color": "Negro"
    },
]

# Cargar imágenes y codificaciones
for user in user_data:
    try:
        image = face_recognition.load_image_file(user["image_path"])
        image_encoding = face_recognition.face_encodings(image)[0]
        known_face_encodings.append(image_encoding)
        known_face_data.append(user)
    except IndexError:
        print(f"No se pudo encontrar una cara en la imagen: {user['image_path']}")


@app.route('/startFaceRecognition', methods=['POST'])
def start_face_recognition():
    global door_status
    video_capture = cv2.VideoCapture(0)

    if not video_capture.isOpened():
        return jsonify({'status': 'Camera Error', 'message': 'No se puede acceder a la cámara.'})

    recognized_data = None
    start_time = time.time()
    time_limit = 10

    while True:
        ret, frame = video_capture.read()
        if not ret:
            break

        rgb_frame = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
        face_locations = face_recognition.face_locations(rgb_frame)
        face_encodings = face_recognition.face_encodings(rgb_frame, face_locations)

        for face_encoding in face_encodings:
            matches = face_recognition.compare_faces(known_face_encodings, face_encoding)
            face_distances = face_recognition.face_distance(known_face_encodings, face_encoding)

            if True in matches:
                best_match_index = np.argmin(face_distances)
                recognized_data = known_face_data[best_match_index]

                if face_distances[best_match_index] < 0.6:
                    door_status = "Opened"
                    video_capture.release()
                    cv2.destroyAllWindows()

                    # Controlar el Arduino después del reconocimiento facial
                    handle_parking_process(recognized_data)

                    # Responder a la app con los datos del usuario
                    return jsonify({
                        'status': door_status,
                        'message': f'Cara reconocida: {recognized_data["name"]}.',
                        'data': recognized_data
                    })

        if time.time() - start_time > time_limit:
            break

    video_capture.release()
    cv2.destroyAllWindows()
    return jsonify({'status': 'Closed', 'message': 'No se reconoció ninguna cara.'})


def handle_parking_process(user_data):
    print(f"Usuario reconocido: {user_data['name']} - Color: {user_data['color']}")

    # Abrir la puerta

    send_command_to_arduino('1\n')
    time.sleep(2)

    # Encender el motor
    send_command_to_arduino('2\n')

    # Detectar color
    while True:
        send_command_to_arduino('C\n')  # Solicitar color al Arduino
        detected_color = read_response_from_arduino()
        print(f"Color detectado: {detected_color}")
        if detected_color.lower() == user_data["color"].lower():
            send_command_to_arduino('3\n')  # Detener motor
            print("Color asociado detectado. Deteniendo motor.")
            time.sleep(7)  # Esperar 7 segundos
            send_command_to_arduino('0\n')  # Reanudar motor
            break


def send_command_to_arduino(command):
    arduino.write(command.encode())
    print(f"Comando enviado al Arduino: {command}")
    time.sleep(1)


def read_response_from_arduino():
    if arduino.in_waiting > 0:
        response = arduino.readline().decode().strip()
        return response
    return "Sin respuesta"


@app.route('/closeDoor', methods=['POST'])
def close_door():
    global door_status
    send_command_to_arduino('0')  # Cerrar puerta
    door_status = "Closed"
    return jsonify({'status': door_status, 'message': 'Puerta cerrada correctamente.'})


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5001)
