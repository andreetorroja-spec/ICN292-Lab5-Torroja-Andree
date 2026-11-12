-- ICN292 - Laboratorio 5 - Andree Torroja
-- Ejecutar sobre una base vacia en MySQL.
CREATE DATABASE andesbike CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE andesbike;

CREATE TABLE tiendas (
    id_tienda INT PRIMARY KEY,
    nombre VARCHAR(60) NOT NULL,
    comuna VARCHAR(50) NOT NULL
);

CREATE TABLE vendedores (
    id_vendedor INT PRIMARY KEY,
    nombre VARCHAR(80) NOT NULL,
    id_tienda INT NULL,
    fecha_ingreso DATE NOT NULL,
    FOREIGN KEY (id_tienda) REFERENCES tiendas(id_tienda)
);

CREATE TABLE bicicletas (
    id_bicicleta INT PRIMARY KEY,
    modelo VARCHAR(60) NOT NULL,
    categoria ENUM('Eléctrica','Infantil','Montaña','Ruta','Urbana') NOT NULL,
    precio DECIMAL(10,2) NOT NULL CHECK (precio > 0)
);

CREATE TABLE ventas (
    id_venta INT PRIMARY KEY,
    id_vendedor INT NOT NULL,
    id_bicicleta INT NOT NULL,
    fecha DATE NOT NULL,
    unidades INT NOT NULL CHECK (unidades > 0),
    FOREIGN KEY (id_vendedor) REFERENCES vendedores(id_vendedor),
    FOREIGN KEY (id_bicicleta) REFERENCES bicicletas(id_bicicleta)
);

INSERT INTO tiendas (id_tienda, nombre, comuna) VALUES
(1, 'Andes Providencia', 'Providencia'),
(2, 'Andes Maipú', 'Maipú'),
(3, 'Andes Concepción', 'Concepción'),
(4, 'Andes La Serena', 'La Serena');

INSERT INTO vendedores (id_vendedor, nombre, id_tienda, fecha_ingreso) VALUES
(1, 'Camila Ortiz', 1, '2024-06-20'),
(2, 'Diego Fuentes', 1, '2024-01-15'),
(3, 'Javiera Soto', 2, '2023-07-24'),
(4, 'Matías Herrera', 2, '2024-01-15'),
(5, 'Paula Riquelme', 3, '2022-11-02'),
(6, 'Ignacio Vera', 3, '2024-08-19'),
(7, 'Fernanda Lillo', 1, '2025-02-03'),
(8, 'Rubén Castro', NULL, '2025-06-10');

INSERT INTO bicicletas (id_bicicleta, modelo, categoria, precio) VALUES
(1, 'Cordillera 29', 'Montaña', 549990.00),
(2, 'Ruta Austral', 'Ruta', 899990.00),
(3, 'Urbana Pro', 'Urbana', 329990.00),
(4, 'Pequeño Andes', 'Infantil', 149990.00),
(5, 'Volt City', 'Eléctrica', 1249990.00),
(6, 'Trail Master', 'Montaña', 749990.00),
(7, 'Urbana Lite', 'Urbana', 229990.00),
(8, 'Sprint R7', 'Ruta', 1099990.00);

INSERT INTO ventas
(id_venta, id_vendedor, id_bicicleta, fecha, unidades) VALUES
(1, 1, 1, '2025-03-04', 2),
(2, 1, 3, '2025-03-18', 1),
(3, 1, 5, '2025-04-02', 1),
(4, 2, 2, '2025-03-04', 1),
(5, 2, 1, '2025-04-11', 3),
(6, 2, 7, '2025-05-06', 2),
(7, 3, 4, '2025-03-21', 4),
(8, 3, 3, '2025-04-15', 2),
(9, 3, 6, '2025-05-20', 1),
(10, 4, 1, '2025-03-27', 1),
(11, 4, 5, '2025-05-09', 2),
(12, 5, 2, '2025-04-08', 1),
(13, 5, 6, '2025-04-23', 2),
(14, 5, 4, '2025-06-02', 5),
(15, 6, 3, '2025-05-13', 3),
(16, 6, 7, '2025-06-17', 1),
(17, 6, 1, '2025-06-24', 2),
(18, 1, 6, '2025-06-30', 1);

