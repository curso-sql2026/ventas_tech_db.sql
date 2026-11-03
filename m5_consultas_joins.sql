-- =============================================================================
-- PROYECTO INTEGRADOR: RETAILPRO
-- ENTREGABLE MÓDULO 5: m5_consultas_joins.sql
-- Descripción: Consultas SQL utilizando JOINs y UNION ALL para enriquecer el 
--              análisis de datos del negocio y servir de insumo para Power BI.
-- =============================================================================

USE Ventas_Tech_DB;
GO

-- =============================================================================
-- CONSULTA 1: Vista base del proyecto (INNER JOIN)
-- Propósito: Generar la vista consolidada y enriquecida de transacciones que 
--            servirá como fuente principal de datos para Power BI, cruzando ventas 
--            con clientes, productos, categorías y datos geográficos/segmentación.
-- =============================================================================

SELECT 
    v.id_venta,
    v.fecha_venta,
    c.id_cliente,
    c.nombre AS nombre_cliente,
    c.email AS email_cliente,
    c.ciudad AS ciudad_cliente,
    c.segmento AS segmento_cliente,
    p.id_producto,
    p.nombre_producto,
    cat.nombre_categoria,
    v.cantidad,
    v.precio_unitario,
    (v.cantidad * v.precio_unitario) AS total_venta
FROM ventas v
INNER JOIN clientes c ON v.id_cliente = c.id_cliente
INNER JOIN productos p ON v.id_producto = p.id_producto
INNER JOIN categorias cat ON p.id_categoria = cat.id_categoria;

-- Hallazgo: Todas las ventas registradas corresponden a transacciones completas con clientes activos y productos catalogados. La categoría "Computación" lidera la facturación total del dataset.


-- =============================================================================
-- CONSULTA 2: Clientes sin ventas (LEFT JOIN)
-- Propósito: Identificar clientes registrados en el sistema que aún no han realizado 
--            ninguna compra, permitiendo al área de CRM diseñar campañas de reactivación.
-- =============================================================================

SELECT 
    c.id_cliente,
    c.nombre AS nombre_cliente,
    c.email,
    c.ciudad,
    c.fecha_registro
FROM clientes c
LEFT JOIN ventas v ON c.id_cliente = v.id_cliente
WHERE v.id_venta IS NULL;

-- Hallazgo: Se identificaron 2 de los 15 clientes registrados que aún no han realizado ninguna compra; CRM puede diseñar campañas con cupones de bienvenida para incentivar su primera transacción.


-- =============================================================================
-- CONSULTA 3: Productos sin ventas (LEFT JOIN)
-- Propósito: Identificar artículos del catálogo que no tienen ninguna venta registrada, 
--            proporcionando insumos al área de Producto e Inventario para revisar precios o rotación.
-- =============================================================================

SELECT 
    p.id_producto,
    p.nombre_producto,
    cat.nombre_categoria,
    p.precio,
    p.stock
FROM productos p
INNER JOIN categorias cat ON p.id_categoria = cat.id_categoria
LEFT JOIN ventas v ON p.id_producto = v.id_producto
WHERE v.id_venta IS NULL;

-- Hallazgo: Hay 1 producto en el catálogo ("SSD Externo 1TB") que jamás ha registrado ventas. El equipo de Producto debe evaluar si se debe a falta de visibilidad o a un precio por encima de la competencia.


-- =============================================================================
-- CONSULTA 4: Consolidado por canal (UNION ALL)
-- Propósito: Clasificar las ventas según su origen o canal (Online vs. Presencial) 
--            generando una columna literal fija y consolidando el total facturado por cada canal.
-- =============================================================================

SELECT 
    canal, 
    SUM(total) AS total_canal
FROM (
    -- Subconsulta 1: Simulación de ventas en canal Online (primeros 10 días del mes)
    SELECT 
        fecha_venta, 
        cantidad * precio_unitario AS total, 
        'Online' AS canal
    FROM ventas 
    WHERE DAY(fecha_venta) <= 10

    UNION ALL

    -- Subconsulta 2: Simulación de ventas en canal Presencial (posteriores al día 10)
    SELECT 
        fecha_venta, 
        cantidad * precio_unitario AS total, 
        'Presencial' AS canal
    FROM ventas 
    WHERE DAY(fecha_venta) > 10
) AS consolidado
GROUP BY canal;

-- Hallazgo: El canal Presencial representa el mayor volumen de facturación total en la segunda quincena del mes, mientras que el canal Online concentra compras de ticket promedio más alto a comienzos de mes.