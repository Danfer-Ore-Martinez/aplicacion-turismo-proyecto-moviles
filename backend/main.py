from datetime import time
from typing import TypeVar

import bcrypt
from fastapi import Depends, FastAPI, HTTPException, Query, status
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy import func, select
from sqlalchemy.exc import IntegrityError
from sqlalchemy.orm import Session, joinedload

import models
import schemas
from database import get_db

app = FastAPI(title="API Itinerarios Turísticos", version="1.0.0")

# CORS abierto para desarrollo local (útil si pruebas Flutter Web).
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)


# ---------- Utilidades ----------
def hash_password(password: str) -> str:
    return bcrypt.hashpw(password.encode(), bcrypt.gensalt()).decode()


def verify_password(password: str, hashed: str) -> bool:
    try:
        return bcrypt.checkpw(password.encode(), hashed.encode())
    except ValueError:
        return False


T = TypeVar("T")


def get_or_404(db: Session, model: type[T], pk: int, nombre: str) -> T:
    obj = db.get(model, pk)
    if obj is None:
        raise HTTPException(status.HTTP_404_NOT_FOUND, f"{nombre} no encontrado")
    return obj


def commit_or_409(db: Session, mensaje: str):
    try:
        db.commit()
    except IntegrityError:
        db.rollback()
        raise HTTPException(status.HTTP_409_CONFLICT, mensaje)


@app.get("/", tags=["Salud"])
def raiz():
    return {"mensaje": "API de itinerarios funcionando"}


@app.get("/health", tags=["Salud"])
def health_check():
    return {"status": "ok"}


@app.get("/v1/models", tags=["Salud"])
def list_models():
    """Endpoint compatible con OpenAI. Usado por herramientas de IA locales."""
    return {"object": "list", "data": []}


@app.get("/salud/bd", tags=["Salud"])
def probar_bd(db: Session = Depends(get_db)):
    db.execute(select(1))
    return {"bd": "conectada"}


# ---------- Usuarios ----------
@app.post("/usuarios/registro", response_model=schemas.UsuarioOut,
          status_code=201, tags=["Usuarios"])
def registrar_usuario(datos: schemas.UsuarioCreate, db: Session = Depends(get_db)):
    existe = db.scalar(select(models.Usuario).where(models.Usuario.correo == datos.correo))
    if existe:
        raise HTTPException(status.HTTP_409_CONFLICT, "El correo ya está registrado")
    usuario = models.Usuario(
        nombre=datos.nombre,
        correo=datos.correo,
        contrasena_hash=hash_password(datos.contrasena),
    )
    db.add(usuario)
    commit_or_409(db, "No se pudo registrar el usuario")
    db.refresh(usuario)
    return usuario


@app.post("/usuarios/login", response_model=schemas.UsuarioOut, tags=["Usuarios"])
def login(datos: schemas.UsuarioLogin, db: Session = Depends(get_db)):
    usuario = db.scalar(select(models.Usuario).where(models.Usuario.correo == datos.correo))
    if not usuario or not verify_password(datos.contrasena, usuario.contrasena_hash):
        raise HTTPException(status.HTTP_401_UNAUTHORIZED, "Correo o contraseña incorrectos")
    return usuario


@app.get("/usuarios/{id_usuario}", response_model=schemas.UsuarioOut, tags=["Usuarios"])
def obtener_usuario(id_usuario: int, db: Session = Depends(get_db)):
    return get_or_404(db, models.Usuario, id_usuario, "Usuario")


# ---------- Categorías ----------
@app.get("/categorias", response_model=list[schemas.CategoriaOut], tags=["Categorías"])
def listar_categorias(db: Session = Depends(get_db)):
    return db.scalars(select(models.Categoria).order_by(models.Categoria.nombre)).all()


@app.post("/categorias", response_model=schemas.CategoriaOut,
          status_code=201, tags=["Categorías"])
def crear_categoria(datos: schemas.CategoriaCreate, db: Session = Depends(get_db)):
    categoria = models.Categoria(**datos.model_dump())
    db.add(categoria)
    commit_or_409(db, "La categoría ya existe")
    db.refresh(categoria)
    return categoria


# ---------- Destinos ----------
@app.get("/destinos", response_model=list[schemas.DestinoOut], tags=["Destinos"])
def listar_destinos(
    id_categoria: int | None = None,
    buscar: str | None = Query(default=None, description="Texto en el nombre"),
    db: Session = Depends(get_db),
):
    consulta = select(models.Destino).order_by(models.Destino.nombre)
    if id_categoria is not None:
        consulta = consulta.where(models.Destino.id_categoria == id_categoria)
    if buscar:
        consulta = consulta.where(
            models.Destino.nombre.contains(buscar)
            | models.Destino.actividad.contains(buscar)
        )
    return db.scalars(consulta).all()


