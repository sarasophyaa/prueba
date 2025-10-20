create database CosmosBd;
use CosmosBd;

CREATE TABLE Departamento (
    idDepartamento INT AUTO_INCREMENT PRIMARY KEY,
    nombreDepartamento VARCHAR(60) NOT NULL,
    ciudad VARCHAR(50) NOT NULL
);

CREATE TABLE Empleado (
    idEmpleado INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    cargo VARCHAR(80) NOT NULL,
    edad INT,
    salario DECIMAL(10,2),
    fechaIngreso DATE,
    idDepartamento INT,
    FOREIGN KEY (idDepartamento) REFERENCES Departamento(idDepartamento)
);
CREATE TABLE IF NOT EXISTS HistorialSalarios (
    idHistorial INT AUTO_INCREMENT PRIMARY KEY,
    idEmpleado INT,
    salarioAnterior DECIMAL(10,2),
    salarioNuevo DECIMAL(10,2),
    diferencia DECIMAL(10,2),
    porcentajeCambio DECIMAL(10,2),
    fechaCambio DATETIME
);

INSERT INTO Departamento (nombreDepartamento, ciudad) VALUES
('Desarrollo de Software', 'Bogotá'),
('Diseño UX/UI', 'Medellín'),
('Análisis de Datos', 'Cali'),
('Recursos Humanos', 'Bogotá'),
('Marketing Digital', 'Barranquilla');

INSERT INTO Empleado (nombre, cargo, edad, salario, fechaIngreso, idDepartamento) VALUES
('Laura Torres', 'Desarrolladora Backend', 29, 5200.00, '2021-05-14', 1),
('Mateo Rodríguez', 'Analista de QA', 32, 4700.00, '2020-09-01', 1),
('Daniela Gómez', 'Diseñadora UX', 27, 4100.00, '2022-03-22', 2),
('Camilo Duarte', 'Diseñador UI', 30, 4300.00, '2023-01-18', 2),
('Valeria López', 'Científica de Datos', 34, 6400.00, '2019-11-10', 3),
('Andrés Morales', 'Analista de Datos Junior', 25, 3600.00, '2023-04-05', 3),
('Mariana Herrera', 'Coordinadora de RRHH', 38, 5900.00, '2018-06-29', 4),
('Juan Esteban Rivas', 'Asistente de RRHH', 26, 3300.00, '2022-07-12', 4),
('Sofía Ramírez', 'Estratega Digital', 31, 4800.00, '2021-08-09', 5),
('Carlos Méndez', 'Community Manager', 28, 3500.00, '2023-02-25', 5);

##Consultas básicas
#1
select nombre,cargo,salario from empleado;

#2
select nombre,salario
from empleado
where salario>(select avg(salario) from empleado);

#3
select nombre,salario
from empleado 
where (nombre like "%a" or nombre like "%o")
and salario<5000;

##Consultas multitablas y subconsultas

#4
select e.nombre as "Nombre Empleado", 
d.nombreDepartamento as "Nombre departamento",
e.cargo
from empleado e
join departamento d
on d.idDepartamento=e.idDepartamento;

#5
select e.nombre as "Nombre Empleado", 
d.nombreDepartamento as "Nombre departamento",
e.salario
from empleado e
join departamento d
on d.idDepartamento=e.idDepartamento
where e.salario>(select avg(e2.salario) 
from empleado e2
where e2.idDepartamento = e.idDepartamento);

#6
select e.nombre as "Nombre Empleado", 
d.nombreDepartamento as "Nombre departamento",
e.salario
from Departamento d
left join empleado e
on d.idDepartamento=e.idDepartamento
where e.idEmpleado is null;

#7
SELECT e.nombre AS "Nombre Empleado", 
       d.nombreDepartamento AS "Nombre Departamento",
       e.salario
