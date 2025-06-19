DROP DATABASE  IF EXISTS pizzeria_db;
CREATE DATABASE pizzeria_db;

USE pizzeria_db;

CREATE TABLE `cliente`(
    `id` INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `nombre` VARCHAR(100) NOT NULL,
    `telefono` VARCHAR(11) NOT NULL,
    `direccion` VARCHAR(150) NOT NULL
);
CREATE TABLE `combo`(
    `id` INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `nombre` VARCHAR(100) NOT NULL,
    `precio` DECIMAL(10, 2) NOT NULL
);
CREATE TABLE `metodo_pago`(
    `id` INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `nombre` VARCHAR(100) NOT NULL
);
CREATE TABLE `presentacion`(
    `id` INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `nombre` VARCHAR(100) NOT NULL
);
CREATE TABLE `ingrediente`(
    `id` INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `nombre` VARCHAR(100) NOT NULL,
    `stock` INT NOT NULL,
    `precio` DECIMAL(10, 2) NOT NULL
);
CREATE TABLE `tipo_producto`(
    `id` INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `nombre` VARCHAR(100) NOT NULL
);
CREATE TABLE `producto`(
    `id` INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `nombre` VARCHAR(100) NOT NULL,
    `tipo_producto_id` INT NOT NULL,
    CONSTRAINT `producto_tipo_producto_id_foreign` 
    FOREIGN KEY(`tipo_producto_id`) 
    REFERENCES `tipo_producto`(`id`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE
);
CREATE TABLE `pedido`(
    `id` INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `fecha_recogida` DATETIME NOT NULL,
    `total` DECIMAL(10, 2) NOT NULL,
    `cliente_id` INT NOT NULL,
    `metodo_pago_id` INT NOT NULL,
    CONSTRAINT `pedido_metodo_pago_id_foreign` FOREIGN KEY(`metodo_pago_id`) REFERENCES `metodo_pago`(`id`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE
);
CREATE TABLE `detalle_pedido`(
    `id` INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `cantidad` INT NOT NULL,
    `pedido_id` INT NOT NULL,
    CONSTRAINT `detalle_pedido_pedido_id_foreign` FOREIGN KEY(`pedido_id`) REFERENCES `pedido`(`id`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE
);
CREATE TABLE `factura`(
    `id` INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `cliente` VARCHAR(100) NOT NULL,
    `total` DECIMAL(10, 2) NOT NULL,
    `fecha` DATETIME NOT NULL,
    `pedido_id` INT NOT NULL,
    `cliente_id` INT NOT NULL,
    CONSTRAINT `factura_cliente_id_foreign` FOREIGN KEY(`cliente_id`) REFERENCES `cliente`(`id`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
    CONSTRAINT `factura_pedido_id_foreign` FOREIGN KEY(`pedido_id`) REFERENCES `pedido`(`id`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE
);
CREATE TABLE `ingrediente_extra`(
    `id` INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `cantidad` INT NOT NULL,
    `detalle_pedido_id` INT NOT NULL,
    `ingrediente_id` INT NOT NULL,
    CONSTRAINT `ingredientes_extra_ingrediente_id_foreign` 
    FOREIGN KEY(`ingrediente_id`) 
    REFERENCES `ingrediente`(`id`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
    CONSTRAINT `ingredientes_extra_detalle_pedido_id_foreign` FOREIGN KEY(`detalle_pedido_id`) REFERENCES `detalle_pedido`(`id`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE
);
CREATE TABLE `combo_producto`(
    `id` INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `producto_id` INT NOT NULL,
    `combo_id` INT NOT NULL,
    CONSTRAINT `combo_producto_producto_id_foreign` FOREIGN KEY(`producto_id`) REFERENCES `producto`(`id`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
    CONSTRAINT `combo_producto_combo_id_foreign` FOREIGN KEY(`combo_id`) REFERENCES `combo`(`id`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE
);
CREATE TABLE `producto_presentacion`(
    `id` INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `producto_id` INT NOT NULL,
    `presentacion_id` INT NOT NULL,
    `precio` DECIMAL(10, 2) NOT NULL,
    CONSTRAINT `producto_presentacion_presentacion_id_foreign` FOREIGN KEY(`presentacion_id`) REFERENCES `presentacion`(`id`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
    CONSTRAINT `producto_presentacion_producto_id_foreign` FOREIGN KEY(`producto_id`) REFERENCES `producto`(`id`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE
);
CREATE TABLE `detalle_pedido_producto`(
    `detalle_id` INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `producto_id` INT NOT NULL,
    CONSTRAINT `detalle_pedido_producto_detalle_id_foreign` 
    FOREIGN KEY(`detalle_id`) 
    REFERENCES `detalle_pedido`(`id`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
    CONSTRAINT `detalle_pedido_producto_producto_id_foreign` FOREIGN KEY(`producto_id`) REFERENCES `producto`(`id`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE
);
CREATE TABLE `detalle_pedido_combo`(
    `detalle_id` INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `combo_id` INT NOT NULL,
    CONSTRAINT `detalle_pedido_combo_detalle_id_foreign` 
    FOREIGN KEY(`detalle_id`) 
    REFERENCES `detalle_pedido`(`id`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
    CONSTRAINT `detalle_pedido_combo_combo_id_foreign` FOREIGN KEY(`combo_id`) REFERENCES `combo`(`id`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE
);


CREATE TABLE IF NOT EXISTS resumen_ventas (
fecha       DATE      PRIMARY KEY,
total_pedidos INT,
total_ingresos DECIMAL(12,2),
creado_en DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS alerta_stock (
  id              INT AUTO_INCREMENT PRIMARY KEY,
  ingrediente_id  INT NOT NULL,
  stock_actual    INT NOT NULL,
  fecha_alerta    DATETIME NOT NULL,
  creado_en DATETIME DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT `alerta_stock_ingrediente` 
    FOREIGN KEY(`ingrediente_id`) 
    REFERENCES `ingrediente`(`id`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE
);

USE pizzeria_db;

-- Insertar tipos de producto
INSERT INTO tipo_producto (nombre) VALUES 
('Pizza'),
('Bebida')

-- Insertar clientes
INSERT INTO cliente (nombre, telefono, direccion) VALUES 
('Juan Pérez', '12345678901', 'Calle Principal 123'),
('María Gómez', '98765432109', 'Avenida Central 456'),
('Pedro López', '45678912345', 'Calle Secundaria 789');

-- Insertar métodos de pago
INSERT INTO metodo_pago (nombre) VALUES 
('Efectivo'),
('Tarjeta de crédito'),
('Transferencia');

-- Insertar presentaciones
INSERT INTO presentacion (nombre) VALUES 
('Pequeña'),
('Mediana'),
('Grande');

-- Insertar ingredientes
INSERT INTO ingrediente (nombre, stock, precio) VALUES 
('Queso mozzarella', 100, 2.50),
('Salsa de tomate', 200, 1.00),
('Pepperoni', 50, 3.00),
('Champiñones', 75, 2.00);

-- Insertar productos
INSERT INTO producto (nombre, tipo_producto_id) VALUES 
('Pizza pepperoni', 1),
('Pizza cuatro quesos', 1),
('Coca-Cola', 2),
('Jugo de Tamarindo', 2);

-- Insertar combos
INSERT INTO combo (nombre, precio) VALUES 
('Combo familiar', 25.00),
('Combo personal', 12.00);

-- Insertar relaciones combo-producto
INSERT INTO combo_producto (producto_id, combo_id) VALUES 
(1, 1), -- Pizza pepperoni en Combo familiar
(3, 1), -- Coca-Cola en Combo familiar
(2, 2), -- Pizza cuatro quesos en Combo personal
(3, 2); -- Coca-Cola en Combo personal

-- Insertar producto-presentación
INSERT INTO producto_presentacion (producto_id, presentacion_id, precio) VALUES 
(1, 1, 8.00),  
(1, 2, 12.00), 
(1, 3, 16.00), 
(2, 1, 9.00),  
(2, 2, 13.00), 
(2, 3, 17.00), 
(3, 2, 2.50),  
(4, 2, 5.00);  

-- Insertar pedidos
INSERT INTO pedido (fecha_recogida, total, cliente_id, metodo_pago_id) VALUES 
('2025-06-11 18:00:00', 60000, 1, 1),
('2025-06-12 19:00:00', 25000, 2, 2),
('2025-06-14 18:00:00', 100000, 3, 1),
('2025-06-10 19:00:00', 15900, 2, 2); 

-- Insertar detalles de pedido
INSERT INTO detalle_pedido (cantidad, pedido_id) VALUES 
(2, 1), 
(1, 2); 

-- Insertar detalles de pedido-producto
INSERT INTO detalle_pedido_producto (detalle_id, producto_id) VALUES 
(1, 1), 
(2, 3); 

-- Insertar detalles de pedido-combo
INSERT INTO detalle_pedido_combo (detalle_id, combo_id) VALUES 
(1, 2); 

-- Insertar ingredientes extra
INSERT INTO ingrediente_extra (cantidad, detalle_pedido_id, ingrediente_id) VALUES 
(1, 1, 3), 
(2, 1, 4); 

-- Insertar facturas
INSERT INTO factura (cliente, total, fecha, pedido_id, cliente_id) VALUES 
('Juan Pérez', 28.50, '2025-06-11 18:05:00', 1, 1),
('María Gómez', 15.50, '2025-06-11 19:05:00', 2, 2);

INSERT INTO pedido (fecha_recogida, total, cliente_id, metodo_pago_id) VALUES 
('2025-06-18 18:00:00', 60000, 1, 1),
('2025-06-18 19:00:00', 25000, 2, 2),
('2025-06-18 18:00:00', 100000, 3, 1),
('2025-06-18 19:00:00', 15900, 2, 2); 