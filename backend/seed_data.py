"""
Script de datos semilla para la base de datos ItinerariosDB.
Inserta categorías y destinos turísticos de Ica.

Uso:
    cd backend
    python seed_data.py

Requiere que la base de datos y las tablas ya estén creadas.
"""

from decimal import Decimal

from database import SessionLocal, engine
import models

# ---------- Categorías ----------
CATEGORIAS = [
    {"nombre": "Natural", "descripcion": "Destinos de naturaleza y paisajes"},
    {"nombre": "Cultural", "descripcion": "Destinos culturales e históricos"},
    {"nombre": "Religioso", "descripcion": "Destinos de carácter religioso"},
    {"nombre": "Aventura", "descripcion": "Destinos para deportes extremos y aventura"},
    {"nombre": "Enoturismo", "descripcion": "Destinos relacionados con vinos y piscos"},
]

# ---------- Destinos turísticos de Ica ----------
DESTINOS = [
    {
        "nombre": "Laguna de Huacachina",
        "descripcion": "Oasis natural rodeado de dunas, ideal para sandboard y paseos en tubular.",
        "ubicacion": "Huacachina, Ica, Perú",
        "horario": "Abierto todo el día",
        "precio_entrada": Decimal("0"),
        "actividad": "Sandboarding",
        "categoria": "Natural",
    },
    {
        "nombre": "Parque Temático de Cachiche",
        "descripcion": "Parque temático basado en leyendas locales, con la famosa escultura de la bruja de Cachiche.",
        "ubicacion": "Cachiche, Ica, Perú",
        "horario": "8:00 AM - 6:00 PM",
        "precio_entrada": Decimal("0"),
        "actividad": "Cultura y leyendas",
        "categoria": "Cultural",
    },
    {
        "nombre": "Hacienda Tacama",
        "descripcion": "La bodega más antigua de América, especializada en la producción de vinos y piscos premium.",
        "ubicacion": "La Tacama, Ica, Perú",
        "horario": "9:00 AM - 5:00 PM",
        "precio_entrada": Decimal("0"),
        "actividad": "Cata de vinos y piscos",
        "categoria": "Enoturismo",
    },
    {
        "nombre": "Cañón de los Perdidos",
        "descripcion": "Impresionante cañón con paredes de roca ideales para rappel, caminatas y deportes extremos.",
        "ubicacion": "Los Aquijes, Ica, Perú",
        "horario": "7:00 AM - 4:00 PM",
        "precio_entrada": Decimal("0"),
        "actividad": "Rappel y aventura",
        "categoria": "Aventura",
    },
    {
        "nombre": "Santuario del Señor de Luren",
        "descripcion": "Templo principal de Ica que alberga la imagen del Señor de Luren, patrón de la ciudad.",
        "ubicacion": "Centro de Ica, Perú",
        "horario": "6:00 AM - 8:00 PM",
        "precio_entrada": Decimal("0"),
        "actividad": "Peregrinación religiosa",
        "categoria": "Religioso",
    },
    {
        "nombre": "Bosque de Piedras",
        "descripcion": "Formaciones rocosas naturales con figuras caprichosas esculpidas por el viento y el tiempo.",
        "ubicacion": "Subtanjalla, Ica, Perú",
        "horario": "8:00 AM - 5:00 PM",
        "precio_entrada": Decimal("0"),
        "actividad": "Caminata y exploración",
        "categoria": "Natural",
    },
    {
        "nombre": "Palmera de las 7 Cabezas",
        "descripcion": "Palmera datilera única en el mundo con siete cabezas, considerada patrimonio natural de Ica.",
        "ubicacion": "San Juan Bautista, Ica, Perú",
        "horario": "Abierto todo el día",
        "precio_entrada": Decimal("0"),
        "actividad": "Visita histórica",
        "categoria": "Cultural",
    },
    {
        "nombre": "Fiesta de la Vendimia",
        "descripcion": "Celebración anual en honor a la cosecha de uva, con elección de reina, desfiles y degustación de vinos.",
        "ubicacion": "Plaza de Armas de Ica, Perú",
        "horario": "Marzo (evento anual)",
        "precio_entrada": Decimal("0"),
        "actividad": "Festival y celebración",
        "categoria": "Cultural",
    },
    {
        "nombre": "Procesión del Señor de Luren",
        "descripcion": "Tradición religiosa centenaria donde la imagen del Señor de Luren recorre las calles de Ica.",
        "ubicacion": "Centro de Ica, Perú",
        "horario": "Septiembre (evento anual)",
        "precio_entrada": Decimal("0"),
        "actividad": "Procesión religiosa",
        "categoria": "Religioso",
    },
    {
        "nombre": "Museo Adolfo Bermúdez Jenkins",
        "descripcion": "Museo regional que alberga una importante colección arqueológica de las culturas Paracas, Nazca e Ica.",
        "ubicacion": "Centro de Ica, Perú",
        "horario": "8:00 AM - 5:00 PM",
        "precio_entrada": Decimal("0"),
        "actividad": "Visita cultural y arqueológica",
        "categoria": "Cultural",
    },
    {
        "nombre": "Parque de la Palma",
        "descripcion": "Parque ubicado frente a la Universidad Nacional San Luis Gonzaga, conocido por su emblemática palmera.",
        "ubicacion": "Frente a la UNICA, Ica, Perú",
        "horario": "Abierto todo el día",
        "precio_entrada": Decimal("0"),
        "actividad": "Descanso y recreación",
        "categoria": "Natural",
    },
]


def seed():
    """Inserta las categorías y destinos si no existen."""
    db = SessionLocal()
    try:
        # --- Categorías ---
        print("Insertando categorías...")
        for cat_data in CATEGORIAS:
            existe = db.query(models.Categoria).filter_by(nombre=cat_data["nombre"]).first()
            if existe:
                print(f"  - Categoría '{cat_data['nombre']}' ya existe, omitida.")
                continue
            categoria = models.Categoria(**cat_data)
            db.add(categoria)
        db.commit()

        # --- Destinos ---
        print("Insertando destinos...")
        for dest_data in DESTINOS:
            # Buscar la categoría por nombre
            categoria = db.query(models.Categoria).filter_by(nombre=dest_data["categoria"]).first()
            if not categoria:
                print(f"  ⚠ Categoría '{dest_data['categoria']}' no encontrada para '{dest_data['nombre']}'.")
                continue

            # Verificar si el destino ya existe
            existe = db.query(models.Destino).filter_by(nombre=dest_data["nombre"]).first()
            if existe:
                print(f"  - Destino '{dest_data['nombre']}' ya existe, omitido.")
                continue

            destino = models.Destino(
                nombre=dest_data["nombre"],
                descripcion=dest_data["descripcion"],
                ubicacion=dest_data["ubicacion"],
                horario=dest_data["horario"],
                precio_entrada=dest_data["precio_entrada"],
                actividad=dest_data["actividad"],
                id_categoria=categoria.id_categoria,
            )
            db.add(destino)
        db.commit()

        # --- Resumen ---
        total_cats = db.query(models.Categoria).count()
        total_dest = db.query(models.Destino).count()
        print(f"\n¡Datos semilla completados!")
        print(f"  Categorías: {total_cats}")
        print(f"  Destinos:   {total_dest}")

    except Exception as e:
        db.rollback()
        print(f"\nError al insertar datos semilla: {e}")
        raise
    finally:
        db.close()


if __name__ == "__main__":
    seed()
