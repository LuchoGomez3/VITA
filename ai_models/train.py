import os
import csv
import datetime
import tensorflow as tf
from tensorboard.plugins.hparams import api as hp
from model_builder import build_weight_estimation_model
from data_pipeline import create_tf_dataset

dropout_rate = 0.1
batch_size = 8
neurons = 512
learning_rate = 0.01

HP_DROPOUT = dropout_rate
HP_BATCH_SIZE = batch_size
HP_NEURONS = neurons
HP_LEARNING_RATE = learning_rate

def preparar_datos_entrenamiento():
    dict_pesos = {}
    
    # Leer el CSV
    with open('dataset.csv', mode='r', encoding='utf-8') as datos:
        lector = csv.reader(datos)
        next(lector)  # Saltar la primera fila (cabecera)
        for i in lector:
            dict_pesos[i[0]] = float(i[8])

    # Ruta EXACTA a las imágenes
    downloads_path = os.path.join(os.path.expanduser('~'), 'Downloads', 'images', 'images')

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

def entrenar_con_hparams(hparams, rutas, pesos):
    # Crear dataset inyectando el Batch Size de esta prueba en particular
    dataset_entrenamiento = create_tf_dataset(
        rutas, 
        pesos, 
        is_training=True, 
        batch_size=hparams[HP_BATCH_SIZE]
    )
    
    print(f"🧠 Construyendo modelo con Dropout: {hparams[HP_DROPOUT]}, Batch Size: {hparams[HP_BATCH_SIZE]}, Neuronas: {hparams[HP_NEURONS]}, Tasa de Aprendizaje: {hparams[HP_LEARNING_RATE]}")
    model = build_weight_estimation_model(dropout_rate=hparams[HP_DROPOUT], 
                                          neurons=hparams[HP_NEURONS], 
                                          learning_rate=hparams[HP_LEARNING_RATE])
    
    # Entrenar
    model.fit(
        dataset_entrenamiento,
        epochs=10,
    )

    model.save(f"modelo_pesaje_b{hparams[HP_BATCH_SIZE]}_d{hparams[HP_DROPOUT]}_lr{hparams[HP_LEARNING_RATE]}_n{hparams[HP_NEURONS]}.keras")

def main():
    rutas, pesos = preparar_datos_entrenamiento()
    
    if len(rutas) == 0:
        print("❌ Error: No hay imágenes para entrenar.")
        return

    hparams = {
        HP_DROPOUT: dropout_rate,
        HP_BATCH_SIZE: batch_size,
        HP_NEURONS: neurons,
        HP_LEARNING_RATE: learning_rate
    }
    
    print("-" * 50)
    print(f"--- Iniciando entranamiento con Dropout: {dropout_rate}, Batch Size: {batch_size}, Neuronas: {neurons}, Tasa de Aprendizaje: {learning_rate} ---")
    
    entrenar_con_hparams(hparams, rutas, pesos)
            
    print("💾 ¡Entrenamiento finalizado y guardado!")

if __name__ == "__main__":
    main()