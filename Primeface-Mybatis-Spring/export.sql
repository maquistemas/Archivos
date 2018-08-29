create or replace PACKAGE BODY        "PK_XCRI_ALTAS_VAL_ASIG_CODSBS" IS
-- --------------------------------------------------------------------------------------------------------------------
-- Author : FVITES - Created: 01/07/2004
-- Purpose: Contiene la funcionalidad para el proceso de altas. Este proceso es el que se ejecutaba en una macro excel
-- --------------------------------------------------------------------------------------------------------------------
-- MODIFICACIONES:
-- JCFS 2015-09: Se aumentan los nuevos parametros dia_refer y cod_sec_envio, con valores por defecto
-- --------------------------------------------------------------------------------------------------------------------

-- Public constant declarations
PRV_ESTADO_APROXIMADO CONSTANT VARCHAR2(1)   := 'B';
PRV_ESTADO_DUDA       CONSTANT VARCHAR2(1)   := 'D';

-- Public variable declarations
PRV_ERROR   VARCHAR2(2000);
PRV_MENSAJE VARCHAR2(500);
PRN_RETURN  NUMBER;

-----------------------------------------------------------------
  -- Implementacion de Funciones y Procedimientos
-----------------------------------------------------------------

PROCEDURE SP_PROC_PRINCIPAL_FILTRO_ALTA
        (pv_ano_refer     xcri_altas_val_asig_codsbs_fv.ano_refer%type,
         pv_mes_refer     xcri_altas_val_asig_codsbs_fv.mes_refer%type,
         pv_cod_reporte   xcri_altas_val_asig_codsbs_fv.cod_reporte%type,
         pv_cod_empresa   xcri_altas_val_asig_codsbs_fv.cod_empresa%type,
         pv_usuario       xcri_altas_val_asig_codsbs_fv.cod_usu_proc%type,
         pv_dia_refer     IN xcri_altas_val_asig_codsbs_fv.dia_refer%type default '01',
         pv_cod_sec_envio IN xcri_altas_val_asig_codsbs_fv.cod_sec_envio%type default '01',
         ov_mensaje       OUT VARCHAR2,
         on_return        OUT NUMBER )
IS
---------------------
--       Autor                     Fecha         Software
--       Francisco Vite Shelton    19/08/2004    Oracle 8i
---------------------
--       Parametros
--           pv_ano_refer   :  Año de referencia.
--           pv_mes_refer   :  Mes de referencia.
--           pv_cod_reporte :  Codigo reporte a cargar (RCD/RTC)
--           pv_cod_empresa :  Codigo de la Entidad.
--           pv_usuario     : Usuario que ejecuta el proceso.
--           ov_mensaje     : Retorna el mensaje de ocurrir alguna observacion.
--           on_return      : Retorna el codigo de error
--                            -1 : Error
--                             1 : OK
---------------------
--       Descripcion:        Procedimiento que realiza el proceso de filtro. la diferencia con SP_PROC_PRINCIPAL_FILTRO_ALTAS es
--                           el hecho de proporcionar valores de retorno que indicaran el exito o no del proceso.
---------------------
-- Ejecucion
--  PK_XCRI_ALTAS_VAL_ASIG_CODSBS.SP_PROC_PRINCIPAL_FILTRO_ALTA ('2004','04','RCD','00102','FVITES');
---------------------
lv_ruta                  VARCHAR2(120);
lv_filename_filtro_altas  VARCHAR2(120);
lutl_file_filtro_altas   UTL_FILE.FILE_TYPE;
ln_paso NUMBER;

BEGIN
   PRV_MENSAJE := '';
   PRN_RETURN  := 1;

   ln_paso := 1;
   INSERT INTO CRA_TIEMPOS_PROCESO ( ANO_REFER, MES_REFER, COD_PROCESO, ETAPA, NUM_PASO, FEC_INICIO, DESCRIPCION, COD_ENTIDAD, DIA_REFER, COD_SEC_ENVIO )
   VALUES (pv_ano_refer, pv_mes_refer, pv_cod_reporte, '73', ln_paso, SYSDATE, 'ALTAS - PROCESO PRINCIPAL DEL FILTRO DE ALTA - INICIO', pv_cod_empresa, pv_dia_refer, pv_cod_sec_envio);
   COMMIT;

   /*-- EJECUTOR DE PROCESO PRINCIPAL--*/
   SP_PROC_PRINCIPAL_FILTRO_ALTAS ( pv_ano_refer, pv_mes_refer, pv_cod_reporte, pv_cod_empresa, pv_usuario, pv_dia_refer, pv_cod_sec_envio );
   ov_mensaje := PRV_MENSAJE;
   on_return  := PRN_RETURN;

   ln_paso := 1;
   INSERT INTO CRA_TIEMPOS_PROCESO ( ANO_REFER, MES_REFER, COD_PROCESO, ETAPA, NUM_PASO, FEC_INICIO, DESCRIPCION, COD_ENTIDAD, DIA_REFER, COD_SEC_ENVIO )
   VALUES (pv_ano_refer, pv_mes_refer, pv_cod_reporte, '74', ln_paso, SYSDATE, 'ALTAS - PROCESO PRINCIPAL DE POST ALTAS - INICIO', pv_cod_empresa, pv_dia_refer, pv_cod_sec_envio);
   COMMIT;

   IF PRN_RETURN = 1 THEN
      -- EJECUTOR DE PROCESO PRINCIPAL POST ALTAS --
      -- FILTROS ESPECIALES EN REASIGNACION CODSBS --
      SP_POST_ALTAS_ASIG_CODSBS ( pv_ano_refer, pv_mes_refer, pv_cod_reporte, pv_cod_empresa, pv_usuario, pv_dia_refer, pv_cod_sec_envio );
      ov_mensaje := PRV_MENSAJE;
      on_return  := PRN_RETURN;
   END IF;

   ln_paso := 1;
   INSERT INTO CRA_TIEMPOS_PROCESO ( ANO_REFER, MES_REFER, COD_PROCESO, ETAPA, NUM_PASO, FEC_INICIO, DESCRIPCION, COD_ENTIDAD, DIA_REFER, COD_SEC_ENVIO )
   VALUES (pv_ano_refer, pv_mes_refer, pv_cod_reporte, '75', ln_paso, SYSDATE, 'ALTAS - PROCESO PRINCIPAL DEL COMPARATIVO DEL CONTROL 71', pv_cod_empresa, pv_dia_refer, pv_cod_sec_envio);
   COMMIT;

   IF PRN_RETURN = 1 THEN
      -- EJECUTOR DE PROCESO POST ALTAS --
      -- OBTIENE ARCHIVO COMPARATIVO DEL CONTROL 71 --
      SP_REP_COMPARATIVO_CONTROL_71 ( pv_ano_refer, pv_mes_refer, pv_cod_reporte, pv_cod_empresa, pv_usuario, 71, pv_dia_refer, pv_cod_sec_envio );
      ov_mensaje := PRV_MENSAJE;
      on_return  := PRN_RETURN;
   END IF;

   ln_paso := 1;
   INSERT INTO CRA_TIEMPOS_PROCESO ( ANO_REFER, MES_REFER, COD_PROCESO, ETAPA, NUM_PASO, FEC_INICIO, DESCRIPCION, COD_ENTIDAD, DIA_REFER, COD_SEC_ENVIO )
   VALUES (pv_ano_refer, pv_mes_refer, pv_cod_reporte, '76', ln_paso, SYSDATE, 'ALTAS - PROCESO PRINCIPAL DE GENERACION DE ARCHIVO EXCEL', pv_cod_empresa, pv_dia_refer, pv_cod_sec_envio);
   COMMIT;

   IF PRN_RETURN <> 1 THEN
      -- Genera un archivo Excel
      lv_filename_filtro_altas := 'Filtro_altas_';
      lv_filename_filtro_altas := lv_filename_filtro_altas || pv_cod_reporte || pv_ano_refer || pv_mes_refer || '_' || pv_cod_empresa || '.xls';
      lv_ruta := SF_ALTAS_RUTA_FILE_UNIX (pv_usuario, lv_filename_filtro_altas, 'C' );

      -- renombra archivo
      lv_filename_filtro_altas :=  'OBS_' || lv_filename_filtro_altas ;
      -- Abriendo el Archivo de salida
      lutl_file_filtro_altas   := UTL_FILE.FOPEN (lv_ruta, lv_filename_filtro_altas, 'W');
      -- Almacenando informacion en el Registro de salida
      UTL_FILE.PUT_LINE (lutl_file_filtro_altas, chr(13));
      UTL_FILE.PUT_LINE (lutl_file_filtro_altas, ov_mensaje ||chr(13));
      -- Cierra los archivos
      UTL_FILE.FCLOSE(lutl_file_filtro_altas);
   END IF;

  RETURN;

  -- Control de Errores
  EXCEPTION
     WHEN OTHERS THEN
         -- Actualizar estado de este proceso y colocarlo en error
         -- Actualiza Observaciones del Sistema
        PRV_ERROR   := SQLERRM;
        PRV_MENSAJE := substr(PRV_ERROR,1,255) || ' -- SP_PROC_PRINCIPAL_FILTRO_ALTA';
        PRN_RETURN  := -1;
        UTL_FILE.FCLOSE(lutl_file_filtro_altas);
        RETURN;

END SP_PROC_PRINCIPAL_FILTRO_ALTA;

-----------------------------------------------------------------

-- Procedimiento que realiza el proceso de filtro
PROCEDURE SP_PROC_PRINCIPAL_FILTRO_ALTAS
        (pv_ano_refer    xcri_altas_val_asig_codsbs_fv.ano_refer%type,
         pv_mes_refer    xcri_altas_val_asig_codsbs_fv.mes_refer%type,
         pv_cod_reporte  xcri_altas_val_asig_codsbs_fv.cod_reporte%type,
         pv_cod_empresa  xcri_altas_val_asig_codsbs_fv.cod_empresa%type,
         pv_usuario      xcri_altas_val_asig_codsbs_fv.cod_usu_proc%type,
         pv_dia_refer     IN xcri_altas_val_asig_codsbs_fv.dia_refer%type default '01',
         pv_cod_sec_envio IN xcri_altas_val_asig_codsbs_fv.cod_sec_envio%type default '01')
IS
---------------------
--       Autor                     Fecha         Software
--       Francisco Vite Shelton    17/08/2004    Oracle 8i
---------------------
--       Parametros
--           pv_ano_refer   :  Año de referencia.
--           pv_mes_refer   :  Mes de referencia.
--           pv_cod_reporte :  Codigo reporte a cargar (RCD/RTC)
--           pv_cod_empresa :  Codigo de la Entidad.
--           pv_usuario     : Usuario que ejecuta el proceso.
---------------------
--       Descripcion
--         Establece la ejecucion para todo el proceso de filtro de altas
--         Comprende los siguientes procesos principales:
--            SP_CARGA_DATA
--            SP_PROCESA_DATA
--            SP_GENERA_FILE_SALIDA
---------------------
-- Ejecucion
--  PK_XCRI_ALTAS_VAL_ASIG_CODSBS.SP_PROC_PRINCIPAL_FILTRO_ALTAS ('2004','04','RCD','00102','FVITES');
---------------------
BEGIN
   PRV_MENSAJE := '';
   PRN_RETURN  := 1;

    /*-- EJECUTOR DE PROCESO --*/
    -- Carga Datos a los temporales
   SP_CARGA_DATA ( pv_ano_refer, pv_mes_refer, pv_cod_reporte, pv_cod_empresa, pv_usuario, pv_dia_refer, pv_cod_sec_envio );
   IF PRN_RETURN <> 1 THEN
      RETURN;
   END IF;

   -- Procesa Filtro
   SP_PROCESA_DATA ( pv_ano_refer, pv_mes_refer, pv_cod_reporte, pv_cod_empresa, pv_usuario, pv_dia_refer, pv_cod_sec_envio );
   IF PRN_RETURN <> 1 THEN
      RETURN;
   END IF;

   ---------------------------------------------------
   -- FVSH 20050614: Se Desactivo esta opcion por no estar en uso. En su lugar se genero el archivo de aproximados
   -- Reporta archivo de salida EXCEL
   --SP_GENERA_FILE_SALIDA ( pv_ano_refer, pv_mes_refer, pv_cod_reporte, pv_cod_empresa, pv_usuario);
   ---------------------------------------------------

   -- Actualiza resultados en la tabla de asignaciones de CODSBS
   SP_ACTUALIZA_ASIG_COD_SBS ( pv_ano_refer, pv_mes_refer, pv_cod_reporte, pv_cod_empresa, pv_usuario, pv_dia_refer, pv_cod_sec_envio );

   RETURN;

   -- Control de Errores
   EXCEPTION
      WHEN OTHERS THEN
         -- Actualizar estado de este proceso y colocarlo en error
         -- Actualiza Observaciones del Sistema
         PRV_ERROR   := SQLERRM;
         PRV_MENSAJE := substr(PRV_ERROR,1,255) || ' -- SP_PROC_PRINCIPAL_FILTRO_ALTAS';
         PRN_RETURN  := -1;
    RETURN;

END SP_PROC_PRINCIPAL_FILTRO_ALTAS;

-----------------------------------------------------------------

-- Procedimiento que efectua la carga de data
PROCEDURE SP_CARGA_DATA
        (pv_ano_refer    xcri_altas_val_asig_codsbs_fv.ano_refer%type,
         pv_mes_refer    xcri_altas_val_asig_codsbs_fv.mes_refer%type,
         pv_cod_reporte  xcri_altas_val_asig_codsbs_fv.cod_reporte%type,
         pv_cod_empresa  xcri_altas_val_asig_codsbs_fv.cod_empresa%type,
         pv_usuario      xcri_altas_val_asig_codsbs_fv.cod_usu_proc%type,
         pv_dia_refer     IN xcri_altas_val_asig_codsbs_fv.dia_refer%type default '01',
         pv_cod_sec_envio IN xcri_altas_val_asig_codsbs_fv.cod_sec_envio%type default '01')
IS
---------------------
--       Autor                     Fecha         Software
--       Francisco Vite Shelton    01/07/2004    Oracle 8i
---------------------
--       Parametros
--           pv_ano_refer   :  Año de referencia.
--           pv_mes_refer   :  Mes de referencia.
--           pv_cod_reporte :  Codigo reporte a cargar (RCD/RTC)
--           pv_cod_empresa :  Codigo de la Entidad.
--           pv_usuario     : Usuario que ejecuta el proceso.
---------------------
--       Descripcion
--         Establece la cargar inicial para efectuar el proceso de altas
---------------------
-- Ejecucion
--  PK_XCRI_ALTAS_VAL_ASIG_CODSBS.SP_CARGA_DATA ('2004','04','RCD','00102','SISDES');
---------------------

--- Cursor para cargar la data al sistema
/* JCFS 16/08/2010: Los SELECT 2 al 5 son idénticos, excepto por la última línea en la que se hace el JOIN entre las tablas
                    CRA_VALID_ASIG_CODSBS y CRI_PERSONA. El campo de CRA_VALID_ASIG_CODSBS utilizado para hacer el JOIN
                    cambia en cada query (COD_SBS_COINC_IDE, COD_SBS_COINC_RUC, COD_SBS_COINC_UNI y COD_SBS_COINC_SIG) */
CURSOR cur_carga_data IS
SELECT 0 AS POS, 1 AS TIP_ORDEN,
       TO_CHAR(NUM_SEC_REG) AS NUM_SEC_REG, COD_SBS,
       NVL(NOM_CLIENTE, ' ') AS DES_PERSONA,
       TIP_DOC_IDEN, NUM_DOC_IDEN,
       TIP_DOC_TRIB, NUM_DOC_TRIB,
       COD_UNICO_CLIE, NOM_SIGLA,
       COD_EST_ASIG,
       NULL AS DES_TIP_DOC_IDEN,
       COD_SBS_COINC_IDE, COD_SBS_COINC_RUC,
       COD_SBS_COINC_UNI, COD_SBS_COINC_SIG,
       TIP_PERSONA,
       NULL AS DES_TIP_PERSONA,
       NUM_SEC_REG AS SECUENCIA_ENLACE
  FROM CRA_VALID_ASIG_CODSBS
 WHERE ANO_REFER = pv_ano_refer AND MES_REFER = pv_mes_refer AND
       COD_REPORTE = pv_cod_reporte AND COD_EMPRESA = pv_cod_empresa AND
       DIA_REFER = pv_dia_refer AND COD_SEC_ENVIO = pv_cod_sec_envio AND
       COD_EST_ASIG IN ('A', 'B', 'D') AND IND_EST_ASIG = 'P' AND
       IND_REG_OBSERV IS NULL
UNION
SELECT 0, 2 AS TIP_ORDEN, NULL, B.COD_SBS,
       SF_CRI_PERSONA_DES_PERSONA(B.COD_SBS, B.TIP_PERSONA) AS DES_PERSONA,
       SF_CRI_PERSONA_TIP_DOCID(B.COD_SBS, B.TIP_PERSONA) AS TIP_DOC_IDEN,
       SF_CRI_PERSONA_NUM_DOCID(B.COD_SBS, B.TIP_PERSONA) AS NUM_DOC_IDEN,
       DECODE(B.NUM_RUC11, NULL, '2', '3') AS TIP_DOC_TRIB,
       DECODE(B.NUM_RUC11, NULL, B.NUM_RUC, B.NUM_RUC11) AS NUM_DOC_TRIB,
       A.COD_UNICO_CLIE AS COD_UNICO_CLIE,
       SF_CRI_PERSONA_DES_SIGLAS(B.COD_SBS, B.TIP_PERSONA) AS NOM_SIGLA,
       NULL,
       NULL AS DES_TIP_DOC_IDEN,
       A.COD_SBS_COINC_IDE, A.COD_SBS_COINC_RUC,
       A.COD_SBS_COINC_UNI, A.COD_SBS_COINC_SIG,
       B.TIP_PERSONA,
       NULL AS DES_TIP_PERSONA,
       NUM_SEC_REG AS SECUENCIA_ENLACE
  FROM CRA_VALID_ASIG_CODSBS A, CRI_PERSONA B
 WHERE A.ANO_REFER = pv_ano_refer AND A.MES_REFER = pv_mes_refer AND
       A.COD_REPORTE = pv_cod_reporte AND A.COD_EMPRESA = pv_cod_empresa AND
       A.DIA_REFER = pv_dia_refer AND A.COD_SEC_ENVIO = pv_cod_sec_envio AND
       A.COD_EST_ASIG IN ('A', 'B', 'D') AND A.IND_EST_ASIG = 'P' AND
       A.IND_REG_OBSERV IS NULL AND A.COD_SBS_COINC_IDE = B.COD_SBS
UNION
SELECT 0, 2 AS TIP_ORDEN, NULL, B.COD_SBS,
       SF_CRI_PERSONA_DES_PERSONA(B.COD_SBS, B.TIP_PERSONA) AS DES_PERSONA,
       SF_CRI_PERSONA_TIP_DOCID(B.COD_SBS, B.TIP_PERSONA) AS TIP_DOC_IDEN,
       SF_CRI_PERSONA_NUM_DOCID(B.COD_SBS, B.TIP_PERSONA) AS NUM_DOC_IDEN,
       DECODE(B.NUM_RUC11, NULL, '2', '3') AS TIP_DOC_TRIB,
       DECODE(B.NUM_RUC11, NULL, B.NUM_RUC, B.NUM_RUC11) AS NUM_DOC_TRIB,
       A.COD_UNICO_CLIE AS COD_UNICO_CLIE,
       SF_CRI_PERSONA_DES_SIGLAS(B.COD_SBS, B.TIP_PERSONA) AS NOM_SIGLA,
       NULL,
       NULL AS DES_TIP_DOC_IDEN,
       A.COD_SBS_COINC_IDE, A.COD_SBS_COINC_RUC,
       A.COD_SBS_COINC_UNI, A.COD_SBS_COINC_SIG,
       B.TIP_PERSONA,
       NULL AS DES_TIP_PERSONA,
       NUM_SEC_REG AS SECUENCIA_ENLACE
  FROM CRA_VALID_ASIG_CODSBS A, CRI_PERSONA B
 WHERE A.ANO_REFER = pv_ano_refer AND A.MES_REFER = pv_mes_refer AND
       A.COD_REPORTE = pv_cod_reporte AND A.COD_EMPRESA = pv_cod_empresa AND
       A.DIA_REFER = pv_dia_refer AND A.COD_SEC_ENVIO = pv_cod_sec_envio AND
       A.COD_EST_ASIG IN ('A', 'B', 'D') AND A.IND_EST_ASIG = 'P' AND
       A.IND_REG_OBSERV IS NULL AND A.COD_SBS_COINC_RUC = B.COD_SBS
UNION
SELECT 0, 2 AS TIP_ORDEN, NULL, B.COD_SBS,
       SF_CRI_PERSONA_DES_PERSONA(B.COD_SBS, B.TIP_PERSONA) AS DES_PERSONA,
       SF_CRI_PERSONA_TIP_DOCID(B.COD_SBS, B.TIP_PERSONA) AS TIP_DOC_IDEN,
       SF_CRI_PERSONA_NUM_DOCID(B.COD_SBS, B.TIP_PERSONA) AS NUM_DOC_IDEN,
       DECODE(B.NUM_RUC11, NULL, '2', '3') AS TIP_DOC_TRIB,
       DECODE(B.NUM_RUC11, NULL, B.NUM_RUC, B.NUM_RUC11) AS NUM_DOC_TRIB,
       A.COD_UNICO_CLIE AS COD_UNICO_CLIE,
       SF_CRI_PERSONA_DES_SIGLAS(B.COD_SBS, B.TIP_PERSONA) AS NOM_SIGLA,
       NULL,
       NULL AS DES_TIP_DOC_IDEN,
       A.COD_SBS_COINC_IDE, A.COD_SBS_COINC_RUC,
       A.COD_SBS_COINC_UNI, A.COD_SBS_COINC_SIG,
       B.TIP_PERSONA,
       NULL AS DES_TIP_PERSONA,
       NUM_SEC_REG AS SECUENCIA_ENLACE
  FROM CRA_VALID_ASIG_CODSBS A, CRI_PERSONA B
 WHERE A.ANO_REFER = pv_ano_refer AND A.MES_REFER = pv_mes_refer AND
       A.COD_REPORTE= pv_cod_reporte AND A.COD_EMPRESA = pv_cod_empresa AND
       A.DIA_REFER = pv_dia_refer AND A.COD_SEC_ENVIO = pv_cod_sec_envio AND
       A.COD_EST_ASIG IN ('A', 'B', 'D') AND A.IND_EST_ASIG = 'P' AND
       A.IND_REG_OBSERV IS NULL AND A.COD_SBS_COINC_UNI = B.COD_SBS
UNION
SELECT 0, 2 AS TIP_ORDEN, NULL, B.COD_SBS,
       SF_CRI_PERSONA_DES_PERSONA(B.COD_SBS, B.TIP_PERSONA) AS DES_PERSONA,
       SF_CRI_PERSONA_TIP_DOCID(B.COD_SBS, B.TIP_PERSONA) AS TIP_DOC_IDEN,
       SF_CRI_PERSONA_NUM_DOCID(B.COD_SBS, B.TIP_PERSONA) AS NUM_DOC_IDEN,
       DECODE(B.NUM_RUC11, NULL, '2', '3') AS TIP_DOC_TRIB,
       DECODE(B.NUM_RUC11, NULL, B.NUM_RUC, B.NUM_RUC11) AS NUM_DOC_TRIB,
       A.COD_UNICO_CLIE AS COD_UNICO_CLIE,
       SF_CRI_PERSONA_DES_SIGLAS(B.COD_SBS, B.TIP_PERSONA) AS NOM_SIGLA,
       NULL,
       NULL AS DES_TIP_DOC_IDEN,
       A.COD_SBS_COINC_IDE, A.COD_SBS_COINC_RUC,
       A.COD_SBS_COINC_UNI, A.COD_SBS_COINC_SIG,
       B.TIP_PERSONA,
       NULL AS DES_TIP_PERSONA,
       NUM_SEC_REG AS SECUENCIA_ENLACE
  FROM CRA_VALID_ASIG_CODSBS A, CRI_PERSONA B
 WHERE A.ANO_REFER = pv_ano_refer AND A.MES_REFER = pv_mes_refer AND
       A.COD_REPORTE = pv_cod_reporte AND A.COD_EMPRESA = pv_cod_empresa AND
       A.DIA_REFER = pv_dia_refer AND A.COD_SEC_ENVIO = pv_cod_sec_envio AND
       A.COD_EST_ASIG IN ('A', 'B', 'D') AND A.IND_EST_ASIG = 'P' AND
       A.IND_REG_OBSERV IS NULL AND A.COD_SBS_COINC_SIG = B.COD_SBS
 ORDER BY 20, 14, 15, 16, 17 ;

ln_num_reg_insertados NUMBER(8);
ln_secuencia NUMBER(8);
ln_count NUMBER(8);
ln_sw NUMBER(1);
ln_pos_cadena NUMBER(3);
lv_proc_tip_persona xcri_altas_val_asig_codsbs_fv.tip_persona%type;

