import tensorflow as tf
from data_pipeline import create_tf_dataset
import os, csv


batch_size = 8

# 1. Función para preparar los datos nuevos (igual que en tu train.py)
def preparar_datos_nuevos():
    dict_pesos = {}
        
    # Leer el CSV
    with open('./datasets/measurements.csv', mode='r', encoding='utf-8') as datos:
        lector = csv.reader(datos)
        next(lector)  # Saltar la primera fila (cabecera)
        for i in lector:
            dict_pesos[i[0]] = float(i[5])

    # Ruta EXACTA a las imágenes /home/ernesto/Documents/dataset_vita_ai/images_2/Cattle side and back view images/side view
    downloads_path = os.path.join(os.path.expanduser('~'), 'Documents', 'dataset_vita_ai/images_2/Cattle side and back view images', 'side view')

    image_paths = []
    weights = []

    print("🔍 Escaneando subcarpetas en busca de imágenes...")

    for identificador, peso in dict_pesos.items():
        nombre_archivo = f"{identificador}.png"
        ruta_completa = os.path.join(downloads_path, nombre_archivo)
        
        if os.path.exists(ruta_completa):
            image_paths.append(ruta_completa)
            weights.append(peso)
        else:
            print(f"⚠️ Advertencia: No se encontró la imagen en {ruta_completa}")

    print(f"✅ ¡Listas armadas! Se extrajeron {len(image_paths)} imágenes para entrenar.")
    return image_paths, weights

def main():
    rutas, pesos = preparar_datos_nuevos()
    dataset_nuevo = create_tf_dataset(rutas, pesos, is_training=True, batch_size=batch_size)

    # 2. 🧠 MAGIA ACÁ: Cargar el modelo que ya entrenaste previamente
    print("Cargando modelo existente...")
    model = tf.keras.models.load_model('modelo_pesaje_b16_d0.1_lr0.01_n2048.keras')

    # 3. ⚙️ AJUSTE FINO (Fine-Tuning)
    # Como el modelo ya sabe bastante, le bajamos la "velocidad de aprendizaje" 
    # para que las fotos nuevas sumen conocimiento sin borrar lo que ya aprendió antes.
    model.optimizer.learning_rate.assign(0.0001) # Un paso mucho más chiquito

    # 4. 🚀 Re-entrenar el modelo
    print("Iniciando re-entrenamiento (Fine-Tuning)...")
    history = model.fit(
        dataset_nuevo,
        epochs=20 # Podes probar con menos épocas, ej: 5
    )
    
    # 5. Guardar la versión mejorada (podés pisar el viejo o crear uno nuevo)
    model.save('modelo_pesaje_calibrado_villaminetti.keras')
    print("💾 ¡Modelo re-entrenado y guardado exitosamente!")

if __name__ == "__main__":
    main()