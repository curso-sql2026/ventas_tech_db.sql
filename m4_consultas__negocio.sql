USE Ventas_Tech_DB;
GO

-- ============================================================================
-- CONSULTA 1: Resumen ejecutivo mensual
-- Muestra el total facturado, cantidad de pedidos y ticket promedio por mes.
-- ============================================================================
SELECT 
    MONTH(fecha_venta) AS mes,
    SUM(cantidad * precio_unitario) AS total_facturado,
    COUNT(*) AS cantidad_pedidos,
    AVG(cantidad * precio_unitario) AS ticket_promedio
FROM 
    ventas
GROUP BY 
    MONTH(fecha_venta)
ORDER BY 
    mes;
GO


-- ============================================================================
-- CONSULTA 2: Ranking de productos (Top 5)
-- Top 5 de productos por facturación total y sus unidades vendidas.
-- ============================================================================
SELECT TOP 5
    id_producto,
    SUM(cantidad) AS unidades_vendidas,
    SUM(cantidad * precio_unitario) AS total_generado
FROM 
    ventas
GROUP BY 
    id_producto
ORDER BY 
    total_generado DESC;
GO


-- ============================================================================
-- CONSULTA 3: Clientes recurrentes
-- Clientes con más de un pedido, mostrando pedidos realizados y gasto total.
-- ============================================================================
SELECT 
    id_cliente,
    COUNT(*) AS cantidad_pedidos,
    SUM(cantidad * precio_unitario) AS total_gastado
FROM 
    ventas
GROUP BY 
    id_cliente
HAVING 
    COUNT(*) > 1
ORDER BY 
    total_gastado DESC;
GO


-- ============================================================================
-- CONSULTA 4: Meses por encima/por debajo del promedio general
-- Compara la facturación de cada mes con el promedio de facturación mensual general.
-- ============================================================================
WITH FacturacionMensual AS (
    SELECT 
        MONTH(fecha_venta) AS mes,
        SUM(cantidad * precio_unitario) AS total_facturado
    FROM 
        ventas
    GROUP BY 
        MONTH(fecha_venta)
)
SELECT 
    mes,
    total_facturado,
    CASE 
        WHEN total_facturado >= (SELECT AVG(total_facturado) FROM FacturacionMensual) 
            THEN 'Por encima'
        ELSE 'Por debajo'
    END AS comparativa_promedio
FROM 
    FacturacionMensual
ORDER BY 
    mes;
GO


-- ============================================================================
-- BLOQUE DE CIERRE: Hallazgos de Negocio
-- ============================================================================
/*
HALLAZGOS CONCRETOS A PARTIR DE LOS RESULTADOS:

1. Concentración temporal en marzo:
   La totalidad de las ventas registradas (10 transacciones que suman $5.998,00) 
   ocurrieron en el mes de marzo (Mes 3), por lo que actualmente marzo representa 
   el 100% de la facturación y no existen datos comparativos para otros meses.

2. Concentración de facturación en el Producto 1:
   El producto con id_producto = 1 lidera ampliamente el ranking con $3.600,00 
   facturados (3 unidades vendidas), representando aproximadamente el 60% de los 
   ingresos totales de la empresa.

3. Fidelización y recurrencia de clientes:
   El 100% de la base de clientes actual (los 5 clientes registrados) son recurrentes, 
   habiendo realizado exactamente 2 pedidos cada uno en la plataforma.
*/