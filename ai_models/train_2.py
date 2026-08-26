import os
import csv
import datetime
import tensorflow as tf
from tensorboard.plugins.hparams import api as hp
from model_builder import build_weight_estimation_model
from data_pipeline import create_tf_dataset

batch_size = 16

def preparar_datos_entrenamiento():
    dict_pesos = {}
    
    # Leer el CSV
    with open('./datasets/dataset_1.csv', mode='r', encoding='utf-8') as datos:
        lector = csv.reader(datos)
        next(lector)  # Saltar la primera fila (cabecera)
        for i in lector:
            dict_pesos[i[0]] = float(i[8])

    # Ruta EXACTA a las imágenes
    downloads_path = os.path.join(os.path.expanduser('D:'), '\Ernesto\Downloads', 'cow_images', 'images')

    image_paths = []
    weights = []

    print("🔍 Escaneando subcarpetas en busca de imágenes...")

    for identificador, peso in dict_pesos.items():
        nombre_carpeta = identificador.replace('_0.jpg', '')
        nombre_archivo = f"{nombre_carpeta}_0.jpg"
        ruta_completa = os.path.join(downloads_path, nombre_carpeta, nombre_archivo)
        
        if os.path.exists(ruta_completa):
            image_paths.append(ruta_completa)
            weights.append(peso)
        else:
            print(f"⚠️ Advertencia: No se encontró la imagen en {ruta_completa}")

    print(f"✅ ¡Listas armadas! Se extrajeron {len(image_paths)} imágenes para entrenar.")
    return image_paths, weights

def main():
    rutas, pesos = preparar_datos_entrenamiento()
    dataset_nuevo = create_tf_dataset(rutas, pesos, is_training=True, batch_size=batch_size)

    if len(rutas) == 0:
        print("❌ Error: No hay imágenes para entrenar.")
        return
    
    print("-" * 50)
    
    
    model = tf.keras.models.load_model('modelo_pesaje_b16_d0.1_lr0.01_n2048.keras')
    
    # model.optimizer.learning_rate.assing(0.0001)
    
    # Entrenar
    model.fit(
        dataset_nuevo,
        epochs=40,
    )

    model.save(f"modelo_pesaje__reentrenado.keras")

            
    print("💾 ¡Entrenamiento finalizado y guardado!")

if __name__ == "__main__":
    main()