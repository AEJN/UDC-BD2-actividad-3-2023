CREATE TABLE Deudores (
    cc NUMBER NOT NULL,
    clave VARCHAR2(20) NOT NULL,
    nombre VARCHAR2(50) NOT NULL,
    apellido VARCHAR2(50) NOT NULL,
    email VARCHAR2(100) NOT NULL,
    CONSTRAINT pk_deudores PRIMARY KEY (cc),
    CONSTRAINT uk_deudores_email UNIQUE (email)
);

CREATE TABLE Creditos (
    id NUMBER NOT NULL,
    fecha DATE NOT NULL,
    valor NUMBER NOT NULL,
    cuotas NUMBER NOT NULL,
    interes NUMBER NOT NULL,
    estado VARCHAR2(20) DEFAULT 'Activo' NOT NULL,
    deudor_id NUMBER NOT NULL,
    CONSTRAINT pk_creditos PRIMARY KEY (id),
    CONSTRAINT fk_creditos_deudores FOREIGN KEY (deudor_id) REFERENCES Deudores(cc)
);

CREATE TABLE Pagos (
    id NUMBER NOT NULL,
    fecha DATE NOT NULL,
    valor NUMBER(10, 2) NOT NULL CHECK (valor > 0),
    credito_id NUMBER NOT NULL,
    CONSTRAINT pk_pagos PRIMARY KEY (id),
    CONSTRAINT fk_pagos_creditos FOREIGN KEY (credito_id) REFERENCES CreditZos(id)
);

INSERT INTO Deudores (cc, clave, nombre, apellido, email)
VALUES (123, 'Abc', 'Fulanito', 'De tal', 'fulanito1@gmail.com');

SELECT cc, clave, nombre, apellido, email
FROM Deudores;

INSERT INTO Creditos (id, fecha, valor, cuotas, interes, estado, deudor_id)
VALUES (1, TO_DATE('2022-05-09', 'YYYY-MM-DD'), 100000, 5, 0.40, 'Activo', 123);

SELECT id, fecha, valor, cuotas, interes, estado, deudor_id
FROM Creditos;

INSERT INTO Pagos (id, fecha, valor, credito_id)
VALUES (1, ADD_MONTHS((SELECT fecha FROM Creditos WHERE id = 1), 1), 28000, 1);

INSERT INTO Pagos (id, fecha, valor, credito_id)
VALUES (2, ADD_MONTHS(SYSDATE, 1), 28000, 1);

INSERT INTO Pagos (id, fecha, valor, credito_id)
VALUES (3, ADD_MONTHS((SELECT fecha FROM Pagos WHERE id = 1), 1), 28000, 1);

INSERT INTO Pagos (id, fecha, valor, credito_id)
VALUES (4, ADD_MONTHS((SELECT fecha FROM Pagos WHERE id = 1), 1), 28000, 1);

INSERT INTO Pagos (id, fecha, valor, credito_id)
VALUES (5, ADD_MONTHS((SELECT fecha FROM Pagos WHERE id = 1), 1), -28000, 1);

UPDATE Creditos
SET estado = 'Finalizado'
WHERE id = 1;

SELECT id, fecha, valor, cuotas, interes, estado, deudor_id
FROM Creditos
WHERE id = 1;

SELECT id, fecha, valor, credito_id
FROM Pagos
WHERE credito_id = 1;

SELECT 'TOTAL PAGOS: $' || SUM(valor) AS Total_Pagos
FROM Pagos
WHERE credito_id = 1;

DELETE FROM Pagos WHERE credito_id = 1;

SELECT * FROM Pagos WHERE credito_id = 1;

BEGIN
  
   DECLARE
      v_fecha_credito DATE;
   BEGIN

      SELECT fecha INTO v_fecha_credito FROM Creditos WHERE id = 1;
      
   
      INSERT INTO Pagos (id, fecha, valor, credito_id) VALUES (1, ADD_MONTHS(v_fecha_credito, 1), 28000, 1);
      INSERT INTO Pagos (id, fecha, valor, credito_id) VALUES (2, ADD_MONTHS(SYSDATE, 1), 28000, 1);
      INSERT INTO Pagos (id, fecha, valor, credito_id) VALUES (3, ADD_MONTHS((SELECT fecha FROM Pagos WHERE id = 1), 1), 28000, 1);
      INSERT INTO Pagos (id, fecha, valor, credito_id) VALUES (4, ADD_MONTHS((SELECT fecha FROM Pagos WHERE id = 1), 1), 28000, 1);
      INSERT INTO Pagos (id, fecha, valor, credito_id) VALUES (5, ADD_MONTHS((SELECT fecha FROM Pagos WHERE id = 1), 1), -28000, 1);

 
      COMMIT;
   EXCEPTION

      WHEN OTHERS THEN
         ROLLBACK;
         RAISE;
   END;
END;

UPDATE Creditos SET estado = 'Finalizado' WHERE id = 1;

