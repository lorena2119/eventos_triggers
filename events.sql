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
