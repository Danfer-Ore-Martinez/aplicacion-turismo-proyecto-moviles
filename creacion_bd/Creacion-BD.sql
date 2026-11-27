/* 
=====================================================
   Esquema SQL Server - Itinerarios turísticos
=====================================================
Proposito del Script:
   Crear la Tablas: USUARIO, CATEGORIA, DESTINO, ITINERARIO, DETALLE_ITINERARIO, VALORACION, FAVORITO.
*/
USE master;
GO 
CREATE DATABASE ItinerariosDB;
GO
USE ItinerariosDB;
GO

/* ---------- USUARIO ---------- */
CREATE TABLE USUARIO (
    id_usuario       INT IDENTITY(1,1) NOT NULL,
    nombre           NVARCHAR(100)     NOT NULL,
    correo           NVARCHAR(150)     NOT NULL,
    contrasena_hash  VARCHAR(255)      NOT NULL,
    CONSTRAINT PK_USUARIO PRIMARY KEY (id_usuario),
    CONSTRAINT UQ_USUARIO_correo UNIQUE (correo)
);
GO

/* ---------- CATEGORIA ---------- */
CREATE TABLE CATEGORIA (
    id_categoria  INT IDENTITY(1,1) NOT NULL,
    nombre        NVARCHAR(100)     NOT NULL,
    descripcion   NVARCHAR(255)     NULL,
    CONSTRAINT PK_CATEGORIA PRIMARY KEY (id_categoria),
    CONSTRAINT UQ_CATEGORIA_nombre UNIQUE (nombre)
);
GO

/* ---------- DESTINO ---------- */
CREATE TABLE DESTINO (
    id_destino      INT IDENTITY(1,1) NOT NULL,
    nombre          NVARCHAR(150)     NOT NULL,
    descripcion     NVARCHAR(MAX)     NULL,
    ubicacion       NVARCHAR(255)     NULL,
    horario         NVARCHAR(100)     NULL,
    precio_entrada  DECIMAL(10,2)     NOT NULL CONSTRAINT DF_DESTINO_precio DEFAULT 0,
    actividad       NVARCHAR(100)     NULL,
    id_categoria    INT               NOT NULL,
    CONSTRAINT PK_DESTINO PRIMARY KEY (id_destino),
    CONSTRAINT CK_DESTINO_precio CHECK (precio_entrada >= 0),
    CONSTRAINT FK_DESTINO_CATEGORIA FOREIGN KEY (id_categoria)
        REFERENCES CATEGORIA (id_categoria)
);
GO

/* ---------- ITINERARIO ---------- */
CREATE TABLE ITINERARIO (
    id_itinerario       INT IDENTITY(1,1) NOT NULL,
    id_usuario          INT               NOT NULL,
    nombre              NVARCHAR(150)     NOT NULL,
    fecha_inicio        DATE              NOT NULL,
    fecha_fin           DATE              NOT NULL,
    presupuesto_estimado DECIMAL(12,2)    NULL,
    CONSTRAINT PK_ITINERARIO PRIMARY KEY (id_itinerario),
    CONSTRAINT CK_ITINERARIO_fechas CHECK (fecha_fin >= fecha_inicio),
    CONSTRAINT CK_ITINERARIO_presupuesto CHECK (presupuesto_estimado IS NULL OR presupuesto_estimado >= 0),
    CONSTRAINT FK_ITINERARIO_USUARIO FOREIGN KEY (id_usuario)
        REFERENCES USUARIO (id_usuario)
        ON DELETE CASCADE
);
GO

/* ---------- DETALLE_ITINERARIO ---------- */
CREATE TABLE DETALLE_ITINERARIO (
    id_detalle     INT IDENTITY(1,1) NOT NULL,
    id_itinerario  INT               NOT NULL,
    id_destino     INT               NOT NULL,
    fecha_visita   DATE              NOT NULL,
    hora_visita    TIME(0)           NULL,
    actividad      NVARCHAR(255)     NULL,
    CONSTRAINT PK_DETALLE_ITINERARIO PRIMARY KEY (id_detalle),
    CONSTRAINT FK_DETALLE_ITINERARIO FOREIGN KEY (id_itinerario)
        REFERENCES ITINERARIO (id_itinerario)
        ON DELETE CASCADE,
    CONSTRAINT FK_DETALLE_DESTINO FOREIGN KEY (id_destino)
        REFERENCES DESTINO (id_destino)
);
GO

/* ---------- VALORACION ---------- */
CREATE TABLE VALORACION (
    id_valoracion      INT IDENTITY(1,1) NOT NULL,
    id_usuario         INT               NOT NULL,
    id_destino         INT               NOT NULL,
    calificacion       TINYINT           NOT NULL,
    comentario         NVARCHAR(500)     NULL,
    fecha_publicacion  DATETIME2(0)      NOT NULL CONSTRAINT DF_VALORACION_fecha DEFAULT SYSDATETIME(),
    CONSTRAINT PK_VALORACION PRIMARY KEY (id_valoracion),
    CONSTRAINT CK_VALORACION_calificacion CHECK (calificacion BETWEEN 1 AND 5),
    CONSTRAINT FK_VALORACION_USUARIO FOREIGN KEY (id_usuario)
        REFERENCES USUARIO (id_usuario)
        ON DELETE CASCADE,
    CONSTRAINT FK_VALORACION_DESTINO FOREIGN KEY (id_destino)
        REFERENCES DESTINO (id_destino)
);
GO