SELECT * FROM Creditos WHERE id = 1;

SELECT * FROM Pagos WHERE credito_id = 1;

SELECT 'TOTAL PAGOS: $' || SUM(valor) AS TotalPagos
FROM Pagos
WHERE credito_id = 1;

ROLLBACK;

SELECT * FROM Pagos WHERE credito_id = 1;

SELECT 'TOTAL PAGOS: $' || SUM(valor) AS total_pagos
FROM Pagos
WHERE credito_id = 1;

SELECT p.id, p.fecha, p.valor, p.credito_id,
       (SELECT c.valor FROM Creditos c WHERE c.id = p.credito_id) AS valor_credito
FROM Pagos p
WHERE p.credito_id = 1;

SELECT p.id, p.fecha, p.valor, p.credito_id, c.valor AS valor_credito
FROM (
    SELECT id, fecha, valor, credito_id
    FROM Pagos
    WHERE credito_id = 1
) p
INNER JOIN Creditos c ON c.id = p.credito_id;

SELECT *
FROM Deudores
WHERE cc IN (
    SELECT deudor_id
    FROM Creditos
    WHERE estado = 'Activo'
);

SELECT cr.id, cr.valor AS valor_credito, SUM(p.valor) AS suma_pagos
FROM Creditos cr
JOIN Pagos p ON cr.id = p.credito_id
GROUP BY cr.id, cr.valor
HAVING SUM(p.valor) > 50000;

SELECT Deudores.nombre, Creditos.valor, Pagos.fecha
FROM Deudores
JOIN Creditos ON Deudores.cc = Creditos.deudor_id
JOIN Pagos ON Creditos.id = Pagos.credito_id;

SELECT Deudores.nombre, Creditos.valor, Pagos.fecha
FROM Deudores
JOIN Creditos ON Deudores.cc = Creditos.deudor_id
JOIN Pagos ON Creditos.id = Pagos.credito_id
UNION ALL
SELECT Deudores.nombre, NULL, NULL
FROM Deudores
LEFT JOIN Creditos ON Deudores.cc = Creditos.deudor_id
WHERE Creditos.id IS NULL
UNION ALL
SELECT NULL, NULL, Pagos.fecha
FROM Pagos
LEFT JOIN Creditos ON Pagos.credito_id = Creditos.id
WHERE Creditos.id IS NULL;

SELECT Deudores.nombre, Creditos.valor, Pagos.fecha
FROM Deudores
LEFT JOIN Creditos ON Deudores.cc = Creditos.deudor_id
LEFT JOIN Pagos ON Creditos.id = Pagos.credito_id;

SELECT Deudores.nombre, Creditos.valor, Pagos.fecha
FROM Deudores
LEFT JOIN Creditos ON Deudores.cc = Creditos.deudor_id
LEFT JOIN Pagos ON Creditos.id = Pagos.credito_id;

SELECT Deudores.nombre, Creditos.valor, Pagos.fecha
FROM Creditos
RIGHT JOIN Deudores ON Creditos.deudor_id = Deudores.cc
RIGHT JOIN Pagos ON Creditos.id = Pagos.credito_id;

SELECT cc, clave, nombre, apellido, email, NULL AS id, NULL AS fecha, NULL AS valor, NULL AS cuotas, NULL AS interes, NULL AS estado, NULL AS deudor_id, NULL AS credito_id
FROM Deudores
UNION
SELECT NULL AS cc, NULL AS clave, NULL AS nombre, NULL AS apellido, NULL AS email, id, fecha, valor, cuotas, interes, estado, deudor_id, NULL AS credito_id
FROM Creditos
UNION
SELECT NULL AS cc, NULL AS clave, NULL AS nombre, NULL AS apellido, NULL AS email, NULL AS id, fecha, valor, NULL AS cuotas, NULL AS interes, NULL AS estado, NULL AS deudor_id, credito_id
FROM Pagos;

SELECT cc, nombre, apellido, email
FROM Deudores
WHERE cc IN (
    SELECT deudor_id
    FROM Creditos
    WHERE estado = 'Activo'
)
INTERSECT
SELECT cc, nombre, apellido, email
FROM Deudores
WHERE cc IN (
    SELECT deudor_id
    FROM Creditos
    WHERE id IN (
        SELECT credito_id
        FROM Pagos
        WHERE valor < 0
    )
);

CREATE VIEW VistaDeudoresPagos AS
SELECT d.cc, d.nombre, d.apellido, d.email, c.id AS credito_id, p.fecha AS fecha_pago, p.valor AS valor_pago
FROM Deudores d
JOIN Creditos c ON d.cc = c.deudor_id
JOIN Pagos p ON c.id = p.credito_id;

SELECT *
FROM VistaDeudoresPagos;

CREATE OR REPLACE VIEW VistaDeudoresPagos AS
SELECT D.cc, D.nombre, D.apellido, D.email, P.fecha AS fecha_pago, P.valor AS valor_pago
FROM Deudores D
INNER JOIN Creditos C ON D.cc = C.deudor_id
INNER JOIN Pagos P ON C.id = P.credito_id;

