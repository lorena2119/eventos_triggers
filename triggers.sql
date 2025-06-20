USE pizzeria_db;
--- 1. Validar stock antes de agregar detalle de producto (Trigger `BEFORE INSERT`).
DELIMITER $$
DROP TRIGGER IF EXISTS trg_before_insert_detalle;
CREATE TRIGGER IF NOT EXISTS trg_before_insert_detalle
BEFORE INSERT ON detalle_pedido
FOR EACH ROW
BEGIN
    IF NEW.cantidad < 1 THEN
        SIGNAL SQLSTATE '40001'
         SET MESSAGE_TEXT = 'La cantidad de ser minimo 1';

    END IF;
END $$
DELIMITER ;

-- 2. Descontar stock tras agregar ingredientes extra (Trigger `AFTER INSERT`).
DELIMITER $$
DROP TRIGGER IF EXISTS trg_after_agregar_ingrediente;
CREATE TRIGGER IF NOT EXISTS trg_after_agregar_ingrediente
AFTER INSERT ON ingrediente_extra
FOR EACH ROW
BEGIN
    UPDATE ingrediente SET stock = stock - NEW.cantidad WHERE NEW.ingrediente_id = id;
END $$
DELIMITER ;
SELECT * FROM ingrediente;

-- 3. Registrar auditoría de cambios de precio (Trigger `AFTER UPDATE`).
DROP TRIGGER IF EXISTS trg_after_agregar_auditoria;
DELIMITER $$
CREATE TRIGGER IF NOT EXISTS trg_after_agregar_auditoria
AFTER UPDATE ON producto_presentacion
FOR EACH ROW
BEGIN
    IF NEW.precio <> OLD.precio THEN
        INSERT INTO auditoria_precio(producto_id, old_precio, new_precio, creado_en, usuario_creador, presentacion_id) VALUES
        (NEW.producto_id, OLD.precio, NEW.precio, NOW(), USER(), NEW.presentacion_id);
    END IF;
END $$
DELIMITER ;
SELECT * FROM auditoria_precio;
 UPDATE producto_presentacion SET precio = 28000  WHERE id = 2;

-- 4. Impedir precio cero o negativo en producto_presentacion (Trigger `BEFORE UPDATE`).
DELIMITER $$
DROP TRIGGER IF EXISTS trg_avoid_cero_in_precio;
CREATE TRIGGER IF NOT EXISTS trg_avoid_cero_in_precio
BEFORE INSERT ON producto_presentacion
FOR EACH ROW
BEGIN
    IF NEW.precio < 1 THEN
        SIGNAL SQLSTATE '40001'
         SET MESSAGE_TEXT = 'El precio debe ser mayor a 0';

    END IF;
END $$
DELIMITER ;

-- 5. Generar factura automática (Trigger `AFTER INSERT`).
DROP TRIGGER IF EXISTS trg_after_agregar_pedido;
DELIMITER $$
CREATE TRIGGER IF NOT EXISTS trg_after_agregar_pedido
AFTER INSERT ON pedido
FOR EACH ROW
BEGIN
    DECLARE cliente_nombre VARCHAR(100);

    SELECT nombre INTO cliente_nombre
    FROM cliente
    WHERE id = NEW.cliente_id;
    
    -- IF cliente_nombre IS NULL THEN
    --     SIGNAL SQLSTATE '45000'
    --     SET MESSAGE_TEXT = 'Error: No se encontró el cliente para el cliente_id especificado';
    -- END IF;
    INSERT INTO factura(cliente, total, fecha, pedido_id, cliente_id) VALUES
    (cliente_nombre, NEW.total, NOW(), NEW.id, NEW.cliente_id);
END $$
DELIMITER ;
SELECT * FROM factura;

-- 6. Actualizar estado de pedido tras facturar (Trigger `AFTER INSERT`).
DELIMITER $$
CREATE TRIGGER IF NOT EXISTS trg_after_cambiar_estado
AFTER INSERT ON factura
FOR EACH ROW
BEGIN
    UPDATE pedido SET estado = 'Pocesando' WHERE id = NEW.pedido_id;
END $$
DELIMITER ;
SELECT * FROM factura;
SELECT * FROM pedido;