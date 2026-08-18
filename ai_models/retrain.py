import tensorflow as tf
from data_pipeline import create_tf_dataset

# 1. Función para preparar los datos nuevos (igual que en tu train.py)
def preparar_datos_nuevos():
    # Acá cargás tu diccionario con las FOTOS NUEVAS que conseguiste
    # ... tu lógica de escaneo de carpetas ...
    rutas_nuevas = [...] 
    pesos_nuevos = [...]
    return rutas_nuevas, pesos_nuevos

def main():
    rutas, pesos = preparar_datos_nuevos()
    dataset_nuevo = create_tf_dataset(rutas, pesos, is_training=True)

    # 2. 🧠 MAGIA ACÁ: Cargar el modelo que ya entrenaste previamente
    print("Cargando modelo existente...")
    model = tf.keras.models.load_model('modelo_pesaje_base.keras')

    # 3. ⚙️ AJUSTE FINO (Fine-Tuning)
    # Como el modelo ya sabe bastante, le bajamos la "velocidad de aprendizaje" 
    # para que las fotos nuevas sumen conocimiento sin borrar lo que ya aprendió antes.
    model.optimizer.learning_rate.assign(0.0001) # Un paso mucho más chiquito

    # 4. 🚀 Re-entrenar el modelo
    print("Iniciando re-entrenamiento (Fine-Tuning)...")
    history = model.fit(
        dataset_nuevo,
        epochs=10 # Podes probar con menos épocas, ej: 5
    )
    
    # 5. Guardar la versión mejorada (podés pisar el viejo o crear uno nuevo)
    model.save('modelo_pesaje_calibrado_villaminetti.keras')
    print("💾 ¡Modelo re-entrenado y guardado exitosamente!")

if __name__ == "__main__":
    main()