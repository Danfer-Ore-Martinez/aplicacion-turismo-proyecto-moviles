from datetime import date, datetime, time
from decimal import Decimal

from sqlalchemy import (
    Date, DateTime, ForeignKey, Numeric, SmallInteger, String, Text, Time,
    UniqueConstraint, func,
)
from sqlalchemy.orm import Mapped, mapped_column, relationship

from database import Base


class Usuario(Base):
    __tablename__ = "USUARIO"

    id_usuario: Mapped[int] = mapped_column(primary_key=True, autoincrement=True)
    nombre: Mapped[str] = mapped_column(String(100))
    correo: Mapped[str] = mapped_column(String(150), unique=True)
    contrasena_hash: Mapped[str] = mapped_column(String(255))

    itinerarios: Mapped[list["Itinerario"]] = relationship(back_populates="usuario")


class Categoria(Base):
    __tablename__ = "CATEGORIA"

    id_categoria: Mapped[int] = mapped_column(primary_key=True, autoincrement=True)
    nombre: Mapped[str] = mapped_column(String(100), unique=True)
    descripcion: Mapped[str | None] = mapped_column(String(255))


class Destino(Base):
    __tablename__ = "DESTINO"

    id_destino: Mapped[int] = mapped_column(primary_key=True, autoincrement=True)
    nombre: Mapped[str] = mapped_column(String(150))
    descripcion: Mapped[str | None] = mapped_column(Text)
    ubicacion: Mapped[str | None] = mapped_column(String(255))
    horario: Mapped[str | None] = mapped_column(String(100))
    precio_entrada: Mapped[Decimal] = mapped_column(Numeric(10, 2), default=0)
    actividad: Mapped[str | None] = mapped_column(String(100))
    id_categoria: Mapped[int] = mapped_column(ForeignKey("CATEGORIA.id_categoria"))

    categoria: Mapped[Categoria] = relationship()


class Itinerario(Base):
    __tablename__ = "ITINERARIO"

    id_itinerario: Mapped[int] = mapped_column(primary_key=True, autoincrement=True)
    id_usuario: Mapped[int] = mapped_column(ForeignKey("USUARIO.id_usuario"))
    nombre: Mapped[str] = mapped_column(String(150))
    fecha_inicio: Mapped[date] = mapped_column(Date)
    fecha_fin: Mapped[date] = mapped_column(Date)
    presupuesto_estimado: Mapped[Decimal | None] = mapped_column(Numeric(12, 2))

    usuario: Mapped[Usuario] = relationship(back_populates="itinerarios")
    detalles: Mapped[list["DetalleItinerario"]] = relationship(
        back_populates="itinerario", cascade="all, delete-orphan"
    )


class DetalleItinerario(Base):
    __tablename__ = "DETALLE_ITINERARIO"

    id_detalle: Mapped[int] = mapped_column(primary_key=True, autoincrement=True)
    id_itinerario: Mapped[int] = mapped_column(ForeignKey("ITINERARIO.id_itinerario"))
    id_destino: Mapped[int] = mapped_column(ForeignKey("DESTINO.id_destino"))
    fecha_visita: Mapped[date] = mapped_column(Date)
    hora_visita: Mapped[time | None] = mapped_column(Time)
    actividad: Mapped[str | None] = mapped_column(String(255))

    itinerario: Mapped[Itinerario] = relationship(back_populates="detalles")
    destino: Mapped[Destino] = relationship()


class Valoracion(Base):
    __tablename__ = "VALORACION"

    id_valoracion: Mapped[int] = mapped_column(primary_key=True, autoincrement=True)
    id_usuario: Mapped[int] = mapped_column(ForeignKey("USUARIO.id_usuario"))
    id_destino: Mapped[int] = mapped_column(ForeignKey("DESTINO.id_destino"))
    calificacion: Mapped[int] = mapped_column(SmallInteger)
    comentario: Mapped[str | None] = mapped_column(String(500))
    fecha_publicacion: Mapped[datetime] = mapped_column(
        DateTime, server_default=func.sysdatetime()
    )

    usuario: Mapped[Usuario] = relationship()


class Favorito(Base):
    __tablename__ = "FAVORITO"
    __table_args__ = (UniqueConstraint("id_usuario", "id_destino"),)

    id_favorito: Mapped[int] = mapped_column(primary_key=True, autoincrement=True)
    id_usuario: Mapped[int] = mapped_column(ForeignKey("USUARIO.id_usuario"))
    id_destino: Mapped[int] = mapped_column(ForeignKey("DESTINO.id_destino"))
    fecha_guardado: Mapped[datetime] = mapped_column(
        DateTime, server_default=func.sysdatetime()
    )

    destino: Mapped[Destino] = relationship()