BEGIN
  ln_num_reg_insertados := 0;
  ln_secuencia          := 0;
  ln_count              := 0;
  ln_sw                 := 0;

  BEGIN
     SELECT count(1) INTO ln_count
       FROM XCRI_ALTAS_VAL_ASIG_CODSBS_fv t
      WHERE t.ano_refer = pv_ano_refer AND t.mes_refer = pv_mes_refer
        AND t.cod_reporte = pv_cod_reporte AND t.cod_empresa = pv_cod_empresa
        AND t.DIA_REFER = pv_dia_refer AND t.COD_SEC_ENVIO = pv_cod_sec_envio ;
  EXCEPTION
     WHEN OTHERS THEN
        ln_count := 0;
  END;

  IF ln_count > 0 THEN
     ln_sw := 0;
     BEGIN
        DELETE XCRI_ALTAS_VAL_ASIG_CODSBS_fv
         WHERE ano_refer = pv_ano_refer AND mes_refer = pv_mes_refer
           AND cod_reporte = pv_cod_reporte AND cod_empresa = pv_cod_empresa
           AND DIA_REFER = pv_dia_refer AND COD_SEC_ENVIO = pv_cod_sec_envio ;
     EXCEPTION
        WHEN OTHERS THEN
           ln_count := 1;
     END;
     IF ln_sw = 0 THEN
        COMMIT;
     END IF;
     --RETURN;
  END IF;

   for cur_carga in cur_carga_data loop
       ln_secuencia := ln_secuencia + 1;
       -- Hace la asignacion del tipo de persona de acuerdo a los datos alcanzados

       /*---- Cambios realizados ppor FVSH 20070422
              -- Tome el tipo de persona reportado
       IF cur_carga.tip_persona = '2' THEN  -- Persona Juridica
          lv_proc_tip_persona := '2';
       ELSE
          -- Asume por default Persona Natural
          lv_proc_tip_persona := '1';

          -- Ahora verifica si es mancomuna
          ln_pos_cadena := nvl(instr(UPPER(cur_carga.des_persona),'Y/O'),0);

          IF ln_pos_cadena > 0 THEN  -- Persona Mancomunada
             lv_proc_tip_persona := '3';
          END IF;
       END IF;
       --*/
          -- Asigna tipo de persona reportado. En teoria el Y/O ya no deberia contemplarse
          lv_proc_tip_persona := cur_carga.tip_persona;
          ln_pos_cadena := nvl(instr(UPPER(cur_carga.des_persona),'Y/O'),0);
          IF ln_pos_cadena > 0 THEN -- Persona Mancomunada
             lv_proc_tip_persona := '3';
          END IF;

       INSERT INTO XCRI_ALTAS_VAL_ASIG_CODSBS_FV
              (  ano_refer, mes_refer, cod_reporte, cod_empresa, secuencia,
                 pos, tip_orden, num_sec_reg, cod_sbs, desc_persona,
                 tip_doc_iden, num_doc_iden, tip_doc_trib, num_doc_trib, cod_unico_clie,
                 nom_sigla, cod_est_asig, cod_sbs_coinc_ide, cod_sbs_coinc_ruc, cod_sbs_coinc_uni,
                 cod_sbs_coinc_sig, tip_persona, proc_desc_1, proc_desc_2, proc_desc_3,
                 proc_desc_4, proc_desc_5, proc_coincidencias, proc_porc_aproximacion, proc_estado,
                 proc_condicion, proc_tip_persona, cod_usu_proc, fec_aprobacion, secuencia_enlace, dia_refer, cod_sec_envio
              )
          VALUES
              (  pv_ano_refer, pv_mes_refer, pv_cod_reporte, pv_cod_empresa, ln_secuencia,
                 cur_carga.pos, cur_carga.tip_orden, cur_carga.num_sec_reg, cur_carga.cod_sbs, cur_carga.des_persona,
                 cur_carga.tip_doc_iden, cur_carga.num_doc_iden, cur_carga.tip_doc_trib, cur_carga.num_doc_trib, cur_carga.cod_unico_clie,
                 cur_carga.nom_sigla, cur_carga.cod_est_asig, cur_carga.cod_sbs_coinc_ide, cur_carga.cod_sbs_coinc_ruc, cur_carga.cod_sbs_coinc_uni,
                 cur_carga.cod_sbs_coinc_sig, cur_carga.tip_persona, NULL, NULL, NULL,
                 NULL, NULL, NULL, NULL, NULL, -- 'No OK' -- proc_estado
                 NULL, lv_proc_tip_persona, pv_usuario, Sysdate, cur_carga.secuencia_enlace, pv_dia_refer, pv_cod_sec_envio
              ) ;

       ln_num_reg_insertados := ln_num_reg_insertados + 1;
       -- realiza la transaccion cada mil registros
       IF ln_num_reg_insertados > 1000 THEN
          COMMIT;
          ln_num_reg_insertados := 0;
       END IF;

   end loop;

   COMMIT;

  -- Control de Errores
  EXCEPTION
    WHEN OTHERS THEN
         -- Actualizar estado de este proceso y colocarlo en error
         -- Actualiza Observaciones del Sistema
       PRV_ERROR   := SQLERRM;
       PRV_MENSAJE := substr(PRV_ERROR,1,255) || ' -- SP_CARGA_DATA';
       PRN_RETURN  := -1;
       RETURN;

END SP_CARGA_DATA;

-----------------------------------------------------------------

-- Procedimiento que efectua la logica de altas (macro excel)
PROCEDURE SP_PROCESA_DATA
        (pv_ano_refer     xcri_altas_val_asig_codsbs_fv.ano_refer%type,
         pv_mes_refer     xcri_altas_val_asig_codsbs_fv.mes_refer%type,
         pv_cod_reporte   xcri_altas_val_asig_codsbs_fv.cod_reporte%type,
         pv_cod_empresa   xcri_altas_val_asig_codsbs_fv.cod_empresa%type,
         pv_usuario       xcri_altas_val_asig_codsbs_fv.cod_usu_proc%type,
         pv_dia_refer     IN xcri_altas_val_asig_codsbs_fv.dia_refer%type default '01',
         pv_cod_sec_envio IN xcri_altas_val_asig_codsbs_fv.cod_sec_envio%type default '01' )
IS
---------------------
--       Autor                     Fecha         Software
--       Francisco Vite Shelton    01/07/2004    Oracle 8i
---------------------
--       Parametros
--           pv_ano_refer   :  Año de referencia.
--           pv_mes_refer   :  Mes de referencia.
--           pv_cod_reporte :  Codigo reporte a cargar (RCD/RTC)
--           pv_cod_empresa :  Codigo de la Entidad.
--           pv_usuario     : Usuario que ejecuta el proceso.
---------------------
--       Descripcion
--         Efectua la logica del proceso de altas. Esta logica es la que se tenia en una macro de excel.
---------------------
-- Ejecucion
--  PK_XCRI_ALTAS_VAL_ASIG_CODSBS.SP_PROCESA_DATA ('2004','04','RCD','00102','SISDES');
---------------------

--- Cursor para cargar la data al sistema
CURSOR cur_proc_data IS
SELECT  ano_refer, mes_refer, cod_reporte, cod_empresa
      , secuencia, pos, tip_orden, num_sec_reg, cod_sbs, desc_persona
      , tip_doc_iden, num_doc_iden, tip_doc_trib, num_doc_trib
      , cod_unico_clie, nom_sigla, cod_est_asig
      , cod_sbs_coinc_ide, cod_sbs_coinc_ruc, cod_sbs_coinc_uni, cod_sbs_coinc_sig
      , tip_persona, proc_tip_persona, dia_refer, cod_sec_envio
 FROM XCRI_ALTAS_VAL_ASIG_CODSBS_FV T
WHERE T.ANO_REFER   = pv_ano_refer
  AND T.MES_REFER   = pv_mes_refer
  AND T.COD_REPORTE = pv_cod_reporte
  AND T.COD_EMPRESA = pv_cod_empresa
  AND T.DIA_REFER   = pv_dia_refer
  AND T.COD_SEC_ENVIO = pv_cod_sec_envio
ORDER BY T.SECUENCIA ASC ;

-- Lista de variables para separar el nombre
lv_desc_persona  xcri_altas_val_asig_codsbs_fv.desc_persona%type;
lv_proc_desc_1   xcri_altas_val_asig_codsbs_fv.proc_desc_1%type;
lv_proc_desc_2   xcri_altas_val_asig_codsbs_fv.proc_desc_2%type;
lv_proc_desc_3   xcri_altas_val_asig_codsbs_fv.proc_desc_3%type;
lv_proc_desc_4   xcri_altas_val_asig_codsbs_fv.proc_desc_4%type;
lv_proc_desc_5   xcri_altas_val_asig_codsbs_fv.proc_desc_5%type;
ln_pos_blanco    NUMBER(3);
lv_desc_persona_rep  xcri_altas_val_asig_codsbs_fv.desc_persona%type;
lv_proc_desc_1_rep   xcri_altas_val_asig_codsbs_fv.proc_desc_1%type;
lv_proc_desc_2_rep   xcri_altas_val_asig_codsbs_fv.proc_desc_2%type;
lv_proc_desc_3_rep   xcri_altas_val_asig_codsbs_fv.proc_desc_3%type;
lv_proc_desc_4_rep   xcri_altas_val_asig_codsbs_fv.proc_desc_4%type;
lv_proc_desc_5_rep   xcri_altas_val_asig_codsbs_fv.proc_desc_5%type;
lv_proc_tip_persona_sugerido xcri_altas_val_asig_codsbs_fv.proc_tip_persona%type;
lv_tip_persona_rep           xcri_altas_val_asig_codsbs_fv.tip_persona%type;
ln_num_reg_update    NUMBER(6);
ln_coincidencias     xcri_altas_val_asig_codsbs_fv.proc_coincidencias%type;
ln_porc_aproximacion xcri_altas_val_asig_codsbs_fv.proc_porc_aproximacion%type;
ln_long_proc_desc    NUMBER(3);
ln_long_desc         NUMBER(3);
ln_reg_comparar      NUMBER(3);
ln_proc_desc_blancos NUMBER(3);
ln_proc_desc_ant_blancos NUMBER(3);

-- Estado y condicion del registro procesado
lv_proc_estado            xcri_altas_val_asig_codsbs_fv.proc_estado%type;
lv_proc_condicion         xcri_altas_val_asig_codsbs_fv.proc_condicion%type;
lv_proc_condicion_sec_act xcri_altas_val_asig_codsbs_fv.proc_condicion%type;

BEGIN
  ln_num_reg_update := 0;
  ln_coincidencias  := 0;
  ln_reg_comparar   := 0;
  lv_desc_persona := NULL;
  lv_proc_desc_1  := NULL;
  lv_proc_desc_2  := NULL;
  lv_proc_desc_3  := NULL;
  lv_proc_desc_4  := NULL;
  lv_proc_desc_5  := NULL;

   ---------------------------
   -- OJO: Tener presente que hace la comparacion de dos en dos filas
   --------------------------
   for cur_proc in cur_proc_data loop
       --------------------------------------
       -- Proceso inicia separacion de nombres
       -- CELDAS F - G - H - I - J
--       lv_proc_desc_1  := NULL;   -- CELDA  F 10
       lv_proc_desc_2  := NULL;   -- CELDA  G 10
       lv_proc_desc_3  := NULL;   -- CELDA  H 10
       lv_proc_desc_4  := NULL;   -- CELDA  I 10
       lv_proc_desc_5  := NULL;   -- CELDA  J 10

       lv_desc_persona := cur_proc.desc_persona;
       lv_proc_desc_1  := lv_desc_persona;
       -- busca primer blanco
       ln_pos_blanco := nvl(instr(lv_desc_persona,' '),0);
       IF ln_pos_blanco > 0 THEN
          lv_proc_desc_1 := trim(substr(lv_desc_persona,1,ln_pos_blanco - 1));
          -- busca segundo blanco
          lv_desc_persona := trim(substr(lv_desc_persona,ln_pos_blanco + 1, length(lv_desc_persona)));
          ln_pos_blanco := nvl(instr(lv_desc_persona,' '),0);
          --
          lv_proc_desc_2  := lv_desc_persona;

          IF  ln_pos_blanco > 0 THEN
              lv_proc_desc_2 := trim(substr(lv_desc_persona,1,ln_pos_blanco - 1));

              -- busca tercer blanco
              lv_desc_persona := trim(substr(lv_desc_persona,ln_pos_blanco + 1, length(lv_desc_persona)));
              ln_pos_blanco := nvl(instr(lv_desc_persona,' '),0);
              lv_proc_desc_3  := lv_desc_persona;

              IF  ln_pos_blanco > 0 THEN
                  lv_proc_desc_3 := trim(substr(lv_desc_persona,1,ln_pos_blanco - 1));

                  -- busca cuarto blanco
                  lv_desc_persona := trim(substr(lv_desc_persona,ln_pos_blanco + 1, length(lv_desc_persona)));
                  ln_pos_blanco := nvl(instr(lv_desc_persona,' '),0);
                  --
                  lv_proc_desc_4  := lv_desc_persona;

                  IF  ln_pos_blanco > 0 THEN
                      lv_proc_desc_4 := trim(substr(lv_desc_persona,1,ln_pos_blanco - 1));

                      -- busca quinto blanco  -- nuevo proceso
                      lv_desc_persona := trim(substr(lv_desc_persona,ln_pos_blanco + 1, length(lv_desc_persona)));
                      ln_pos_blanco := nvl(instr(lv_desc_persona,' '),0);
                      --
                      lv_proc_desc_5  := lv_desc_persona;
                  END IF;
              END IF;
          END IF;
       END IF;
       --------------------------------------
       --  Busca las coincidencias
       -- Si es de tipo orden 1 quiere decir que se trata
       -- del registro en analisis (registro REPORTADO)
       IF cur_proc.tip_orden = 1 THEN
         lv_proc_desc_1_rep  :=  lv_proc_desc_1;     -- CELDA  F 9
         lv_proc_desc_2_rep  :=  lv_proc_desc_2;     -- CELDA  G 9
         lv_proc_desc_3_rep  :=  lv_proc_desc_3;     -- CELDA  H 9
         lv_proc_desc_4_rep  :=  lv_proc_desc_4;     -- CELDA  I 9
         lv_proc_desc_5_rep  :=  lv_proc_desc_5;     -- CELDA  J 9
         lv_desc_persona_rep := cur_proc.desc_persona;
         --
         lv_tip_persona_rep  := cur_proc.tip_persona;
         --
         lv_proc_tip_persona_sugerido  := cur_proc.proc_tip_persona;

         ln_reg_comparar := 1;
      ELSE
         ln_coincidencias  := 0;
         ln_long_proc_desc := 0;
         -- Contador del numero de comparaciones
         -- usado al momento de almacenar datos
         -- solo se permiten comparar dos registros
         ln_reg_comparar := ln_reg_comparar + 1;

         -- COINCIDENCIAS y PORCENTAJE APROXIMACIONES
         -- CELDAS  K9 y K10
         --
         -- COINCIDENCIAS K 9
         IF lv_proc_desc_1_rep = lv_proc_desc_1 OR
            lv_proc_desc_1_rep = lv_proc_desc_2 OR
            lv_proc_desc_1_rep = lv_proc_desc_3 OR
            lv_proc_desc_1_rep = lv_proc_desc_4 OR
            lv_proc_desc_1_rep = lv_proc_desc_5 THEN
            ln_coincidencias  := ln_coincidencias + 1;
            ln_long_proc_desc := ln_long_proc_desc + nvl(length(lv_proc_desc_1_rep),0);
         END IF;

         IF lv_proc_desc_2_rep = lv_proc_desc_1 OR
            lv_proc_desc_2_rep = lv_proc_desc_2 OR
            lv_proc_desc_2_rep = lv_proc_desc_3 OR
            lv_proc_desc_2_rep = lv_proc_desc_4 OR
            lv_proc_desc_2_rep = lv_proc_desc_5 THEN
            ln_coincidencias  := ln_coincidencias + 1;
            ln_long_proc_desc := ln_long_proc_desc + nvl(length(lv_proc_desc_2_rep),0);
         END IF;

         IF lv_proc_desc_3_rep = lv_proc_desc_1 OR
            lv_proc_desc_3_rep = lv_proc_desc_2 OR
            lv_proc_desc_3_rep = lv_proc_desc_3 OR
            lv_proc_desc_3_rep = lv_proc_desc_4 OR
            lv_proc_desc_3_rep = lv_proc_desc_5 THEN
            ln_coincidencias  := ln_coincidencias + 1;
            ln_long_proc_desc := ln_long_proc_desc + nvl(length(lv_proc_desc_3_rep),0);
         END IF;

         IF lv_proc_desc_4_rep = lv_proc_desc_1 OR
            lv_proc_desc_4_rep = lv_proc_desc_2 OR
            lv_proc_desc_4_rep = lv_proc_desc_3 OR
            lv_proc_desc_4_rep = lv_proc_desc_4 OR
            lv_proc_desc_4_rep = lv_proc_desc_5 THEN
            ln_coincidencias  := ln_coincidencias + 1;
            ln_long_proc_desc := ln_long_proc_desc + nvl(length(lv_proc_desc_4_rep),0);
         END IF;

         IF lv_proc_desc_5_rep = lv_proc_desc_1 OR
            lv_proc_desc_5_rep = lv_proc_desc_2 OR
            lv_proc_desc_5_rep = lv_proc_desc_3 OR
            lv_proc_desc_5_rep = lv_proc_desc_4 OR
            lv_proc_desc_5_rep = lv_proc_desc_5 THEN
            ln_coincidencias  := ln_coincidencias + 1;
            ln_long_proc_desc := ln_long_proc_desc + nvl(length(lv_proc_desc_5_rep),0);
         END IF;

         -- Busca cuantos blancos existen en cada separacion
         -- Cadenas vacias separacion actual
         ln_proc_desc_blancos  := 0;
         IF length(lv_proc_desc_1) = 0 THEN
            ln_proc_desc_blancos  := ln_proc_desc_blancos + 1;
         END IF;

         IF length(lv_proc_desc_2) = 0 THEN
            ln_proc_desc_blancos  := ln_proc_desc_blancos + 1;
         END IF;

         IF length(lv_proc_desc_3) = 0 THEN
            ln_proc_desc_blancos  := ln_proc_desc_blancos + 1;
         END IF;

         IF length(lv_proc_desc_4) = 0 THEN
            ln_proc_desc_blancos  := ln_proc_desc_blancos + 1;
         END IF;

         IF length(lv_proc_desc_5) = 0 THEN
            ln_proc_desc_blancos  := ln_proc_desc_blancos + 1;
         END IF;

         -- separacion anterior
         ln_proc_desc_ant_blancos  := 0;
         IF length(lv_proc_desc_1_rep) = 0 THEN
            ln_proc_desc_ant_blancos  := ln_proc_desc_ant_blancos + 1;
         END IF;

         IF length(lv_proc_desc_2_rep) = 0 THEN
            ln_proc_desc_ant_blancos  := ln_proc_desc_ant_blancos + 1;
         END IF;

         IF length(lv_proc_desc_3_rep) = 0 THEN
            ln_proc_desc_ant_blancos  := ln_proc_desc_ant_blancos + 1;
         END IF;

         IF length(lv_proc_desc_4_rep) = 0 THEN
            ln_proc_desc_ant_blancos  := ln_proc_desc_ant_blancos + 1;
         END IF;

         IF length(lv_proc_desc_5_rep) = 0 THEN
            ln_proc_desc_ant_blancos  := ln_proc_desc_ant_blancos + 1;
         END IF;

         -- Busca el valor minimo entre las cadenas en blanco
         -- si el minimo es 1 entoces se resta coincidencias
--         IF ln_proc_desc_ant_blancos >= ln_proc_desc_blancos THEN
--            -- Minimo ln_proc_desc_blancos
--            IF ln_proc_desc_blancos >= 1 THEN
--               ln_coincidencias := ln_coincidencias - ln_proc_desc_ant_blancos;
--            END IF;
--         ELSE
--            -- Minimo ln_proc_desc_ant_blancos
--            IF ln_proc_desc_ant_blancos >= 1 THEN
--               ln_coincidencias := ln_coincidencias - ln_proc_desc_ant_blancos;
--            END IF;
--         END IF;

         IF ln_proc_desc_blancos     >=1 AND
            ln_proc_desc_ant_blancos >=1 THEN
            ln_coincidencias := ln_coincidencias - ln_proc_desc_ant_blancos;
         END IF;
         -- Fin Coincidnecias

         ----
         --- APROXIMACIONES    CELDA K 10
         -- Longitud de la cadena total
         ln_long_desc         := nvl(length(cur_proc.desc_persona),0);
         ln_porc_aproximacion := 0;

         IF ln_long_desc > 0 THEN
            ln_porc_aproximacion := ln_long_proc_desc / ln_long_desc;
         END IF;

         --- Proceso para obtener el ESTADO y CONDICION del resgitro analizado
         -- ESTADO   CELDA L
         IF trim(substr(lv_desc_persona_rep,1,15)) = trim(substr(cur_proc.desc_persona,1,15)) THEN
            lv_proc_estado := '';
         ELSE
            IF ln_coincidencias >= 2 THEN
               IF lv_proc_tip_persona_sugerido = '2' AND ln_porc_aproximacion > 0.3 THEN
                  lv_proc_estado := '';
               ELSE
                  IF lv_proc_tip_persona_sugerido = '1' AND ln_porc_aproximacion > 0.2 THEN
                     lv_proc_estado := '';
                  ELSE
                     lv_proc_estado := 'No OK';
                  END IF;
               END IF;
            ELSE
               -- ln_coincidencias < 2
               IF ln_porc_aproximacion > 0.5 THEN
                  lv_proc_estado := '';
               ELSE
                 lv_proc_estado := 'No OK';
               END IF;
            END IF;
         END IF;
         -- Fin Estado
         --
         -- CONDICION   -- CELDA M 9
         lv_proc_condicion := '';
         IF lv_proc_tip_persona_sugerido = cur_proc.proc_tip_persona THEN
            -- Proc tipo persona registro anterior
            -- Proc Tipo persona registro actual
            IF lv_proc_tip_persona_sugerido = lv_tip_persona_rep THEN
               -- tipo persona registro anterior
               IF UPPER(lv_proc_estado) = 'NO OK' THEN
                  -- estado del proceso, calculado en la etapa anterior
                 lv_proc_condicion := 'Chequear';
               ELSE
                 lv_proc_condicion := '';
               END IF;
            END IF;
         ELSE
           lv_proc_condicion := 'Nuevo';
         END IF;

          -- Condicion   -- CELDA M 10
         lv_proc_condicion_sec_act := '';
         IF cur_proc.proc_tip_persona = cur_proc.tip_persona THEN
            lv_proc_condicion_sec_act := '';
         ELSE
            lv_proc_condicion_sec_act := 'Corregir Maestro';
         END IF;

      END IF;

       -- ACTUALIZA SEPARACION DE NOMBRES

       UPDATE XCRI_ALTAS_VAL_ASIG_CODSBS_FV T
          SET T.PROC_DESC_1 = lv_proc_desc_1
             ,T.PROC_DESC_2 = lv_proc_desc_2
             ,T.PROC_DESC_3 = lv_proc_desc_3
             ,T.PROC_DESC_4 = lv_proc_desc_4
             ,T.PROC_DESC_5 = lv_proc_desc_5
       WHERE T.ANO_REFER    = cur_proc.ano_refer
         AND T.MES_REFER    = cur_proc.mes_refer
         AND T.COD_REPORTE  = cur_proc.cod_reporte
         AND T.COD_EMPRESA  = cur_proc.cod_empresa
         AND T.SECUENCIA    = cur_proc.secuencia
         AND T.DIA_REFER    = cur_proc.dia_refer
         AND T.COD_SEC_ENVIO = cur_proc.cod_sec_envio ;

        COMMIT;

       -- ACTUALIZA COINCIDENCIAS Y APROXIMACIONES
       -- La actualizacion la realizara cada vez que compara dos registros
       -- Se debe establecer que pasara cuando existe mas
       -- de una coincidencia. Por el momento se esta restringiendo
       -- esta validacion de registros.
       IF ln_reg_comparar = 2 THEN

          -- APROXIMACIONES
          UPDATE XCRI_ALTAS_VAL_ASIG_CODSBS_FV T
             SET T.PROC_PORC_APROXIMACION = ln_porc_aproximacion
                ,T.PROC_CONDICION         = lv_proc_condicion_sec_act
           WHERE T.ANO_REFER   = cur_proc.ano_refer
             AND T.MES_REFER   = cur_proc.mes_refer
             AND T.COD_REPORTE = cur_proc.cod_reporte
             AND T.COD_EMPRESA = cur_proc.cod_empresa
             AND T.SECUENCIA   = cur_proc.secuencia
             AND T.DIA_REFER   = cur_proc.dia_refer
             AND T.COD_SEC_ENVIO = cur_proc.cod_sec_envio ;

          -- COINCIDENCIAS
          UPDATE XCRI_ALTAS_VAL_ASIG_CODSBS_FV T
             SET T.PROC_COINCIDENCIAS = ln_coincidencias
                ,T.PROC_ESTADO        = lv_proc_estado
                ,T.PROC_CONDICION     = lv_proc_condicion
           WHERE T.ANO_REFER   = cur_proc.ano_refer
             AND T.MES_REFER   = cur_proc.mes_refer
             AND T.COD_REPORTE = cur_proc.cod_reporte
             AND T.COD_EMPRESA = cur_proc.cod_empresa
             AND T.SECUENCIA   = cur_proc.secuencia - 1
             AND T.DIA_REFER   = cur_proc.dia_refer
             AND T.COD_SEC_ENVIO = cur_proc.cod_sec_envio ;

          COMMIT;
       ELSE
          IF ln_reg_comparar > 2 THEN
             -- Existe mas de una una ocurrencia para este registro
             IF lv_tip_persona_rep <> '2' THEN
                -- Personas Naturales o Mancomunos que tengan mas de una incidencia seran observadas
                lv_proc_estado    := 'No OK';
                lv_proc_condicion := 'Chequear +2';

                UPDATE XCRI_ALTAS_VAL_ASIG_CODSBS_FV T
                   SET T.PROC_ESTADO        = lv_proc_estado
                      ,T.PROC_CONDICION     = lv_proc_condicion
                 WHERE T.ANO_REFER   = cur_proc.ano_refer
                   AND T.MES_REFER   = cur_proc.mes_refer
                   AND T.COD_REPORTE = cur_proc.cod_reporte
                   AND T.COD_EMPRESA = cur_proc.cod_empresa
                   AND T.SECUENCIA   = cur_proc.secuencia + 1 - ln_reg_comparar
                   AND T.DIA_REFER   = cur_proc.dia_refer
                   AND T.COD_SEC_ENVIO = cur_proc.cod_sec_envio ;

                 COMMIT;
             END IF;
          END IF;
       END IF;

       ln_num_reg_update := ln_num_reg_update + 1;
       IF ln_num_reg_update > 1000 THEN
          COMMIT;
          ln_num_reg_update := 0;
       END IF;

   end loop;

  COMMIT;

  -- Control de Errores
  EXCEPTION
    WHEN OTHERS THEN
         -- Actualizar estado de este proceso y colocarlo en error
         -- Actualiza Observaciones del Sistema
     PRV_ERROR   := SQLERRM;
     PRV_MENSAJE := substr(PRV_ERROR,1,255) || ' -- SP_PROCESA_DATA';
     PRN_RETURN  := -1;
     RETURN;

END SP_PROCESA_DATA;

----------------------------------------------------------

-- Procedimiento para generar el archivo de salida del filtro
PROCEDURE SP_GENERA_FILE_SALIDA
        (pv_ano_refer     xcri_altas_val_asig_codsbs_fv.ano_refer%type,
         pv_mes_refer     xcri_altas_val_asig_codsbs_fv.mes_refer%type,
         pv_cod_reporte   xcri_altas_val_asig_codsbs_fv.cod_reporte%type,
         pv_cod_empresa   xcri_altas_val_asig_codsbs_fv.cod_empresa%type,
         pv_usuario       xcri_altas_val_asig_codsbs_fv.cod_usu_proc%type,
         pv_dia_refer     IN xcri_altas_val_asig_codsbs_fv.dia_refer%type default '01',
         pv_cod_sec_envio IN xcri_altas_val_asig_codsbs_fv.cod_sec_envio%type default '01' )
