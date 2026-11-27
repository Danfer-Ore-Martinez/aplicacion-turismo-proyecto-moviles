/* 
=====================================================
   Script ALTER - Agregar columna actividad a DESTINO
=====================================================
Ejecutar este script si la base de datos ItinerariosDB
ya fue creada previamente y necesita el nuevo campo.
*/
USE ItinerariosDB;
GO

-- Verificar si la columna ya existe antes de agregarla
IF NOT EXISTS (
    SELECT 1 
    FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE TABLE_NAME = 'DESTINO' AND COLUMN_NAME = 'actividad'
)
BEGIN
    ALTER TABLE DESTINO
    ADD actividad NVARCHAR(100) NULL;

    PRINT 'Columna actividad agregada a la tabla DESTINO.';
END
ELSE
BEGIN
    PRINT 'La columna actividad ya existe en la tabla DESTINO.';
END
GO
