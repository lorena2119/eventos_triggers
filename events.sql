USE pizzeria_db;
-- 1. Resumen Diario Único : crear un evento que genere un resumen de ventas **una sola vez** al finalizar el día de ayer y luego se elimine automáticamente llamado `ev_resumen_diario_unico`.
DELIMITER $$
CREATE EVENT ev_resumen_diario_unico
ON SCHEDULE AT CURRENT_TIMESTAMP + INTERVAL 1 DAY
ON COMPLETION NOT PRESERVE
DO
BEGIN
    INSERT INTO resumen_ventas (fecha, total_ingresos, total_pedidos)
    SELECT 
        DATE_SUB(CURDATE(), INTERVAL 1 DAY) AS fecha,
        SUM(total) AS 'Ingresos Totales',
        COUNT(id) AS 'Total de pedidos realizados'
    FROM pedido
    WHERE DATE(fecha_recogida) = DATE_SUB(CURDATE(), INTERVAL 1 DAY);
END $$
DELIMITER ;
SELECT * FROM information_schema.events WHERE event_name = 'ev_resumen_diario_unico';
DROP EVENT IF EXISTS ev_resumen_diario_unico;
SELECT * 
FROM resumen_ventas;

-- 2. Resumen Semanal Recurrente: cada lunes a las 01:00 AM, generar el total de pedidos e ingresos de la semana pasada, **manteniendo** el evento para que siga ejecutándose cada semana llamado `ev_resumen_semanal`.
DELIMITER $$
CREATE EVENT ev_resumen_semanal
ON SCHEDULE EVERY 1 WEEK 
STARTS '2025-06-23 00:00:00'
DO
BEGIN
    INSERT INTO resumen_ventas (fecha, total_ingresos, total_pedidos)
    SELECT 
        DATE_SUB(CURDATE(), INTERVAL 1 WEEK) AS fechaInicio,
        SUM(total) AS 'Ingresos Totales',
        COUNT(id) AS 'Total de pedidos realizados'
    FROM pedido
    WHERE DATE(fecha_recogida) = DATE_SUB(CURDATE(), INTERVAL 1 WEEK);
END $$
DELIMITER ;
SELECT * FROM information_schema.events WHERE event_name = 'ev_resumen_semanal';
DROP EVENT IF EXISTS ev_resumen_semanal;
SELECT * 
FROM resumen_ventas;

--3. Alerta de Stock Bajo Única: en un futuro arranque del sistema (requerimiento del sistema), generar una única pasada de alertas (`alerta_stock`) de ingredientes con stock < 5, y luego autodestruir el evento.
DELIMITER $$
CREATE EVENT alerta_stock_unica
ON SCHEDULE AT CURRENT_TIMESTAMP + INTERVAL 1 DAY
ON COMPLETION NOT PRESERVE
DO
BEGIN
    INSERT INTO alerta_stock (ingrediente_id, stock_actual, fecha_alerta)
    SELECT 
        id,
        stock,
        NOW()
    FROM ingrediente
    WHERE stock < 5;
END $$
DELIMITER ;
SELECT * FROM information_schema.events WHERE event_name = 'alerta_stock';
DROP EVENT IF EXISTS alerta_stock_unica;
SELECT * 
FROM alerta_stock;

-- 4. Monitoreo Continuo de Stock: cada 30 minutos, revisar ingredientes con stock < 10 e insertar alertas en `alerta_stock`, **dejando** el evento activo para siempre llamado `ev_monitor_stock_bajo`.
DELIMITER $$
CREATE EVENT ev_monitor_stock_bajo
ON SCHEDULE EVERY 30 MINUTE 
DO
BEGIN
    INSERT INTO alerta_stock (ingrediente_id, stock_actual, fecha_alerta)
    SELECT 
        id,
        stock,
        NOW()
    FROM ingrediente
    WHERE stock < 10;
END $$
DELIMITER ;
SELECT * FROM information_schema.events WHERE event_name = 'ev_monitor_stock_bajo';
DROP EVENT IF EXISTS ev_monitor_stock_bajo;
SELECT * 
FROM resumen_ventas;
-- TRUNCATE Table alerta_stock;

-- 5. Limpieza de Resúmenes Antiguos: una sola vez, eliminar de `resumen_ventas` los registros con fecha anterior a hace 365 días y luego borrar el evento llamado `ev_purgar_resumen_antiguo`.
DROP EVENT IF EXISTS ev_purgar_resumen_antiguo;
CREATE EVENT ev_purgar_resumen_antiguo
ON SCHEDULE AT CURRENT_TIMESTAMP + INTERVAL 1 SECOND
ON COMPLETION NOT PRESERVE
DO
    DELETE FROM resumen_ventas WHERE creado_en < NOW() - INTERVAL 365 DAY;

SELECT * FROM information_schema.events WHERE event_name = 'ev_purgar_resumen_antiguo';