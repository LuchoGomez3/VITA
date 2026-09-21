import tensorflow as tf
from tensorflow.keras.applications import MobileNetV2
from tensorflow.keras.layers import Dense, GlobalAveragePooling2D
from tensorflow.keras.models import Model

def build_weight_estimation_model(input_shape=(224, 224, 3), dropout_rate=0.2, neurons=512, learning_rate=0.0001):
    # 1. Cargar el modelo base sin la capa final de clasificación
    base_model = MobileNetV2(
        weights='imagenet',
        include_top=False,
        input_shape=input_shape
    )

    # 2. Congelar los pesos iniciales (Feature Extraction)
    # Esto evita destruir las características visuales que la red ya sabe reconocer
    base_model.trainable = False

    # 3. Agregar las capas personalizadas para Regresión (Pesaje)
    x = base_model.output
    x = GlobalAveragePooling2D()(x)
    x = Dense(neurons, activation='relu')(x) # Capa oculta intermedia
    x = tf.keras.layers.Dropout(dropout_rate)(x) # Agregar dropout
    # Capa de salida: 1 sola neurona con activación lineal (devuelve los Kilogramos)
    predictions = Dense(1, activation='linear')(x)

    # 4. Ensamblar el modelo final
    model = Model(inputs=base_model.input, outputs=predictions)

    # 5. Compilar utilizando métricas de error
    model.compile(
        optimizer=tf.keras.optimizers.Adam(learning_rate=learning_rate),
        loss='mse', # Penaliza errores grandes (Error Cuadrático Medio)
        metrics=['mae'] # MAE te dirá por cuántos KG le está errando en promedio
    )
    
    return model

if __name__ == "__main__":
    # Prueba rápida para verificar que compila
    model = build_weight_estimation_model()
    model.summary()