IS
---------------------
--       Autor                     Fecha         Software
--       Francisco Vite Shelton    17/08/2004    Oracle 8i
---------------------
--       Parametros
--           pv_ano_refer   :  Año de referencia.
--           pv_mes_refer   :  Mes de referencia.
--           pv_cod_reporte :  Codigo reporte a cargar (RCD/RTC)
--           pv_cod_empresa :  Codigo de la Entidad.
--           pv_usuario     : Usuario que ejecuta el proceso.
---------------------
--       Descripcion
--         Establece la ejecucion para todo el proceso de filtro de altas
--         Comprende dos procesos principales:
---------------------
-- Ejecucion
--  PK_XCRI_ALTAS_VAL_ASIG_CODSBS.SP_GENERA_FILE_SALIDA ('2004','04','RCD','00102','FVITES');
---------------------

-- Datos de la entidad
CURSOR cur_entidad IS
Select     'Entidad: ' || chr(9) || pv_cod_empresa || ' - ' || e.nom_ent_vig_corto as entidad
from ays_ent_vigilada e
where e.cod_ent_vig = pv_cod_empresa ;

-- Cabecera del resultado del filtro
CURSOR cur_cabecera IS
Select     'PROC_CONDICION'
||chr(9)|| 'PROC_ESTADO'
||chr(9)|| 'NUM_SEC_REG'
||chr(9)|| 'COD_SBS'
||chr(9)|| 'DESC_PERSONA'
||chr(9)|| 'DES_TIP_PERSONA'
||chr(9)|| 'DES_TIP_DOC_IDEN'
||chr(9)|| 'NUM_DOC_IDEN'
||chr(9)|| 'NUM_DOC_TRIB'
||chr(9)|| 'COD_UNICO_CLIE'
||chr(9)|| 'NOM_SIGLA'
||chr(9)|| 'ESTADO'
||chr(9)|| 'DES_TIP_PERSONA_PROC' as cabecera
from dual ;

CURSOR cur_reg_deudores IS
Select            T.PROC_CONDICION
      ||chr(9)||  T.PROC_ESTADO
      ||chr(9)||  T.NUM_SEC_REG
      ||chr(9)||  T.COD_SBS
      ||chr(9)||  T.DESC_PERSONA
      ||chr(9)||  SF_DES_ADM_ELEMENTO ( 'TIP_PERSONA' , T.TIP_PERSONA)
      ||chr(9)||  SF_DES_ADM_ELEMENTO ( 'TIP_DOC_IDENT' , T.TIP_DOC_IDEN)
      ||chr(9)||  T.NUM_DOC_IDEN
      ||chr(9)||  T.NUM_DOC_TRIB
      ||chr(9)||  T.COD_UNICO_CLIE
      ||chr(9)||  T.NOM_SIGLA
      ||chr(9)||  decode(T.COD_EST_ASIG,'A', 'Antiguo',T.COD_EST_ASIG)
      ||chr(9)||  SF_DES_ADM_ELEMENTO ( 'TIP_PERSONA', T.PROC_TIP_PERSONA) AS deudor
 FROM XCRI_ALTAS_VAL_ASIG_CODSBS_FV T
WHERE T.ANO_REFER   = pv_ano_refer
  AND T.MES_REFER   = pv_mes_refer
  AND T.COD_REPORTE = pv_cod_reporte
  AND T.COD_EMPRESA = pv_cod_empresa
  AND ( length(T.PROC_ESTADO) > 0 OR length(T.PROC_CONDICION ) > 0 )
  AND T.DIA_REFER   = pv_dia_refer
  AND T.COD_SEC_ENVIO = pv_cod_sec_envio
ORDER BY 1 asc ;

lv_ruta                  VARCHAR2(120);
lv_filename_filtro_altas VARCHAR2(120);
lutl_file_filtro_altas   UTL_FILE.FILE_TYPE;
ln_num_reg_sal           NUMBER;
lv_reg_cab_cons          VARCHAR2(500);

BEGIN
  ------------------------------------------
  -- Inicio: Generando archivo Consolidado ---
  ------------------------------------------
  -- seteando la ruta y el nombre del archivo
  -- Verifica si existen registros para generar archivo
  ---------------------------------------------------------
  ----  Inicia proceso para generar el archivo consolidado
  ---------------------------------------------------------

  lv_filename_filtro_altas := 'Filtro_altas_';
  lv_filename_filtro_altas :=   lv_filename_filtro_altas || pv_cod_reporte || pv_ano_refer || pv_mes_refer || '_' || pv_cod_empresa || '.xls';
  lv_ruta      := SF_ALTAS_RUTA_FILE_UNIX (pv_usuario, lv_filename_filtro_altas, 'C' );

  -- Abriendo el Archivo de salida
  lutl_file_filtro_altas   := UTL_FILE.FOPEN (lv_ruta, lv_filename_filtro_altas, 'W');
  lv_reg_cab_cons      := '';

  -- Almacenando informacion en el Registro de salida
  -- Registro de cabecera
  ln_num_reg_sal := 0;
  UTL_FILE.PUT_LINE (lutl_file_filtro_altas, chr(13));

  FOR cur_ent IN cur_entidad LOOP
      lv_reg_cab_cons  := cur_ent.entidad;
      ln_num_reg_sal := ln_num_reg_sal + 1 ;
  END LOOP;

  UTL_FILE.PUT_LINE (lutl_file_filtro_altas, chr(13));
  UTL_FILE.PUT_LINE (lutl_file_filtro_altas, lv_reg_cab_cons ||chr(13));
  UTL_FILE.PUT_LINE (lutl_file_filtro_altas, chr(13));
  UTL_FILE.PUT_LINE (lutl_file_filtro_altas, chr(13));

  FOR cur_cab IN cur_cabecera LOOP
      lv_reg_cab_cons  := cur_cab.cabecera;
      ln_num_reg_sal := ln_num_reg_sal + 1 ;
  END LOOP;

  UTL_FILE.PUT_LINE (lutl_file_filtro_altas, lv_reg_cab_cons ||chr(13));

  FOR cur_deud IN cur_reg_deudores LOOP
      lv_reg_cab_cons  := cur_deud.deudor;
      ln_num_reg_sal := ln_num_reg_sal + 1 ;
      UTL_FILE.PUT_LINE (lutl_file_filtro_altas, lv_reg_cab_cons ||chr(13));
  END LOOP;

  -- Cierra los archivos
  UTL_FILE.FCLOSE(lutl_file_filtro_altas);
  --  UTL_FILE.FCLOSE_ALL;

  -- Finaliza OK
  DBMS_OUTPUT.PUT_LINE ('Final : '||to_char(sysdate,'yyyy-mm-dd hh24:mi:ss'));

  -- Fin: Generando archivo de salida ---
RETURN;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
       ROLLBACK;
       DBMS_OUTPUT.PUT_LINE('Fin de registro');
       PRV_ERROR   := SQLERRM;
       PRV_MENSAJE := substr(PRV_ERROR,1,255) || ' -- SP_GENERA_FILE_SALIDA';
       PRN_RETURN  := -1;
       UTL_FILE.FCLOSE(lutl_file_filtro_altas);

   WHEN UTL_FILE.INVALID_PATH THEN
       ROLLBACK;
       DBMS_OUTPUT.PUT_LINE('UTL_FILE: Ruta no valida');
       PRV_ERROR   := SQLERRM;
       PRV_MENSAJE := substr(PRV_ERROR,1,255) || ' -- SP_GENERA_FILE_SALIDA';
       PRN_RETURN  := -1;
       UTL_FILE.FCLOSE(lutl_file_filtro_altas);

   WHEN UTL_FILE.READ_ERROR THEN
       ROLLBACK;
       DBMS_OUTPUT.PUT_LINE('UTL_FILE: Error en lectura');
       PRV_ERROR   := SQLERRM;
       PRV_MENSAJE := substr(PRV_ERROR,1,255) || ' -- SP_GENERA_FILE_SALIDA';
       PRN_RETURN  := -1;
       UTL_FILE.FCLOSE(lutl_file_filtro_altas);

   WHEN UTL_FILE.WRITE_ERROR THEN
       ROLLBACK;
       DBMS_OUTPUT.PUT_LINE('UTL_FILE: Error en escritura');
       PRV_ERROR   := SQLERRM;
       PRV_MENSAJE := substr(PRV_ERROR,1,255) || ' -- SP_GENERA_FILE_SALIDA';
       PRN_RETURN  := -1;
       UTL_FILE.FCLOSE(lutl_file_filtro_altas);

   WHEN UTL_FILE.INVALID_MODE THEN
       ROLLBACK;
       DBMS_OUTPUT.PUT_LINE('UTL_FILE: Error en modo de acceso');
       PRV_ERROR   := SQLERRM;
       PRV_MENSAJE := substr(PRV_ERROR,1,255) || ' -- SP_GENERA_FILE_SALIDA';
       PRN_RETURN  := -1;
       UTL_FILE.FCLOSE(lutl_file_filtro_altas);

   WHEN UTL_FILE.INVALID_FILEHANDLE THEN
       ROLLBACK;
       DBMS_OUTPUT.PUT_LINE('UTL_FILE: Error ');
       PRV_ERROR   := SQLERRM;
       PRV_MENSAJE := substr(PRV_ERROR,1,255) || ' -- SP_GENERA_FILE_SALIDA';
       PRN_RETURN  := -1;
       UTL_FILE.FCLOSE(lutl_file_filtro_altas);

   WHEN UTL_FILE.INVALID_OPERATION THEN
       ROLLBACK;
       DBMS_OUTPUT.PUT_LINE('UTL_FILE: Error ');
       PRV_ERROR   := SQLERRM;
       PRV_MENSAJE := substr(PRV_ERROR,1,255) || ' -- SP_GENERA_FILE_SALIDA';
       PRN_RETURN  := -1;
       UTL_FILE.FCLOSE(lutl_file_filtro_altas);

   WHEN UTL_FILE.INVALID_MAXLINESIZE THEN
       ROLLBACK;
       DBMS_OUTPUT.PUT_LINE('UTL_FILE: Error ');
       PRV_ERROR   := SQLERRM;
       PRV_MENSAJE := substr(PRV_ERROR,1,255) || ' -- SP_GENERA_FILE_SALIDA';
       PRN_RETURN  := -1;
       UTL_FILE.FCLOSE(lutl_file_filtro_altas);

   WHEN UTL_FILE.INTERNAL_ERROR THEN
       ROLLBACK;
       DBMS_OUTPUT.PUT_LINE('UTL_FILE: Error ');
       PRV_ERROR   := SQLERRM;
       PRV_MENSAJE := substr(PRV_ERROR,1,255) || ' -- SP_GENERA_FILE_SALIDA';
       PRN_RETURN  := -1;
       UTL_FILE.FCLOSE(lutl_file_filtro_altas);

  WHEN OTHERS THEN
       -- Actualizar estado de este proceso y colocarlo en error.
       -- Actualiza Observaciones del Sistema.
       UTL_FILE.FCLOSE(lutl_file_filtro_altas);
       PRV_ERROR   := SQLERRM;
       PRV_MENSAJE := substr(PRV_ERROR,1,255) || ' -- SP_GENERA_FILE_SALIDA';
       PRN_RETURN  := -1;

END SP_GENERA_FILE_SALIDA;

----------------------------------------------------------

   -- Procedimiento para Actualizas la asignacion de cod_sbs
   -- esto se ejecutara despues de realizar el filtro
PROCEDURE SP_ACTUALIZA_ASIG_COD_SBS
        (pv_ano_refer     xcri_altas_val_asig_codsbs_fv.ano_refer%type,
         pv_mes_refer     xcri_altas_val_asig_codsbs_fv.mes_refer%type,
         pv_cod_reporte   xcri_altas_val_asig_codsbs_fv.cod_reporte%type,
         pv_cod_empresa   xcri_altas_val_asig_codsbs_fv.cod_empresa%type,
         pv_usuario       xcri_altas_val_asig_codsbs_fv.cod_usu_proc%type,
         pv_dia_refer     IN xcri_altas_val_asig_codsbs_fv.dia_refer%type default '01',
         pv_cod_sec_envio IN xcri_altas_val_asig_codsbs_fv.cod_sec_envio%type default '01' )
IS
---------------------
--       Autor                     Fecha         Software
--       Francisco Vite Shelton    19/08/2004    Oracle 8i
---------------------
--       Parametros
--           pv_ano_refer   :  Año de referencia.
--           pv_mes_refer   :  Mes de referencia.
--           pv_cod_reporte :  Codigo reporte a cargar (RCD/RTC)
--           pv_cod_empresa :  Codigo de la Entidad.
--           pv_usuario     : Usuario que ejecuta el proceso.
---------------------
--       Descripcion
--         Procedimiento para Actualizas la asignacion de cod_sbs. Esto se ejecutara despues de realizar el filtro
--         toma en consideracion los registros detectados por el sistema para ser observados. El nuevo estado de estos
--         registros sera considerado como aproximado
--
--         Esta actualizacion considera a todos los registros despues del filtro realizado a excepcion de las dudas que seran
--         analizadas una a una por los usuarios DERC
---------------------
-- Ejecucion
--  PK_XCRI_ALTAS_VAL_ASIG_CODSBS.SP_ACTUALIZA_ASIG_COD_SBS ('2004','04','RCD','00102','FVITES');
---------------------

CURSOR cur_act_estado_deudores IS
   Select   T.PROC_CONDICION
          , T.PROC_ESTADO
          , T.NUM_SEC_REG
          , T.COD_SBS
          , T.DESC_PERSONA
          , SF_DES_ADM_ELEMENTO ( 'TIP_PERSONA' , T.TIP_PERSONA) DESC_TIP_PERSONA
          , SF_DES_ADM_ELEMENTO ( 'TIP_DOC_IDENT' , T.TIP_DOC_IDEN) DESC_TIP_DOCID
          , T.NUM_DOC_IDEN
          , T.NUM_DOC_TRIB
          , T.COD_UNICO_CLIE
          , T.NOM_SIGLA
          , decode(T.COD_EST_ASIG,'A', 'Antiguo',T.COD_EST_ASIG) DESC_ESTADO
          , SF_DES_ADM_ELEMENTO ( 'TIP_PERSONA', T.PROC_TIP_PERSONA) DESC_TIP_PERSONA_PROC
 FROM XCRI_ALTAS_VAL_ASIG_CODSBS_FV T
WHERE T.ANO_REFER   = pv_ano_refer
  AND T.MES_REFER   = pv_mes_refer
  AND T.COD_REPORTE = pv_cod_reporte
  AND T.COD_EMPRESA = pv_cod_empresa
  AND (length(T.PROC_ESTADO) > 0 OR length(T.PROC_CONDICION ) > 0)
  AND nvl(T.COD_EST_ASIG,'NULL') <> 'D'
  AND T.DIA_REFER   = pv_dia_refer
  AND T.COD_SEC_ENVIO = pv_cod_sec_envio
ORDER BY  1 asc ;
-----------------------------
lv_estado  Varchar2(1);
ln_num_reg_cli     NUMBER;

BEGIN
  -- VALOR QUE TOMARA EL ESTADO
  -- en este caso sera aproximado
  lv_estado := 'B';
  ln_num_reg_cli := 0;

  FOR cur_deud IN cur_act_estado_deudores LOOP
      -- Proceso de actualizacion
      ln_num_reg_cli := ln_num_reg_cli + 1 ;

      IF cur_deud.num_sec_reg > 0 THEN
            -- existen observados que no aparecen con secuencia
            -- ejemplo los 'Corregir maestro'
         UPDATE CRA_VALID_ASIG_CODSBS A
            SET A.COD_EST_ASIG = lv_estado
          WHERE A.ANO_REFER   = pv_ano_refer
            AND A.MES_REFER   = pv_mes_refer
            AND A.COD_REPORTE = pv_cod_reporte
            AND A.COD_EMPRESA = pv_cod_empresa
            AND A.NUM_SEC_REG = cur_deud.num_sec_reg
            AND A.DIA_REFER   = pv_dia_refer
            AND A.COD_SEC_ENVIO = pv_cod_sec_envio ;
      END IF;

      IF ln_num_reg_cli > 1000 THEN
         COMMIT;
         ln_num_reg_cli := 0;
      END IF;
  END LOOP;

  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    PRV_ERROR   := SQLERRM;
    PRV_MENSAJE := substr(PRV_ERROR,1,255) || ' -- SP_ACTUALIZA_ASIG_COD_SBS';
    PRN_RETURN  := -5;
    RETURN ;

END SP_ACTUALIZA_ASIG_COD_SBS;

----------------------------------------------------

-- Obtiene la ruta para cargar el archivo a la BD
FUNCTION  SF_ALTAS_RUTA_FILE_UNIX
       ( pv_usuario      xcri_altas_val_asig_codsbs_fv.cod_usu_proc%type
        ,pv_archivo    VARCHAR2
        ,pv_tipofile    VARCHAR2
        ,pv_cod_reporte  VARCHAR2 DEFAULT 'RCD'
       )
RETURN VARCHAR2 IS
---------------------
--       Autor                     Fecha         Software
--       Francisco Vite Shelton    17/08/2004    Oracle 8i
---------------------
--       Parametros
--           pv_usuario : Usuario con el que ha ingresado al Sistema
--           pv_archivo : Nombre del archivo a generar
---------------------
--       Descripcion
--         Funcion que retorna la ruta del unix donde se almacenaran los archivos del filtro para altas.
---------------------
lv_ruta_unix      VARCHAR2(120);
lv_ruta_reporte   VARCHAR2(120);
ln_validadato     NUMBER;
lv_ano_refer      xcri_altas_val_asig_codsbs_fv.ano_refer%type;
lv_mes_refer      xcri_altas_val_asig_codsbs_fv.mes_refer%type;

BEGIN
   lv_ruta_unix := '';

 -- Filtro_altas_RCD200407_00101.xls
 lv_ano_refer := SUBSTR(pv_archivo,17,4);
 lv_mes_refer := SUBSTR(pv_archivo,21,2);

 ln_validadato := 1 ;
 /*-- Valida año
 ln_validadato := SF_VALIDA_ANHO ( lv_ano_refer, lv_mensaje, lv_codmensaje);
 -- Valida mes
 IF ln_validadato = 1 THEN
    ln_validadato := SF_VALIDA_MES ( lv_mes_refer, lv_mensaje, lv_codmensaje);
 END IF; --*/

 IF ln_validadato = 1 THEN
    --lv_ruta_unix  := '/siscra/validacion/altas/';
    lv_ruta_reporte := '';
    select trim(SF_OBT_RUTA_DE_VALIDACION(pv_cod_reporte)) into lv_ruta_reporte from dual;
    lv_ruta_reporte := nvl(lv_ruta_reporte,'/siscra/validacion');
    lv_ruta_unix  := lv_ruta_reporte || '/altas/';
    lv_ruta_unix := lv_ruta_unix || lv_ano_refer || '_' || lv_mes_refer;
 END IF;

 RETURN lv_ruta_unix;

EXCEPTION
  WHEN OTHERS THEN
       PRV_ERROR   := SQLERRM;
       PRV_MENSAJE := substr(PRV_ERROR,1,255) || ' -- SF_ALTAS_RUTA_FILE_UNIX';
       PRN_RETURN  := -1;

    RETURN '';
END SF_ALTAS_RUTA_FILE_UNIX;

----------------------------------------------------------

-- Procedimiento principal de las asignaciones de cod_sbs. Esto se ejecutara despues de todo el proceso de altas
PROCEDURE SP_POST_ALTAS_ASIG_CODSBS
        (pv_ano_refer     cra_valid_asig_codsbs.ano_refer%type,
         pv_mes_refer     cra_valid_asig_codsbs.mes_refer%type,
         pv_cod_reporte   cra_valid_asig_codsbs.cod_reporte%type,
         pv_cod_empresa   cra_valid_asig_codsbs.cod_empresa%type,
         pv_usuario       cra_valid_asig_codsbs.cod_usu_apr%type,
         pv_dia_refer     IN cra_valid_asig_codsbs.dia_refer%type default '01',
         pv_cod_sec_envio IN cra_valid_asig_codsbs.cod_sec_envio%type default '01'
         )
IS
---------------------
--       Autor                     Fecha         Software
--       Francisco Vite Shelton    15/03/2005    Oracle 8i
---------------------
--       Parametros
--           pv_ano_refer   :  Año de referencia.
--           pv_mes_refer   :  Mes de referencia.
--           pv_cod_reporte :  Codigo reporte a cargar (RCD/RTC)
--           pv_cod_empresa :  Codigo de la Entidad.
--           pv_usuario     : Usuario que ejecuta el proceso.
---------------------
--       Descripcion
--         Este proceso realiza la ejecucion de los procesos principales de post altas.
---------------------
-- Ejecucion
--  PK_XCRI_ALTAS_VAL_ASIG_CODSBS.SP_POST_ALTAS_ASIG_CODSBS ('2005','02','RCD','00102','FVITES');
---------------------
-- Variable para obtener el tipo de consulta arealizar
  -- lv_tipo_consulta:
  --          '1' : Compara segundo nombre
  --          '0' : No Compara segundo nombre

lv_tipo_consulta VARCHAR2(1);

BEGIN
  -- Ejecuta el proceso principal de las asignaciones post altas
  -------------------------------     ----------------------------
  -- Los clasificados como antiguos y solo consideran el cod_unico los retorna a DUDAS
  SP_POST_ALTAS_ASIG_X_CODUNI ( pv_ano_refer, pv_mes_refer, pv_cod_reporte,pv_cod_empresa, pv_usuario, pv_dia_refer, pv_cod_sec_envio );
  IF PRN_RETURN  <> 1 THEN
     RETURN;
  END IF;

  -- '1' : Compara segundo nombre
  lv_tipo_consulta := '1';
  SP_POST_ALTAS_PROCESA_ASIG ( pv_ano_refer, pv_mes_refer, pv_cod_reporte, pv_cod_empresa, pv_usuario, lv_tipo_consulta, pv_dia_refer, pv_cod_sec_envio );
  IF PRN_RETURN  <> 1 THEN
     RETURN;
  END IF;

  -- '0' : No Compara segundo nombre
  lv_tipo_consulta := '0';
  SP_POST_ALTAS_PROCESA_ASIG ( pv_ano_refer, pv_mes_refer, pv_cod_reporte, pv_cod_empresa, pv_usuario, lv_tipo_consulta, pv_dia_refer, pv_cod_sec_envio );
  IF PRN_RETURN  <> 1 THEN
     RETURN;
  END IF;

  -- Verifica que los deudores clasificados como nuevos no esten en el maestro (Busca Tipo y Numero de documento)
  SP_POST_ALTAS_CAMBIO_ESTADO_NV ( pv_ano_refer, pv_mes_refer, pv_cod_reporte, pv_cod_empresa, pv_usuario, pv_dia_refer, pv_cod_sec_envio );
  IF PRN_RETURN  <> 1 THEN
     RETURN;
  END IF;
  -------------------------------     ----------------------------
  -- FVSH  2005-06-14
  -- Genera el archivo de aproximados/Dudas
  --  SP_POST_ALTAS_GENERA_FILE_APRX( pv_ano_refer, pv_mes_refer, pv_cod_reporte,pv_cod_empresa, pv_usuario);
  -- APROXIMADOS
  SP_POST_ALTA_GENE_FILE_APX_DUD( pv_ano_refer, pv_mes_refer, pv_cod_reporte,pv_cod_empresa, pv_usuario, PRV_ESTADO_APROXIMADO, pv_dia_refer, pv_cod_sec_envio );
  IF PRN_RETURN  <> 1 THEN
     RETURN;
  END IF;

  -- DUDAS
  SP_POST_ALTA_GENE_FILE_APX_DUD( pv_ano_refer, pv_mes_refer, pv_cod_reporte,pv_cod_empresa, pv_usuario, PRV_ESTADO_DUDA, pv_dia_refer, pv_cod_sec_envio );

EXCEPTION
  WHEN OTHERS THEN
    PRV_ERROR   := SQLERRM;
    PRV_MENSAJE := substr(PRV_ERROR,1,255) ||' -- SP_POST_ALTAS_ASIG_CODSBS';
    PRN_RETURN  := -5;
    RETURN ;

END SP_POST_ALTAS_ASIG_CODSBS;

----------------------------------------------------------
 -- Procedimiento para Actualizar la asignacion de cod_sbs
 -- realiza una busqueda para los deudores asugnados
 -- Solo por Codigo Unico y calsificados como antiguos.
 -- esto se ejecutara despues de todo el proceso de altas
PROCEDURE SP_POST_ALTAS_ASIG_X_CODUNI
        (pv_ano_refer     cra_valid_asig_codsbs.ano_refer%type,
         pv_mes_refer     cra_valid_asig_codsbs.mes_refer%type,
         pv_cod_reporte   cra_valid_asig_codsbs.cod_reporte%type,
         pv_cod_empresa   cra_valid_asig_codsbs.cod_empresa%type,
         pv_usuario       cra_valid_asig_codsbs.cod_usu_apr%type,
         pv_dia_refer     IN cra_valid_asig_codsbs.dia_refer%type default '01',
         pv_cod_sec_envio IN cra_valid_asig_codsbs.cod_sec_envio%type default '01'
         )
IS
---------------------
--       Autor                     Fecha         Software
--       Francisco Vite Shelton    15/03/2005    Oracle 8i
---------------------
--       Parametros
--           pv_ano_refer   :  Año de referencia.
--           pv_mes_refer   :  Mes de referencia.
--           pv_cod_reporte :  Codigo reporte a cargar (RCD/RTC)
--           pv_cod_empresa :  Codigo de la Entidad.
--           pv_usuario     : Usuario que ejecuta el proceso.
--
---------------------
--       Descripcion
--   Realiza la Busqueda de los Deudores clasificados como Antiguos
--   Para cada tipo de persona, tomando en consideracion que la
--   unica coincidencia sea el Codigo Unico o aquellos
--   deudores que se les asignara la coincidencia por Codigo Unico
--   y tenga diferencia con el codigo sbs encontrado para el Doc Id.
--   ANO_REFER,MES_REFER,COD_REPORTE,COD_EMPRESA,NUM_SEC_REG)
--   ---
--   Los deudores encotrados los traslada a DUDAS
--   ----->    ANTIGUOS (A)  ===>  Dudas (D)
--
---------------------
-- Ejecucion
--  PK_XCRI_ALTAS_VAL_ASIG_CODSBS.SP_POST_ALTAS_ASIG_X_CODUNI ('2005','02','RCD','00102','FVITES');
---------------------

