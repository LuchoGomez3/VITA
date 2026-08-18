import tensorflow as tf
import os
import numpy as np

# 1. Cargar el "cerebro" que acabás de entrenar
print("🧠 Cargando el modelo de VITA...")
model = tf.keras.models.load_model('modelo_pesaje_base.keras')

def predecir_peso(ruta_imagen):
    if not os.path.exists(ruta_imagen):
        print(f"❌ Error: No se encontró la imagen en {ruta_imagen}")
        return

    # 2. Leer y preparar la imagen exactamente igual que en el entrenamiento
    img = tf.io.read_file(ruta_imagen)
    img = tf.image.decode_jpeg(img, channels=3)
    img = tf.image.resize(img, [224, 224]) # El tamaño que exige MobileNetV2
    img = tf.keras.applications.mobilenet_v2.preprocess_input(img)
    
    # El modelo espera lotes (batches), así que metemos la imagen en un lote de 1 sola foto
    img_batch = tf.expand_dims(img, axis=0)

    # 3. ¡Hacer la predicción!
    print("⏳ Analizando biometría del animal...")
    prediccion = model.predict(img_batch)
    peso_estimado = prediccion[0][0]
    
    print("-" * 40)
    print(f"🐄 RESULTADO VITA: El peso estimado es {peso_estimado:.2f} kg")
    print("-" * 40)

if __name__ == "__main__":
    # TODO: Poné acá la ruta a una foto tuya de prueba (Ideal si sabés cuánto pesa realmente)
    ruta_prueba = r"/home/ernesto/Downloads/images/images/BLF2018/BLF2018_0.jpg" 
    predecir_peso(ruta_prueba)