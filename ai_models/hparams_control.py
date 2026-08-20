import os
import csv
import datetime
import tensorflow as tf
from tensorboard.plugins.hparams import api as hp
from model_builder import build_weight_estimation_model
from data_pipeline import create_tf_dataset

# 1. Definir los hiperparámetros y sus rangos de prueba
#HP_DROPOUT = hp.HParam('dropout', hp.Discrete([0.1, 0.2, 0.3, 0.4, 0.5])) # Probaremos con 10%, 20%, 30%, 40% y 50%
#HP_BATCH_SIZE = hp.HParam('batch_size', hp.Discrete([8, 16, 32])) # Probaremos lotes de 8, 16 y 32
#HP_NEURONS = hp.HParam('neurons', hp.Discrete([512, 1024, 2048])) # Probaremos con 512, 1024 y 2048 neuronas
#HP_LEARNING_RATE = hp.HParam('learning_rate', hp.Discrete([0.0001, 0.001, 0.01])) # Probaremos con 0.0001, 0.001 y 0.01

# Reasignando desde donde se quedo la ejecución anterior
HP_DROPOUT = hp.HParam('dropout', hp.Discrete([0.5])) # Probaremos con 10%, 20%, 30%, 40% y 50%
HP_BATCH_SIZE = hp.HParam('batch_size', hp.Discrete([8, 16, 32])) # Probaremos lotes de 8, 16 y 32
HP_NEURONS = hp.HParam('neurons', hp.Discrete([512, 1024, 2048])) # Probaremos con 512, 1024 y 2048 neuronas
HP_LEARNING_RATE = hp.HParam('learning_rate', hp.Discrete([0.0001, 0.001, 0.01])) # Probaremos con 0.0001, 0.001 y 0.01

#HP_DROPOUT = hp.HParam('dropout', hp.Discrete([0.4, 0.5])) # Probaremos con 10%, 20%, 30%, 40% y 50%
#HP_BATCH_SIZE = hp.HParam('batch_size', hp.Discrete([8, 16, 32])) # Probaremos lotes de 8, 16 y 32
#HP_NEURONS = hp.HParam('neurons', hp.Discrete([512, 1024, 2048])) # Probaremos con 512, 1024 y 2048 neuronas
#HP_LEARNING_RATE = hp.HParam('learning_rate', hp.Discrete([0.0001, 0.001, 0.01])) # Probaremos con 0.0001, 0.001 y 0.01


def preparar_datos_entrenamiento():
    dict_pesos = {}
    
    # Leer el CSV
    with open('./datasets/dataset_1.csv', mode='r', encoding='utf-8') as datos:
        lector = csv.reader(datos)
        next(lector)  # Saltar la primera fila (cabecera)
        for i in lector:
            dict_pesos[i[0]] = float(i[8])

    # Ruta EXACTA a las imágenes
    downloads_path = os.path.join(os.path.expanduser('~'), 'Documents', 'dataset_vita_ai/images_1/', 'images')

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

def entrenar_con_hparams(run_dir, hparams, rutas, pesos):
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

    # Configurar los "espías" de TensorBoard
    tensorboard_callback = tf.keras.callbacks.TensorBoard(
        log_dir=run_dir, 
        histogram_freq=1
    )
    hparams_callback = hp.KerasCallback(run_dir, hparams)

    # Entrenar
    model.fit(
        dataset_entrenamiento,
        epochs=10, # Dejado en 10 para que la prueba total no tarde una eternidad
        callbacks=[tensorboard_callback, hparams_callback]
    )

def main():
    rutas, pesos = preparar_datos_entrenamiento()
    
    if len(rutas) == 0:
        print("❌ Error: No hay imágenes para entrenar.")
        return

    # Limpiar o crear la carpeta maestra de logs
    base_logdir = os.path.join("logs", "hparam_tuning")
    os.makedirs(base_logdir, exist_ok=True)

    print("🚀 Iniciando el Bucle de Búsqueda de Hiperparámetros...")
    session_num = 106
    
    # 2. Bucle Automático: Combina todos los Dropouts con todos los Batch Sizes
    for dropout_rate in HP_DROPOUT.domain.values:
        for batch_size in HP_BATCH_SIZE.domain.values:
            for neurons in HP_NEURONS.domain.values:
                for learning_rate in HP_LEARNING_RATE.domain.values:
                    hparams = {
                        HP_DROPOUT: dropout_rate,
                        HP_BATCH_SIZE: batch_size,
                        HP_NEURONS: neurons,
                        HP_LEARNING_RATE: learning_rate
                    }
            
                    # Nombre único para cada prueba
                    run_name = f"run-{session_num}_drop{dropout_rate}_batch{batch_size}_neurons{neurons}_lr{learning_rate}_{datetime.datetime.now().strftime('%Y%m%d-%H%M%S')}"
                    run_dir = os.path.join(base_logdir, run_name)
                    
                    print("-" * 50)
                    print(f"--- Iniciando experimento: {run_name} ---")
                    
                    entrenar_con_hparams(run_dir, hparams, rutas, pesos)
                    session_num += 1
            
    print("💾 ¡Todas las combinaciones finalizaron exitosamente!")

if __name__ == "__main__":
    main()