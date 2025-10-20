/* ==========================================================
   QUIZ — FUNCIONES Y TRIGGERS (Veterinaria)
   Autora: Sara Ajaj
   Base: Cliente / Mascota / Vacuna
   ========================================================== */


/* ==========================================================
   1️⃣  AGREGAR CAMPO Y FUNCIÓN PARA VIGENCIA DE VACUNA
   ========================================================== */

-- Agregar el campo de fecha de vigencia
ALTER TABLE Vacuna
ADD COLUMN fechaVigencia DATE;

-- Crear función que determina si la vacuna está vigente o vencida
DELIMITER $$

CREATE FUNCTION estadoVacuna(p_idVacuna INT)
RETURNS VARCHAR(20)
DETERMINISTIC
BEGIN
    DECLARE v_fechaVigencia DATE;
    DECLARE v_estado VARCHAR(20);

    SELECT fechaVigencia INTO v_fechaVigencia
    FROM Vacuna
    WHERE idVacuna = p_idVacuna;

    IF v_fechaVigencia >= CURDATE() THEN
        SET v_estado = 'Vigente';
    ELSE
        SET v_estado = 'Vencida';
    END IF;

    RETURN v_estado;
END $$

DELIMITER ;

-- Prueba:
-- SELECT nombreVacuna, estadoVacuna(idVacuna) AS Estado FROM Vacuna;


/* ==========================================================
   2️⃣  FUNCIÓN PARA MOSTRAR INFO DE MASCOTA (nombre, raza, propietario)
   ========================================================== */

DELIMITER $$

CREATE FUNCTION infoMascota(p_idMascota INT)
RETURNS VARCHAR(200)
DETERMINISTIC
BEGIN
    DECLARE v_nombreMascota VARCHAR(100);
    DECLARE v_raza VARCHAR(50);
    DECLARE v_propietario VARCHAR(100);
    DECLARE v_resultado VARCHAR(200);

    SELECT m.nombreMascota, m.raza, c.nombreCliente
    INTO v_nombreMascota, v_raza, v_propietario
    FROM Mascota m
    JOIN Cliente c ON m.idCliente = c.idCliente
    WHERE m.idMascota = p_idMascota;

    SET v_resultado = CONCAT('Mascota: ', v_nombreMascota,
                             ', Raza: ', v_raza,
                             ', Propietario: ', v_propietario);

    RETURN v_resultado;
END $$

DELIMITER ;

-- Prueba:
-- SELECT infoMascota(1);


/* ==========================================================
   3️⃣  TRIGGER: IMPEDIR ELIMINAR CLIENTE SI TIENE MASCOTAS
   ========================================================== */

DELIMITER $$

CREATE TRIGGER impedirEliminarCliente
BEFORE DELETE ON Cliente
FOR EACH ROW
BEGIN
    IF EXISTS (SELECT 1 FROM Mascota WHERE idCliente = OLD.idCliente) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'No se puede eliminar el cliente: tiene mascotas registradas.';
    END IF;
END $$

DELIMITER ;


/* ==========================================================
   4️⃣  TRIGGER: GUARDAR CLIENTES ELIMINADOS EN OTRA TABLA
   ========================================================== */

-- Crear tabla para guardar los clientes eliminados
CREATE TABLE IF NOT EXISTS ClientesEliminados (
    idCliente INT,
    nombreCliente VARCHAR(100),
    correo VARCHAR(100),
    telefono VARCHAR(50),
    fechaEliminacion DATETIME
);

-- Crear el trigger
DELIMITER $$

CREATE TRIGGER guardarClienteEliminado
AFTER DELETE ON Cliente
FOR EACH ROW
BEGIN
    INSERT INTO ClientesEliminados(
        idCliente, nombreCliente, correo, telefono, fechaEliminacion
    )
    VALUES (
        OLD.idCliente, OLD.nombreCliente, OLD.correo, OLD.telefono, NOW()
    );
END $$

DELIMITER ;


/* ==========================================================
   5️⃣  TRIGGER: ACTUALIZAR AUTOMÁTICAMENTE LA FECHA DE ACTUALIZACIÓN
   ========================================================== */

-- Agregar el campo a la tabla Cliente
ALTER TABLE Cliente
ADD COLUMN fechaActualizacion DATETIME;

-- Crear el trigger que actualiza el campo automáticamente
DELIMITER $$

CREATE TRIGGER actualizarFechaCliente
BEFORE UPDATE ON Cliente
FOR EACH ROW
BEGIN
    SET NEW.fechaActualizacion = NOW();
END $$

DELIMITER ;

-- Prueba:
-- UPDATE Cliente SET telefono = '3209998877' WHERE idCliente = 3;
-- SELECT * FROM Cliente;