FROM Empleado e
JOIN (
    SELECT idDepartamento, MAX(salario) AS SalarioMaximo
    FROM Empleado
    GROUP BY idDepartamento
) AS MaximoDept
  ON e.idDepartamento = MaximoDept.idDepartamento
  AND e.salario = MaximoDept.SalarioMaximo
JOIN Departamento d
  ON d.idDepartamento = e.idDepartamento;
  
  #Funciones agrupaciones
  
#8 
select avg(salario) as "salario promedio",
max(salario) as "Salario Máximo",
min(salario) "Salaario minmo"
from empleado
group by idDepartamento;


#9
SELECT d.idDepartamento,
       d.nombreDepartamento,
       ROUND(AVG(e.salario), 2) AS promedioSalario
FROM Departamento d
JOIN Empleado e
  ON e.idDepartamento = d.idDepartamento
GROUP BY d.idDepartamento, d.nombreDepartamento
HAVING AVG(e.salario) > 4500;

#10
SELECT nombre AS "Nombre Empleado",
       cargo,
       fechaIngreso,
       salario
FROM Empleado
ORDER BY fechaIngreso ASC, salario DESC;

#11
CREATE OR REPLACE VIEW vistaEmpleadosDept AS
SELECT e.nombre AS "Nombre Empleado",
       e.cargo,
       d.nombreDepartamento AS "Departamento",
       d.ciudad
FROM Empleado e
JOIN Departamento d
  ON e.idDepartamento = d.idDepartamento;
  SELECT * FROM vistaEmpleadosDept;

#12
CREATE OR REPLACE VIEW vistaSalariosAltos AS
SELECT e.nombre AS "Nombre Empleado",
       e.cargo,
       e.salario,
       ROUND(AVG(e2.salario), 2) AS PromedioGeneral,
       ROUND(e.salario - AVG(e2.salario), 2) AS Diferencia
FROM Empleado e
JOIN Empleado e2
  ON 1 = 1  -- para poder calcular el promedio general en toda la tabla
GROUP BY e.idEmpleado, e.nombre, e.cargo, e.salario
HAVING e.salario > AVG(e2.salario);
  
  #13
  DELIMITER $$

CREATE PROCEDURE buscarEmpleado(IN p_idEmpleado INT)
BEGIN
    SELECT e.idEmpleado,
           e.nombre,
           e.cargo,
           e.edad,
           e.salario,
           e.fechaIngreso,
           d.nombreDepartamento AS Departamento,
           d.ciudad
    FROM Empleado e
    JOIN Departamento d ON e.idDepartamento = d.idDepartamento
    WHERE e.idEmpleado = p_idEmpleado;
END $$

DELIMITER ;
CALL buscarEmpleado(3);

DELIMITER $$

CREATE PROCEDURE actualizarSalario(
    IN p_idEmpleado INT,
    IN p_nuevoSalario DECIMAL(10,2)
)
BEGIN
    DECLARE v_salarioAnterior DECIMAL(10,2);
    DECLARE v_diferencia DECIMAL(10,2);
    DECLARE v_porcentaje DECIMAL(10,2);

    -- Obtener el salario actual
    SELECT salario INTO v_salarioAnterior
    FROM Empleado
    WHERE idEmpleado = p_idEmpleado;

    -- Calcular diferencia y porcentaje
    SET v_diferencia = p_nuevoSalario - v_salarioAnterior;
    SET v_porcentaje = (v_diferencia / v_salarioAnterior) * 100;

    -- Actualizar salario
    UPDATE Empleado
    SET salario = p_nuevoSalario
    WHERE idEmpleado = p_idEmpleado;

    -- Insertar registro en el historial
    INSERT INTO HistorialSalarios(
        idEmpleado, salarioAnterior, salarioNuevo, diferencia, porcentajeCambio, fechaCambio
    )
    VALUES (
        p_idEmpleado, v_salarioAnterior, p_nuevoSalario, v_diferencia, v_porcentaje, NOW()
    );
END $$

DELIMITER ;