SELECT * FROM VistaDeudoresPagos;

SELECT view_name
FROM all_views
WHERE owner = 'SYSTEM'; 

DROP VIEW vistadeudorespagos;

BEGIN
  
  SAVEPOINT inicio_transaccion;

  BEGIN
  
    INSERT INTO Deudores (cc, clave, nombre, apellido, email)
    VALUES (456, 'Def', 'Menganito', 'De tal', 'menganito@gmail.com');


    INSERT INTO Creditos (id, fecha, valor, cuotas, interes, estado, deudor_id)
    VALUES (2, SYSDATE, 150000, 6, 0.35, 'Activo', 456);


    INSERT INTO Pagos (id, fecha, valor, credito_id)
    VALUES (6, ADD_MONTHS((SELECT fecha FROM Creditos WHERE id = 2), 1), 30000, 2);


    INSERT INTO Pagos (id, fecha, valor, credito_id)
    VALUES (7, ADD_MONTHS(SYSDATE, 1), 30000, 2);

   
    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      
      ROLLBACK TO SAVEPOINT inicio_transaccion;

     
      DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
  END;
END;
/

SELECT *
FROM Creditos
WHERE EXISTS (
  SELECT 1
  FROM Pagos
  WHERE Pagos.credito_id = Creditos.id
  AND Pagos.valor < 0
);


CREATE OR REPLACE FUNCTION verificar_deudor(
    p_cc NUMBER,
    p_clave VARCHAR2
) RETURN BOOLEAN AS
    v_count NUMBER;
BEGIN
    SELECT COUNT(*)
    INTO v_count
    FROM Deudores
    WHERE cc = p_cc AND clave = p_clave;

    IF v_count > 0 THEN
        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;
END;
/

DECLARE
    v_result BOOLEAN;
BEGIN
    v_result := verificar_deudor(999, 'ClaveIncorrecta');
    IF v_result THEN
        DBMS_OUTPUT.PUT_LINE('El deudor existe.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('El deudor no existe.');
    END IF;
END;
/

SELECT verificar_deudor(123, 'abc') AS existe_deudor FROM dual;


CREATE OR REPLACE FUNCTION obtener_info_credito(
    p_cc NUMBER
) RETURN VARCHAR2 AS
    v_nombre Deudores.nombre%TYPE;
    v_fecha Creditos.fecha%TYPE;
    v_valor Creditos.valor%TYPE;
    v_estado Creditos.estado%TYPE;
BEGIN
    SELECT d.nombre, c.fecha, c.valor, c.estado
    INTO v_nombre, v_fecha, v_valor, v_estado
    FROM Deudores d
    JOIN Creditos c ON d.cc = c.deudor_id
    WHERE d.cc = p_cc
    AND c.fecha = (
        SELECT MAX(fecha)
        FROM Creditos
        WHERE deudor_id = p_cc
    );

    RETURN 'NOMBRE: ' || v_nombre || ', FECHA: ' || TO_CHAR(v_fecha, 'DD-MM-YYYY') ||
           ', VALOR: $' || v_valor || ', ESTADO: ' || v_estado;
END;
/

DECLARE
    v_result VARCHAR2(200);
BEGIN
    v_result := obtener_info_credito(123);
    DBMS_OUTPUT.PUT_LINE(v_result);
END;
/

SELECT obtener_info_credito(123) AS informacion_credito FROM dual;

CREATE OR REPLACE FUNCTION sumatoria_acumulativa(
    p_num1 NUMBER,
    p_num2 NUMBER
) RETURN NUMBER AS
    v_suma_acumulativa NUMBER := 0;
BEGIN
    FOR i IN p_num1..p_num2 LOOP
        v_suma_acumulativa := v_suma_acumulativa + i;
    END LOOP;

    RETURN v_suma_acumulativa;
END;
/

DECLARE
    v_resultado NUMBER;
BEGIN
    v_resultado := sumatoria_acumulativa(1, 5);
    DBMS_OUTPUT.PUT_LINE('Sumatoria acumulativa: ' || v_resultado);
END;
/

SELECT sumatoria_acumulativa(1, 5) AS resultado FROM dual;

CREATE OR REPLACE PROCEDURE obtener_creditos_activos(
    p_cc NUMBER,
    p_cantidad OUT NUMBER
) AS
BEGIN
    SELECT COUNT(*)
    INTO p_cantidad
    FROM Creditos c
    WHERE c.deudor_id = p_cc
    AND c.estado = 'Activo';
END;
/

DECLARE
    v_cc NUMBER := 123;
    v_cantidad NUMBER;
BEGIN
    obtener_creditos_activos(v_cc, v_cantidad);
    DBMS_OUTPUT.PUT_LINE('Cantidad de créditos activos: ' || v_cantidad);
END;
/





























































