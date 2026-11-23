
-- CASO 1: LISTADO DE CLIENTES
SELECT TO_CHAR(c.numrun, 'FM99G999G999', 'NLS_NUMERIC_CHARACTERS='',.''')
           || '-' || c.dvrun AS "RUT Cliente",
       INITCAP(TRIM(c.pnombre) || ' ' || c.appaterno) AS "Nombre Cliente",
       UPPER(p.nombre_prof_ofic) AS "Profesión Cliente",
       TO_CHAR(c.fecha_inscripcion, 'DD-MM-YYYY') AS "Fecha de Inscripción",
       c.direccion AS "Dirección Cliente"
FROM CLIENTE c
JOIN PROFESION_OFICIO p
  ON c.cod_prof_ofic = p.cod_prof_ofic
JOIN TIPO_CLIENTE t
  ON c.cod_tipo_cliente = t.cod_tipo_cliente
WHERE UPPER(p.nombre_prof_ofic) IN ('CONTADOR', 'VENDEDOR')
  AND UPPER(t.nombre_tipo_cliente) = 'TRABAJADORES DEPENDIENTES'
  AND EXTRACT(YEAR FROM c.fecha_inscripcion) >
      (SELECT ROUND(AVG(EXTRACT(YEAR FROM fecha_inscripcion)))
       FROM CLIENTE)
ORDER BY c.numrun ASC;

-- CASO 2: CREAR TABLA DE CLIENTES CON CUPO DISPONIBLE
CREATE TABLE CLIENTES_CUPOS_COMPRA AS
SELECT TO_CHAR(c.numrun, 'FM99G999G999', 'NLS_NUMERIC_CHARACTERS='',.''')
          || '-' || c.dvrun AS RUT_CLIENTE,
       TRUNC(MONTHS_BETWEEN(SYSDATE, c.fecha_nacimiento) / 12) AS EDAD,
       '$' || TO_CHAR(t.cupo_disp_compra, 'FM999G999G999',
                     'NLS_NUMERIC_CHARACTERS='',.''') AS CUPO_DISPONIBLE_COMPRA,
       UPPER(tc.nombre_tipo_cliente) AS TIPO_CLIENTE
FROM CLIENTE c
JOIN TARJETA_CLIENTE t
  ON c.numrun = t.numrun
JOIN TIPO_CLIENTE tc
  ON c.cod_tipo_cliente = tc.cod_tipo_cliente
WHERE t.cupo_disp_compra >=
      (SELECT MAX(cupo_disp_compra)
       FROM TARJETA_CLIENTE
       WHERE EXTRACT(YEAR FROM fecha_solic_tarjeta) =
             EXTRACT(YEAR FROM SYSDATE) - 1);

-- VERIFICACION CASO 2: RESULTADOS EN ORDEN ASCENDENTE POR EDAD
SELECT RUT_CLIENTE, EDAD, CUPO_DISPONIBLE_COMPRA, TIPO_CLIENTE
FROM CLIENTES_CUPOS_COMPRA
ORDER BY EDAD ASC;