lv_entidad       VARCHAR2(5);
lv_ano_refer     VARCHAR2(4);
lv_mes_refer     VARCHAR2(2);
lv_tipo_reporte  VARCHAR2(3);

 CURSOR cur_cod_unico_cliente IS
    -- PERSONAS NATURALES
   SELECT ANO_REFER,
          MES_REFER,
          COD_REPORTE,
          COD_EMPRESA,
          NUM_SEC_REG
     FROM cra_valid_asig_codsbs a
    WHERE a.ano_refer         = lv_ano_refer
      AND a.mes_refer         = lv_mes_refer
      AND a.cod_reporte       = lv_tipo_reporte
      AND a.cod_empresa       = lv_entidad
      AND a.cod_est_asig      = 'A'
      AND a.cod_sbs_a_asignar = a.cod_sbs_coinc_uni
      AND nvl(a.cod_sbs_coinc_ide,0) <> a.cod_sbs_coinc_uni
      AND a.tip_persona       = 1
      AND a.cod_sbs_coinc_uni > 0
      AND a.dia_refer         = pv_dia_refer
      AND a.cod_sec_envio     = pv_cod_sec_envio
   UNION
    -- PERSONAS JURIDICAS
   Select ANO_REFER,
          MES_REFER,
          COD_REPORTE,
          COD_EMPRESA,
          NUM_SEC_REG
     from cra_valid_asig_codsbs a
    where a.ano_refer         = lv_ano_refer
      and a.mes_refer         = lv_mes_refer
      and a.cod_reporte       = lv_tipo_reporte
      and a.cod_empresa       = lv_entidad
      and a.cod_est_asig      = 'A'
      and a.cod_sbs_a_asignar = a.cod_sbs_coinc_uni
      and nvl(a.cod_sbs_coinc_ruc,0) <> a.cod_sbs_coinc_uni
      and a.tip_persona       = 2
      AND a.cod_sbs_coinc_uni > 0
      AND a.dia_refer         = pv_dia_refer
      AND a.cod_sec_envio     = pv_cod_sec_envio
   UNION
    -- PERSONAS MANCOMUNOS
   SELECT ANO_REFER,
          MES_REFER,
          COD_REPORTE,
          COD_EMPRESA,
          NUM_SEC_REG
     FROM cra_valid_asig_codsbs a
    WHERE a.ano_refer         = lv_ano_refer
      AND a.mes_refer         = lv_mes_refer
      AND a.cod_reporte       = lv_tipo_reporte
      AND a.cod_empresa       = lv_entidad
      AND a.cod_est_asig      = 'A'
      AND a.cod_sbs_a_asignar = a.cod_sbs_coinc_uni
      AND nvl(a.cod_sbs_coinc_ide,0) <> a.cod_sbs_coinc_uni
      AND a.tip_persona       = 3
      AND a.cod_sbs_coinc_uni > 0
      AND a.dia_refer         = pv_dia_refer
      AND a.cod_sec_envio     = pv_cod_sec_envio ;

BEGIN
  lv_entidad       := pv_cod_empresa;
  lv_ano_refer     := pv_ano_refer;
  lv_mes_refer     := pv_mes_refer;
  lv_tipo_reporte  := pv_cod_reporte;

  FOR cur_cod_uni IN cur_cod_unico_cliente LOOP
      UPDATE cra_valid_asig_codsbs x
         SET x.cod_est_asig = 'D'
       WHERE x.ANO_REFER   = lv_ano_refer
         and x.MES_REFER   = lv_mes_refer
         and x.COD_REPORTE = lv_tipo_reporte
         and x.COD_EMPRESA = lv_entidad
         and x.NUM_SEC_REG = cur_cod_uni.NUM_SEC_REG
         and x.DIA_REFER   = pv_dia_refer
         and x.COD_SEC_ENVIO = pv_cod_sec_envio ;
  END LOOP;

  commit;
  PRN_RETURN  := 1;

EXCEPTION
  WHEN OTHERS THEN
    rollback;
    PRV_ERROR   := SQLERRM;
    PRV_MENSAJE := substr(PRV_ERROR,1,255) ||' -- SP_POST_ALTAS_ASIG_X_CODUNI';
    PRN_RETURN  := -5;
    RETURN ;

END SP_POST_ALTAS_ASIG_X_CODUNI;

----------------------------------------------------------

-- Procedimiento para Actualizar la asignacion de cod_sbs
-- esto se ejecutara despues de todo el proceso de altas
PROCEDURE SP_POST_ALTAS_PROCESA_ASIG
        (pv_ano_refer     cra_valid_asig_codsbs.ano_refer%type,
         pv_mes_refer     cra_valid_asig_codsbs.mes_refer%type,
         pv_cod_reporte   cra_valid_asig_codsbs.cod_reporte%type,
         pv_cod_empresa   cra_valid_asig_codsbs.cod_empresa%type,
         pv_usuario       cra_valid_asig_codsbs.cod_usu_apr%type,
         pv_tipo_consulta VARCHAR2,
         pv_dia_refer     IN cra_valid_asig_codsbs.dia_refer%type default '01',
         pv_cod_sec_envio IN cra_valid_asig_codsbs.cod_sec_envio%type default '01'
         )
IS
---------------------
--       Autor                     Fecha         Software
--       Francisco Vite Shelton    15/03/2005    Oracle 8i
---------------------
--       Parametros
--           pv_ano_refer   :  Año de referencia.
--           pv_mes_refer   :  Mes de referencia.
--           pv_cod_reporte :  Codigo reporte a cargar (RCD/RTC)
--           pv_cod_empresa :  Codigo de la Entidad.
--           pv_usuario     : Usuario que ejecuta el proceso.
--
--           pv_tipo_consulta: Identifica el tipo de consulta a realizar
--                       '1' : Consulta considera el Segundo Nombre
--                       '0' : Consulta no considera el Segundo Nombre
---------------------
--       Descripcion
--         Procedimiento para Actualizas la asignacion de cod_sbs. Esto se ejecutara despues de realizar las asignaciones de los codigos SBS.
--         Este proceso realiza la ejecucion de los procesos principales de post altas..
---------------------
-- Ejecucion
--  PK_XCRI_ALTAS_VAL_ASIG_CODSBS.SP_POST_ALTAS_PROCESA_ASIG ('2005','02','RCD','00102','FVITES','1');
--------------------------------------------------------------

BEGIN
  -- Compara informacion con el maestro de personas  (ape_pat, ape_mat, primer_nom, seg_nom, tipo_doc, num_doc)
  --   Los resgistros coincidentes los considera como ANTIGUOS (A)
  --
  -- pv_tipo_consulta:
  --          '1' : Compara segundo nombre
  --          '0' : No Compara segundo nombre

 SP_POST_ALTAS_ASIG_CODSBS_DEU ( pv_ano_refer, pv_mes_refer, pv_cod_reporte, pv_cod_empresa, pv_usuario, pv_tipo_consulta, 'A', pv_dia_refer, pv_cod_sec_envio );
 IF PRN_RETURN  <> 1 THEN
    RETURN;
 END IF;
   -----------------------------         -----------------------------
   -- Los rsgistros son trasladados de un ESTADO a otro, en general el traslado es:
   -- DUDAS (D)       ----> No codificables (X)
   -- APROXIMADOS (B) ----> No codificables (X)
   ---------------
   --- CAMBIO DE ESTADO A PARTIR DEL 2005 - 04 - 15
   -- DUDAS (D)       ----> Antiguos (A)
   -- APROXIMADOS (B) ----> Antiguos (A)

   -- pv_tipo_consulta:
   --          '1' : Compara segundo nombre
   --          '0' : No Compara segundo nombre
   -- DUDAS (D)       ----> No codificables (X)
   -- A PARTIR DEL 2005 - 04 - 15
   -- DUDAS (D)       ----> Antiguos (A)

 SP_POST_ALTAS_CAMBIO_ESTADO ( pv_ano_refer, pv_mes_refer, pv_cod_reporte, pv_cod_empresa, pv_usuario, pv_tipo_consulta, 'D', 'A', pv_dia_refer, pv_cod_sec_envio );
 IF  PRN_RETURN <> 1 THEN
     RETURN;
 END IF;

 -- APROXIMADOS (B) ----> No codificables (X)
 -- A PARTIR DEL 2005 - 04 - 15
 -- APROXIMADOS (B) ----> Antiguos (A)

 SP_POST_ALTAS_CAMBIO_ESTADO ( pv_ano_refer, pv_mes_refer, pv_cod_reporte, pv_cod_empresa, pv_usuario, pv_tipo_consulta, 'B', 'A', pv_dia_refer, pv_cod_sec_envio );

EXCEPTION
  WHEN OTHERS THEN
    PRV_ERROR   := SQLERRM;
    PRV_MENSAJE := substr(PRV_ERROR,1,255) ||' -- SP_POST_ALTAS_PROCESA_ASIG';
    PRN_RETURN  := -5;
    RETURN ;

END SP_POST_ALTAS_PROCESA_ASIG;

-- Procedimiento para Actualizar la asignacion de cod_sbs. Esto se ejecutara despues de todo el proceso de altas
PROCEDURE SP_POST_ALTAS_ASIG_CODSBS_DEU
        (pv_ano_refer     cra_valid_asig_codsbs.ano_refer%type,
         pv_mes_refer     cra_valid_asig_codsbs.mes_refer%type,
         pv_cod_reporte   cra_valid_asig_codsbs.cod_reporte%type,
         pv_cod_empresa   cra_valid_asig_codsbs.cod_empresa%type,
         pv_usuario       cra_valid_asig_codsbs.cod_usu_apr%type,
         pv_tipo_consulta VARCHAR2,
         pv_estado_asig   VARCHAR2,
         pv_dia_refer     IN cra_valid_asig_codsbs.dia_refer%type default '01',
         pv_cod_sec_envio IN cra_valid_asig_codsbs.cod_sec_envio%type default '01'
         )
IS
---------------------
--       Autor                     Fecha         Software
--       Francisco Vite Shelton    15/03/2005    Oracle 8i
---------------------
--       Parametros
--           pv_ano_refer   :  Año de referencia.
--           pv_mes_refer   :  Mes de referencia.
--           pv_cod_reporte :  Codigo reporte a cargar (RCD/RTC)
--           pv_cod_empresa :  Codigo de la Entidad.
--           pv_usuario     : Usuario que ejecuta el proceso.
--
--           pv_tipo_consulta: Identifica el tipo de consulta a realizar
--                       '1' : Consulta considera el Segundo Nombre
--                       '0' : Consulta no considera el Segundo Nombre
--
--           pv_estado_asig  : Identifica el estado hacia el cual se desea
--                             llevar los registros a procesar por defaul.
---------------------
--       Descripcion
--         Procedimiento para Actualizas la asignacion de cod_sbs. Esto se ejecutara despues de realizar las asignaciones de los codigos SBS.
--         Este proceso tomo en consideracion todos los deudores reportados como nuevos por las entidades en un periodo determinado.
--
--         Las busquedas realizadas considera los siguientes criterios:
--        (I)  Busqueda por todos los campos de Identificacion
--                ape_paterno
--                ape_materno
--                nom_persona
--                segundo_nombre
--                tip_doc_iden
--                num_doc_iden
---------------------
-- Ejecucion
--  PK_XCRI_ALTAS_VAL_ASIG_CODSBS.SP_POST_ALTAS_ASIG_CODSBS ('2005','02','RCD','00102','FVITES','1','A');
--  PK_XCRI_ALTAS_VAL_ASIG_CODSBS.SP_POST_ALTAS_ASIG_CODSBS ('2005','02','RCD','00102','FVITES','0','X');
---------------------
BEGIN
   IF pv_cod_reporte = 'RCD' THEN
      SP_POST_ALTAS_ASIG_CODSBS_RCD ( pv_ano_refer, pv_mes_refer, pv_cod_reporte, pv_cod_empresa, pv_usuario,
                                      pv_tipo_consulta, pv_estado_asig );
   ELSE
      SP_POST_ALTAS_ASIG_CODSBS_RCA ( pv_ano_refer, pv_mes_refer, pv_cod_reporte, pv_cod_empresa, pv_usuario,
                                      pv_tipo_consulta, pv_estado_asig, pv_dia_refer, pv_cod_sec_envio );
   END IF;

EXCEPTION
  WHEN OTHERS THEN
    PRV_ERROR   := SQLERRM;
    PRV_MENSAJE := substr(PRV_ERROR,1,255) || ' -- SP_POST_ALTAS_ASIG_CODSBS';
    PRN_RETURN  := -5;
    RETURN ;

END SP_POST_ALTAS_ASIG_CODSBS_DEU;

----------------------------------------------------------

-- Procedimiento para Actualizar la asignacion de cod_sbs
-- esto se ejecutara despues de todo el proceso de altas
PROCEDURE SP_POST_ALTAS_ASIG_CODSBS_RCD
        (pv_ano_refer     cra_valid_asig_codsbs.ano_refer%type,
         pv_mes_refer     cra_valid_asig_codsbs.mes_refer%type,
         pv_cod_reporte   cra_valid_asig_codsbs.cod_reporte%type,
         pv_cod_empresa   cra_valid_asig_codsbs.cod_empresa%type,
         pv_usuario       cra_valid_asig_codsbs.cod_usu_apr%type,
         pv_tipo_consulta VARCHAR2,
         pv_estado_asig   VARCHAR2
         )
IS
---------------------
--       Autor                     Fecha         Software
--       Francisco Vite Shelton    15/03/2005    Oracle 8i
---------------------
--       Parametros
--           pv_ano_refer   :  Año de referencia.
--           pv_mes_refer   :  Mes de referencia.
--           pv_cod_reporte :  Codigo reporte a cargar (RCD/RTC)
--           pv_cod_empresa :  Codigo de la Entidad.
--           pv_usuario     : Usuario que ejecuta el proceso.
--
--           pv_tipo_consulta: Identifica el tipo de consulta a realizar
--                       '1' : Consulta considera el Segundo Nombre
--                       '0' : Consulta no considera el Segundo Nombre
--
--           pv_estado_asig  : Identifica el estado hacia el cual se desea
--                             llevar los registros a procesar por defaul.
---------------------
--       Descripcion
--         Procedimiento para Actualizas la asignacion de cod_sbs. Esto se ejecutara despues de realizar las asignaciones de los codigos SBS.
--         Este proceso tomo en consideracion todos los deudores reportados como nuevos por las entidades en un periodo determinado.
--
--         Las busquedas realizadas considera los siguientes criterios:
--        (I)  Busqueda por todos los campos de Identificacion
--                ape_paterno
--                ape_materno
--                nom_persona
--                segundo_nombre
--                tip_doc_iden
--                num_doc_iden
---------------------
-- Ejecucion
--  PK_XCRI_ALTAS_VAL_ASIG_CODSBS.SP_POST_ALTAS_ASIG_CODSBS ('2005','02','RCD','00102','FVITES','1','A');
--  PK_XCRI_ALTAS_VAL_ASIG_CODSBS.SP_POST_ALTAS_ASIG_CODSBS ('2005','02','RCD','00102','FVITES','0','X');
---------------------

lv_tipo_reporte      varchar2(3);
lv_ano_refer         varchar2(4);
lv_mes_refer         varchar2(2);
lv_cod_ent_vig       varchar2(5);
lv_estado_asig       varchar2(1);
lv_tipo_consulta     VARCHAR2(1);

-- LISTA DE DEUDORES EN LA TABLA TEMPORAL DE ASIGNACION DE CODIGOS SBS
-- COMPARA LOS NOMBRES CON EL MAESTRO DE PERSONAS NATURALES
CURSOR cur_coinc_nom IS
SELECT h.num_sec_reg
      ,n.cod_sbs
  FROM  cri_persona_nat n
      , cri_persona p
     ,(  select r.cod_sbs
               ,r.num_sec_reg
               ,r.nom_sigla
               ,trim(r.nom_cliente)    as nom_cliente
               ,trim(r.ape_materno)    as ape_materno
               ,trim(r.ape_casada)     as ape_casada
               ,trim(r.primer_nombre)  as primer_nombre
               ,trim(r.segundo_nombre) as segundo_nombre
               ,r.tip_doc_iden
               ,r.num_doc_iden
           from cra_valid_identif_rcd r
               ,cra_valid_asig_codsbs a
          where r.ano_refer       = lv_ano_refer
            and r.mes_refer       = lv_mes_refer
            and r.cod_empresa     = lv_cod_ent_vig
            and r.tip_formulario  = '1'
            and r.tip_informacion = '1'
            and a.COD_REPORTE     = lv_tipo_reporte
            and a.COD_EMPRESA     = lv_cod_ent_vig
            and a.ano_refer       = lv_ano_refer
            and a.mes_refer       = lv_mes_refer
            and r.cod_sbs         = 0
--            and a.cod_est_asig    = lv_estado_asig_cons
            and r.num_sec_reg     = a.num_sec_reg
            and r.tip_persona = '1'
           ) h
  WHERE trim(n.ape_paterno )    = h.nom_cliente
    AND trim(n.ape_materno )    = h.ape_materno
    AND trim(n.nom_persona )    = h.primer_nombre
--    AND trim(n.segundo_nombre)  = h.segundo_nombre
    AND decode(lv_tipo_consulta,'0','0','1',n.segundo_nombre,'X') = decode(lv_tipo_consulta,'0','0','1',h.segundo_nombre,'Y' )
    AND not(n.segundo_nombre like '%Y/O%' ) AND nvl(p.tip_reg_mv,' ') <> 'X' -- no evaluar los rechazados por RENIEC
    AND n.tip_docto_ident = h.tip_doc_iden
    AND n.num_docto_ident = h.num_doc_iden
    AND p.cod_sbs         = n.cod_sbs
    AND nvl(p.tip_condicion,'NULL') <> 'RPZDO'
 ORDER BY   h.num_sec_reg asc
          , n.cod_sbs asc ;

 -- lv_tipo_consulta : '0' No considera el segundo nombre
 --                    '1' Considera el segundo nombre
 ------------------------------------
-- BUSCA QUE EL NUMERO REGISTROS DE COINCIDENCIAS SEA UNO
-- LOS MAYORES A UNO NO SE ACTUALIZARAN
/*
CURSOR cur_count_reg IS
SELECT COUNT(*) num_reg
  FROM cri_persona_nat n
     , cri_persona p
     , ( select r.cod_sbs
               ,r.num_sec_reg
               ,r.nom_sigla
               ,trim(r.nom_cliente)    as nom_cliente
               ,trim(r.ape_materno)    as ape_materno
               ,trim(r.ape_casada)     as ape_casada
               ,trim(r.primer_nombre)  as primer_nombre
               ,trim(r.segundo_nombre) as segundo_nombre
               ,r.tip_doc_iden
           from cra_valid_identif_rcd r
               ,cra_valid_asig_codsbs a
          where r.ano_refer       = lv_ano_refer
            and r.mes_refer       = lv_mes_refer
            and r.cod_empresa     = lv_cod_ent_vig
            and r.tip_formulario  = '1'
            and r.tip_informacion = '1'
            and a.COD_REPORTE     = lv_tipo_reporte
            and a.COD_EMPRESA     = lv_cod_ent_vig
            and a.ano_refer       = lv_ano_refer
            and a.mes_refer       = lv_mes_refer
            and r.cod_sbs         = 0
--            and a.cod_est_asig    = lv_estado_asig_cons
            and r.num_sec_reg     = a.num_sec_reg
            and r.tip_persona = '1'
         ) h
 WHERE trim(n.ape_paterno)     = h.nom_cliente
   AND trim(n.ape_materno)     = h.ape_materno
   AND trim(n.nom_persona)     = h.primer_nombre
--   AND trim(n.segundo_nombre)  = h.segundo_nombre
   AND decode(lv_tipo_consulta,'0','0','1',n.segundo_nombre,'X') = decode(lv_tipo_consulta,'0','0','1',h.segundo_nombre,'Y' )
   AND not(n.segundo_nombre like '%Y/O%' )
   AND h.num_sec_reg     = ln_num_sec_reg
   AND n.tip_docto_ident = h.tip_doc_iden
   AND p.cod_sbs         = n.cod_sbs
   AND nvl(p.tip_condicion,'NULL') <> 'RPZDO' ;
*/
ln_count  NUMBER(6);
ln_return NUMBER(2);

BEGIN
   lv_tipo_reporte  := pv_cod_reporte;
   lv_tipo_consulta := pv_tipo_consulta;
   lv_ano_refer    := pv_ano_refer;
   lv_mes_refer    := pv_mes_refer;
   lv_cod_ent_vig  := pv_cod_empresa;
   ln_return       := 1;
   ln_count        := 0;

   -- De Cualquier estado pasara hacia antiguo
   --lv_estado_asig_cons := 'D';
--   lv_estado_asig  := 'A';
   lv_estado_asig   := pv_estado_asig;

   FOR cur_nom in cur_coinc_nom LOOP
       ln_count := ln_count + 1;
       BEGIN
          -- ln_count := ln_count + 1;
           IF ln_count > 0 THEN
              UPDATE cra_valid_asig_codsbs a
                 SET a.cod_est_asig      = lv_estado_asig
                   , a.cod_sbs_a_asignar = cur_nom.cod_sbs
                   , a.cod_sbs_coinc_ide = cur_nom.cod_sbs
               WHERE a.ano_refer    = lv_ano_refer
                 AND a.mes_refer    = lv_mes_refer
                 AND a.cod_reporte  = lv_tipo_reporte
                 AND a.cod_empresa  = lv_cod_ent_vig
                 AND a.num_sec_reg  = cur_nom.num_sec_reg
--                 AND a.cod_est_asig = lv_estado_asig_cons
                 ;
           END IF;

       EXCEPTION
        WHEN OTHERS THEN
          ln_return := -1;
       END ;
   END LOOP ;

   COMMIT;
   PRN_RETURN  := 1;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    PRV_ERROR   := SQLERRM;
    PRV_MENSAJE := substr(PRV_ERROR,1,255) || ' -- SP_POST_ALTAS_ASIG_CODSBS_RCD';
    PRN_RETURN  := -5;
    RETURN ;

END SP_POST_ALTAS_ASIG_CODSBS_RCD;

-- Procedimiento para Actualizar la asignacion de cod_sbs. Esto se ejecutara despues de todo el proceso de altas
PROCEDURE SP_POST_ALTAS_ASIG_CODSBS_RCA
        (pv_ano_refer     cra_valid_asig_codsbs.ano_refer%type,
         pv_mes_refer     cra_valid_asig_codsbs.mes_refer%type,
         pv_cod_reporte   cra_valid_asig_codsbs.cod_reporte%type,
         pv_cod_empresa   cra_valid_asig_codsbs.cod_empresa%type,
         pv_usuario       cra_valid_asig_codsbs.cod_usu_apr%type,
         pv_tipo_consulta VARCHAR2,
         pv_estado_asig   VARCHAR2,
         pv_dia_refer     IN cra_valid_asig_codsbs.dia_refer%type default '01',
         pv_cod_sec_envio IN cra_valid_asig_codsbs.cod_sec_envio%type default '01'
         )
IS
---------------------
--       Autor                     Fecha         Software
--       Francisco Vite Shelton    15/03/2005    Oracle 8i
---------------------
--       Parametros
--           pv_ano_refer   :  Año de referencia.
--           pv_mes_refer   :  Mes de referencia.
--           pv_cod_reporte :  Codigo reporte a cargar (RCD/RTC)
--           pv_cod_empresa :  Codigo de la Entidad.
--           pv_usuario     : Usuario que ejecuta el proceso.
--
--           pv_tipo_consulta: Identifica el tipo de consulta a realizar
--                       '1' : Consulta considera el Segundo Nombre
--                       '0' : Consulta no considera el Segundo Nombre
--
--           pv_estado_asig  : Identifica el estado hacia el cual se desea llevar los registros a procesar por defaul.
---------------------
--       Descripcion
--         Procedimiento para Actualizas la asignacion de cod_sbs
--         esto se ejecutara despues de realizar las asignaciones de los codigos SBS.
--         Este proceso tomo en consideracion todos los deudores reportados como nuevos por las entidades en un periodo determinado.
--
--         Las busquedas realizadas considera los siguientes criterios:
--        (I)  Busqueda por todos los campos de Identificacion
--                ape_paterno
--                ape_materno
--                nom_persona
--                segundo_nombre
--                tip_doc_iden
--                num_doc_iden
---------------------
-- Ejecucion
--  PK_XCRI_ALTAS_VAL_ASIG_CODSBS.SP_POST_ALTAS_ASIG_CODSBS ('2005','02','RCD','00102','FVITES','1','A');
--  PK_XCRI_ALTAS_VAL_ASIG_CODSBS.SP_POST_ALTAS_ASIG_CODSBS ('2005','02','RCD','00102','FVITES','0','X');
---------------------

lv_tipo_reporte      varchar2(3);
lv_ano_refer         varchar2(4);
lv_mes_refer         varchar2(2);
lv_cod_ent_vig       varchar2(5);
lv_estado_asig       varchar2(1);
lv_tipo_consulta     VARCHAR2(1);

-- LISTA DE DEUDORES EN LA TABLA TEMPORAL DE ASIGNACION DE CODIGOS SBS. COMPARA LOS NOMBRES CON EL MAESTRO DE PERSONAS NATURALES
CURSOR cur_coinc_nom IS
SELECT h.num_sec_reg, n.cod_sbs
  FROM cri_persona_nat n, cri_persona p
     ,( select r.cod_sbs
               ,r.num_sec_reg
               ,r.nom_sigla
               ,trim(r.nom_cliente)    as nom_cliente
               ,trim(r.ape_materno)    as ape_materno
               ,trim(r.ape_casada)     as ape_casada
               ,trim(r.primer_nombre)  as primer_nombre
               ,trim(r.segundo_nombre) as segundo_nombre
               ,r.tip_doc_iden
               ,r.num_doc_iden
           from cra_valid_identif r, cra_valid_asig_codsbs a
          where r.cod_reporte     = lv_tipo_reporte
            and r.ano_refer       = lv_ano_refer
            and r.mes_refer       = lv_mes_refer
            and r.cod_empresa     = lv_cod_ent_vig
            and r.tip_formulario  = '1'
            and r.tip_informacion = '1'
            and a.COD_REPORTE     = lv_tipo_reporte
            and a.COD_EMPRESA     = lv_cod_ent_vig
            and a.ano_refer       = lv_ano_refer
            and a.mes_refer       = lv_mes_refer
            and r.cod_sbs         = 0
--            and a.cod_est_asig  = lv_estado_asig_cons
            and r.num_sec_reg     = a.num_sec_reg
            and r.tip_persona     = '1'
            and r.dia_refer       = pv_dia_refer
            and r.cod_sec_envio   = pv_cod_sec_envio
           ) h
  WHERE trim(n.ape_paterno )    = h.nom_cliente
    AND trim(n.ape_materno )    = h.ape_materno
    AND trim(n.nom_persona )    = h.primer_nombre
--    AND trim(n.segundo_nombre)  = h.segundo_nombre
    AND decode(lv_tipo_consulta,'0','0','1',n.segundo_nombre,'X') = decode(lv_tipo_consulta,'0','0','1',h.segundo_nombre,'Y' )
    AND not(n.segundo_nombre like '%Y/O%' )
    AND n.tip_docto_ident = h.tip_doc_iden
    AND n.num_docto_ident = h.num_doc_iden
    AND p.cod_sbs         = n.cod_sbs
    AND nvl(p.tip_condicion,'NULL') <> 'RPZDO'
  ORDER BY h.num_sec_reg asc, n.cod_sbs asc ;