-- Consulta 1
SELECT v.nombre, COUNT(ve.id_venta) AS cantidad_ventas
FROM vendedores AS v
LEFT JOIN ventas AS ve ON ve.id_vendedor = v.id_vendedor
GROUP BY v.id_vendedor, v.nombre
ORDER BY cantidad_ventas DESC, v.nombre ASC;

-- Consulta 2
SELECT t.nombre, COUNT(ve.id_venta) AS cantidad_ventas,
       COALESCE(SUM(ve.unidades), 0) AS unidades_vendidas
FROM tiendas AS t
LEFT JOIN vendedores AS v ON v.id_tienda = t.id_tienda
LEFT JOIN ventas AS ve ON ve.id_vendedor = v.id_vendedor
GROUP BY t.id_tienda, t.nombre
ORDER BY unidades_vendidas DESC;

-- Consulta 3
SELECT t.nombre
FROM tiendas AS t
LEFT JOIN vendedores AS v ON v.id_tienda = t.id_tienda
WHERE v.id_vendedor IS NULL;

-- Consulta 4
SELECT b.modelo
FROM bicicletas AS b
LEFT JOIN ventas AS ve
    ON ve.id_bicicleta = b.id_bicicleta
   AND ve.fecha >= '2025-06-01'
   AND ve.fecha < '2025-07-01'
WHERE ve.id_venta IS NULL;

-- Consulta 5
SELECT v.nombre AS vendedor, t.nombre AS tienda
FROM vendedores AS v
LEFT JOIN tiendas AS t ON t.id_tienda = v.id_tienda
LEFT JOIN ventas AS ve ON ve.id_vendedor = v.id_vendedor
WHERE ve.id_venta IS NULL;

-- Consulta 6
SELECT v1.nombre AS vendedor_1,
       v1.fecha_ingreso AS ingreso_1,
       v2.nombre AS vendedor_2,
       v2.fecha_ingreso AS ingreso_2,
       t.nombre AS tienda
FROM vendedores AS v1
JOIN vendedores AS v2
    ON v1.id_tienda = v2.id_tienda
   AND (v1.fecha_ingreso < v2.fecha_ingreso
        OR (v1.fecha_ingreso = v2.fecha_ingreso
            AND v1.id_vendedor < v2.id_vendedor))
JOIN tiendas AS t ON t.id_tienda = v1.id_tienda;

-- Consulta 7
SELECT t.nombre, SUM(ve.unidades * b.precio) AS monto_total
FROM tiendas AS t
JOIN vendedores AS v ON v.id_tienda = t.id_tienda
JOIN ventas AS ve ON ve.id_vendedor = v.id_vendedor
JOIN bicicletas AS b ON b.id_bicicleta = ve.id_bicicleta
WHERE b.categoria IN ('Montaña', 'Ruta')
GROUP BY t.id_tienda, t.nombre
HAVING SUM(ve.unidades * b.precio) > 2000000
ORDER BY monto_total DESC;

-- Consulta 8
SELECT modelo, precio
FROM bicicletas
WHERE precio > (SELECT AVG(precio) FROM bicicletas)
ORDER BY precio DESC;

-- Consulta 9
SELECT v.nombre, AVG(ve.unidades) AS promedio_unidades
FROM vendedores AS v
JOIN ventas AS ve ON ve.id_vendedor = v.id_vendedor
GROUP BY v.id_vendedor, v.nombre
HAVING AVG(ve.unidades) > (SELECT AVG(unidades) FROM ventas)
ORDER BY promedio_unidades DESC, v.nombre ASC;

-- Consulta 10
SELECT v.nombre, SUM(ve.unidades * b.precio) AS monto_total
FROM vendedores AS v
LEFT JOIN ventas AS ve ON ve.id_vendedor = v.id_vendedor
LEFT JOIN bicicletas AS b ON b.id_bicicleta = ve.id_bicicleta
GROUP BY v.id_vendedor, v.nombre
ORDER BY monto_total DESC;