/* ---------- FAVORITO ---------- */
CREATE TABLE FAVORITO (
    id_favorito    INT IDENTITY(1,1) NOT NULL,
    id_usuario     INT               NOT NULL,
    id_destino     INT               NOT NULL,
    fecha_guardado DATETIME2(0)      NOT NULL CONSTRAINT DF_FAVORITO_fecha DEFAULT SYSDATETIME(),
    CONSTRAINT PK_FAVORITO PRIMARY KEY (id_favorito),
    CONSTRAINT UQ_FAVORITO_usuario_destino UNIQUE (id_usuario, id_destino),
    CONSTRAINT FK_FAVORITO_USUARIO FOREIGN KEY (id_usuario)
        REFERENCES USUARIO (id_usuario)
        ON DELETE CASCADE,
    CONSTRAINT FK_FAVORITO_DESTINO FOREIGN KEY (id_destino)
        REFERENCES DESTINO (id_destino)
);
GO

/* ---------- Índices en llaves foráneas ---------- */
CREATE INDEX IX_DESTINO_categoria      ON DESTINO (id_categoria);
CREATE INDEX IX_ITINERARIO_usuario     ON ITINERARIO (id_usuario);
CREATE INDEX IX_DETALLE_itinerario     ON DETALLE_ITINERARIO (id_itinerario);
CREATE INDEX IX_DETALLE_destino        ON DETALLE_ITINERARIO (id_destino);
CREATE INDEX IX_VALORACION_usuario     ON VALORACION (id_usuario);
CREATE INDEX IX_VALORACION_destino     ON VALORACION (id_destino);
CREATE INDEX IX_FAVORITO_destino       ON FAVORITO (id_destino);
GO

/* ---------- Datos semilla: Categorías ---------- */
INSERT INTO CATEGORIA (nombre, descripcion) VALUES
('Natural',     'Destinos de naturaleza y paisajes'),
('Cultural',    'Destinos culturales e históricos'),
('Religioso',   'Destinos de carácter religioso'),
('Aventura',    'Destinos para deportes extremos y aventura'),
('Enoturismo',  'Destinos relacionados con vinos y piscos');
GO

/* ---------- Datos semilla: Destinos ---------- */
INSERT INTO DESTINO (nombre, descripcion, ubicacion, horario, precio_entrada, actividad, id_categoria) VALUES
('Laguna de Huacachina',             'Oasis natural rodeado de dunas, ideal para sandboard y paseos en tubular.',          'Huacachina, Ica, Perú',            'Abierto todo el día',       0, 'Sandboarding',                  1),
('Parque Temático de Cachiche',      'Parque temático basado en leyendas locales, con la famosa escultura de la bruja de Cachiche.', 'Cachiche, Ica, Perú',     '8:00 AM - 6:00 PM',        0, 'Cultura y leyendas',            2),
('Hacienda Tacama',                  'La bodega más antigua de América, especializada en la producción de vinos y piscos premium.', 'La Tacama, Ica, Perú',    '9:00 AM - 5:00 PM',        0, 'Cata de vinos y piscos',        5),
('Cañón de los Perdidos',            'Impresionante cañón con paredes de roca ideales para rappel, caminatas y deportes extremos.', 'Los Aquijes, Ica, Perú',  '7:00 AM - 4:00 PM',        0, 'Rappel y aventura',             4),
('Santuario del Señor de Luren',     'Templo principal de Ica que alberga la imagen del Señor de Luren, patrón de la ciudad.',    'Centro de Ica, Perú',     '6:00 AM - 8:00 PM',        0, 'Peregrinación religiosa',       3),
('Bosque de Piedras',                'Formaciones rocosas naturales con figuras caprichosas esculpidas por el viento y el tiempo.', 'Subtanjalla, Ica, Perú',  '8:00 AM - 5:00 PM',        0, 'Caminata y exploración',        1),
('Palmera de las 7 Cabezas',         'Palmera datilera única en el mundo con siete cabezas, considerada patrimonio natural de Ica.',  'San Juan Bautista, Ica, Perú', 'Abierto todo el día',    0, 'Visita histórica',              2),
('Fiesta de la Vendimia',            'Celebración anual en honor a la cosecha de uva, con elección de reina, desfiles y degustación de vinos.', 'Plaza de Armas de Ica, Perú', 'Marzo (evento anual)',  0, 'Festival y celebración',        2),
('Procesión del Señor de Luren',     'Tradición religiosa centenaria donde la imagen del Señor de Luren recorre las calles de Ica.',  'Centro de Ica, Perú',     'Septiembre (evento anual)', 0, 'Procesión religiosa',           3),
('Museo Adolfo Bermúdez Jenkins',    'Museo regional que alberga una importante colección arqueológica de las culturas Paracas, Nazca e Ica.', 'Centro de Ica, Perú', '8:00 AM - 5:00 PM', 0, 'Visita cultural y arqueológica', 2),
('Parque de la Palma',               'Parque ubicado frente a la Universidad Nacional San Luis Gonzaga, conocido por su emblemática palmera.', 'Frente a la UNICA, Ica, Perú', 'Abierto todo el día', 0, 'Descanso y recreación', 1);
GO