ln_count  NUMBER(6);
ln_return NUMBER(2);

BEGIN
   lv_tipo_reporte  := pv_cod_reporte;
   lv_tipo_consulta := pv_tipo_consulta;
   lv_ano_refer    := pv_ano_refer;
   lv_mes_refer    := pv_mes_refer;
   lv_cod_ent_vig  := pv_cod_empresa;
   ln_return       := 1;
   ln_count        := 0;

   -- De Cualquier estado pasara hacia antiguo
   --lv_estado_asig_cons := 'D';
--   lv_estado_asig  := 'A';
   lv_estado_asig   := pv_estado_asig;

   FOR cur_nom in cur_coinc_nom LOOP
       ln_count := ln_count + 1;
       BEGIN
           IF ln_count > 0 THEN
              UPDATE cra_valid_asig_codsbs a
                 SET a.cod_est_asig      = lv_estado_asig
                   , a.cod_sbs_a_asignar = cur_nom.cod_sbs
                   , a.cod_sbs_coinc_ide = cur_nom.cod_sbs
               WHERE a.ano_refer    = lv_ano_refer
                 AND a.mes_refer    = lv_mes_refer
                 AND a.cod_reporte  = lv_tipo_reporte
                 AND a.cod_empresa  = lv_cod_ent_vig
                 AND a.num_sec_reg  = cur_nom.num_sec_reg
--                 AND a.cod_est_asig = lv_estado_asig_cons
                 AND a.dia_refer       = pv_dia_refer
                 AND a.cod_sec_envio   = pv_cod_sec_envio ;
           END IF;

       EXCEPTION
         WHEN OTHERS THEN
           ln_return := -1;
       END ;
   END LOOP ;

   COMMIT;
   PRN_RETURN  := 1;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    PRV_ERROR   := SQLERRM;
    PRV_MENSAJE := substr(PRV_ERROR,1,255) || ' -- SP_POST_ALTAS_ASIG_CODSBS_RCA';
    PRN_RETURN  := -5;
    RETURN ;

END SP_POST_ALTAS_ASIG_CODSBS_RCA;

----------------------------------------------------------

   -- Procedimiento para Actualizar la asignacion de cod_sbs de un estado hacia otro determinado por el usuario
   -- realiza una busqueda por el registro completo del deudor si asi se requiere.
   -- Se ejecutara despues de todo el proceso de altas.
PROCEDURE SP_POST_ALTAS_CAMBIO_ESTADO
        (pv_ano_refer         cra_valid_asig_codsbs.ano_refer%type,
         pv_mes_refer         cra_valid_asig_codsbs.mes_refer%type,
         pv_cod_reporte       cra_valid_asig_codsbs.cod_reporte%type,
         pv_cod_empresa       cra_valid_asig_codsbs.cod_empresa%type,
         pv_usuario           cra_valid_asig_codsbs.cod_usu_apr%type,
         pv_tipo_consulta     VARCHAR2,
         pv_estado_asig_base  VARCHAR2,
         pv_estado_asig_hacia VARCHAR2,
         pv_dia_refer         IN cra_valid_asig_codsbs.dia_refer%type default '01',
         pv_cod_sec_envio     IN cra_valid_asig_codsbs.cod_sec_envio%type default '01'
         )
IS
---------------------
--       Autor                     Fecha         Software
--       Francisco Vite Shelton    15/03/2005    Oracle 8i
---------------------
--       Parametros
--           pv_ano_refer   :  Año de referencia.
--           pv_mes_refer   :  Mes de referencia.
--           pv_cod_reporte :  Codigo reporte a cargar (RCD/RTC)
--           pv_cod_empresa :  Codigo de la Entidad.
--           pv_usuario     : Usuario que ejecuta el proceso.
--
--           pv_tipo_consulta: Identifica el tipo de consulta a realizar
--                       '1' : Consulta considera el Segundo Nombre
--                       '0' : Consulta no considera el Segundo Nombre
--
--           pv_estado_asig_base  : Identifica el estado base desde el cual se desea llevar los registros a procesar.
--           pv_estado_asig_hacia : Identifica el estado hacia donde se desea llevar los registros a procesar.
---------------------
--       Descripcion
--         Procedimiento para Actualizas la asignacion de cod_sbs. Esto se ejecutara despues de realizar las asignaciones de los codigos SBS.
--         Este proceso tomo en consideracion todos los deudores reportados como nuevos por las entidades en un periodo determinado.
--
--         Las busquedas realizadas considera los siguientes criterios:
--        (I)  Busqueda por todos los campos de Identificacion
--                ape_paterno, ape_materno, nom_persona, segundo_nombre, tip_doc_iden, num_doc_iden
---------------------
-- Ejecucion
--  PK_XCRI_ALTAS_VAL_ASIG_CODSBS.SP_POST_ALTAS_CAMBIO_ESTADO ('2005','02','RCD','00102','FVITES','1','A','X');
--  PK_XCRI_ALTAS_VAL_ASIG_CODSBS.SP_POST_ALTAS_CAMBIO_ESTADO ('2005','02','RCD','00102','FVITES','0','X','B');
---------------------
-- BUSQUEDA DE COINCIDENCIAS DE DEUDORES CATALOGADOS COMO DUDAS
-- LOS PATRONES USADOS SON: Tipo persona, Tipo Documento Identidad, Numero Documento Identidad
----------
-- en esta primera etapa se consideran persona naturales
-------------
ln_count           number;
ls_estado_nuevo    varchar2(1);
ln_num_secuencia   number(10);
ln_cod_sbs_asignar number(10);
lv_estado_base     Varchar2(1);
lv_cod_ent_vig     Varchar2(5);
lv_ano_refer       Varchar2(4);
lv_mes_refer       Varchar2(2);
lv_tipo_reporte    Varchar2(3);
ln_nombre_actual   varchar2(520);
ln_nombre_anterior varchar2(520);
ln_num_reg         number(3);
lv_tipo_persona    VARCHAR2(1);

----------------------------------------------------------------------------
-- Obtiene Datos del deudor para comparar los nombres y asignar el codigo sbs.
-- Esta validadcion se obtiene para los deudores que tengan 2 incidencias.
-- Los parametros de Busqueda y coincidencia son:
--     * Tipo de Documento
--     * Numero de Documento (excluye los ceros a la izquierda)
--     * Tipo de persona ('1')
--     * Excluye deudores que presenten en la glosa "Y/O"
--     * Coincide cod_sbs por DNI(encontrado maestro) y cod_sbs cero (nuevos)
----------------------------------------------------------------------------

CURSOR cur_actualiza_asig is
SELECT  f.num_sec_reg
      , f.cod_sbs
      , f.desc_persona
      , f.tip_doc_iden
      , f.num_doc_iden
      , f.tip_doc_trib
      , f.num_doc_trib
      , f.cod_unico_clie
      , f.cod_sbs_coinc_ide
      , f.cod_sbs_coinc_ruc
      , f.cod_sbs_coinc_uni
      , f.tip_persona
      ,f.secuencia_enlace
      ,f.proc_desc_1
      ,a.nom_ape_paterno
      ,f.proc_desc_2
      ,a.nom_ape_materno
      ,f.proc_desc_3
      ,a.nom_nombres
      ,nvl(f.proc_desc_4,' ')  as proc_desc_4
      ,nvl(a.nom_segundo_nombre,' ')  as nom_segundo_nombre
 FROM cra_valid_asig_codsbs a, XCRI_ALTAS_VAL_ASIG_CODSBS_FV f
WHERE a.ano_refer        = lv_ano_refer
  AND a.mes_refer        = lv_mes_refer
  AND a.cod_reporte      = lv_tipo_reporte
  AND a.cod_empresa      = lv_cod_ent_vig
  AND a.cod_est_asig     = lv_estado_base
  AND a.dia_refer        = pv_dia_refer
  AND a.cod_sec_envio    = pv_cod_sec_envio
  AND f.ano_refer        = a.ano_refer
  AND f.mes_refer        = a.mes_refer
  AND f.cod_reporte      = a.cod_reporte
  AND f.cod_empresa      = a.cod_empresa
  AND f.secuencia_enlace = a.num_sec_reg
  AND f.tip_doc_iden     = a.tip_doc_iden
--  AND f.num_doc_iden     = a.num_doc_iden
  AND decode(nvl(test_number(f.num_doc_iden),-1), -1, f.num_doc_iden, test_number(f.num_doc_iden)) =
      decode(nvl(test_number(a.num_doc_iden),-1), -1, a.num_doc_iden, test_number(a.num_doc_iden))
  AND f.tip_persona      = a.tip_persona
  AND f.tip_persona      = lv_tipo_persona
  AND f.dia_refer        = a.dia_refer
  AND f.cod_sec_envio    = a.cod_sec_envio
  and not(f.desc_persona like '%Y/O%' )
--  AND a.cod_sbs_coinc_ide = a.cod_sbs_a_asignar
--  AND a.cod_sbs_a_asignar  = 0
  AND f.secuencia_enlace = ln_num_secuencia
  AND ( f.cod_sbs = f.cod_sbs_coinc_ide OR f.cod_sbs = 0 )
ORDER BY f.cod_sbs ASC ;

------------------------------------------------------------------------------
-- CURSOR PARA CONOCER EL NUMERO DE REGISTROS QUE COINCIDEN
-- SI SON MAS DE DOS ENTONCES INGRESA A OBSERVACION.
cursor cur_num_reg is
select f.secuencia_enlace, count(1) AS num_registros
 from cra_valid_asig_codsbs a, XCRI_ALTAS_VAL_ASIG_CODSBS_FV f
where a.ano_refer        = lv_ano_refer
  and a.mes_refer        = lv_mes_refer
  and a.cod_reporte      = lv_tipo_reporte
  and a.cod_empresa      = lv_cod_ent_vig
  and a.cod_est_asig     = lv_estado_base
  AND a.dia_refer        = pv_dia_refer
  AND a.cod_sec_envio    = pv_cod_sec_envio
  and f.ano_refer        = a.ano_refer
  and f.mes_refer        = a.mes_refer
  and f.cod_reporte      = a.cod_reporte
  and f.cod_empresa      = a.cod_empresa
  and f.secuencia_enlace = a.num_sec_reg
  and f.tip_doc_iden     = a.tip_doc_iden
  and f.dia_refer        = a.dia_refer
  and f.cod_sec_envio    = a.cod_sec_envio
--  and f.num_doc_iden     = a.num_doc_iden
  and decode(nvl(test_number(f.num_doc_iden),-1), -1, f.num_doc_iden, test_number(f.num_doc_iden)) =
      decode(nvl(test_number(a.num_doc_iden),-1), -1, a.num_doc_iden, test_number(a.num_doc_iden))
  and f.tip_persona      = a.tip_persona
  and f.tip_persona      = lv_tipo_persona
  and not(f.desc_persona like '%Y/O%' )
  AND (f.cod_sbs = f.cod_sbs_coinc_ide OR f.cod_sbs = 0 )
group by f.secuencia_enlace
having count(*) = 2
order by f.secuencia_enlace asc;

BEGIN
  lv_tipo_persona := '1';
  ln_count := 0;
  lv_cod_ent_vig  := pv_cod_empresa;
  lv_ano_refer    := pv_ano_refer;
  lv_mes_refer    := pv_mes_refer;
  lv_tipo_reporte := pv_cod_reporte;
  lv_estado_base  := pv_estado_asig_base;

  IF pv_tipo_consulta not in ('0','1') THEN
     PRV_MENSAJE := 'Tipo de consulta es invalida, no es 0 ni 1 ' || ' -- SP_POST_ALTAS_CAMBIO_ESTADO';
     PRN_RETURN  := -5;
     RETURN;
  END IF;

  FOR cur_count in cur_num_reg LOOP
      ln_count := cur_count.num_registros;
      ln_num_secuencia := cur_count.secuencia_enlace;
      ln_cod_sbs_asignar := 0;
      lv_estado_base     := pv_estado_asig_base;

     IF ln_count = 2 THEN
        ln_num_reg := 0 ;
        -------------------------------
        FOR cur_act in cur_actualiza_asig LOOP
           ln_cod_sbs_asignar := cur_act.cod_sbs_coinc_ide;
           ln_num_reg := ln_num_reg + 1 ;

           IF ln_num_reg = 1 THEN
              ln_nombre_actual   := trim(cur_act.proc_desc_1) || ' ' || trim(cur_act.proc_desc_2) || ' ' || trim(cur_act.proc_desc_3);
              -- validar si desea considerar el segundo nombre
              IF pv_tipo_consulta = '1' THEN
                 ln_nombre_actual   := ln_nombre_actual || ' ' || trim(cur_act.proc_desc_4);
              END IF;
           ELSE
              ln_nombre_anterior   := trim(cur_act.proc_desc_1) || ' ' || trim(cur_act.proc_desc_2) || ' ' || trim(cur_act.proc_desc_3);
              -- validar si desea considerar el segundo nombre
              IF pv_tipo_consulta = '1' THEN
                 ln_nombre_anterior   := ln_nombre_anterior || ' ' || trim(cur_act.proc_desc_4);
               END IF;
           END IF;
        END LOOP;
        -----------------------------------
        -- apellido paterno es diferente
        IF ln_nombre_actual = ln_nombre_anterior THEN
           ls_estado_nuevo := pv_estado_asig_hacia;
        ELSE
           ln_cod_sbs_asignar := 0;
        END IF;
     END IF;

     IF ln_cod_sbs_asignar > 0 THEN
        UPDATE cra_valid_asig_codsbs a
           SET a.cod_sbs_a_asignar = ln_cod_sbs_asignar, a.cod_est_asig = ls_estado_nuevo
         WHERE a.ano_refer    = lv_ano_refer
           AND a.mes_refer    = lv_mes_refer
           AND a.cod_reporte  = lv_tipo_reporte
           AND a.cod_empresa  = lv_cod_ent_vig
           AND a.num_sec_reg  = ln_num_secuencia
           AND a.cod_est_asig = lv_estado_base
           AND a.dia_refer     = pv_dia_refer
           AND a.cod_sec_envio = pv_cod_sec_envio ;
     END IF;
 END LOOP;

 commit;
 PRN_RETURN  := 1;

EXCEPTION
  WHEN OTHERS THEN
    Rollback;
    PRV_ERROR   := SQLERRM;
    PRV_MENSAJE := substr(PRV_ERROR,1,255) || ' -- SP_POST_ALTAS_CAMBIO_ESTADO';
    PRN_RETURN  := -5;
    RETURN ;

END SP_POST_ALTAS_CAMBIO_ESTADO;

----------------------------------------------------------

PROCEDURE SP_POST_ALTAS_CAMBIO_ESTADO_NV
        (pv_ano_refer     cra_valid_asig_codsbs.ano_refer%type,
         pv_mes_refer     cra_valid_asig_codsbs.mes_refer%type,
         pv_cod_reporte   cra_valid_asig_codsbs.cod_reporte%type,
         pv_cod_empresa   cra_valid_asig_codsbs.cod_empresa%type,
         pv_usuario       cra_valid_asig_codsbs.cod_usu_apr%type,
         pv_dia_refer     IN cra_valid_asig_codsbs.dia_refer%type default '01',
         pv_cod_sec_envio IN cra_valid_asig_codsbs.cod_sec_envio%type default '01'
         )
IS
---------------------
--       Autor                     Fecha         Software
--       Francisco Vite Shelton    06/06/2005    Oracle 8i
---------------------
--       Parametros
--           pv_ano_refer   :  Año de referencia.
--           pv_mes_refer   :  Mes de referencia.
--           pv_cod_reporte :  Codigo reporte a cargar (RCD/RTC)
--           pv_cod_empresa :  Codigo de la Entidad.
--           pv_usuario     : Usuario que ejecuta el proceso.
--
---------------------
--       Descripcion
--         Se ejecutara despues de todo el proceso de pre-altas.
--
--         Procedimiento para Actualizar el estado de los deudores clasificados como Nuevos pero que su tipo y numero de documento
--         ya se encuentran en el maestro SBS.
--         Al identificar a estos deudores cambia el estado de Nuevos(N) hacia Dudas (D) para ser analizados por DERC.
--
--         Este proceso tambien se encuentra en el proceso final de altas
--         en el procedimiento PK_VALIDADOR.SP_INGRESA_CODSBS_NUEVO_RCD, en el cual dichos deudores se observan para no ser consolidados.
--
--         Las busquedas realizadas considera los siguientes criterios:
--        (I)  Busqueda por todos los campos de Identificacion
--                tip_doc_iden
--                num_doc_iden
---------------------
-- Ejecucion
--  PK_XCRI_ALTAS_VAL_ASIG_CODSBS.SP_POST_ALTAS_CAMBIO_ESTADO_NUEVOS ('2005','05','RCD','00102','FVITES');
---------------------
lv_cod_ent_vig     Varchar2(5);
lv_ano_refer       Varchar2(4);
lv_mes_refer       Varchar2(2);
lv_tipo_reporte    Varchar2(3);
lv_tipo_persona    VARCHAR2(1);

-------------------    -------------------
-- PROCESO SOLO PARA PERSONAS NATURALES
--  F.V.SH    2005-06-06
-------------------    -------------------
-- Obtiene clientes clasificados como nuevos pero el documento de identidad ya esta en el maestro
CURSOR cur_doc_id_existe IS
  SELECT N.TIP_DOCTO_IDENT as tipo_doc_id
        ,N.NUM_DOCTO_IDENT as num_doc_id
        ,t.num_sec_reg
        ,t.tip_persona
        ,n.cod_sbs as cod_sbs
   FROM cri_persona p, CRI_PERSONA_NAT N
       ,( select a.num_sec_reg, a.tip_doc_iden, a.num_doc_iden, a.tip_persona
            from cra_valid_asig_codsbs a
           where a.ano_refer    = lv_ano_refer
             and a.mes_refer    = lv_mes_refer
             and a.cod_empresa  = lv_cod_ent_vig
             and a.cod_reporte  = lv_tipo_reporte
             and a.cod_est_asig = 'N'
             and a.tip_persona  = lv_tipo_persona
             and a.cod_sbs      = 0
             and a.dia_refer     = pv_dia_refer
             and a.cod_sec_envio = pv_cod_sec_envio
        ) T
WHERE p.cod_sbs = n.cod_sbs AND nvl(p.tip_reg_mv,' ') <> 'X' -- no evaluar los rechazados por RENIEC
  AND NOT (upper(nvl(n.segundo_nombre,' ')) like '%Y/O%')
  AND n.tip_docto_ident = t.tip_doc_iden
  AND n.num_docto_ident = t.num_doc_iden
  AND decode(nvl(test_number(n.num_docto_ident),-1), -1, n.num_docto_ident, test_number(n.num_docto_ident)) =
      decode(nvl(test_number(t.num_doc_iden),-1), -1, t.num_doc_iden, test_number(t.num_doc_iden))
order by t.num_sec_reg asc ;

ln_count_existe_doc_periodo  NUMBER(3);

BEGIN
  lv_tipo_persona := '1';
  lv_cod_ent_vig  := pv_cod_empresa;
  lv_ano_refer    := pv_ano_refer;
  lv_mes_refer    := pv_mes_refer;
  lv_tipo_reporte := pv_cod_reporte;
  ln_count_existe_doc_periodo:= 0;

-- F.V.SH 2005-06-06
-- Los duplicados los coloca en dudas.
   FOR cur_e_id in cur_doc_id_existe LOOP
       -- Valida si el documneto fue generado en este periodo
       -- cod_sbs > 0 y fue clasificado como nuevo
       ln_count_existe_doc_periodo:= -1;

            SELECT count(*)
              INTO ln_count_existe_doc_periodo
              FROM CRA_VALID_ASIG_CODSBS
	           WHERE ano_refer    = lv_ano_refer
	             AND mes_refer    = lv_mes_refer
               and cod_reporte  = lv_tipo_reporte
               and cod_empresa <> lv_cod_ent_vig
               and dia_refer     = pv_dia_refer
               and cod_sec_envio = pv_cod_sec_envio
               AND num_doc_iden = cur_e_id.num_doc_id
               AND num_doc_iden NOT IN ('0','00', '000', '0000', '00000', '000000',
                                       '0000000', '00000000','00000000000')
               AND tip_doc_iden = cur_e_id.tipo_doc_id
               AND tip_persona  = cur_e_id.tip_persona
               AND cod_sbs > 0 ;

       IF ln_count_existe_doc_periodo = 0 THEN
            -- Coloca en Duda los registros por duplicidad de documento de identidad
            UPDATE CRA_VALID_ASIG_CODSBS a
               SET a.cod_est_asig      = 'D'
                  ,a.cod_sbs_coinc_ide = cur_e_id.cod_sbs
                  ,a.cod_sbs_a_asignar = cur_e_id.cod_sbs
	           WHERE a.ano_refer    = lv_ano_refer
	             AND a.mes_refer    = lv_mes_refer
               AND a.cod_reporte  = lv_tipo_reporte
               AND a.cod_empresa  = lv_cod_ent_vig
               AND a.num_sec_reg  = cur_e_id.num_sec_reg
               AND a.dia_refer     = pv_dia_refer
               AND a.cod_sec_envio = pv_cod_sec_envio ;

            COMMIT;
       END IF;
   END LOOP;

  commit;
  PRN_RETURN  := 1;

EXCEPTION
  WHEN OTHERS THEN
    Rollback;
    PRV_ERROR   := SQLERRM;
    PRV_MENSAJE := substr(PRV_ERROR,1,255) || ' -- SP_POST_ALTAS_CAMBIO_ESTADO_NUEVOS';
    PRN_RETURN  := -5;
    RETURN ;

END SP_POST_ALTAS_CAMBIO_ESTADO_NV;

----------------------------------------------------------

PROCEDURE SP_POST_ALTA_GENE_FILE_APX_DUD
        (pv_ano_refer     xcri_altas_val_asig_codsbs_fv.ano_refer%type,
         pv_mes_refer     xcri_altas_val_asig_codsbs_fv.mes_refer%type,
         pv_cod_reporte   xcri_altas_val_asig_codsbs_fv.cod_reporte%type,
         pv_cod_empresa   xcri_altas_val_asig_codsbs_fv.cod_empresa%type,
         pv_usuario       xcri_altas_val_asig_codsbs_fv.cod_usu_proc%type,
         pv_estado        xcri_altas_val_asig_codsbs_fv.cod_est_asig%type,
         pv_dia_refer     IN xcri_altas_val_asig_codsbs_fv.dia_refer%type default '01',
         pv_cod_sec_envio IN xcri_altas_val_asig_codsbs_fv.cod_sec_envio%type default '01'
         )
IS
---------------------
--       Autor                     Fecha         Software
--       Francisco Vite Shelton    14/06/2005    Oracle 8i
---------------------
--       Parametros
--           pv_ano_refer   :  Año de referencia.
--           pv_mes_refer   :  Mes de referencia.
--           pv_cod_reporte :  Codigo reporte a cargar (RCD/RTC)
--           pv_cod_empresa :  Codigo de la Entidad.
--           pv_usuario     : Usuario que ejecuta el proceso.
---------------------
--       Descripcion
--         Genera el archivo de aproximaciones que antes se realizaba en la GTI.
--         Este reporte se obtiene para que el analista DERC desde un archivo excel pueda
--         verificar los nombres de los deudores que se encuentran en estado de Aproximados.
--         Este procedimiento se ejecuta al final del proceso de altas.
---------------------
-- Ejecucion
--  PK_XCRI_ALTAS_VAL_ASIG_CODSBS.SP_POST_ALTAS_GENERA_FILE_APRX ('2005','05','RCD','00105','FVITES');
---------------------

-- Datos de la entidad
CURSOR cur_entidad IS
Select chr(9) || pv_cod_empresa || ' - ' || e.nom_ent_vig_corto
    || chr(9)
    || chr(9) || 'Periodo: ' || pv_ano_refer  || ' - ' || pv_mes_refer
    as entidad
from ays_ent_vigilada e
where e.cod_ent_vig = pv_cod_empresa ;

-- Cabecera del resultado del filtro
CURSOR cur_cabecera IS
Select     '#'
||chr(9)|| 'NUM SEC'
||chr(9)|| 'COD_SBS'
||chr(9)|| 'DESC_PERSONA'
||chr(9)|| 'TIP_VALIDACION'
||chr(9)|| 'TIP DOC IDEN'
||chr(9)|| 'NUM DOC IDEN'
||chr(9)|| 'TIP DOC TRIB'
||chr(9)|| 'NUM DOC TRIB'
||chr(9)|| 'COD UNICO'
||chr(9)|| 'COD_SBS COINC_IDE'
||chr(9)|| 'COD_SBS COINC_RUC'
||chr(9)|| 'COD_SBS COINC_UNI'
||chr(9)|| 'TIP PERSONA'
||chr(9)|| 'COD_SBS ASIGNAR' as cabecera
from dual ;

-- FVSH   20050614
-- Este reporte se obtiene para que el analista DERC desde un archivo excel pueda
-- verificar los nombres de los deudores que se encunetran en estado de Aproximados.
-- Este reporte es una alternativa a la opcion proporcionada por el modulo de la Central de Riesgos.
CURSOR cur_reg_deudores IS
SELECT      rownum
||chr(9)||  t.num_sec_reg
||chr(9)||  t.cod_sbs
||chr(9)||  t.desc_persona
||chr(9)||  t.tip_reg_mv
||chr(9)||  t.tip_doc_iden
||chr(9)||  t.num_doc_iden
||chr(9)||  t.tip_doc_trib
||chr(9)||  t.num_doc_trib
||chr(9)||  t.cod_unico_clie
||chr(9)||  t.cod_sbs_coinc_ide
||chr(9)||  t.cod_sbs_coinc_ruc
||chr(9)||  t.cod_sbs_coinc_uni
||chr(9)||  t.tip_persona
||chr(9)||  t.cod_sbs_a_asignar AS deudor
FROM
     (
     Select f.num_sec_reg
           ,f.cod_sbs
           ,f.desc_persona
           ,SF_OBT_DATOS_CRI_PERSONA(f.cod_sbs, 'TIP_REG_MV' ) as tip_reg_mv
           ,f.tip_doc_iden
           ,f.num_doc_iden
           ,f.tip_doc_trib
           ,f.num_doc_trib
           ,f.cod_unico_clie
           ,f.cod_sbs_coinc_ide
           ,a.cod_sbs_coinc_ruc
           ,f.cod_sbs_coinc_uni
           ,f.tip_persona
           ,a.cod_sbs_a_asignar
           ,f.secuencia_enlace
     from cra_valid_asig_codsbs a, XCRI_ALTAS_VAL_ASIG_CODSBS_FV f
     where a.ano_refer        = pv_ano_refer
       and a.mes_refer        = pv_mes_refer
       and a.cod_reporte      = pv_cod_reporte
       and a.cod_empresa      = pv_cod_empresa
       and a.dia_refer        = pv_dia_refer
       and a.cod_sec_envio    = pv_cod_sec_envio
       and a.cod_est_asig     = PRV_ESTADO_APROXIMADO
       and f.ano_refer        = a.ano_refer
       and f.mes_refer        = a.mes_refer
       and f.cod_reporte      = a.cod_reporte
       and f.cod_empresa      = a.cod_empresa
       and f.dia_refer        = a.dia_refer
       and f.cod_sec_envio    = a.cod_sec_envio
       and f.secuencia_enlace = a.num_sec_reg
     order by f.secuencia_enlace asc
) T
order by t.secuencia_enlace asc ;

