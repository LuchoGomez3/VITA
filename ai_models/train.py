import os
import tensorflow as tf
from model_builder import build_weight_estimation_model
from data_pipeline import create_tf_dataset
import csv

# TODO: Importá acá la función que creaste vos
# from tu_archivo import funcion_que_devuelve_diccionario

def preparar_datos_entrenamiento():
    # 1. Llamás a tu función que devuelve el diccionario
    # weights_dict = funcion_que_devuelve_diccionario()
    
    
    # Acomodar pesos de cada imagen

    dict_pesos = {}
    with open('dataset.csv', mode='r', encoding='utf-8') as datos:
        lector = csv.reader(datos)
        lector.__next__()  # Saltar la primera fila (cabecera)
        for i in lector:
            dict_pesos[i[0]] = float(i[8])

  
    # 2. Definí la ruta EXACTA donde está la carpeta principal que contiene a todas estas subcarpetas.
    # Reemplazá 'Dataset_Bovinos' por el nombre de la carpeta real en tus Descargas
    downloads_path = os.path.join(os.path.expanduser('~'), 'Downloads/images', 'images')

    image_paths = []
    weights = []

    print("🔍 Escaneando subcarpetas en busca de imágenes...")

    # 3. Iteramos sobre tu diccionario
    for identificador, peso in dict_pesos.items():
        # Por si tu función devolvió 'BLF2001_0.jpg' en vez de 'BLF2001', lo limpiamos:
        nombre_carpeta = identificador.replace('_0.jpg', '')
        
        # Armamos el nombre del archivo según tu regla
        nombre_archivo = f"{nombre_carpeta}_0.jpg"
        
        # MAGIA ACÁ: Unimos la ruta principal + nombre de subcarpeta + nombre del archivo
        # Quedaría algo como: C:\Users\Ernesto\Downloads\Dataset_Bovinos\BLF2001\BLF2001_0.jpg
        ruta_completa = os.path.join(downloads_path, nombre_carpeta, nombre_archivo)
        
        # Validamos que la imagen realmente exista en esa subcarpeta
        if os.path.exists(ruta_completa):
            image_paths.append(ruta_completa)
            weights.append(peso)
        else:
            print(f"⚠️ Advertencia: No se encontró la imagen en {ruta_completa}")

    print(f"✅ ¡Listas armadas! Se extrajeron {len(image_paths)} imágenes de las subcarpetas para entrenar.")
    return image_paths, weights

def main():
    # 1. Preparar las listas con tus datos
    rutas, pesos = preparar_datos_entrenamiento()
    
    if len(rutas) == 0:
        print("❌ Error: No hay imágenes para entrenar. Revisá la carpeta de Descargas.")
        return

    # 2. Crear el pipeline de datos optimizado (el que armamos en data_pipeline.py)
    dataset_entrenamiento = create_tf_dataset(rutas, pesos, is_training=True)

    # 3. Traer la arquitectura de la red neuronal (MobileNetV2 adaptada)
    print("🧠 Construyendo el modelo...")
    model = build_weight_estimation_model()

    # 4. ¡ARRANCAR EL ENTRENAMIENTO! (Fase 1)
    # epochs=10 significa que va a repasar todas las imágenes 10 veces para aprender
    print("🚀 Iniciando entrenamiento...")
    history = model.fit(
        dataset_entrenamiento,
        epochs=160
    )
    
    # 5. Guardar el modelo entrenado para usarlo después
    model.save('modelo_pesaje_base.keras')
    print("💾 Modelo guardado exitosamente como 'modelo_pesaje_base.keras'")

if __name__ == "__main__":
    main()