@app.get("/destinos/{id_destino}", response_model=schemas.DestinoOut, tags=["Destinos"])
def obtener_destino(id_destino: int, db: Session = Depends(get_db)):
    return get_or_404(db, models.Destino, id_destino, "Destino")


@app.post("/destinos", response_model=schemas.DestinoOut,
          status_code=201, tags=["Destinos"])
def crear_destino(datos: schemas.DestinoCreate, db: Session = Depends(get_db)):
    get_or_404(db, models.Categoria, datos.id_categoria, "Categoría")
    destino = models.Destino(**datos.model_dump())
    db.add(destino)
    commit_or_409(db, "No se pudo crear el destino")
    db.refresh(destino)
    return destino


@app.put("/destinos/{id_destino}", response_model=schemas.DestinoOut, tags=["Destinos"])
def actualizar_destino(id_destino: int, datos: schemas.DestinoCreate,
                       db: Session = Depends(get_db)):
    destino = get_or_404(db, models.Destino, id_destino, "Destino")
    get_or_404(db, models.Categoria, datos.id_categoria, "Categoría")
    for campo, valor in datos.model_dump().items():
        setattr(destino, campo, valor)
    commit_or_409(db, "No se pudo actualizar el destino")
    db.refresh(destino)
    return destino


@app.delete("/destinos/{id_destino}", status_code=204, tags=["Destinos"])
def eliminar_destino(id_destino: int, db: Session = Depends(get_db)):
    destino = get_or_404(db, models.Destino, id_destino, "Destino")
    db.delete(destino)
    commit_or_409(db, "El destino está en uso (itinerarios, valoraciones o favoritos)")


# ---------- Itinerarios ----------
@app.post("/itinerarios", response_model=schemas.ItinerarioOut,
          status_code=201, tags=["Itinerarios"])
def crear_itinerario(datos: schemas.ItinerarioCreate, db: Session = Depends(get_db)):
    get_or_404(db, models.Usuario, datos.id_usuario, "Usuario")
    itinerario = models.Itinerario(**datos.model_dump())
    db.add(itinerario)
    commit_or_409(db, "No se pudo crear el itinerario")
    db.refresh(itinerario)
    return itinerario


@app.get("/usuarios/{id_usuario}/itinerarios",
         response_model=list[schemas.ItinerarioOut], tags=["Itinerarios"])
def listar_itinerarios_usuario(id_usuario: int, db: Session = Depends(get_db)):
    get_or_404(db, models.Usuario, id_usuario, "Usuario")
    return db.scalars(
        select(models.Itinerario)
        .where(models.Itinerario.id_usuario == id_usuario)
        .order_by(models.Itinerario.fecha_inicio.desc())
    ).all()


@app.get("/itinerarios/{id_itinerario}",
         response_model=schemas.ItinerarioConDetalles, tags=["Itinerarios"])
def obtener_itinerario(id_itinerario: int, db: Session = Depends(get_db)):
    itinerario = db.scalar(
        select(models.Itinerario)
        .options(joinedload(models.Itinerario.detalles)
                 .joinedload(models.DetalleItinerario.destino))
        .where(models.Itinerario.id_itinerario == id_itinerario)
    )
    if itinerario is None:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "Itinerario no encontrado")
    itinerario.detalles.sort(key=lambda d: (d.fecha_visita, d.hora_visita or time.min))
    return itinerario


@app.put("/itinerarios/{id_itinerario}",
         response_model=schemas.ItinerarioOut, tags=["Itinerarios"])
def actualizar_itinerario(id_itinerario: int, datos: schemas.ItinerarioUpdate,
                          db: Session = Depends(get_db)):
    itinerario = get_or_404(db, models.Itinerario, id_itinerario, "Itinerario")
    for campo, valor in datos.model_dump().items():
        setattr(itinerario, campo, valor)
    commit_or_409(db, "No se pudo actualizar el itinerario")
    db.refresh(itinerario)
    return itinerario


@app.delete("/itinerarios/{id_itinerario}", status_code=204, tags=["Itinerarios"])
def eliminar_itinerario(id_itinerario: int, db: Session = Depends(get_db)):
    itinerario = get_or_404(db, models.Itinerario, id_itinerario, "Itinerario")
    db.delete(itinerario)  # sus detalles se eliminan en cascada
    commit_or_409(db, "No se pudo eliminar el itinerario")


# ---------- Detalle de itinerario ----------
@app.post("/itinerarios/{id_itinerario}/detalles",
          response_model=schemas.DetalleOut, status_code=201, tags=["Itinerarios"])