-- FVSH   20050812
-- Este reporte se obtiene para que el analista DERC desde un archivo excel pueda
-- verificar los nombres de los deudores que se encunetran en estado de DUDAS.
-- Este reporte es una alternativa a la opcion proporcionada por el modulo de la Central de Riesgos.
CURSOR cur_reg_deudores_dudas IS
SELECT rownum
||chr(9)||  H.num_sec_reg
||chr(9)||  H.cod_sbs
||chr(9)||  H.desc_persona
||chr(9)||  H.tip_reg_mv
||chr(9)||  H.tip_doc_iden
||chr(9)||  H.num_doc_iden
||chr(9)||  H.tip_doc_trib
||chr(9)||  H.num_doc_trib
||chr(9)||  H.cod_unico_clie
||chr(9)||  H.cod_sbs_coinc_ide
||chr(9)||  H.cod_sbs_coinc_ruc
||chr(9)||  H.cod_sbs_coinc_uni
||chr(9)||  H.tip_persona
||chr(9)||  H.cod_sbs_a_asignar
as deudor
FROM
(
SELECT G.num_sec_reg
      ,G.cod_sbs
      ,G.desc_persona
      ,g.tip_reg_mv
      ,G.tip_doc_iden
      ,G.num_doc_iden
      ,G.tip_doc_trib
      ,G.num_doc_trib
      ,G.cod_unico_clie
      ,G.cod_sbs_coinc_ide
      ,G.cod_sbs_coinc_ruc
      ,G.cod_sbs_coinc_uni
      ,G.tip_persona
      ,G.cod_sbs_a_asignar
      ,G.secuencia_enlace
FROM
(
select to_char(f.num_sec_reg) as num_sec_reg
      ,f.cod_sbs
      ,f.desc_persona
      ,SF_OBT_DATOS_CRI_PERSONA(f.cod_sbs, 'TIP_REG_MV' ) as tip_reg_mv
      ,f.tip_doc_iden
      ,f.num_doc_iden
      ,f.tip_doc_trib
      ,f.num_doc_trib
      ,f.cod_unico_clie
      ,f.cod_sbs_coinc_ide
      ,a.cod_sbs_coinc_ruc
      ,f.cod_sbs_coinc_uni
      ,f.tip_persona
      ,a.cod_sbs_a_asignar
      ,f.secuencia_enlace
 from cra_valid_asig_codsbs a, XCRI_ALTAS_VAL_ASIG_CODSBS_FV f
where a.ano_refer        = pv_ano_refer
  and a.mes_refer        = pv_mes_refer
  and a.cod_reporte      = pv_cod_reporte
  and a.cod_empresa      = pv_cod_empresa
  and a.dia_refer        = pv_dia_refer
  and a.cod_sec_envio    = pv_cod_sec_envio
  and a.cod_est_asig     = PRV_ESTADO_DUDA
  and f.ano_refer        = a.ano_refer
  and f.mes_refer        = a.mes_refer
  and f.cod_reporte      = a.cod_reporte
  and f.cod_empresa      = a.cod_empresa
  and f.dia_refer        = a.dia_refer
  and f.cod_sec_envio    = a.cod_sec_envio
  and f.secuencia_enlace = a.num_sec_reg

UNION

SELECT TO_CHAR(v.NUM_SEC_REG) AS NUM_SEC_REG
       ,v.COD_SBS
       ,NVL(v.NOM_CLIENTE, ' ') AS DES_PERSONA
       ,SF_OBT_DATOS_CRI_PERSONA(v.cod_sbs, 'TIP_REG_MV' ) as tip_reg_mv
       ,v.TIP_DOC_IDEN
       ,v.NUM_DOC_IDEN
       ,v.TIP_DOC_TRIB
       ,v.NUM_DOC_TRIB
       ,v.COD_UNICO_CLIE
       ,v.COD_SBS_COINC_IDE
       ,v.COD_SBS_COINC_RUC
       ,v.COD_SBS_COINC_UNI
       ,v.TIP_PERSONA
       ,v.cod_sbs_a_asignar
       ,v.NUM_SEC_REG  SECUENCIA_ENLACE
  FROM CRA_VALID_ASIG_CODSBS V
 WHERE v.ANO_REFER 	    = pv_ano_refer
   AND v.MES_REFER 	    = pv_mes_refer
   AND v.COD_REPORTE 	  = pv_cod_reporte
   AND v.COD_EMPRESA 	  = pv_cod_empresa
   AND v.dia_refer      = pv_dia_refer
   AND v.cod_sec_envio  = pv_cod_sec_envio
   AND v.COD_EST_ASIG   = PRV_ESTADO_DUDA
   AND v.IND_EST_ASIG   = 'P'
   AND v.IND_REG_OBSERV IS NULL
   AND v.num_sec_reg in
          (
            select a.num_sec_reg
              from cra_valid_asig_codsbs a
             where a.ano_refer    = pv_ano_refer
               and a.mes_refer    = pv_mes_refer
               and a.cod_reporte  = pv_cod_reporte
               and a.cod_empresa  = pv_cod_empresa
               and a.dia_refer      = pv_dia_refer
               and a.cod_sec_envio  = pv_cod_sec_envio
               and a.cod_est_asig = PRV_ESTADO_DUDA

             MINUS

            select f.num_sec_reg
              from cra_valid_asig_codsbs a, XCRI_ALTAS_VAL_ASIG_CODSBS_FV f
             where a.ano_refer        = pv_ano_refer
               and a.mes_refer        = pv_mes_refer
               and a.cod_reporte      = pv_cod_reporte
               and a.cod_empresa      = pv_cod_empresa
               and a.dia_refer        = pv_dia_refer
               and a.cod_sec_envio    = pv_cod_sec_envio
               and a.cod_est_asig     = PRV_ESTADO_DUDA
               and f.ano_refer        = a.ano_refer
               and f.mes_refer        = a.mes_refer
               and f.cod_reporte      = a.cod_reporte
               and f.cod_empresa      = a.cod_empresa
               and f.dia_refer        = a.dia_refer
               and f.cod_sec_envio    = a.cod_sec_envio
               and f.secuencia_enlace = a.num_sec_reg
          )

UNION
(
SELECT NULL
      ,B.COD_SBS
      ,SF_CRI_PERSONA_DES_PERSONA(B.COD_SBS, B.TIP_PERSONA) AS DES_PERSONA
      ,b.tip_reg_mv
      ,SF_CRI_PERSONA_TIP_DOCID(B.COD_SBS, B.TIP_PERSONA) AS TIP_DOC_IDEN
      ,SF_CRI_PERSONA_NUM_DOCID(B.COD_SBS, B.TIP_PERSONA) AS NUM_DOC_IDEN
      ,DECODE(B.NUM_RUC11, NULL, '2', '3') AS TIP_DOC_TRIB
      ,DECODE(B.NUM_RUC11, NULL, B.NUM_RUC, B.NUM_RUC11) AS NUM_DOC_TRIB
      ,A.COD_UNICO_CLIE AS COD_UNICO_CLIE
      ,A.COD_SBS_COINC_IDE
      ,A.COD_SBS_COINC_RUC
      ,A.COD_SBS_COINC_UNI
      ,B.TIP_PERSONA
      ,a.cod_sbs_a_asignar
      ,a.NUM_SEC_REG  SECUENCIA_ENLACE
  FROM CRA_VALID_ASIG_CODSBS A, CRI_PERSONA B
 WHERE A.ANO_REFER 				 = pv_ano_refer
   AND A.MES_REFER 				 = pv_mes_refer
   AND A.COD_REPORTE 			 = pv_cod_reporte
   AND A.COD_EMPRESA 		   = pv_cod_empresa
   AND a.dia_refer         = pv_dia_refer
   AND a.cod_sec_envio     = pv_cod_sec_envio
   AND A.COD_EST_ASIG      = PRV_ESTADO_DUDA
   AND A.IND_EST_ASIG 		 = 'P'
   AND A.IND_REG_OBSERV 	 IS NULL
   AND A.COD_SBS_COINC_IDE = B.COD_SBS
   AND a.num_sec_reg in
         (
          select a.num_sec_reg
            from cra_valid_asig_codsbs a
           where a.ano_refer    = pv_ano_refer
             and a.mes_refer    = pv_mes_refer
             and a.cod_reporte  = pv_cod_reporte
             and a.cod_empresa  = pv_cod_empresa
             and a.dia_refer     = pv_dia_refer
             and a.cod_sec_envio = pv_cod_sec_envio
             and a.cod_est_asig = PRV_ESTADO_DUDA

             MINUS

           select f.num_sec_reg
             from cra_valid_asig_codsbs a
                , XCRI_ALTAS_VAL_ASIG_CODSBS_FV f
            where a.ano_refer        = pv_ano_refer
              and a.mes_refer        = pv_mes_refer
              and a.cod_reporte      = pv_cod_reporte
              and a.cod_empresa      = pv_cod_empresa
              and a.dia_refer        = pv_dia_refer
              and a.cod_sec_envio    = pv_cod_sec_envio
              and a.cod_est_asig     = PRV_ESTADO_DUDA
              and f.ano_refer        = a.ano_refer
              and f.mes_refer        = a.mes_refer
              and f.cod_reporte      = a.cod_reporte
              and f.cod_empresa      = a.cod_empresa
              and f.dia_refer        = a.dia_refer
              and f.cod_sec_envio    = a.cod_sec_envio
              and f.secuencia_enlace = a.num_sec_reg
        )
)
)G
ORDER BY G.SECUENCIA_ENLACE asc
) H
ORDER BY H.SECUENCIA_ENLACE asc;

lv_ruta                  VARCHAR2(120);
lv_filename_lista_aproximados VARCHAR2(120);
lutl_file_lista_aproximados   UTL_FILE.FILE_TYPE;
ln_num_reg_sal           NUMBER;
lv_reg_cab_aprx          VARCHAR2(500);

BEGIN
  -- Inicio: Generando archivo de aproximados
  -- seteando la ruta y el nombre del archivo

  ln_num_reg_sal := 0;
  -- Verifica si existen registros para generar archivo

  IF pv_estado = PRV_ESTADO_APROXIMADO THEN
     FOR cur_count IN cur_reg_deudores LOOP
         ln_num_reg_sal  := ln_num_reg_sal + 1;
         Exit;
     END LOOP;
  ELSE
     IF pv_estado = PRV_ESTADO_DUDA THEN
        FOR cur_count IN cur_reg_deudores_dudas LOOP
            ln_num_reg_sal  := ln_num_reg_sal + 1;
            Exit;
        END LOOP;
     ELSE
        RETURN;
     END IF;
  END IF;

  IF nvl(ln_num_reg_sal,0) <= 0 THEN
     RETURN;
     -- No existen registros de aproximados/Dudas
  END IF;
  ln_num_reg_sal := 0;

  -- Inicia proceso para generar el archivo aproximados/Dudas
  IF pv_estado = PRV_ESTADO_APROXIMADO THEN
     lv_filename_lista_aproximados := 'Lista_aproxm_';
  ELSE
     IF pv_estado = PRV_ESTADO_DUDA THEN
        lv_filename_lista_aproximados := 'Lista_dudass_';
     ELSE
        RETURN;
     END IF;
  END IF;

  lv_filename_lista_aproximados :=  lv_filename_lista_aproximados || pv_cod_reporte || pv_ano_refer || pv_mes_refer || '_' || pv_cod_empresa || '.xls';

  lv_ruta := SF_ALTAS_RUTA_FILE_UNIX (pv_usuario, lv_filename_lista_aproximados, 'C' );

  -- Abriendo el Archivo de Aproximados
  lutl_file_lista_aproximados := UTL_FILE.FOPEN (lv_ruta, lv_filename_lista_aproximados, 'W');
  lv_reg_cab_aprx := '';

  -- Almacenando informacion en el Registro de aproximados
  -- Registro de cabecera
  ln_num_reg_sal := 0;

  UTL_FILE.PUT_LINE (lutl_file_lista_aproximados, chr(13));

  FOR cur_ent IN cur_entidad LOOP
      lv_reg_cab_aprx  := cur_ent.entidad;
      ln_num_reg_sal := ln_num_reg_sal + 1 ;
  END LOOP;

  UTL_FILE.PUT_LINE (lutl_file_lista_aproximados, chr(13));
  UTL_FILE.PUT_LINE (lutl_file_lista_aproximados, lv_reg_cab_aprx ||chr(13));
  UTL_FILE.PUT_LINE (lutl_file_lista_aproximados, chr(13));
  UTL_FILE.PUT_LINE (lutl_file_lista_aproximados, chr(13));

  FOR cur_cab IN cur_cabecera LOOP
      lv_reg_cab_aprx  := cur_cab.cabecera;
      ln_num_reg_sal := ln_num_reg_sal + 1 ;
  END LOOP;

  UTL_FILE.PUT_LINE (lutl_file_lista_aproximados, lv_reg_cab_aprx ||chr(13));

  IF pv_estado = PRV_ESTADO_APROXIMADO THEN
     FOR cur_deud IN cur_reg_deudores LOOP
         lv_reg_cab_aprx  := cur_deud.deudor;
         ln_num_reg_sal := ln_num_reg_sal + 1 ;
         UTL_FILE.PUT_LINE (lutl_file_lista_aproximados, lv_reg_cab_aprx ||chr(13));
     END LOOP;
  ELSE
     FOR cur_deud IN cur_reg_deudores_dudas LOOP
         lv_reg_cab_aprx  := cur_deud.deudor;
         ln_num_reg_sal := ln_num_reg_sal + 1 ;
         UTL_FILE.PUT_LINE (lutl_file_lista_aproximados, lv_reg_cab_aprx ||chr(13));
     END LOOP;
  END IF;

  -- Cierra los archivos
  UTL_FILE.FCLOSE(lutl_file_lista_aproximados);
  --  UTL_FILE.FCLOSE_ALL;

  -- Finaliza OK
  DBMS_OUTPUT.PUT_LINE ('Final : '||to_char(sysdate,'yyyy-mm-dd hh24:mi:ss'));
  -- Fin: Generando archivo de Aproximados ---
  RETURN;

 EXCEPTION
   WHEN NO_DATA_FOUND THEN
       ROLLBACK;
       DBMS_OUTPUT.PUT_LINE('Fin de registro');
       PRV_ERROR   := SQLERRM;
       PRV_MENSAJE := substr(PRV_ERROR,1,255) || ' -- SP_POST_ALTAS_GENERA_FILE_APRX';
       PRN_RETURN  := -1;
       UTL_FILE.FCLOSE(lutl_file_lista_aproximados);

   WHEN UTL_FILE.INVALID_PATH THEN
       ROLLBACK;
       DBMS_OUTPUT.PUT_LINE('UTL_FILE: Ruta no valida');
       PRV_ERROR   := SQLERRM;
       PRV_MENSAJE := substr(PRV_ERROR,1,255) || ' -- SP_POST_ALTAS_GENERA_FILE_APRX';
       PRN_RETURN  := -1;
       UTL_FILE.FCLOSE(lutl_file_lista_aproximados);

   WHEN UTL_FILE.READ_ERROR THEN
       ROLLBACK;
       DBMS_OUTPUT.PUT_LINE('UTL_FILE: Error en lectura');
       PRV_ERROR   := SQLERRM;
       PRV_MENSAJE := substr(PRV_ERROR,1,255) || ' -- SP_POST_ALTAS_GENERA_FILE_APRX';
       PRN_RETURN  := -1;
       UTL_FILE.FCLOSE(lutl_file_lista_aproximados);

   WHEN UTL_FILE.WRITE_ERROR THEN
       ROLLBACK;
       DBMS_OUTPUT.PUT_LINE('UTL_FILE: Error en escritura');
       PRV_ERROR   := SQLERRM;
       PRV_MENSAJE := substr(PRV_ERROR,1,255) || ' -- SP_POST_ALTAS_GENERA_FILE_APRX';
       PRN_RETURN  := -1;
       UTL_FILE.FCLOSE(lutl_file_lista_aproximados);

   WHEN UTL_FILE.INVALID_MODE THEN
       ROLLBACK;
       DBMS_OUTPUT.PUT_LINE('UTL_FILE: Error en modo de acceso');
       PRV_ERROR   := SQLERRM;
       PRV_MENSAJE := substr(PRV_ERROR,1,255) || ' -- SP_POST_ALTAS_GENERA_FILE_APRX';
       PRN_RETURN  := -1;
       UTL_FILE.FCLOSE(lutl_file_lista_aproximados);

   WHEN UTL_FILE.INVALID_FILEHANDLE THEN
       ROLLBACK;
       DBMS_OUTPUT.PUT_LINE('UTL_FILE: Error ');
       PRV_ERROR   := SQLERRM;
       PRV_MENSAJE := substr(PRV_ERROR,1,255) || ' -- SP_POST_ALTAS_GENERA_FILE_APRX';
       PRN_RETURN  := -1;
       UTL_FILE.FCLOSE(lutl_file_lista_aproximados);

   WHEN UTL_FILE.INVALID_OPERATION THEN
       ROLLBACK;
       DBMS_OUTPUT.PUT_LINE('UTL_FILE: Error ');
       PRV_ERROR   := SQLERRM;
       PRV_MENSAJE := substr(PRV_ERROR,1,255) || ' -- SP_POST_ALTAS_GENERA_FILE_APRX';
       PRN_RETURN  := -1;
       UTL_FILE.FCLOSE(lutl_file_lista_aproximados);

   WHEN UTL_FILE.INVALID_MAXLINESIZE THEN
       ROLLBACK;
       DBMS_OUTPUT.PUT_LINE('UTL_FILE: Error ');
       PRV_ERROR   := SQLERRM;
       PRV_MENSAJE := substr(PRV_ERROR,1,255) || ' -- SP_POST_ALTAS_GENERA_FILE_APRX';
       PRN_RETURN  := -1;
       UTL_FILE.FCLOSE(lutl_file_lista_aproximados);

   WHEN UTL_FILE.INTERNAL_ERROR THEN
       ROLLBACK;
       DBMS_OUTPUT.PUT_LINE('UTL_FILE: Error ');
       PRV_ERROR   := SQLERRM;
       PRV_MENSAJE := substr(PRV_ERROR,1,255) || ' -- SP_POST_ALTAS_GENERA_FILE_APRX';
       PRN_RETURN  := -1;
       UTL_FILE.FCLOSE(lutl_file_lista_aproximados);

  WHEN OTHERS THEN
       -- Actualizar estado de este proceso y colocarlo en error.
       -- Actualiza Observaciones del Sistema.
       UTL_FILE.FCLOSE(lutl_file_lista_aproximados);
       PRV_ERROR   := SQLERRM;
       PRV_MENSAJE := substr(PRV_ERROR,1,255) || ' -- SP_POST_ALTAS_GENERA_FILE_APRX';
       PRN_RETURN  := -1;

END SP_POST_ALTA_GENE_FILE_APX_DUD;

----------------------------------------------------------

   -- Procedimiento para Actualizar la asignacion de Estados. Cambia de un estado hacia otro determinado por el usuario
   -- Se ejecutara despues de todo el proceso de altas. Antes de ejecutar el proceso RAYITO (Procedure Invocado solo desde PowerBuilder)
PROCEDURE SP_ALTAS_MODIF_CAMBIO_ESTADO
        (pv_ano_refer          cra_valid_asig_codsbs.ano_refer%type,
         pv_mes_refer          cra_valid_asig_codsbs.mes_refer%type,
         pv_cod_reporte        cra_valid_asig_codsbs.cod_reporte%type,
         pv_cod_empresa        cra_valid_asig_codsbs.cod_empresa%type,
         pv_usuario            cra_valid_asig_codsbs.cod_usu_apr%type,
         pv_estado_asig_actual cra_valid_asig_codsbs.cod_est_asig%type,
         pv_estado_asig_nuevo  cra_valid_asig_codsbs.cod_est_asig%type,
         pv_tipo_proceso       VARCHAR2,
         pv_dia_refer          IN cra_valid_asig_codsbs.dia_refer%type default '01',
         pv_cod_sec_envio      IN cra_valid_asig_codsbs.cod_sec_envio%type default '01',
         ov_mensaje            OUT VARCHAR2,
         on_return             OUT NUMBER
         )
