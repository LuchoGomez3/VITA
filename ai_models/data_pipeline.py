import tensorflow as tf
import os

# Configuración base (MobileNetV2 exige que las imágenes sean de 224x224)
IMG_HEIGHT = 224
IMG_WIDTH = 224
BATCH_SIZE = 8

      



def process_path(file_path, weight):
    """
    Lee la imagen desde el disco, la decodifica, la redimensiona y la normaliza.
    """
    # 1. Leer el archivo físico
    img = tf.io.read_file(file_path)
    
    # 2. Decodificar el JPEG a un tensor (matriz de píxeles) de 3 canales (RGB)
    img = tf.image.decode_jpeg(img, channels=3)
    
    # 3. Redimensionar a 224x224
    img = tf.image.resize(img, [IMG_HEIGHT, IMG_WIDTH])
    
    # 4. Normalizar los píxeles. MobileNetV2 espera valores entre -1 y 1.
    img = tf.keras.applications.mobilenet_v2.preprocess_input(img)
    
    return img, weight

def augment_image(img, weight):
    """
    Data Augmentation: Aplica transformaciones aleatorias para que el modelo sea más robusto.
    """
    # Voltear la imagen horizontalmente al azar (como un espejo)
    img = tf.image.random_flip_left_right(img)
    # Cambiar levemente el brillo para simular distintos horarios en el campo
    img = tf.image.random_brightness(img, max_delta=0.5)
    
    return img, weight

def create_tf_dataset(image_paths, weights, is_training=True):
    """
    Crea un pipeline de datos ultra eficiente usando tf.data
    """
    # Crear el dataset inicial con las rutas de las fotos y sus pesos exactos
    ds = tf.data.Dataset.from_tensor_slices((image_paths, weights))
    
    # Mapear la función para leer y procesar las imágenes usando los núcleos de la CPU
    ds = ds.map(process_path, num_parallel_calls=tf.data.AUTOTUNE)
    
    if is_training:
        # Aplicar Data Augmentation solo en entrenamiento
        ds = ds.map(augment_image, num_parallel_calls=tf.data.AUTOTUNE)
        # Mezclar los datos para que la red no aprenda el orden de memoria
        ds = ds.shuffle(buffer_size=1000)
    
    # Agrupar en lotes de a 32 imágenes y optimizar la carga (prefetch)
    ds = ds.batch(BATCH_SIZE).prefetch(tf.data.AUTOTUNE)
    
    return ds