def agregar_detalle(id_itinerario: int, datos: schemas.DetalleCreate,
                    db: Session = Depends(get_db)):
    itinerario = get_or_404(db, models.Itinerario, id_itinerario, "Itinerario")
    get_or_404(db, models.Destino, datos.id_destino, "Destino")
    if not (itinerario.fecha_inicio <= datos.fecha_visita <= itinerario.fecha_fin):
        raise HTTPException(
            status.HTTP_422_UNPROCESSABLE_ENTITY,
            "La fecha de visita debe estar dentro del rango del itinerario",
        )
    detalle = models.DetalleItinerario(id_itinerario=id_itinerario, **datos.model_dump())
    db.add(detalle)
    commit_or_409(db, "No se pudo agregar el detalle")
    db.refresh(detalle)
    return detalle


@app.delete("/detalles/{id_detalle}", status_code=204, tags=["Itinerarios"])
def eliminar_detalle(id_detalle: int, db: Session = Depends(get_db)):
    detalle = get_or_404(db, models.DetalleItinerario, id_detalle, "Detalle")
    db.delete(detalle)
    commit_or_409(db, "No se pudo eliminar el detalle")


# ---------- Valoraciones ----------
@app.post("/destinos/{id_destino}/valoraciones",
          response_model=schemas.ValoracionOut, status_code=201, tags=["Valoraciones"])
def crear_valoracion(id_destino: int, datos: schemas.ValoracionCreate,
                     db: Session = Depends(get_db)):
    get_or_404(db, models.Destino, id_destino, "Destino")
    get_or_404(db, models.Usuario, datos.id_usuario, "Usuario")
    valoracion = models.Valoracion(id_destino=id_destino, **datos.model_dump())
    db.add(valoracion)
    commit_or_409(db, "No se pudo crear la valoración")
    db.refresh(valoracion)
    return valoracion


@app.get("/destinos/{id_destino}/valoraciones",
         response_model=schemas.ResumenValoraciones, tags=["Valoraciones"])
def listar_valoraciones(
    id_destino: int, db: Session = Depends(get_db)
) -> schemas.ResumenValoraciones:
    get_or_404(db, models.Destino, id_destino, "Destino")
    valoraciones = db.scalars(
        select(models.Valoracion)
        .options(joinedload(models.Valoracion.usuario))
        .where(models.Valoracion.id_destino == id_destino)
        .order_by(models.Valoracion.fecha_publicacion.desc())
    ).all()
    promedio = db.scalar(
        select(func.avg(models.Valoracion.calificacion))
        .where(models.Valoracion.id_destino == id_destino)
    )
    return schemas.ResumenValoraciones(
        promedio=round(float(promedio), 2) if promedio is not None else 0.0,
        total=len(valoraciones),
        valoraciones=[schemas.ValoracionOut.model_validate(v) for v in valoraciones],
    )


@app.delete("/valoraciones/{id_valoracion}", status_code=204, tags=["Valoraciones"])
def eliminar_valoracion(id_valoracion: int, db: Session = Depends(get_db)):
    valoracion = get_or_404(db, models.Valoracion, id_valoracion, "Valoración")
    db.delete(valoracion)
    commit_or_409(db, "No se pudo eliminar la valoración")


# ---------- Favoritos ----------
@app.get("/usuarios/{id_usuario}/favoritos",
         response_model=list[schemas.FavoritoOut], tags=["Favoritos"])
def listar_favoritos(id_usuario: int, db: Session = Depends(get_db)):
    get_or_404(db, models.Usuario, id_usuario, "Usuario")
    return db.scalars(
        select(models.Favorito)
        .options(joinedload(models.Favorito.destino))
        .where(models.Favorito.id_usuario == id_usuario)
        .order_by(models.Favorito.fecha_guardado.desc())
    ).all()


@app.post("/usuarios/{id_usuario}/favoritos",
          response_model=schemas.FavoritoOut, status_code=201, tags=["Favoritos"])
def agregar_favorito(id_usuario: int, datos: schemas.FavoritoCreate,
                     db: Session = Depends(get_db)):
    get_or_404(db, models.Usuario, id_usuario, "Usuario")
    get_or_404(db, models.Destino, datos.id_destino, "Destino")
    favorito = models.Favorito(id_usuario=id_usuario, id_destino=datos.id_destino)
    db.add(favorito)
    commit_or_409(db, "El destino ya está en favoritos")
    db.refresh(favorito)
    return favorito


@app.delete("/usuarios/{id_usuario}/favoritos/{id_destino}",
            status_code=204, tags=["Favoritos"])
def quitar_favorito(id_usuario: int, id_destino: int, db: Session = Depends(get_db)):
    favorito = db.scalar(
        select(models.Favorito).where(
            models.Favorito.id_usuario == id_usuario,
            models.Favorito.id_destino == id_destino,
        )
    )
    if favorito is None:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "Favorito no encontrado")
    db.delete(favorito)
    commit_or_409(db, "No se pudo quitar el favorito")