IS
---------------------
--       Autor                     Fecha         Software
--       Francisco Vite Shelton    14/03/2006    Oracle 8i
---------------------
--       Parametros
--           pv_ano_refer   :  Año de referencia.
--           pv_mes_refer   :  Mes de referencia.
--           pv_cod_reporte :  Codigo reporte a cargar (RCD/RTC)
--           pv_cod_empresa :  Codigo de la Entidad.
--           pv_usuario     :  Usuario que ejecuta el proceso.
--           pv_estado_asig_actual  : Identifica el estado base desde el cual se desea llevar los registros a procesar.
--           pv_estado_asig_nuevo : Identifica el estado hacia donde se desea llevar los registros a procesar.
--           ------------
--           pv_tipo_proceso     :  Permite validar los cambios de estado
--                      0 ==>  Caso Estandar.
--                                 Los posibles cambios de estado que se pueden realizar son:
--                            Secuencia	Estado Inicial	        Estado Final
--                                1	        Dudas	                 Antiguos
--                                2	        Aproximados	           Antiguos
--                                3	        No codificables	       Dudas	 ( previa Validacion que NO existan reg.en  Dudas)
--                                4	        Aproximados	           Dudas	 ( previa Validacion que NO existan reg.en  Dudas)
--
--                      1 ==>  Caso Especial.
--                                 Los posibles cambios de estado que se pueden realizar son:
--                            Secuencia	Estado Inicial	        Estado Final
--                                1	        No codificables	       Dudas
--                                2	        Aproximados	           Dudas
--
--                                3	        Dudas	                 Nuevos
--                                4	        Aproximados	           Nuevos
--                                5	        No codificables	       Nuevos
--
--           ------------
--           ov_mensaje     : Retorna el mensaje de ocurrir alguna observacion.
--           on_return      : Retorna el codigo de error
--                            -1 : Error
--                             1 : OK
---------------------
--       Descripcion
--     Procedimiento para Actualizar la asignacion de Estados. Cambia de un estado hacia otro determinado por el usuario
--     Se ejecutara despues de todo el proceso de altas. Antes de ejecutar el proceso RAYITO. DERC tiene autonomia para administrar este proceso.
---------------------
-- Ejecucion
--  PK_XCRI_ALTAS_VAL_ASIG_CODSBS.SP_ALTAS_MODIF_CAMBIO_ESTADO ('2006','02','RCD','00102','FVITES','A','X');
------------------------------------------------------------------------------------
---------------------       COMENTARIOS A TENER EN CUENTA      ---------------------
-- Esta acción se realiza a solicitud de DERC una vez que han culminado con la revisión manual
-- de los deudores que luego del proceso de validación se clasificaron como Dudas o Aproximados.
--
-- Los estados disponibles son: Antiguos, Aproximados, Dudas, No Codificables, Nuevos.
--
-- Los posibles cambios de estado que se pueden realizar son:
--
-- Secuencia	Estado Inicial	        Estado Final	     Observación
--     1	        Dudas	                 Antiguos
--     2	        Aproximados	           Antiguos
--     3	        No codificables	       Dudas
--
--     Obs. : Esta secuencia se debe respetar para la actualización.
--           Puede existir una secuencia adicional a solicitud de DERC para lo cual
--           se debe analizar el impacto que puede ocasionar en la identificación.
--
--  Excepciones donde se debe tener un análisis con mayor detalle:
-- Secuencia	 Estado Inicial	        Estado Final	     Observación
--      1	         Dudas	              Nuevos	         Análisis impacto
--      2	         Aproximados	        Nuevos	         Análisis impacto
--      3	         No codificables	    Nuevos	         Análisis impacto
--
--  Nota 1: Para realizar esta acciòn se tiene que estar 100% seguro de que los deudores hayan sido revisados y no existan inconvenientes de identificación.
--          Esta acción es crítica debido a que dependiendo del estado final que se establezca es el que identificara al deudor y puede ocasionar malas asignaciones.
--          De presentarse observaciones en este proceso (ejemplo se realizo un actualización indebida) se recomienda  reiniciar el proceso de validación
--          preferentemente desde la etapa de matricula (esto pude ocasionar un doble trabajo en el proceso de altas.
--
--  Nota 2: Una vez realizada esta acción se procede a culminar con la etapa de altas ejecutando
--          el proceso asignado para este fin (proceso conocido por los usuarios como: "rayito")
--
--  Nota 3: Se debe modificar el proceso rayito para que considere al momento de iniciar su ejecución que solo se tengan los estados "Nuevo, Dudas, Antiguos".
------------------------------------------------------------------------------------
lv_estado_nuevo    varchar2(1);
ln_cod_sbs_asignar number(10);
lv_estado_actual   Varchar2(1);
lv_cod_ent_vig     Varchar2(5);
lv_ano_refer       Varchar2(4);
lv_mes_refer       Varchar2(2);
lv_tipo_reporte    Varchar2(3);
ln_result          NUMBER(3);

----------------------------------------------------------------------------
-- Obtiene Si existen datos para cambiar el estado.
-- Esta validadcion se obtiene para los deudores que tengan 2 incidencias.
----------------------------------------------------------------------------
CURSOR cur_actualiza_estado is
SELECT  count(*) as num_registros
  FROM cra_valid_asig_codsbs a
 WHERE a.ano_refer    = lv_ano_refer
   AND a.mes_refer    = lv_mes_refer
   AND a.cod_reporte  = lv_tipo_reporte
   AND a.cod_empresa  = lv_cod_ent_vig
   AND a.dia_refer     = pv_dia_refer
   AND a.cod_sec_envio = pv_cod_sec_envio
   AND a.cod_est_asig = lv_estado_actual;

BEGIN
  lv_cod_ent_vig   := pv_cod_empresa;
  lv_ano_refer     := pv_ano_refer;
  lv_mes_refer     := pv_mes_refer;
  lv_tipo_reporte  := pv_cod_reporte;

  IF pv_tipo_proceso not in ('0','1') THEN
     PRV_MENSAJE := 'Tipo de proceso es invalido, no es 0 ni 1 ' || ' -- SP_ALTAS_MODIF_CAMBIO_ESTADO';
     PRN_RETURN  := -5;
     ov_mensaje  := PRV_MENSAJE;
     on_return   := PRN_RETURN;
     RETURN;
  END IF;

  --- Valida que los estados sean datos coherentes
        -- ESTADO ACTUAL
  ln_result := SF_ADM_ELEMENTO_BUSCA ('TIP_COND_CLIE',pv_estado_asig_actual);
  IF ln_result <> 1 THEN
     PRV_MENSAJE := 'Estado Actual enviado es invalido' || ' -- SP_ALTAS_MODIF_CAMBIO_ESTADO';
     PRN_RETURN  := -5;
     ov_mensaje  := PRV_MENSAJE;
     on_return   := PRN_RETURN;
     RETURN;
  END IF;

        -- ESTADO NUEVO
  ln_result := SF_ADM_ELEMENTO_BUSCA ('TIP_COND_CLIE',pv_estado_asig_nuevo);
  IF ln_result <> 1 THEN
     PRV_MENSAJE := 'Estado Nuevo enviado es invalido' || ' -- SP_ALTAS_MODIF_CAMBIO_ESTADO';
     PRN_RETURN  := -5;
     ov_mensaje  := PRV_MENSAJE;
     on_return   := PRN_RETURN;
     RETURN;
  END IF;

  --------------------------------------------
  -----  VALIDACION POR TIPO DE PROCESO  -----
  --------------------------------------------
  IF pv_tipo_proceso = '0'  THEN
       --            0 ==>  Caso Estandar.
       --                      Los posibles cambios de estado que se pueden realizar son:
       --                  Secuencia	Estado Inicial	        Estado Final
       --                      1	        Dudas	                 Antiguos
       --                      2	        Aproximados	           Antiguos
       --                      3	        No codificables	       Dudas	 ( previa Validacion que NO existan reg.en  Dudas)
       --                      4	        Aproximados	           Dudas	 ( previa Validacion que NO existan reg.en  Dudas)
       --

       IF pv_estado_asig_nuevo not in ('A','D') THEN
          PRV_MENSAJE := 'Nuevos Estados para esta accion son invalidos' || ' -- SP_ALTAS_MODIF_CAMBIO_ESTADO';
          PRN_RETURN  := -5;
          ov_mensaje  := PRV_MENSAJE;
          on_return   := PRN_RETURN;
          RETURN;
       END IF;

       IF pv_estado_asig_nuevo = 'A' THEN
          -- Estado Final Antiguos
          IF pv_estado_asig_actual not in ('D','B') THEN
             PRV_MENSAJE := 'Estado actual para esta accion es invalido' || ' -- SP_ALTAS_MODIF_CAMBIO_ESTADO';
             PRN_RETURN  := -5;
             ov_mensaje  := PRV_MENSAJE;
             on_return   := PRN_RETURN;
             RETURN;
          END IF;
       ELSE
           -- Estado final Dudas
          IF pv_estado_asig_actual not in ('B','X') THEN
             PRV_MENSAJE := 'Estado actual para esta accion es invalido' || ' -- SP_ALTAS_MODIF_CAMBIO_ESTADO';
             PRN_RETURN  := -5;
             ov_mensaje  := PRV_MENSAJE;
             on_return   := PRN_RETURN;
             RETURN;
          END IF;

          --- Valida si existen registros de dudas
          lv_estado_actual := pv_estado_asig_nuevo;
          ln_cod_sbs_asignar := 0;

          FOR cur_count_dudas in cur_actualiza_estado LOOP
              -- Valida si existen registros en Duda.
              ln_cod_sbs_asignar  := cur_count_dudas.num_registros;

              IF ln_cod_sbs_asignar > 0 THEN
                 PRV_MENSAJE := 'Existen registros clasificados como Dudas.Tipo proceso para esta accion es invalido' || ' -- SP_ALTAS_MODIF_CAMBIO_ESTADO';
                 PRN_RETURN  := -5;
                 ov_mensaje  := PRV_MENSAJE;
                 on_return   := PRN_RETURN;
                 RETURN;
              END IF;

              EXIT;
          END LOOP;
       END IF;
  END IF;

  IF pv_tipo_proceso = '1'  THEN
       --            1 ==>  Caso Especial.
       --                      Los posibles cambios de estado que se pueden realizar son:
       --                  Secuencia	Estado Inicial	        Estado Final
       --                      1	        No codificables	       Dudas
       --                      2	        Aproximados	           Dudas
       --
       --                      3	        Dudas	                 Nuevos
       --                      4	        Aproximados	           Nuevos
       --                      5	        No codificables	       Nuevos
       ---------------------------
       IF pv_estado_asig_nuevo not in ('D','N') THEN
          PRV_MENSAJE := 'Nuevos Estados para esta accion son invalidos' || ' -- SP_ALTAS_MODIF_CAMBIO_ESTADO';
          PRN_RETURN  := -5;
          ov_mensaje  := PRV_MENSAJE;
          on_return   := PRN_RETURN;
          RETURN;
       END IF;
       ---------------------------
       IF pv_estado_asig_nuevo = 'D' THEN
          -- Estado Final Dudas
          IF pv_estado_asig_actual not in ('B','X') THEN
             PRV_MENSAJE := 'Estado actual para esta accion es invalido' || ' -- SP_ALTAS_MODIF_CAMBIO_ESTADO';
             PRN_RETURN  := -5;
             ov_mensaje  := PRV_MENSAJE;
             on_return   := PRN_RETURN;
             RETURN;
          END IF;
        ---------------------------
       ELSE
           -- Estado final Nuevos
          IF pv_estado_asig_actual not in ('D','B','X') THEN
             PRV_MENSAJE := 'Estado actual para esta accion es invalido' || ' -- SP_ALTAS_MODIF_CAMBIO_ESTADO';
             PRN_RETURN  := -5;
             ov_mensaje  := PRV_MENSAJE;
             on_return   := PRN_RETURN;
             RETURN;
          END IF;
       END IF;
  END IF;

  lv_estado_actual := pv_estado_asig_actual;
  ln_cod_sbs_asignar  := 0;

  FOR cur_count in cur_actualiza_estado LOOP
      -- Total de registros ha asignar.
     ln_cod_sbs_asignar  := cur_count.num_registros;
     lv_estado_nuevo     := pv_estado_asig_nuevo;

     IF ln_cod_sbs_asignar > 0 THEN
        UPDATE cra_valid_asig_codsbs a
           SET a.cod_est_asig      = lv_estado_nuevo
         WHERE a.ano_refer    = lv_ano_refer
           AND a.mes_refer    = lv_mes_refer
           AND a.cod_reporte  = lv_tipo_reporte
           AND a.cod_empresa  = lv_cod_ent_vig
           AND a.dia_refer     = pv_dia_refer
           AND a.cod_sec_envio = pv_cod_sec_envio
           AND a.cod_est_asig = lv_estado_actual ;
     END IF;
 END LOOP;

 commit;
 PRN_RETURN  := 1;
 PRV_MENSAJE := 'Se han procesado ( ' || ln_cod_sbs_asignar || ' ) registros ' ;
 PRV_MENSAJE := PRV_MENSAJE || '( ' || lv_estado_actual || ' --> '|| lv_estado_nuevo;
 PRV_MENSAJE := PRV_MENSAJE || ' ) ' ;--|| ' -- SP_ALTAS_MODIF_CAMBIO_ESTADO';
 ov_mensaje  := PRV_MENSAJE;
 on_return   := PRN_RETURN;

EXCEPTION
  WHEN OTHERS THEN
    Rollback;
    PRV_ERROR   := SQLERRM;
    PRV_MENSAJE := substr(PRV_ERROR,1,255) || ' -- SP_ALTAS_MODIF_CAMBIO_ESTADO';
    PRN_RETURN  := -1;
    ov_mensaje  := PRV_MENSAJE;
    on_return   := PRN_RETURN;
    RETURN ;

END SP_ALTAS_MODIF_CAMBIO_ESTADO;

----------------------------------------------------------

PROCEDURE SP_REP_COMPARATIVO_CONTROL_71
        ( pv_ano_refer     xcri_altas_val_asig_codsbs_fv.ano_refer%type,
          pv_mes_refer     xcri_altas_val_asig_codsbs_fv.mes_refer%type,
          pv_cod_reporte   xcri_altas_val_asig_codsbs_fv.cod_reporte%type,
          pv_cod_empresa   xcri_altas_val_asig_codsbs_fv.cod_empresa%type,
          pv_usuario       xcri_altas_val_asig_codsbs_fv.cod_usu_proc%type,
          pn_control       cra_val_controles_rcd_x_sec.cod_control%type,
          pv_dia_refer     IN xcri_altas_val_asig_codsbs_fv.dia_refer%type default '01',
          pv_cod_sec_envio IN xcri_altas_val_asig_codsbs_fv.cod_sec_envio%type default '01'
         )
IS
---------------------
--       Autor                     Fecha         Software
--       Francisco Vite Shelton    26/04/2006    Oracle 8i
---------------------
--       Parametros
--           pv_ano_refer   :  Año de referencia.
--           pv_mes_refer   :  Mes de referencia.
--           pv_cod_reporte :  Codigo reporte a cargar (RCD/RTC)
--           pv_cod_empresa :  Codigo de la Entidad.
--           pv_usuario     : Usuario que ejecuta el proceso.
---------------------
--       Descripcion
--         Genera el archivo comparativo para los deudores que presentan el control 71.
--         Este reporte se obtiene para que el analista DERC desde un archivo excel s ia si lo desea pueda
--         verificar los nombres de los deudores que se encuentran observados.
--         Asimismo, si desea y tomando las consideraciones del caso esta data puede ser compartida con
--         las entidades del sistema.
--         Este procedimiento se ejecuta al final del proceso de altas.
---------------------
-- Ejecucion
--  PK_XCRI_ALTAS_VAL_ASIG_CODSBS.SP_REP_COMPARATIVO_CONTROL_71 ('2006','03','RCD','00159','FVITES',71);
---------------------
BEGIN
  IF pv_cod_reporte = 'RCD' THEN
     SP_REP_COMPARAT_CONTROL_71_RCD ( pv_ano_refer, pv_mes_refer, pv_cod_reporte, pv_cod_empresa, pv_usuario, pn_control );
  ELSE
     SP_REP_COMPARAT_CONTROL_71_RCA ( pv_ano_refer, pv_mes_refer, pv_cod_reporte, pv_cod_empresa, pv_usuario, pn_control, pv_dia_refer, pv_cod_sec_envio );
  END IF;

EXCEPTION
   WHEN OTHERS THEN
       PRV_ERROR   := SQLERRM;
       PRV_MENSAJE := substr(PRV_ERROR,1,255) || ' -- SP_REP_COMPARATIVO_CONTROL_71';
       PRN_RETURN  := -1;

END SP_REP_COMPARATIVO_CONTROL_71;

----------------------------------------------------------

PROCEDURE SP_REP_COMPARAT_CONTROL_71_RCD
        ( pv_ano_refer    xcri_altas_val_asig_codsbs_fv.ano_refer%type,
         pv_mes_refer    xcri_altas_val_asig_codsbs_fv.mes_refer%type,
         pv_cod_reporte  xcri_altas_val_asig_codsbs_fv.cod_reporte%type,
         pv_cod_empresa  xcri_altas_val_asig_codsbs_fv.cod_empresa%type,
         pv_usuario      xcri_altas_val_asig_codsbs_fv.cod_usu_proc%type,
         pn_control      cra_val_controles_rcd_x_sec.cod_control%type
         )
IS
---------------------
--       Autor                     Fecha         Software
--       Francisco Vite Shelton    26/04/2006    Oracle 8i
---------------------
--       Parametros
--           pv_ano_refer   :  Año de referencia.
--           pv_mes_refer   :  Mes de referencia.
--           pv_cod_reporte :  Codigo reporte a cargar (RCD/RTC)
--           pv_cod_empresa :  Codigo de la Entidad.
--           pv_usuario     : Usuario que ejecuta el proceso.
---------------------
--       Descripcion
--        Genera el archivo comparativo para los deudores que presentan el control 71.
--        Este reporte se obtiene para que el analista DERC desde un archivo excel, si lo desea, pueda verificar los nombres de los deudores que se encuentran observados.
--        Asimismo, si desea y tomando las consideraciones del caso esta data puede ser compartida con las entidades del sistema.
--        Este procedimiento se ejecuta al final del proceso de altas.
---------------------
-- Ejecucion
--  PK_XCRI_ALTAS_VAL_ASIG_CODSBS.SP_REP_COMPARATIVO_CONTROL_71 ('2006','03','RCD','00159','FVITES',71);
---------------------

-- Datos de la entidad
CURSOR cur_entidad IS
Select chr(9) || pv_cod_empresa || ' - ' || e.nom_ent_vig_corto
    || chr(9)
    || chr(9) || 'Periodo: ' || pv_ano_refer  || ' - ' || pv_mes_refer
    as entidad
from ays_ent_vigilada e
where e.cod_ent_vig = pv_cod_empresa ;

-- Cabecera del resultado del filtro
CURSOR cur_cabecera_comp_control_71 IS
Select     '#'
||chr(9)|| 'NUM SEC'
||chr(9)|| 'TIPO REG'
||chr(9)|| 'TIP DOC IDEN'
||chr(9)|| 'NUM DOC IDEN'
||chr(9)|| 'COD_SBS'
||chr(9)|| 'DESC_PERSONA'
||chr(9)|| 'TIP PERSONA'
||chr(9)|| 'TIP VALIDACION'
||chr(9)|| 'TIP CONDICION' AS cabecera
from dual ;

-- TOTAL DEUDORES CONTROL 71
CURSOR cur_total_deudores_por_control IS
SELECT count(1) AS total_deudores
  FROM cra_val_controles_rcd_x_sec c,cra_valid_identif_rcd i
 WHERE c.ano_refer   = pv_ano_refer
   AND c.mes_refer   = pv_mes_refer
   AND c.cod_empresa = pv_cod_empresa
   AND c.cod_control = 71
   AND i.ano_refer   = pv_ano_refer
   AND i.mes_refer   = pv_mes_refer
   AND i.cod_empresa = c.cod_empresa
   AND i.num_sec_reg = c.num_sec_reg ;

-- FVSH 20060426
-- LISTA DE DEDUORES DEL COMPARATIVO DEL CONTROL 71
-- ESTA LISTA CONTIENE DATOS REPORTADOS Y DATOS DEL MAESTRO SBS
-----------------------------
CURSOR cur_comparativo_control_71 IS
SELECT      v.num_orden,
            v.num_sec
||chr(9)||  v.tipo_reg
||chr(9)||  v.tip_doc
||chr(9)||  v.num_doc
||chr(9)||  v.cod_sbs
||chr(9)||  v.nombre
||chr(9)||  v.tip_persona
||chr(9)||  v.tip_valid
||chr(9)||  v.tip_condicion
as deudor
From
-------------------  -------------------  -------------------
(
select rownum as num_orden
      ,f.num_sec
      ,f.tipo_reg
      ,f.tip_doc
      ,f.num_doc
      ,f.cod_sbs
      ,f.nombre
      ,f.tip_persona
      ,f.tip_valid
      ,f.tip_condicion
  from
      (
      ----------------------------    ----------------------------
      --- DEUDORES REPORTADOS Y OBSERVADOS CON EL CONTROL 71
      ----------------------------    ----------------------------
       SELECT --i.cod_empresa
              i.num_sec_reg  as num_sec
             ,'REP' as tipo_reg
             ,i.tip_doc_iden  as tip_doc
             ,i.num_doc_iden  as num_doc
             ,nvl(to_number(i.cod_sbs),null) as cod_sbs
             ,trim(TRIM(trim(i.nom_cliente) || ' ' || trim(i.ape_materno)) || ' ' ||  trim(i.ape_casada))
              || ' ' || trim(trim(i.primer_nombre) || ' ' || trim(i.segundo_nombre)) as nombre
             ,i.tip_persona
             ,'' as tip_valid
             ,'' as tip_condicion
        FROM cra_val_controles_rcd_x_sec c, cra_valid_identif_rcd i
       WHERE c.ano_refer   = pv_ano_refer
         AND c.mes_refer   = pv_mes_refer
         AND c.cod_empresa = pv_cod_empresa
         AND c.cod_control = 71
         AND i.ano_refer   = pv_ano_refer
         AND i.mes_refer   = pv_mes_refer
         AND i.cod_empresa = c.cod_empresa
         AND i.num_sec_reg = c.num_sec_reg
      -- ORDER BY i.cod_empresa,i.num_sec_reg,i.tip_doc_iden asc, i.num_doc_iden
      ----------------------------    ----------------------------
      UNION
      ----------------------------    ----------------------------
      --- DATOS MAESTRO POR TIPO Y NUMERO DE DOCUMENTO y COD SBS
      ----------------------------    ----------------------------
      Select t.num_sec
             ,'' as tipo_reg
             ,a.tip_docto_ident    as tip_doc
             ,a.num_docto_ident    as num_doc
             ,a.cod_sbs
             ,trim(TRIM(trim(a.ape_paterno) || ' ' || trim(a.ape_materno)) || ' ' ||  trim(a.ape_casada))
              || ' ' || trim(trim(a.nom_persona) || ' ' || trim(a.segundo_nombre)) as nombre
             ,pk_xcri_altas_val_asig_codsbs.SF_OBT_DATOS_CRI_PERSONA(a.cod_sbs,'tip_persona') as tip_persona
             ,pk_xcri_altas_val_asig_codsbs.SF_OBT_DATOS_CRI_PERSONA(a.cod_sbs,'tip_reg_mv') as tip_valid
             ,pk_xcri_altas_val_asig_codsbs.SF_OBT_DATOS_CRI_PERSONA(a.cod_sbs,'tip_condicion') as tip_condicion
        From CRI_PERSONA_NAT A
            ,(   --- TOTAL DEUDORES OBSERVADOS CON EL CONTROL 71
                 SELECT i.cod_empresa
                       ,i.num_sec_reg  as num_sec
                       ,'REP' as tipo_reg
                       ,i.tip_doc_iden  as tip_doc
                       ,i.num_doc_iden  as num_doc
                       ,i.cod_sbs
                       ,trim(TRIM(trim(i.nom_cliente) || ' ' || trim(i.ape_materno)) || ' ' ||  trim(i.ape_casada))
                        || ' ' || trim(trim(i.primer_nombre) || ' ' || trim(i.segundo_nombre)) as nombre
                       ,i.tip_persona
                       ,'' as tip_valid
                       ,'' as tip_condicion
                  FROM cra_val_controles_rcd_x_sec c, cra_valid_identif_rcd i
                 WHERE c.ano_refer   = pv_ano_refer
                   AND c.mes_refer   = pv_mes_refer
                   AND c.cod_empresa = pv_cod_empresa
                   AND c.cod_control = 71
                   AND i.ano_refer   = pv_ano_refer
                   AND i.mes_refer   = pv_mes_refer
                   AND i.cod_empresa = c.cod_empresa
                   AND i.num_sec_reg = c.num_sec_reg
                 ORDER BY i.cod_empresa,i.num_sec_reg,i.tip_doc_iden asc, i.num_doc_iden
             )t
       Where (A.tip_docto_ident = t.tip_doc
         And  A.num_docto_ident = t.num_doc)
          Or  A.COD_SBS = t.cod_sbs
      -------------------  -------------------  -------------------
) F
order by f.num_sec asc, f.tipo_reg asc,f.tip_doc asc, f.num_doc asc, f.cod_sbs asc
) V
order by v.num_orden asc ;

lv_ruta                        VARCHAR2(120);
lv_filename_lista_comparativo  VARCHAR2(120);
lutl_file_lista_comparativo    UTL_FILE.FILE_TYPE;
ln_num_reg_sal                 NUMBER;
lv_reg_cab_comparativo         VARCHAR2(500);

BEGIN
  -----------------------------------------------
  -- Inicio: Generando archivo de comparativo 71 ---
  -----------------------------------------------
  -- seteando la ruta y el nombre del archivo
  IF pn_control <> 71 THEN
     RETURN;
  END IF;

  ln_num_reg_sal := 0;
  -- Verifica si existen registros para generar archivo
  FOR cur_count IN cur_total_deudores_por_control LOOP
      ln_num_reg_sal  := cur_count.total_deudores;
      Exit;
  END LOOP;

  IF nvl(ln_num_reg_sal,0) <= 0 THEN
     RETURN;  -- No existen registros en el control 71
  END IF;

  ---------------------------------------------------------
  ----  Inicia proceso para generar el archivo comparativo control 71
  ---------------------------------------------------------
--     lv_filename_lista_aproximados := 'Lista_aproxm_';
  lv_filename_lista_comparativo := 'Lst_ctrl_071_';
  lv_filename_lista_comparativo :=  lv_filename_lista_comparativo || pv_cod_reporte || pv_ano_refer || pv_mes_refer || '_' || pv_cod_empresa || '.xls';
  lv_ruta      := SF_ALTAS_RUTA_FILE_UNIX (pv_usuario, lv_filename_lista_comparativo, 'C' );

  -- Abriendo el Archivo Comparativo
  lutl_file_lista_comparativo   := UTL_FILE.FOPEN (lv_ruta, lv_filename_lista_comparativo, 'W');
  lv_reg_cab_comparativo      := '';

  -- Almacenando informacion en el Registro comparativo
  -- Registro de cabecera
  ln_num_reg_sal := 0;

  UTL_FILE.PUT_LINE (lutl_file_lista_comparativo, chr(13));

  FOR cur_ent IN cur_entidad LOOP
      lv_reg_cab_comparativo  := cur_ent.entidad;
      ln_num_reg_sal := ln_num_reg_sal + 1 ;
  END LOOP;

  UTL_FILE.PUT_LINE (lutl_file_lista_comparativo, chr(13));
  UTL_FILE.PUT_LINE (lutl_file_lista_comparativo, lv_reg_cab_comparativo ||chr(13));
  UTL_FILE.PUT_LINE (lutl_file_lista_comparativo, chr(13));
  UTL_FILE.PUT_LINE (lutl_file_lista_comparativo, chr(13));

  FOR cur_cab IN cur_cabecera_comp_control_71 LOOP
      lv_reg_cab_comparativo  := cur_cab.cabecera;
      ln_num_reg_sal := ln_num_reg_sal + 1 ;
  END LOOP;

  UTL_FILE.PUT_LINE (lutl_file_lista_comparativo, lv_reg_cab_comparativo ||chr(13));

  FOR cur_deud IN cur_comparativo_control_71 LOOP
      lv_reg_cab_comparativo  := cur_deud.num_orden || CHR(9) || cur_deud.deudor;
      ln_num_reg_sal := ln_num_reg_sal + 1 ;
      UTL_FILE.PUT_LINE (lutl_file_lista_comparativo, lv_reg_cab_comparativo ||chr(13));
  END LOOP;

  -- Cierra los archivos
  UTL_FILE.FCLOSE(lutl_file_lista_comparativo);
  --  UTL_FILE.FCLOSE_ALL;

  -- Finaliza OK
  DBMS_OUTPUT.PUT_LINE ('Final : '||to_char(sysdate,'yyyy-mm-dd hh24:mi:ss'));

  --------------------------------------------
  --  Fin: Generando archivo Comparativo   ---
  --------------------------------------------
RETURN;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
       ROLLBACK;
       DBMS_OUTPUT.PUT_LINE('Fin de registro');
       PRV_ERROR   := SQLERRM;
       PRV_MENSAJE := substr(PRV_ERROR,1,255) || ' -- SP_REP_COMPARATIVO_CONTROL_71_RCD';
       PRN_RETURN  := -1;
       UTL_FILE.FCLOSE(lutl_file_lista_comparativo);

   WHEN UTL_FILE.INVALID_PATH THEN
       ROLLBACK;
       DBMS_OUTPUT.PUT_LINE('UTL_FILE: Ruta no valida');
       PRV_ERROR   := SQLERRM;
       PRV_MENSAJE := substr(PRV_ERROR,1,255) || ' -- SP_REP_COMPARATIVO_CONTROL_71_RCD';
       PRN_RETURN  := -1;
       UTL_FILE.FCLOSE(lutl_file_lista_comparativo);

   WHEN UTL_FILE.READ_ERROR THEN
       ROLLBACK;
       DBMS_OUTPUT.PUT_LINE('UTL_FILE: Error en lectura');
       PRV_ERROR   := SQLERRM;
       PRV_MENSAJE := substr(PRV_ERROR,1,255) || ' -- SP_REP_COMPARATIVO_CONTROL_71_RCD';
       PRN_RETURN  := -1;
       UTL_FILE.FCLOSE(lutl_file_lista_comparativo);

   WHEN UTL_FILE.WRITE_ERROR THEN
       ROLLBACK;
       DBMS_OUTPUT.PUT_LINE('UTL_FILE: Error en escritura');
       PRV_ERROR   := SQLERRM;
       PRV_MENSAJE := substr(PRV_ERROR,1,255) || ' -- SP_REP_COMPARATIVO_CONTROL_71_RCD';
       PRN_RETURN  := -1;
       UTL_FILE.FCLOSE(lutl_file_lista_comparativo);

   WHEN UTL_FILE.INVALID_MODE THEN
       ROLLBACK;
       DBMS_OUTPUT.PUT_LINE('UTL_FILE: Error en modo de acceso');
       PRV_ERROR   := SQLERRM;
       PRV_MENSAJE := substr(PRV_ERROR,1,255) || ' -- SP_REP_COMPARATIVO_CONTROL_71_RCD';
       PRN_RETURN  := -1;
       UTL_FILE.FCLOSE(lutl_file_lista_comparativo);

   WHEN UTL_FILE.INVALID_FILEHANDLE THEN
       ROLLBACK;
       DBMS_OUTPUT.PUT_LINE('UTL_FILE: Error ');
       PRV_ERROR   := SQLERRM;
       PRV_MENSAJE := substr(PRV_ERROR,1,255) || ' -- SP_REP_COMPARATIVO_CONTROL_71_RCD';
       PRN_RETURN  := -1;
       UTL_FILE.FCLOSE(lutl_file_lista_comparativo);

   WHEN UTL_FILE.INVALID_OPERATION THEN
       ROLLBACK;
       DBMS_OUTPUT.PUT_LINE('UTL_FILE: Error ');
       PRV_ERROR   := SQLERRM;
       PRV_MENSAJE := substr(PRV_ERROR,1,255) || ' -- SP_REP_COMPARATIVO_CONTROL_71_RCD';
       PRN_RETURN  := -1;
       UTL_FILE.FCLOSE(lutl_file_lista_comparativo);

   WHEN UTL_FILE.INVALID_MAXLINESIZE THEN
       ROLLBACK;
       DBMS_OUTPUT.PUT_LINE('UTL_FILE: Error ');
       PRV_ERROR   := SQLERRM;
       PRV_MENSAJE := substr(PRV_ERROR,1,255) || ' -- SP_REP_COMPARATIVO_CONTROL_71_RCD';
       PRN_RETURN  := -1;
       UTL_FILE.FCLOSE(lutl_file_lista_comparativo);

   WHEN UTL_FILE.INTERNAL_ERROR THEN
       ROLLBACK;
       DBMS_OUTPUT.PUT_LINE('UTL_FILE: Error ');
       PRV_ERROR   := SQLERRM;
       PRV_MENSAJE := substr(PRV_ERROR,1,255) || ' -- SP_REP_COMPARATIVO_CONTROL_71_RCD';
       PRN_RETURN  := -1;
       UTL_FILE.FCLOSE(lutl_file_lista_comparativo);

  WHEN OTHERS THEN
       -- Actualizar estado de este proceso y colocarlo en error.
       -- Actualiza Observaciones del Sistema.
       UTL_FILE.FCLOSE(lutl_file_lista_comparativo);
       PRV_ERROR   := SQLERRM;
       PRV_MENSAJE := substr(PRV_ERROR,1,255) || ' -- SP_REP_COMPARATIVO_CONTROL_71_RCD';
       PRN_RETURN  := -1;

END SP_REP_COMPARAT_CONTROL_71_RCD;

----------------------------------------------------

PROCEDURE SP_REP_COMPARAT_CONTROL_71_RCA
        ( pv_ano_refer    xcri_altas_val_asig_codsbs_fv.ano_refer%type,
         pv_mes_refer     xcri_altas_val_asig_codsbs_fv.mes_refer%type,
         pv_cod_reporte   xcri_altas_val_asig_codsbs_fv.cod_reporte%type,
         pv_cod_empresa   xcri_altas_val_asig_codsbs_fv.cod_empresa%type,
         pv_usuario       xcri_altas_val_asig_codsbs_fv.cod_usu_proc%type,
         pn_control       cra_val_controles_rcd_x_sec.cod_control%type,
         pv_dia_refer     IN xcri_altas_val_asig_codsbs_fv.dia_refer%type default '01',
         pv_cod_sec_envio IN xcri_altas_val_asig_codsbs_fv.cod_sec_envio%type default '01'
         )
IS
---------------------
--       Autor                     Fecha         Software
--       Francisco Vite Shelton    26/04/2006    Oracle 8i
---------------------
--       Parametros
--           pv_ano_refer   :  Año de referencia.
--           pv_mes_refer   :  Mes de referencia.
--           pv_cod_reporte :  Codigo reporte a cargar (RCD/RTC)
--           pv_cod_empresa :  Codigo de la Entidad.
--           pv_usuario     : Usuario que ejecuta el proceso.
---------------------
--       Descripcion
--        Genera el archivo comparativo para los deudores que presentan el control 71.
--        Este reporte se obtiene para que el analista DERC desde un archivo Excel, si lo desea, pueda verificar los nombres de los deudores que se encuentran observados.
--        Asimismo, si desea y tomando las consideraciones del caso esta data puede ser compartida con las entidades del sistema.
--        Este procedimiento se ejecuta al final del proceso de altas.
---------------------
-- Ejecucion
--  PK_XCRI_ALTAS_VAL_ASIG_CODSBS.SP_REP_COMPARATIVO_CONTROL_71 ('2006','03','RCD','00159','FVITES',71);
---------------------

-- Datos de la entidad
CURSOR cur_entidad IS
Select chr(9) || pv_cod_empresa || ' - ' || e.nom_ent_vig_corto
    || chr(9)
    || chr(9) || 'Periodo: ' || pv_ano_refer  || ' - ' || pv_mes_refer
    as entidad
from ays_ent_vigilada e
where e.cod_ent_vig = pv_cod_empresa;

-- Cabecera del resultado del filtro
CURSOR cur_cabecera_comp_control_71 IS
Select     '#'
||chr(9)|| 'NUM SEC'
||chr(9)|| 'TIPO REG'
||chr(9)|| 'TIP DOC IDEN'
||chr(9)|| 'NUM DOC IDEN'
||chr(9)|| 'COD_SBS'
||chr(9)|| 'DESC_PERSONA'
||chr(9)|| 'TIP PERSONA'
||chr(9)|| 'TIP VALIDACION'
||chr(9)|| 'TIP CONDICION'
 as cabecera
from dual;

---------------
-- TOTAL DEUDORES CONTROL 71
CURSOR cur_total_deudores_por_control IS
 SELECT count(1) AS total_deudores
  FROM cra_val_controles_x_sec c, cra_valid_identif i
 WHERE c.cod_reporte = pv_cod_reporte
   AND c.ano_refer   = pv_ano_refer
   AND c.mes_refer   = pv_mes_refer
   AND c.cod_empresa = pv_cod_empresa
   AND c.dia_refer     = pv_dia_refer
   AND c.cod_sec_envio = pv_cod_sec_envio
   AND c.cod_control = 71
   AND i.cod_reporte = pv_cod_reporte
   AND i.ano_refer   = pv_ano_refer
   AND i.mes_refer   = pv_mes_refer
   AND i.cod_empresa = c.cod_empresa
   and i.dia_refer     = c.dia_refer
   and i.cod_sec_envio = c.cod_sec_envio
   AND i.num_sec_reg = c.num_sec_reg;

----------------------
-- FVSH 20060426
-- LISTA DE DEDUORES DEL COMPARATIVO DEL CONTROL 71
-- ESTA LISTA CONTIENE DATOS REPORTADOS Y DATOS DEL MAESTRO SBS
-----------------------------
CURSOR cur_comparativo_control_71 IS
SELECT      v.num_orden,
            v.num_sec
||chr(9)||  v.tipo_reg
||chr(9)||  v.tip_doc
||chr(9)||  v.num_doc
||chr(9)||  v.cod_sbs
||chr(9)||  v.nombre
||chr(9)||  v.tip_persona
||chr(9)||  v.tip_valid
||chr(9)||  v.tip_condicion
as deudor
From
-------------------  -------------------  -------------------
(
select rownum as num_orden
      ,f.num_sec
      ,f.tipo_reg
      ,f.tip_doc
      ,f.num_doc
      ,f.cod_sbs
      ,f.nombre
      ,f.tip_persona
      ,f.tip_valid
      ,f.tip_condicion
  from
      (
      ----------------------------    ----------------------------
      --- DEUDORES REPORTADOS Y OBSERVADOS CON EL CONTROL 71
      ----------------------------    ----------------------------
       SELECT i.num_sec_reg  as num_sec
             ,'REP' as tipo_reg
             ,i.tip_doc_iden  as tip_doc
             ,i.num_doc_iden  as num_doc
             ,nvl(to_number(i.cod_sbs),null) as cod_sbs
             ,trim(TRIM(trim(i.nom_cliente) || ' ' || trim(i.ape_materno)) || ' ' ||  trim(i.ape_casada))
              || ' ' || trim(trim(i.primer_nombre) || ' ' || trim(i.segundo_nombre)) as nombre
             ,i.tip_persona
             ,'' as tip_valid
             ,'' as tip_condicion
        FROM cra_val_controles_x_sec c, cra_valid_identif i
       WHERE c.cod_reporte = pv_cod_reporte
         AND c.ano_refer   = pv_ano_refer
         AND c.mes_refer   = pv_mes_refer
         AND c.cod_empresa = pv_cod_empresa
         AND c.dia_refer     = pv_dia_refer
         AND c.cod_sec_envio = pv_cod_sec_envio
         AND c.cod_control = 71
         AND i.cod_reporte = pv_cod_reporte
         AND i.ano_refer   = pv_ano_refer
         AND i.mes_refer   = pv_mes_refer
         AND i.cod_empresa = c.cod_empresa
         AND i.dia_refer     = c.dia_refer
         AND i.cod_sec_envio = c.cod_sec_envio
         AND i.num_sec_reg = c.num_sec_reg
      ----------------------------    ----------------------------
      UNION
      ----------------------------    ----------------------------
      --- DATOS MAESTRO POR TIPO Y NUMERO DE DOCUMENTO y COD SBS
      ----------------------------    ----------------------------
      Select t.num_sec
             ,'' as tipo_reg
             ,a.tip_docto_ident    as tip_doc
             ,a.num_docto_ident    as num_doc
             ,a.cod_sbs
             ,trim(TRIM(trim(a.ape_paterno) || ' ' || trim(a.ape_materno)) || ' ' ||  trim(a.ape_casada))
              || ' ' || trim(trim(a.nom_persona) || ' ' || trim(a.segundo_nombre)) as nombre
             ,pk_xcri_altas_val_asig_codsbs.SF_OBT_DATOS_CRI_PERSONA(a.cod_sbs,'tip_persona') as tip_persona
             ,pk_xcri_altas_val_asig_codsbs.SF_OBT_DATOS_CRI_PERSONA(a.cod_sbs,'tip_reg_mv') as tip_valid
             ,pk_xcri_altas_val_asig_codsbs.SF_OBT_DATOS_CRI_PERSONA(a.cod_sbs,'tip_condicion') as tip_condicion
        From CRI_PERSONA_NAT A
            ,(   --- TOTAL DEUDORES OBSERVADOS CON EL CONTROL 71
                 SELECT i.cod_empresa
                       ,i.num_sec_reg  as num_sec
                       ,'REP' as tipo_reg
                       ,i.tip_doc_iden  as tip_doc
                       ,i.num_doc_iden  as num_doc
                       ,i.cod_sbs
                       ,trim(TRIM(trim(i.nom_cliente) || ' ' || trim(i.ape_materno)) || ' ' ||  trim(i.ape_casada))
                        || ' ' || trim(trim(i.primer_nombre) || ' ' || trim(i.segundo_nombre)) as nombre
                       ,i.tip_persona
                       ,'' as tip_valid
                       ,'' as tip_condicion
                  FROM cra_val_controles_x_sec c, cra_valid_identif i
                 WHERE c.cod_reporte = pv_cod_reporte
                   AND c.ano_refer   = pv_ano_refer
                   AND c.mes_refer   = pv_mes_refer
                   AND c.cod_empresa = pv_cod_empresa
                   AND c.dia_refer     = pv_dia_refer
                   AND c.cod_sec_envio = pv_cod_sec_envio
                   AND c.cod_control = 71
                   AND i.cod_reporte = pv_cod_reporte
                   AND i.ano_refer   = pv_ano_refer
                   AND i.mes_refer   = pv_mes_refer
                   AND i.cod_empresa = c.cod_empresa
                   AND i.dia_refer     = c.dia_refer
                   AND i.cod_sec_envio = c.cod_sec_envio
                   AND i.num_sec_reg = c.num_sec_reg
                 ORDER BY i.cod_empresa,i.num_sec_reg,i.tip_doc_iden asc, i.num_doc_iden
             )t
       Where ( A.tip_docto_ident = t.tip_doc And A.num_docto_ident = t.num_doc ) OR A.COD_SBS = t.cod_sbs
      -------------------  -------------------  -------------------
) F
order by f.num_sec asc, f.tipo_reg asc,f.tip_doc asc, f.num_doc asc, f.cod_sbs asc
) V
order by v.num_orden asc;

lv_ruta                        VARCHAR2(120);
lv_filename_lista_comparativo  VARCHAR2(120);
lutl_file_lista_comparativo    UTL_FILE.FILE_TYPE;
ln_num_reg_sal                 NUMBER;
lv_reg_cab_comparativo         VARCHAR2(500);

BEGIN
  -- Inicio: Generando archivo de comparativo 71
  IF pn_control <> 71 THEN
     RETURN;
  END IF;

  ln_num_reg_sal := 0;
  -- Verifica si existen registros para generar archivo
  FOR cur_count IN cur_total_deudores_por_control LOOP
      ln_num_reg_sal  := cur_count.total_deudores;
      Exit;
  END LOOP;

  IF nvl(ln_num_reg_sal,0) <= 0 THEN
     RETURN;               -- No existen registros en el control 71
  END IF;

  ---------------------------------------------------------
  ----  Inicia proceso para generar el archivo comparativo control 71
  ---------------------------------------------------------

--     lv_filename_lista_aproximados := 'Lista_aproxm_';
  lv_filename_lista_comparativo := 'Lst_ctrl_071_';
  lv_filename_lista_comparativo :=  lv_filename_lista_comparativo || pv_cod_reporte || pv_ano_refer || pv_mes_refer || '_' || pv_cod_empresa || '.xls';
  lv_ruta      := SF_ALTAS_RUTA_FILE_UNIX (pv_usuario, lv_filename_lista_comparativo, 'C' );

  -- Abriendo el Archivo Comparativo
  lutl_file_lista_comparativo   := UTL_FILE.FOPEN (lv_ruta, lv_filename_lista_comparativo, 'W');
  lv_reg_cab_comparativo      := '';

  -- Almacenando informacion en el Registro comparativo
  -- Registro de cabecera
  ln_num_reg_sal := 0;
  UTL_FILE.PUT_LINE (lutl_file_lista_comparativo, chr(13));

  FOR cur_ent IN cur_entidad LOOP
      lv_reg_cab_comparativo  := cur_ent.entidad;
      ln_num_reg_sal := ln_num_reg_sal + 1 ;
  END LOOP;

  UTL_FILE.PUT_LINE (lutl_file_lista_comparativo, chr(13));
  UTL_FILE.PUT_LINE (lutl_file_lista_comparativo, lv_reg_cab_comparativo ||chr(13));
  UTL_FILE.PUT_LINE (lutl_file_lista_comparativo, chr(13));
  UTL_FILE.PUT_LINE (lutl_file_lista_comparativo, chr(13));

  FOR cur_cab IN cur_cabecera_comp_control_71 LOOP
      lv_reg_cab_comparativo  := cur_cab.cabecera;
      ln_num_reg_sal := ln_num_reg_sal + 1 ;
  END LOOP;

  UTL_FILE.PUT_LINE (lutl_file_lista_comparativo, lv_reg_cab_comparativo ||chr(13));

  FOR cur_deud IN cur_comparativo_control_71 LOOP
      lv_reg_cab_comparativo  := cur_deud.num_orden || CHR(9) || cur_deud.deudor;
      ln_num_reg_sal := ln_num_reg_sal + 1 ;
      UTL_FILE.PUT_LINE (lutl_file_lista_comparativo, lv_reg_cab_comparativo ||chr(13));
  END LOOP;

  -- Cierra los archivos
  UTL_FILE.FCLOSE(lutl_file_lista_comparativo);
  --  UTL_FILE.FCLOSE_ALL;

  -- Finaliza OK
  DBMS_OUTPUT.PUT_LINE ('Final : '||to_char(sysdate,'yyyy-mm-dd hh24:mi:ss'));

  --------------------------------------------
  --  Fin: Generando archivo Comparativo   ---
  --------------------------------------------
RETURN;

 EXCEPTION
   WHEN NO_DATA_FOUND THEN
       ROLLBACK;
       DBMS_OUTPUT.PUT_LINE('Fin de registro');
       PRV_ERROR   := SQLERRM;
       PRV_MENSAJE := substr(PRV_ERROR,1,255) || ' -- SP_REP_COMPARATIVO_CONTROL_71_RCA';
       PRN_RETURN  := -1;
       UTL_FILE.FCLOSE(lutl_file_lista_comparativo);

   WHEN UTL_FILE.INVALID_PATH THEN
       ROLLBACK;
       DBMS_OUTPUT.PUT_LINE('UTL_FILE: Ruta no valida');
       PRV_ERROR   := SQLERRM;
       PRV_MENSAJE := substr(PRV_ERROR,1,255) || ' -- SP_REP_COMPARATIVO_CONTROL_71_RCA';
       PRN_RETURN  := -1;
       UTL_FILE.FCLOSE(lutl_file_lista_comparativo);

   WHEN UTL_FILE.READ_ERROR THEN
       ROLLBACK;
       DBMS_OUTPUT.PUT_LINE('UTL_FILE: Error en lectura');
       PRV_ERROR   := SQLERRM;
       PRV_MENSAJE := substr(PRV_ERROR,1,255) || ' -- SP_REP_COMPARATIVO_CONTROL_71_RCA';
       PRN_RETURN  := -1;
       UTL_FILE.FCLOSE(lutl_file_lista_comparativo);

   WHEN UTL_FILE.WRITE_ERROR THEN
       ROLLBACK;
       DBMS_OUTPUT.PUT_LINE('UTL_FILE: Error en escritura');
       PRV_ERROR   := SQLERRM;
       PRV_MENSAJE := substr(PRV_ERROR,1,255) || ' -- SP_REP_COMPARATIVO_CONTROL_71_RCA';
       PRN_RETURN  := -1;
       UTL_FILE.FCLOSE(lutl_file_lista_comparativo);

   WHEN UTL_FILE.INVALID_MODE THEN
       ROLLBACK;
       DBMS_OUTPUT.PUT_LINE('UTL_FILE: Error en modo de acceso');
       PRV_ERROR   := SQLERRM;
       PRV_MENSAJE := substr(PRV_ERROR,1,255) || ' -- SP_REP_COMPARATIVO_CONTROL_71_RCA';
       PRN_RETURN  := -1;
       UTL_FILE.FCLOSE(lutl_file_lista_comparativo);

   WHEN UTL_FILE.INVALID_FILEHANDLE THEN
       ROLLBACK;
       DBMS_OUTPUT.PUT_LINE('UTL_FILE: Error ');
       PRV_ERROR   := SQLERRM;
       PRV_MENSAJE := substr(PRV_ERROR,1,255) || ' -- SP_REP_COMPARATIVO_CONTROL_71_RCA';
       PRN_RETURN  := -1;
       UTL_FILE.FCLOSE(lutl_file_lista_comparativo);

   WHEN UTL_FILE.INVALID_OPERATION THEN
       ROLLBACK;
       DBMS_OUTPUT.PUT_LINE('UTL_FILE: Error ');
       PRV_ERROR   := SQLERRM;
       PRV_MENSAJE := substr(PRV_ERROR,1,255) || ' -- SP_REP_COMPARATIVO_CONTROL_71_RCA';
       PRN_RETURN  := -1;
       UTL_FILE.FCLOSE(lutl_file_lista_comparativo);

   WHEN UTL_FILE.INVALID_MAXLINESIZE THEN
       ROLLBACK;
       DBMS_OUTPUT.PUT_LINE('UTL_FILE: Error ');
       PRV_ERROR   := SQLERRM;
       PRV_MENSAJE := substr(PRV_ERROR,1,255) || ' -- SP_REP_COMPARATIVO_CONTROL_71_RCA';
       PRN_RETURN  := -1;
       UTL_FILE.FCLOSE(lutl_file_lista_comparativo);

   WHEN UTL_FILE.INTERNAL_ERROR THEN
       ROLLBACK;
       DBMS_OUTPUT.PUT_LINE('UTL_FILE: Error ');
       PRV_ERROR   := SQLERRM;
       PRV_MENSAJE := substr(PRV_ERROR,1,255) || ' -- SP_REP_COMPARATIVO_CONTROL_71_RCA';
       PRN_RETURN  := -1;
       UTL_FILE.FCLOSE(lutl_file_lista_comparativo);

  WHEN OTHERS THEN
       -- Actualizar estado de este proceso y colocarlo en error.
       -- Actualiza Observaciones del Sistema.
       UTL_FILE.FCLOSE(lutl_file_lista_comparativo);
       PRV_ERROR   := SQLERRM;
       PRV_MENSAJE := substr(PRV_ERROR,1,255) || ' -- SP_REP_COMPARATIVO_CONTROL_71_RCA';
       PRN_RETURN  := -1;

END SP_REP_COMPARAT_CONTROL_71_RCA;

----------------------------------------------------

-- Obtiene datos de un deudor de la tabla CRI_PERSONA
FUNCTION  SF_OBT_DATOS_CRI_PERSONA
        ( pn_cod_sbs xcri_altas_val_asig_codsbs_fv.cod_sbs%type, pv_campo VARCHAR2 )
RETURN VARCHAR2 IS
---------------------
--       Autor                     Fecha         Software
--       Francisco Vite Shelton    17/03/2006    Oracle 8i
---------------------
--       Parametros
--           pn_cod_sbs : Código SBS del usuario
--           pv_campo   : Nombre del campo a buscar
---------------------
--       Descripcion
--         Funcion que retorna el valor de un campo del maestro de personas CRI_PERSONA.
---------------------
lv_return      VARCHAR2(120);

---- CURSOR CON LOS DATOS DE LAS PERSONA
CURSOR cur_cri_persona IS
 select p.tip_reg_mv
       ,p.tip_persona
       ,p.tip_condicion
   from cri_persona p
  where p.cod_sbs = pn_cod_sbs ;

BEGIN
 lv_return := null;

 FOR cur_datos in cur_cri_persona LOOP
     IF lower(pv_campo) = 'tip_reg_mv' THEN
        lv_return := cur_datos.tip_reg_mv;
     END IF;

     IF lower(pv_campo) = 'tip_persona' THEN
        lv_return := cur_datos.tip_persona;
     END IF;

     IF lower(pv_campo) = 'tip_condicion' THEN
        lv_return := cur_datos.tip_condicion;
     END IF;
 END LOOP;

 RETURN lv_return;

EXCEPTION
  WHEN OTHERS THEN
    PRV_ERROR   := SQLERRM;
    PRV_MENSAJE := substr(PRV_ERROR,1,255) || ' -- SF_OBT_DATOS_CRI_PERSONA';
    PRN_RETURN  := -1;
    RETURN '';
END SF_OBT_DATOS_CRI_PERSONA;

----------------------------------------------------

PROCEDURE SP_GENERA_FILE_ALTAS
    (pv_ano_refer     xcri_altas_val_asig_codsbs_fv.ano_refer%type,
     pv_mes_refer     xcri_altas_val_asig_codsbs_fv.mes_refer%type,
     pv_cod_reporte   xcri_altas_val_asig_codsbs_fv.cod_reporte%type,
     pv_cod_empresa   xcri_altas_val_asig_codsbs_fv.cod_empresa%type,
     pv_usuario       xcri_altas_val_asig_codsbs_fv.cod_usu_proc%type,
     pv_dia_refer     IN xcri_altas_val_asig_codsbs_fv.dia_refer%type default '01',
     pv_cod_sec_envio IN xcri_altas_val_asig_codsbs_fv.cod_sec_envio%type default '01',
     ov_mensaje       OUT VARCHAR2,
     on_return        OUT NUMBER )
IS
---------------------
--       Autor                     Fecha         Software
--       Francisco Vite Shelton    28/05/2008    Oracle 8i
---------------------
--       Parametros
--           pv_ano_refer   :  Año de referencia.
--           pv_mes_refer   :  Mes de referencia.
--           pv_cod_reporte :  Codigo reporte a cargar (RCD/RTC)
--           pv_cod_empresa :  Codigo de la Entidad.
--           pv_usuario     : Usuario que ejecuta el proceso.
--           ov_mensaje     : Retorna el mensaje de ocurrir alguna observacion.
--           on_return      : Retorna el codigo de error
--                            -1 : Error
--                             1 : OK
---------------------
--       Descripcion
--        Procedimiento que realiza la generacion de los archivos del proceso de Altas. Proporcionar valores de retorno que indicaran el exito o no del proceso.
--        Este procesos se genera de manera especial, contingencia ante eventos de error en la generacion de archivos durante la ejecucion del proceso principal
---------------------
-- Ejecucion
--  PK_XCRI_ALTAS_VAL_ASIG_CODSBS.SP_GENERA_FILE_ALTAS ('2004','04','RCD','00102','FVITES');
---------------------

lv_ruta                  VARCHAR2(120);
lv_filename_filtro_altas  VARCHAR2(120);
lutl_file_filtro_altas   UTL_FILE.FILE_TYPE;

BEGIN
   PRV_MENSAJE := '';
   PRN_RETURN  := 1;
   dbms_output.put_line ('Inicio');

    /*-- Genera el Archivo de Dudas --*/
    SP_POST_ALTA_GENE_FILE_APX_DUD ( pv_ano_refer, pv_mes_refer, pv_cod_reporte, pv_cod_empresa, pv_usuario, PRV_ESTADO_DUDA, pv_dia_refer, pv_cod_sec_envio );
      dbms_output.put_line ('Dudas');
      ov_mensaje := PRV_MENSAJE;
      on_return  := PRN_RETURN;

   IF PRN_RETURN = 1 THEN
      /*-- Genera el Archivo de Aproximados --*/
       SP_POST_ALTA_GENE_FILE_APX_DUD ( pv_ano_refer, pv_mes_refer, pv_cod_reporte, pv_cod_empresa, pv_usuario, PRV_ESTADO_APROXIMADO, pv_dia_refer, pv_cod_sec_envio );
         dbms_output.put_line ('Aproximados');
         ov_mensaje := PRV_MENSAJE;
         on_return  := PRN_RETURN;
   END IF;

   IF PRN_RETURN = 1 THEN
      /*-- Genera el Archivo del comparativo del control 71 --*/
      SP_REP_COMPARATIVO_CONTROL_71 ( pv_ano_refer, pv_mes_refer, pv_cod_reporte, pv_cod_empresa, pv_usuario, 71, pv_dia_refer, pv_cod_sec_envio );
      dbms_output.put_line ('Control 71');
      ov_mensaje := PRV_MENSAJE;
      on_return  := PRN_RETURN;
   END IF;

   dbms_output.put_line ('Fin');

   IF PRN_RETURN <> 1 THEN
      -- Genera un archivo excel
      lv_filename_filtro_altas := 'Filtro_altas_aux_';
      lv_filename_filtro_altas :=   lv_filename_filtro_altas || pv_cod_reporte || pv_ano_refer || pv_mes_refer || '_' || pv_cod_empresa || '.xls';
      lv_ruta      := SF_ALTAS_RUTA_FILE_UNIX ( pv_usuario, lv_filename_filtro_altas, 'C' );

      -- renombra archivo
      lv_filename_filtro_altas :=  'OBS_' || lv_filename_filtro_altas ;
      -- Abriendo el Archivo de salida
      lutl_file_filtro_altas   := UTL_FILE.FOPEN (lv_ruta, lv_filename_filtro_altas, 'W');

      -- Almacenando informacion en el Registro de salida
      UTL_FILE.PUT_LINE (lutl_file_filtro_altas, chr(13));
      UTL_FILE.PUT_LINE (lutl_file_filtro_altas, ov_mensaje ||chr(13));

      -- Cierra los archivos
      UTL_FILE.FCLOSE(lutl_file_filtro_altas);
  END IF;

  RETURN;

  -- Control de Errores
  EXCEPTION
    WHEN OTHERS THEN
      -- Actualizar estado de este proceso y colocarlo en error
      -- Actualiza Observaciones del Sistema
      PRV_ERROR   := SQLERRM;
      PRV_MENSAJE := substr(PRV_ERROR,1,255) || ' -- SP_GENERA_FILE_ALTAS';
      PRN_RETURN  := -1;
      UTL_FILE.FCLOSE(lutl_file_filtro_altas);
      RETURN;

END SP_GENERA_FILE_ALTAS;

end ;
