import csv


# Acomodar pesos de cada imagen
def process_weight(file_path):
    dict_pesos = {}
    with open(file_path, mode='r', encoding='utf-8') as datos:
        lector = csv.reader(datos)

        for i in lector:
            dict_pesos[i[0]] = i[8]
            
    return dict_pesos        

if __name__ == "__main__":
    file_path = 'dataset.csv'
    dict_pesos = process_weight(file_path)
    print(dict_pesos['BLF2033'])  # Ejemplo de cómo acceder al peso de una imagen específica