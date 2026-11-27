from datetime import date, datetime, time
from decimal import Decimal

from pydantic import BaseModel, ConfigDict, EmailStr, Field, model_validator


class ORM(BaseModel):
    model_config = ConfigDict(from_attributes=True)


# ---------- Usuario ----------
class UsuarioCreate(BaseModel):
    nombre: str = Field(min_length=1, max_length=100)
    correo: EmailStr
    contrasena: str = Field(min_length=6, max_length=72)


class UsuarioLogin(BaseModel):
    correo: EmailStr
    contrasena: str


class UsuarioOut(ORM):
    id_usuario: int
    nombre: str
    correo: EmailStr


# ---------- Categoría ----------
class CategoriaCreate(BaseModel):
    nombre: str = Field(min_length=1, max_length=100)
    descripcion: str | None = None


class CategoriaOut(ORM):
    id_categoria: int
    nombre: str
    descripcion: str | None = None


# ---------- Destino ----------
class DestinoBase(BaseModel):
    nombre: str = Field(min_length=1, max_length=150)
    descripcion: str | None = None
    ubicacion: str | None = None
    horario: str | None = None
    precio_entrada: Decimal = Field(default=Decimal("0"), ge=0)
    id_categoria: int


class DestinoCreate(DestinoBase):
    pass


class DestinoOut(ORM, DestinoBase):
    id_destino: int


# ---------- Detalle de itinerario ----------
class DetalleCreate(BaseModel):
    id_destino: int
    fecha_visita: date
    hora_visita: time | None = None
    actividad: str | None = None


class DetalleOut(ORM):
    id_detalle: int
    id_itinerario: int
    id_destino: int
    fecha_visita: date
    hora_visita: time | None = None
    actividad: str | None = None
    destino: DestinoOut


# ---------- Itinerario ----------
class ItinerarioBase(BaseModel):
    nombre: str = Field(min_length=1, max_length=150)
    fecha_inicio: date
    fecha_fin: date
    presupuesto_estimado: Decimal | None = Field(default=None, ge=0)

    @model_validator(mode="after")
    def validar_fechas(self):
        if self.fecha_fin < self.fecha_inicio:
            raise ValueError("fecha_fin no puede ser anterior a fecha_inicio")
        return self


class ItinerarioCreate(ItinerarioBase):
    id_usuario: int


class ItinerarioUpdate(ItinerarioBase):
    pass


class ItinerarioOut(ORM, ItinerarioBase):
    id_itinerario: int
    id_usuario: int


class ItinerarioConDetalles(ItinerarioOut):
    detalles: list[DetalleOut] = []


# ---------- Valoración ----------
class ValoracionCreate(BaseModel):
    id_usuario: int
    calificacion: int = Field(ge=1, le=5)
    comentario: str | None = Field(default=None, max_length=500)


class ValoracionOut(ORM):
    id_valoracion: int
    id_usuario: int
    id_destino: int
    calificacion: int
    comentario: str | None = None
    fecha_publicacion: datetime
    usuario: UsuarioOut


class ResumenValoraciones(BaseModel):
    promedio: float
    total: int
    valoraciones: list[ValoracionOut]


# ---------- Favorito ----------
class FavoritoCreate(BaseModel):
    id_destino: int


class FavoritoOut(ORM):
    id_favorito: int
    id_usuario: int
    id_destino: int
    fecha_guardado: datetime
    destino: DestinoOut
