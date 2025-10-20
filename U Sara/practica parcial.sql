create database trabajador;
use trabajador;
drop database trabajador;

CREATE TABLE Departamento (
    idDepartamento INT AUTO_INCREMENT PRIMARY KEY,
    nombreDepartamento VARCHAR(50) NOT NULL
);

CREATE TABLE Empleado (
    idEmpleado INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    edad INT NOT NULL,
    salario DECIMAL(10,2) NOT NULL,
    fechaContratacion DATE NOT NULL,
    idDepartamento INT,
    FOREIGN KEY (idDepartamento) REFERENCES Departamento(idDepartamento)
);
 
INSERT INTO Departamento (nombreDepartamento) VALUES
('IT'),
('Ventas'),
('Recursos Humanos'),
('Marketing'),
('Finanzas');

INSERT INTO Empleado (nombre, edad, salario, fechaContratacion, idDepartamento) VALUES
('Ana Torres', 29, 3800.00, '2021-06-15', 2),
('Carlos López', 35, 4500.00, '2019-03-10', 2),
('María Gómez', 42, 5200.00, '2015-11-05', 1),
('Andrés Pérez', 31, 4100.00, '2022-02-20', 4),
('Camila Duarte', 26, 3700.00, '2023-04-12', 3),
('Pedro Sánchez', 39, 6000.00, '2016-08-01', 5),
('Lucía Fernández', 33, 3950.00, '2020-07-23', 1),
('Julián Rodríguez', 45, 7200.00, '2010-12-18', 5),
('Adriana Molina', 28, 3100.00, '2021-09-05', 4),
('Cristian Mejía', 37, 4300.00, '2018-05-27', 2),
('Natalia Vargas', 30, 4800.00, '2022-11-09', 3);

select nombre, edad, salario from empleado;

select*from empleado where salario>4000;

select*from empleado where IdDepartamento=2;

select*from empleado where edad between "30" AND "40";

select*from empleado where fechaContratacion>"2020-01-01";

SELECT d.nombreDepartamento, COUNT(*) AS "Cantidad de Empleados"
FROM empleado e
JOIN departamento d ON e.idDepartamento = d.idDepartamento
GROUP BY d.nombreDepartamento;

select avg(salario) as "Salario Promedio" from empleado;

select*from empleado where nombre LIKE "A%" or  nombre like "C%";

select*from empleado where idDepartamento Not like 1;

select max(salario) as "Mejor Salario" from empleado;

#Ejercicios subconsultas y joins

#1
select e.nombre as "Nombre empleado", 
d.nombreDepartamento as "Nombre departamento"
from empleado e
join departamento d
on e.idDepartamento= d.idDepartamento;

#2
select e.nombre as "Nombre empleado", 
d.nombreDepartamento as "Nombre departamento"
from empleado e
right join departamento d
on e.idDepartamento= d.idDepartamento;

#4 
select round((salario),2) as "salario Promedio" ,
d.nombreDepartamento as "Nombre departamento"
from empleado e
join departamento d
on e.idDepartamento= d.idDepartamento
group by d.nombreDepartamento;

#5
select nombre, salario 
from empleado 
where salario > (select avg(salario) from empleado);

#6 
select e.nombre as "nombre de empleado",
d.nombreDepartamento as "nombre departamento",
e.salario
from empleado e
join departamento d 
on e.idDepartamento= d.idDepartamento
where e.salario > (select avg(e2.salario) from empleado e2
where e.idDepartamento= d.idDepartamento);

#7
select e.nombre as "nombre de empleado",
d.nombreDepartamento as "nombre departamento",
e.salario
from empleado e
join departamento d 
on e.idDepartamento= d.idDepartamento
group by e.salario= (select max(e2.salario) from empleado e2
where e.idDepartamento= d.idDepartamento);

#8
SELECT 
  d.nombreDepartamento AS "Nombre del departamento",
  COUNT(e.idEmpleado) AS "Número de empleados"
FROM departamento d
JOIN empleado e 
  ON d.idDepartamento = e.idDepartamento
GROUP BY d.nombreDepartamento
HAVING COUNT(e.idEmpleado) > 3;

#9
SELECT 
  nombre AS "Empleado más reciente",
  fechaContratacion
FROM empleado
ORDER BY fechaContratacion DESC
LIMIT 1;

#Modificaciones
select * from empleado;
update empleado set nombre= "Amparo" where idEmpleado=1;

select* from empleado;
update empleado set nombre= "Amparo", salario= 3900 where idEmpleado=1;

#Eliminar
delete from empleado where idEmpleado=1;

start transaction; 
delete from empleado where idEmpleado>5;
commit;

/*revertir*/

start transaction;
delete from empleado where IdEmpleado>5;
rollback;
show variables like "autocommit";
SHOW TABLE STATUS LIKE 'empleado';

#vistas
create view vistaEmpleados as select e.nombre as "nombre empleado" ,
e.idDepartamento as "Departamento perteneciente" from empleado e;

select * from vistaEmpleados;

create view vistaDepartamento as select e.nombre as "Empleado", 
d.idDepartamento as "Departamento" 
from empleado e 
inner join Departamento d on e.idDepartamento=d.idDepartamento;

select*from vistaDepartamento;


use
DELIMITER $$
create procedure empleadoporId (in idEmpl int)
begin select nombre from empleado 
where idEmpleado= IdEmpl;
end $$
DELIMITER ;
call empleadoporId(3);

DELIMITER $$
create procedure 
