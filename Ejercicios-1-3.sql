-- EJERCICIO 2
--  2a
-- AL NO HABER UN CÓDIGO DE MOVIMIENTO INTUYO QUE CADA ENTRADA CONTIENE TODAS 
-- LAS VENTAS DE UN PRODUCTO PARA UNA FECHA A UN CLIENTE ESPECIFICO
CREATE TABLE DB.SCHEMA.Ganancias_Diarias AS (
    WITH tabla1 AS (
        SELECT
            prod.cod_prod,
            prod.descripcion AS descripcion_producto,
            marca.descripcion AS descripcion_marca,
            prov.descripcion AS descripcion_proveedor

        FROM Data_Productos prod
            LEFT JOIN Data_Marcas marca 
                ON prod.cod_marca = marca.cod_marca
            LEFT JOIN Data_Proovedores prov
                ON prod.cod_prod = prov.cod_prod

    )

    SELECT
        fecha,
        cli.descripcion AS descripcion_cliente,
        t1.descripcion_proveedor,
        t1.descripcion_producto,
        t1.descripcion_marca,
        cantidad,
        costo,
        venta,
        ((venta / cantidad) - (costo / cantidad)) AS ganancia_neta

    FROM Data_Movimientos mov

        LEFT JOIN tabla1 t1
            ON mov.cod_prod = t1.cod_prod

        LEFT JOIN Data_Clientes cli
            ON mov.cod_cliente = cli.cod_cliente
)
-- 2b

WITH tabla1 AS (
    SELECT
        prod.cod_prod,
        prod.cod_marca,
        marca.descripcion AS descripcion_marca

    FROM Data_Productos prod
    -- EN ESTE CASO ESTARÍAMOS TOMANDO UNICAMENTE AQUELLAS MARCAS QUE TIENEN PRODUCTOS ASOCIADOS
        LEFT JOIN Data_Marcas marca
            ON prod.cod_marca = marca.cod_marca
),

tabla2 AS (

    SELECT
        t1.cod_marca,
        t1.descripcion_marca,

        nvl(SUM(mov.cantidad), 0)) AS total_unidades

    FROM tabla1 t1
        LEFT JOIN Data_Movimientos mov
            ON t1.cod_prod = mov.cod_prod
    GROUP BY 1,2
)

SELECT
    cod_marca,
    descripcion_marca

FROM tabla2
WHERE total_unidades = 0

-- 2c

WITH tabla1 AS (
    SELECT
        fecha,
        descripcion_cliente,

        SUM(ganancia_neta),
        ROW_NUMBER() OVER( PARTITION BY descripcion_cliente, ganancia_neta ORDER BY fecha) AS orden_transaccion

    FROM Ganancias_Diarias
    WHERE fecha <= '2022-04-20' -- FECHA RANDOM
        AND descripcion_cliente = 'Nombre Cliente'
    GROUP BY 1,2
)

SELECT
    fecha,
    descripcion_cliente,

    SUM(ganancia_neta)

FROM tabla1
WHERE orden_transaccion <= 7
GROUP BY 1,2
ORDER BY 1,2


-- EJERCICIO 3

--3a Scheduleando un script de python con Cron especficando minuto hora dia mes a ejecutar y el script
--3b Con un archivo txt que loguee las ocurrencias de la ejecución