use cob_cuentas
go

if exists (select 1 from sysobjects where name = 'sp_cc_cuenta')
begin
   drop proc sp_cc_cuenta
end
go

/*<summary>

Realiza consultas sobre maestro de cuentas corrientes, obteniendo datos generales, datos monetarios
y no monetarios sobre una cuenta.
Ademas realiza  consultas  de  Propietarios  de  Cuenta  y  Cuentas  en base a Clientes o Paquetes.

Nombre Fisico: cc_cuenta.sp

</summary>*/

/*<historylog>
<log LogType="Refactor" revision="1.0" date="12/06/2008" email="alejandro.cerrato@accusys.com.ar">Emision Inicial</log>
<log LogType="Refactor" revision="2.0" date="27/07/2010" email="matias.altamirano@accusys.com.ar">AST 6225-Se incorporo una busqueda a @i_operacion = 'C'.@i_tipo_operacion = "B" = CONSULTA CUENTAS EN BASE A CLIENTE-MONEDA-PRODUCTO</log>
<log LogType="Refactor" revision="3.0" date="30/10/2015" email="diana.diaz@accusys.com.ar">AST-29394</log>
<log LogType="Refactor" revision="4.0" date="06/06/2017" email="mauricio.kranevitter@accusys.com.ar"> AST 38997 </log>
<log LogType="Refactor" revision="5.0" date="18/09/2020" email="alejandro.assan@accusys.com.ar">AST 58276</log>
<log LogType="Refactor" revision="6.0" date="20/10/2021" email="massimo.quirolo@accusys.com.ar">AST 63950</log>
<log LogType="Refactor" revision="7.0" date="20/05/2024" email="nicolas.leszczynski@accusys.com.ar">AST 108621</log>
</historylog>*/

create proc sp_cc_cuenta(
--</parameters>
/**************************************************************************************************************/
/**************************************************************************************************************/
/*                            PARAMETROS DE INGRESO AL SP:                                                    */
/*        LAS BUSQUEDAS SE REALIZAN SEGUN LAS OPERACIONES,  DE AHI SALEN DIFERENTES TIPOS DE BUSQUEDA         */
/**************************************************************************************************************/
/**************************************************************************************************************/
/**** OPERACION:                                                                                              */
/*    @i_operacion = "S" = BUSQUEDA EN BASE A UNA CUENTA                                                      */
/**** OPCIONES:                                                                                               */
/*     1) @i_tipo_operacion = "M" = CONSULTA DE DATOS MONETARIOS                                              */
/*                          = "D" = CONSULTA DE DATOS GENERALES                                               */
/*                          = "C" = CONSULTA DE DESCUBIERTOS Y CHEQUES                                        */
/*                          = "T" = CONSULTA DE TODOS LOS DATOS(SOLO PARA BACK END)                           */
/*       @i_opcion          = "G" = CONSULTA GRILLA DE DESCUBIERTOS(SOLO PARA @i_tipo_operacion = "C")        */
/*                            "C" = CONSULTA INFORMACION DE CHEQUES(SOLO PARA @i_tipo_operacion = "C")        */
/*       @i_tipo_consulta   = "R" = CONSULTA DATOS CUENTA CORRIENTE(VERSION RESUMIDA)(SOLO FRONT END)         */
/*                            "A" = CONSULTA DATOS CUENTA CORRIENTE(VERSION COMPLETA)(DEFAULT)SOLO FRONT END) */
/*    2) @i_tipo_operacion  = "P" = CONSULTA DE DATOS PERSONALIZADOS                                          */
/*    3) @i_tipo_operacion  = "Z" = CONSULTA DE PROPIETARIOS EN BASE A UNA CUENTA                             */
/*       @i_opcion          = "G" = OPCION GRILLA                                                             */
/*                            "L" = OPCION LOTFOCUS                                                           */
/**************************************************************************************************************/
/**** OPERACION:                                                                                              */
/*   @i_operacion = "C" = BUSQUEDA EN BASE A UN CLIENTE O CUENTA                                              */
/**** OPCIONES:                                                                                               */
/*     1)@i_tipo_operacion = "I" = CONSULTA CUENTAS EN BASE A CLIENTE                                         */
/*       @i_opcion         = "G" = OPCION GRILLA                                                              */
/*                           "L" = OPCION LOTFOCUS                                                            */
/*     2)@i_tipo_operacion = "A" = CONSULTA CUENTAS EN BASE A CLIENTE, PERO PARA AMBOS PRODUCTOS              */
/*       @i_opcion         = "G" = OPCION GRILLA                                                              */
/*                           "L" = OPCION LOTFOCUS                                                            */
/*                           "R" = OPCION DE SERVICIO TOPAZ                                                   */
/*     3)@i_tipo_operacion = "B" = CONSULTA CUENTAS EN BASE A CLIENTE-MONEDA-PRODUCTO                         */
/*       @i_opcion         = "G" = OPCION GRILL                                                               */
/**************************************************************************************************************/
/**** OPERACION:                                                                                              */
/*   @i_operacion = "P" = BUSQUEDA EN BASE A UN PAQUETE                                                       */
/**** OPCIONES:                                                                                               */
/*       @i_tipo_operacion = "C" = CONSULTA DE CUENTAS PERTENECIENTES A UN PAQUETE                            */
/*       @i_opcion         = "G" = OPCION GRILLA                                                              */
/*                           "L" = OPCION DE VALIDACION DE CUENTA + PAQUETE                                   */
/**************************************************************************************************************/
/**** LLAMADO, PARA TODAS LAS OPERACIONES:                                                                    */
/*   @i_quien_llama    = "B" = CONSULTA DE [B] BACK END                                                       */
/*                     = "F" = CONSULTA DE [F] FRONT END (DEFAULT) -- GRILLA - VECTOR                         */
/**************************************************************************************************************/
@s_ssn                          int            = null,               --<param required ="no"  description="Numero secuencial unico dado por el monitor transaccional para la transaccion."/>
@s_srv                          varchar(64)    = null,               --<param required ="no"  description="Nombre del servidor donde se origina la transaccion."/>
@s_term                         varchar(10)    = null,               --<param required ="no"  description="Nombre o identificacion de la terminal donde se ejecuto la transaccion."/>
@s_user                         varchar(30)    = null,               --<param required ="no"  description="Nombre del Usuario registrado que ejecuta la transaccion (login)."/>
@s_ofi                          smallint       = null,               --<param required ="no"  description="Numero de la oficina donde se encuentra registrado el usuario que ejecuta la transaccion."/>
@s_date                         datetime       = null,               --<param required ="no"  description="Fecha de proceso del servidor en que se ejecuta la transaccion."/>
@t_debug                        char(1)        = 'N',                --<param required ="no"  description="Indica si la transaccion debe ser ejecutada en modo de depuracion: [S]i  [N]o"/>
@t_file                         varchar(14)    = null,               --<param required ="no"  description="Nombre del archivo que contendra los resultados enviados en modo de debug."/>
@t_from                         varchar(32)    = null,               --<param required ="no"  description="Stored Procedure desde el que fue llamado el programa actual."/>
/* PARAMETROS DE INGRESO */
@t_trn                          smallint,                            --<param required ="yes" description="codigo unico de transaccion cobis."/>
@i_operacion                    char(1),                             --<param required ="yes" description="Tipo de Operacion."/>
@i_tipo_operacion               char(1)        = null,               --<param required ="no"  description="Sub-Tipo de Operacion."/>
@i_opcion                       char(1)        = 'G',                --<param required ="no"  description="Opcion de Ingreso."/>
@i_n_cta_banco                  cuenta         = null,               --<param required ="no"  description="Numero de cuenta banco."/>
@i_n_ctacte                     int            = null,               --<param required ="no"  description="Numero de cuenta banco corta."/>
@i_n_cliente                    int            = null,               --<param required ="no"  description="Numero de cliente."/>
@i_n_paquete                    int            = null,               --<param required ="no"  description="Numero de paquete."/>
@i_c_moneda                     tinyint        = null,               --<param required ="no"  description="Codigo de moneda."/>
@i_secuencial                   int            = 0,                  --<param required ="no"  description="Para grilla de sobregiros."/>
@i_quien_llama                  char(1)        = 'F',                --<param required ="no"  description="Por defualt front end [f] / [b] back end."/>
@i_tipo_consulta                char(1)        = 'A',                --<param required ="no"  description="por defualt consulta Ampliada [a] / [r] Resumida."/>
@i_formato_fecha                smallint       = 101,                --<param required ="no"  description="Formato de la Fecha, Sirve para Devolucion de Grilla."/>
@i_n_modulo                     tinyint        = null,               --<param required ="no"  description="Numero de Modulo Cobis que llama a este SP."/>
@i_n_producto_cobis             tinyint        = null,               --<param required ="no"  description="Numero producto cobis del cual se necesita informacion  / [3] o [4]."/>
@i_c_rol                        char(1)        = null,               --<param required ="no"  description="Rol opcional de busqueda"/>
@i_m_sin_comp_firm              char(1)        = null,               --<param required ="no"  description="Marca que indica que no se van a buscar clientes firmantes que tengan cuenta en compania."/>
@i_m_todos_roles                char(1)        = 'N',                --<param required ="no"  description="Marca que indica si se desean todos los roles o no: s[si]; n[no]."/>
@i_m_usa_moneda_local           char(1)        = 'N',                --<param required ="no"  description="Marca si se debe usar o no la moneda local. s[si]; n[no]."/>
@i_e_cuenta                     char(1)        = null,               --<param required ="no"  description="Si se manda esta variable, se devuelven el estado solicitado, caso contrario, todo"/>
@i_m_anula_paq                  char(1)        = 'S',                --<param required ="no"  description="MARCA SI SE DEBE ANULAR LA CONSULTA DE SALDO A GIRAR COMO PAQUETE. S[SI]; N[NO]."/>
@i_m_macro_adelanto             char(1)        = 'N',                --<param required ="no"  description="MARCA SI SE DEBE ANULAR LA CONSULTA DE CUENTAS CORRIENTES MACRO ADELANDO."/>
@i_n_filas                      tinyint        = 20,                 --<param required ="no" description="Cantidad de filas que devuelve."/>
@i_m_mesa_cambios               char(1)        = 'N',                --<param required ="no"  description="MARCA QUE INDICA SI ES LLAMADO DESDE MESA DE CAMBIOS."/>
@i_n_canal                      smallint       = null,               --<param required ="no"  description="NUMERO DE CANAL"/>
/* PARAMETROS DE SALIDA */
/* CONSULTA DE DATOS GENERALES */
@o_n_ctacte                     int            = null   out,         --<param required ="no"  description="Numero de Cuenta Corta."/>
@o_n_cta_banco                  varchar(16)    = null   out,         --<param required ="no"  description="Numero de Cuenta Banco."/>
@o_d_nombre                     varchar(64)    = null   out,         --<param required ="no"  description="Descripcion de Nombre de Cuenta."/>
@o_n_cliente                    int            = null   out,         --<param required ="no"  description="Numero de Cliente Titular."/>
@o_n_filial                     tinyint        = null   out,         --<param required ="no"  description="Numero de Filial."/>
@o_n_cbu                        varchar(22)    = null   out,         --<param required ="no"  description="Numero de CBU."/>
@o_n_cuit                       varchar(13)    = null   out,         --<param required ="no"  description="Numero de CUIT."/>
@o_c_oficial                    smallint       = null   out,         --<param required ="no"  description="Codigo de Oficial."/>
@o_d_oficial                    varchar(32)    = null   out,         --<param required ="no"  description="Descripcion de Codigo de Oficial."/>
@o_c_uso_firma                  varchar(3)     = null   out,         --<param required ="no"  description="Codigo de Uso Firma."/>
@o_d_uso_firma                  varchar(25)    = null   out,         --<param required ="no"  description="Descripcion de Codigo de Uso Firma."/>
@o_c_moneda                     tinyint        = null   out,         --<param required ="no"  description="Codigo de Moneda."/>
@o_d_moneda                     varchar(15)    = null   out,         --<param required ="no"  description="Descripcion de Codigo de Moneda."/>
@o_c_categoria                  varchar(3)     = null   out,         --<param required ="no"  description="Codigo de Categoria."/>
@o_d_categoria                  varchar(32)    = null   out,         --<param required ="no"  description="Descripcion de Codigo de Categoria."/>
@o_c_oficina                    smallint       = null   out,         --<param required ="no"  description="Codigo de Oficina."/>
@o_d_oficina                    varchar(32)    = null   out,         --<param required ="no"  description="Descripcion de Codigo de Oficina."/>
@o_c_producto                   tinyint        = null   out,         --<param required ="no"  description="Codigo de Producto."/>
@o_d_producto                   varchar(32)    = null   out,         --<param required ="no"  description="Descripcion de Codigo de Producto."/>
@o_c_prod_banc                  smallint       = null   out,         --<param required ="no"  description="Codigo de Producto Bancario."/>
@o_d_prod_banc                  varchar(32)    = null   out,         --<param required ="no"  description="Descripcion de Codigo de Producto Bancario."/>
@o_c_sector_BCRA                varchar(10)    = null   out,         --<param required ="no"  description="Codigo de Sector BCRA."/>
@o_d_sector_BCRA                varchar(32)    = null   out,         --<param required ="no"  description="Descripcion de Codigo de Sector BCRA."/>
@o_c_estado                     char(1)        = null   out,         --<param required ="no"  description="Estado de Cuenta."/>
@o_d_estado                     varchar(20)    = null   out,         --<param required ="no"  description="Deacripcion de Estado de Cuenta."/>
@o_f_apertura                   varchar(12)    = null   out,         --<param required ="no"  description="Fecha de Apertura de Cuenta."/>
@o_f_cierre                     varchar(12)    = null   out,         --<param required ="no"  description="Fecha de Cierre de Cuenta."/>
@o_c_residencia                 varchar(10)    = null   out,         --<param required ="no"  description="Codigo de Residencia."/>
@o_d_residencia                 varchar(32)    = null   out,         --<param required ="no"  description="Descripcion de Codigo de Residencia ."/>
@o_c_rol_ente                   char(1)        = null   out,         --<param required ="no"  description="Tipo de Rol."/>
@o_n_telefono                   varchar(12)    = null   out,         --<param required ="no"  description="Numero de Telefono."/>
@o_n_parroquia                  smallint       = null   out,         --<param required ="no"  description="Numero de Parroquia."/>
@o_c_tipocta                    char(1)        = null   out,         --<param required ="no"  description="Codigo de Tipo de Cuenta."/>
@o_d_tipocta                    varchar(32)    = null   out,         --<param required ="no"  description="Descripcion de Codigo de Tipo de Cuenta."/>
@o_m_tipo                       char(1)        = null   out,         --<param required ="no"  description="Marca de Tipo."/>
@o_m_man_firmas                 char(1)        = null   out,         --<param required ="no"  description="Marca de Mantenimiento de Firma."/>
@o_c_origen                     varchar(3)     = null   out,         --<param required ="no"  description="Codigo de Origen de Cuenta."/>
@o_m_solidaria                  tinyint        = null   out,         --<param required ="no"  description="Marca de Cuenta Solidaria."/>
/* CONSULTA DE DATOS MONETARIOS */
@o_i_remesas                    money          = null   out,         --<param required ="no"  description="Importe Remesas."/>
@o_i_remesas_hoy                money          = null   out,         --<param required ="no"  description="Importe Remesas Hoy."/>
@o_i_24h                        money          = null   out,         --<param required ="no"  description="Importe 24 horas."/>
@o_i_12h                        money          = null   out,         --<param required ="no"  description="Importe 12 horas."/>
@o_i_disponible                 money          = null   out,         --<param required ="no"  description="Importe Disponible de Cuenta."/>
@o_p_disponible                 money          = null   out,         --<param required ="no"  description="Promedio Disponible de Cuenta."/>
@o_i_saldo_contable             money          = null   out,         --<param required ="no"  description="Importe Saldo Contable."/>
@o_i_saldo_para_girar           money          = null   out,         --<param required ="no"  description="Importe Saldo a Girar."/>
@o_i_sobregiro_ocasional        money          = null   out,         --<param required ="no"  description="Importe de Sobregiro Ocasional."/>
@o_i_sobregiro_contratado       money          = null   out,         --<param required ="no"  description="Importe de Sobregiro Contratado."/>
@o_q_dias_sobregiro             smallint       = null   out,         --<param required ="no"  description="Cantidad de Dias Sobregiro."/>
@o_q_dias_sobregiro_cont        smallint       = null   out,         --<param required ="no"  description="Cantidad de Dias Sobregiro Contable."/>
@o_i_bloqueo_valores            money          = null   out,         --<param required ="no"  description="Importe de Bloqueos de Valores."/>
@o_m_bloqueos_valores           smallint       = null   out,         --<param required ="no"  description="Numero de Bloqueos de Valores."/>
@o_q_bloqueos_movimientos       smallint       = null   out,         --<param required ="no"  description="Cantidad de Bloqueos de Movimientos."/>
@o_f_ultimo_movimiento          varchar(12)    = null   out,         --<param required ="no"  description="Fecha de Ultimo Movimiento."/>
@o_f_ultimo_movim_int           varchar(12)    = null   out,         --<param required ="no"  description="Fecha de Ultimo Movimiento."/>
@o_f_ultima_actualizacion       varchar(12)    = null   out,         --<param required ="no"  description="Fecha de Ultima Actualizacion."/>
@o_p_contable_positivo          money          = null   out,         --<param required ="no"  description="Promedio Contable."/>
@o_i_creditos_mes               money          = null   out,         --<param required ="no"  description="Importe Credito Mes."/>
@o_i_creditos_hoy               money          = null   out,         --<param required ="no"  description="Importe Credito Hoy."/>
@o_i_debitos_mes                money          = null   out,         --<param required ="no"  description="Importe Debito Mes."/>
@o_i_debitos_hoy                money          = null   out,         --<param required ="no"  description="Importe Debito Hoy."/>
@o_i_saldo_ayer                 money          = null   out,         --<param required ="no"  description="Saldo de la Cuenta de Ayer."/>
@o_p_contable_negativo          money          = null   out,         --<param required ="no"  description="Promedio Contable Negativo."/>
@o_i_interes_deven              money          = null   out,         --<param required ="no"  description="Importe Interes Devengado."/>
@o_m_congelada                  catalogo       = null   out,         --<param required ="no"  description="Marca de Congelada."/>
@o_f_vencimiento_reduccion      varchar(12)    = null   out,         --<param required ="no"  description="Fecha de Vencimiento de Reduccion."/>
@o_i_saldo_6_meses              money          = null   out,         --<param required ="no"  description="Saldo de Los Ultimos 6 Meses."/>
@o_i_promedio1                  money          = null   out,         --<param required ="no"  description="Importe Promedio 1."/>
@o_i_promedio2                  money          = null   out,         --<param required ="no"  description="Importe Promedio 2."/>
@o_i_promedio3                  money          = null   out,         --<param required ="no"  description="Importe Promedio 3."/>
@o_i_promedio4                  money          = null   out,         --<param required ="no"  description="Importe Promedio 4."/>
@o_i_promedio5                  money          = null   out,         --<param required ="no"  description="Importe Promedio 5."/>
@o_i_promedio6                  money          = null   out,         --<param required ="no"  description="Importe Promedio 6."/>
@o_q_contador_trx               int            = null   out,         --<param required ="no"  description="Contador de Transacciones."/>
@o_q_contador_firma             int            = null   out,         --<param required ="no"  description="Contador de Firma."/>
@o_q_contador_deb               int            = null   out,         --<param required ="no"  description="Contador de Debitos."/>
@o_q_contador_cre               int            = null   out,         --<param required ="no"  description="Contador de Creditos."/>
@o_q_contador_deb_ATM           int            = null   out,         --<param required ="no"  description="Contador de Debitos ATM."/>
@o_q_contador_cre_ATM           int            = null   out,         --<param required ="no"  description="Contador de Creditos ATM.."/>
@o_q_no_computables             int            = null   out,         --<param required ="no"  description="Cantidad de No Computables."/>
@o_i_promedio_6_meses           money          = null   out,         --<param required ="no"  description="Promedio saldo de los ultimos 6 meses."/>
@o_i_12h_dif                    money          = null   out,         --<param required ="no"  description="Importe Diferido 12 Horas."/>
@o_i_24h_dif                    money          = null   out,         --<param required ="no"  description="Importe Diferido 24 Horas."/>
@o_i_48h                        money          = null   out,         --<param required ="no"  description="Importe Diferido 48 Horas."/>
@o_i_72h_diferido               money          = null   out,         --<param required ="no"  description="Importe Diferido 72 Horas."/>
@o_i_rem_diferido               money          = null   out,         --<param required ="no"  description="Importe Diferido 72 Horas Remesas."/>
@o_i_contingente                money          = null   out,         --<param required ="no"  description="Importe Contingencia."/>
@o_i_retenciones                money          = null   out,         --<param required ="no"  description="Importe Retenciones."/>
@o_c_tipo_promedio              char(1)        = null   out,         --<param required ="no"  description="Codigo de Tipo Promedio."/>
@o_i_interes_hoy                money          = null   out,         --<param required ="no"  description="Importe Interes Hoy."/>
@o_i_acreditaciones_diferid     money          = null   out,         --<param required ="no"  description="Importe Acreditaciones Diferidas."/>
@o_i_acum_efectivo              money          = null   out,         --<param required ="no"  description="Importe Acumulado Efectivo."/>
@o_i_saldo_interes              money          = null   out,         --<param required ="no"  description="Importe de Saldo Interes."/>
@o_m_cred_24h                   char(1)        = null   out,         --<param required ="no"  description="Marca de Credito en 24 Horas."/>
@o_q_suspensos                  smallint       = null   out,         --<param required ="no"  description="Cantidad de Valores en Suspenso."/>
@o_f_congelamiento              varchar(12)    = null   out,         --<param required ="no"  description="Fecha de Congelamiento."/>
@o_c_tipo_iva                   varchar(4)     = null   out,         --<param required ="no"  description="Codigo de Tipo de Iva."/>
@o_d_tipo_iva                   varchar(32)    = null   out,         --<param required ="no"  description="Descripcion de Codigo de Tipo de Iva."/>
@o_c_tipo_gan                   varchar(4)     = null   out,         --<param required ="no"  description="Codigo de Tipo de Ganancia."/>
@o_d_tipo_gan                   varchar(64)    = null   out,         --<param required ="no"  description="Descripcion de Codigo de Tipo de Ganancia."/>
@o_m_cred_rem                   char(1)        = null   out,         --<param required ="no"  description="Marca de Creditos Remesas."/>
@o_m_alcanza_impuesto           char(1)        = null   out,         --<param required ="no"  description="Marca de Alcance de Impuesto."/>
@o_p_tasa_exencion              float          = null   out,         --<param required ="no"  description="Tasa de Exencion."/>
@o_p_tasa_exencion_gan          float          = null   out,         --<param required ="no"  description="Tasa de Exencion Ganancias."/>
@o_f_vencimiento_exencion       varchar(12)    = null   out,         --<param required ="no"  description="Fecha de Vencimiento de Exencion."/>
@o_f_vencimiento_exencion_gan   varchar(12)    = null   out,         --<param required ="no"  description="Fecha de Vencimiento de Exencion Ganancias."/>
@o_p_tasa_reduccion             float          = null   out,         --<param required ="no"  description="Tasa de Reduccion."/>
@o_i_salario_mensual            money          = null   out,         --<param required ="no"  description="Salario Mensual."/>
@o_i_tot_ext_salario            money          = null   out,         --<param required ="no"  description="Total de Extraccion de Salario."/>
@o_p_tasa_exen_sellado          float          = null   out,         --<param required ="no"  description="Tasa de Exencion de Sellado."/>
@o_f_venc_exen_sellado          varchar(12)    = null   out,         --<param required ="no"  description="Fecha de Vencimiento de Exencion de Sellado."/>
@o_p_tasa_acreedora             real           = null   out,         --<param required ="no"  description="Promedio de Tasa Acreedora."/>
@o_i_saldo_ayer_idem            money          = null   out,         --<param required ="no"  description="Saldo de Ayer."/>
/* CONSULTA DESCUBIERTOS Y CHEQUES */
@o_d_causal_susp_serv_pagoch    varchar(30)    = null   out,         --<param required ="no"  description="Descripcion de Causal de Suspencion de Servicio."/>
@o_q_anulados                   smallint       = null   out,         --<param required ="no"  description="Cantidad de Cheques Anulados."/>
@o_q_devueltos                  int            = null   out,         --<param required ="no"  description="Cantidad de Cheques Devueltos."/>
@o_q_protestos                  int            = null   out,         --<param required ="no"  description="Cantidad de Cheques Protestos."/>
@o_q_protestos_periodo_ant      int            = null   out,         --<param required ="no"  description="Cantidad de Cheques Protestos Anterior."/>
@o_q_forma_firma                int            = null   out,         --<param required ="no"  description="Cantidad de Cheques Forma Firma."/>
@o_q_certificados               smallint       = null   out,         --<param required ="no"  description="Cantidad de Cheques Certificados."/>
@o_q_prot_justificados          int            = null   out,         --<param required ="no"  description="Cantidad de Cheques Protestos Justificados."/>
@o_f_susp_serv_pagoch           varchar(12)    = null   out,         --<param required ="no"  description="Fecha de Suspencion de Servicio."/>
@o_c_causal_susp_serv_pagoch    char(1)        = null   out,         --<param required ="no"  description="Codigo de Causal de Suspencion de Servicio Pago Cheque."/>
@o_q_retenidos                  smallint       = null   out,         --<param required ="no"  description="Cantidad de Cheques Retenidos."/>
@o_q_num_chq_defectos           smallint       = null   out,         --<param required ="no"  description="Cantidad de Cheques Con Defectos."/>
@o_q_chequeras                  int            = null   out,         --<param required ="no"  description="Cantidad de Chequeras."/>
@o_n_cheque_inicial             int            = null   out,         --<param required ="no"  description="Numero de Cheque Inicial."/>
@o_q_revocados                  smallint       = null   out,         --<param required ="no"  description="Cantidad de Cheques Revocados."/>
/* CONSULTA NO MONETARIA */
@o_c_direccion_ch               tinyint        = null   out,         --<param required ="no"  description="Codigo de Direccion de Chequera."/>
@o_d_direccion_ch               varchar(64)    = null   out,         --<param required ="no"  description="Descripcion de Codigo de Direccion de Chequera."/>
@o_n_cliente_ec                 int            = null   out,         --<param required ="no"  description="Numero de Cliente de Entrega Correspondencia."/>
@o_c_dir_entrega_correspon      smallint       = null   out,         --<param required ="no"  description="Codigo de Direccion de Entrega Correspondencia."/>
@o_d_entrega_correspon          varchar(64)    = null   out,         --<param required ="no"  description="Decripcion de Codigo de Direccion de Entrega Correspondencia."/>
@o_c_ciclo                      char(3)        = null   out,         --<param required ="no"  description="Codigo de Ciclo de Cuenta."/>
@o_d_ciclo                      varchar(30)    = null   out,         --<param required ="no"  description="Descripcion de Codigo de Ciclo de Cuenta."/>
@o_m_capitalizacion             char(1)        = null   out,         --<param required ="no"  description="Marca de Capitalizacion."/>
@o_d_capitalizacion             varchar(30)    = null   out,         --<param required ="no"  description="Descripcion de Capitalizacion."/>
@o_d_tarjeta_debito             varchar(2)     = null   out,         --<param required ="no"  description="Descripcion de Tarjeta de Debito."/>
@o_m_resumen_mag                char(1)        = null   out,         --<param required ="no"  description="Marca de Resumen Magnetico."/>
@o_m_cta_funcionario            varchar(2)     = null   out,         --<param required ="no"  description="Marca de Cuenta Funcionario."/>
@o_c_producto_cta_gastos        smallint       = null   out,         --<param required ="no"  description="Codigo de Producto de Cuenta Gastos."/>
@o_m_debitos_otra_cta           char(1)        = null   out,         --<param required ="no"  description="Mara de debito de Otras Cuentas."/>
@o_n_cuenta_gastos              cuenta         = null   out,         --<param required ="no"  description="Numero de Cuentas Gastos."/>
@o_d_producto_cta_gastos        varchar(18)    = null   out,         --<param required ="no"  description="Descripcion de Productio de Cuenta Gastos."/>
@o_i_saldo_ult_corte            money          = null   out,         --<param required ="no"  description="Importe de Saldo de Ultimo Corte."/>
@o_m_personalizada              char(1)        = null   out,         --<param required ="no"  description="Marca de Cuenta Personalizada."/>
@o_c_tipo_def                   char(1)        = null   out,         --<param required ="no"  description="Tipo de Cuenta."/>
@o_d_tipo_def                   varchar(25)    = null   out,         --<param required ="no"  description="Descripcion de Tipo de Cuenta."/>
@o_c_modo_deposito_cheques      varchar(10)    = null   out,         --<param required ="no"  description="Codigo de Modo de Deposito de Cheques."/>
@o_d_modo_deposito_cheques      varchar(30)    = null   out,         --<param required ="no"  description="Descripcion  de Codigo de Modo de Deposito de Cheques."/>
@o_d_personalizada              varchar(2)     = null   out,         --<param required ="no"  description="Descripcion de Cuenta Personalizada."/>
@o_m_contrato_trasferencia      varchar(2)     = null   out,         --<param required ="no"  description="Marca de Contrato Transferencia."/>
@o_d_tipo_envio                 varchar(40)    = null   out,         --<param required ="no"  description="Descripcion de Tipo de Envio."/>
@o_c_cias_seguros               catalogo       = null   out,         --<param required ="no"  description="Codigo de Compania de Seguros."/>
@o_c_tipo_dir                   char(1)        = null   out,         --<param required ="no"  description="Codigo de Tipo de Direccion."/>
@o_m_cobro_ec                   char(1)        = null   out,         --<param required ="no"  description="Marca de Cobro de Entrega Correspondencia."/>
@o_f_ult_corte                  varchar(12)    = null   out,         --<param required ="no"  description="Fecha de Ultimo Corte."/>
@o_d_cias_seguros               varchar(50)    = null   out,         --<param required ="no"  description="Descripcion de Compania de Seguros."/>
@o_n_paquete                    int            = null   out,         --<param required ="no"  description="Numero de Paquete."/>
@o_c_agen_ec                    smallint       = null   out,         --<param required ="no"  description="Numero de Oficina."/>
@o_m_deposito_inicial           tinyint        = null   out,         --<param required ="no"  description="Marca de Deposito Inicial en la Cuenta."/>
@o_q_sobregiros                 int            = null   out,         --<param required ="no"  description="Cantidad de Sobregiros."/>
@o_m_uso_sobregiro              smallint       = null   out,         --<param required ="no"  description="Marca de Utilizacion de Sobregiro."/>
@o_m_num_cta_asoc               tinyint        = null   out,         --<param required ="no"  description="Marca de Cuenta Asociada."/>
@o_m_uso_remesas                smallint       = null   out,         --<param required ="no"  description="Marca de Uso Remesas."/>
@o_f_ultima_capitalizacion      varchar(12)    = null   out,         --<param required ="no"  description="Fecha de Ultima Capitalizacion."/>
@o_f_prox_capitalizacion        varchar(12)    = null   out,         --<param required ="no"  description="Fecha de Proxima Capitalizacion."/>
@o_m_clasificacion              catalogo       = null   out,         --<param required ="no"  description="Marca de Clasificacion de Cuenta."/>
@o_n_default                    int            = null   out,         --<param required ="no"  description="Default de la Cuenta."/>
@o_k_total                      int            = null   out,         --<param required ="no"  description="Cantidad total de registros"/>
@o_k_pagina                     smallint       = null   out,         --<param required ="no"  description="Numero de Pagina"/>
@o_m_hay_mas                    char(1)        = null   out          --<param required ="no"  description="Marca de si hay mas registros"/>
)--</parameters>
as
declare
@w_return                      int,
@w_sp_name                     varchar(30),
/* VARIABLES DE TRABAJO */
@w_f_proceso                   datetime,
@w_m_usa_decimales             char(1),
@w_q_decimales                 tinyint,
@w_n_mes                       smallint,
@w_n_mes_actual                varchar(2),
@w_q_dias                      tinyint,
@w_n_anio_actual               varchar(4),
@w_f_primer_dia                varchar(12),
@w_f_mes                       smalldatetime,
@w_f_anterior                  smalldatetime,
@w_n_anio                      smallint,
@w_i_transaccion               money,
@w_f_registro                  smalldatetime,
@w_n_error                     int,                                 -- ALMACENA NUMERO DE ERROR, YA SEA DEVUELTO POR OTRO SP O CREADO POR ESTE SP.
@w_e_paquete                   char(1),                              -- PARA ANALIZAR EL ESTADO DEL PAQUETE
@w_n_tabla                     int,
@w_i_saldo_girar               money,
@w_i_saldo_contable            money,
@w_n_cuenta                    int,
@w_n_producto                  tinyint,
@w_k_filas_restantes           int
/* DEFINICION DE VARIABLES Y CARGA DEL NOMBRE DEL SP */
select
@w_sp_name   = 'sp_cc_cuenta',
@w_n_error   = 0,
@w_f_proceso = @s_date                                               -- SE PASA A UNA VARIABLE LOCAL LA FECHA DE PROCESO

if @w_f_proceso is null
begin -- SI NO ENVIAN FECHA DE PROCESO, LA VOY A BUSCAR
   select @w_f_proceso = fp_fecha
   from cobis..ba_fecha_proceso
end   -- SI NO ENVIAN FECHA DE PROCESO, LA VOY A BUSCAR

/* CONTROL DE TRANSACCION */
if @t_trn not in( 30420 )
begin -- ERROR EN CODIGO DE TRANSACCION
   select @w_n_error = 201048

   goto TRATA_ERROR
end   -- ERROR EN CODIGO DE TRANSACCION

if @i_m_usa_moneda_local = 'S' and @i_c_moneda is null
begin -- EN CASO DE QUE ME LO INDIQUEN, UTILIZO LA MONEDA LOCAL
   select @i_c_moneda  = isnull( pa_tinyint, 80 )
   from cobis..cl_parametro
   where pa_nemonico = 'MLO'
   and   pa_producto = 'ADM'

   if @@rowcount <> 1
   begin -- PARAMETRO NO ENCONTRADO
      select @w_n_error = 201196

      goto TRATA_ERROR
   end   -- PARAMETRO NO ENCONTRADO
end   -- EN CASO DE QUE ME LO INDIQUEN, UTILIZO LA MONEDA LOCAL

/**********************/
/* OPCION DE BUSQUEDA */
/**********************/
if @i_operacion = 'S'
begin -- SE REALIZAN BUSQUEDAS EN BASE A UNA CUENTA
   /* SE CONTROLA QUE SE INGRESE AL MENOS ALGUN NUMERO DE CUENTA, CASO CONTRARIO, ERRROR */
   if @i_n_cta_banco is null
   begin
      /* SE TOMA LA CUENTA LARGA PARA TRABAJAR */
      select @i_n_cta_banco = cc_cta_banco
      from cob_cuentas..cc_ctacte
      where cc_ctacte = @i_n_ctacte

      if @@rowcount != 1
      begin -- NO EXISTE CUENTA_BANCO
         select @w_n_error = 201004

         goto TRATA_ERROR
      end   -- NO EXISTE CUENTA_BANCO
   end

   /* SE OBTIENEN DATOS GENERALES DEL MAESTRO DE CUENTAS PARA SER TRATADOS */
   select
   @o_n_ctacte                   = cc_ctacte,
   @o_n_cta_banco                = cc_cta_banco,
   @o_n_filial                   = cc_filial,
   @o_c_oficina                  = cc_oficina,
   @o_c_oficial                  = cc_oficial,
   @o_d_nombre                   = cc_nombre,
   @o_f_apertura                 = convert(varchar(12), cc_fecha_aper, @i_formato_fecha),
   @o_n_cliente                  = cc_cliente,
   @o_n_cuit                     = cc_ced_ruc,
   @o_c_estado                   = cc_estado,
   @o_n_cliente_ec               = cc_cliente_ec,
   @o_c_dir_entrega_correspon    = cc_direccion_ec,
   @o_d_entrega_correspon        = cc_descripcion_ec,
   @o_c_tipo_dir                 = cc_tipo_dir,
   @o_m_cobro_ec                 = cc_cobro_ec,
   @o_c_agen_ec                  = cc_agen_ec,
   @o_n_parroquia                = cc_parroquia,
   @o_m_man_firmas               = cc_man_firmas,
   @o_c_ciclo                    = cc_ciclo,
   @o_c_categoria                = cc_categoria,
   @o_i_creditos_mes             = cc_creditos_mes,
   @o_i_debitos_mes              = cc_debitos_mes,
   @o_i_creditos_hoy             = cc_creditos_hoy,
   @o_i_debitos_hoy              = cc_debitos_hoy,
   @o_i_disponible               = cc_disponible,
   @o_i_12h                      = cc_12h,
   @o_i_12h_dif                  = cc_12h_dif,
   @o_i_24h                      = cc_24h,
   @o_i_24h_dif                  = cc_24h_dif,
   @o_i_48h                      = cc_48h,
   @o_i_72h_diferido             = isnull(cc_72h_diferido,0),
   @o_i_remesas                  = cc_remesas,
   @o_i_remesas_hoy              = cc_rem_hoy,
   @o_i_rem_diferido             = cc_rem_diferido,
   @o_i_contingente              = cc_contingente,
   @o_f_ultimo_movimiento        = convert(varchar(12), cc_fecha_ult_mov,     @i_formato_fecha),
   @o_f_ultimo_movim_int         = convert(varchar(12), cc_fecha_ult_mov_int, @i_formato_fecha),
   @o_f_ultima_actualizacion     = convert(varchar(12), cc_fecha_ult_upd,     @i_formato_fecha),
   @o_m_cred_24h                 = cc_cred_24h,
   @o_m_cred_rem                 = cc_cred_rem,
   @o_q_dias_sobregiro           = cc_dias_sob,
   @o_q_dias_sobregiro_cont      = cc_dias_sob_cont,
   @o_i_retenciones              = cc_retenciones,
   @o_q_certificados             = isnull(cc_certificados,0),
   @o_q_protestos                = isnull(cc_protestos,0),
   @o_q_prot_justificados        = isnull(cc_prot_justificados,0),
   @o_q_protestos_periodo_ant    = isnull(cc_prot_periodo_ant,0),
   @o_q_sobregiros               = cc_sobregiros,
   @o_q_anulados                 = isnull(cc_anulados,0),
   @o_q_revocados                = isnull(cc_revocados,0),
   @o_q_bloqueos_movimientos     = cc_bloqueos,
   @o_m_bloqueos_valores         = cc_num_blqmonto,
   @o_q_suspensos                = cc_suspensos,
   @o_m_uso_sobregiro            = cc_uso_sobregiro,
   @o_m_uso_remesas              = cc_uso_remesa,
   @o_c_producto                 = cc_producto,
   @o_m_tipo                     = cc_tipo,
   @o_c_moneda                   = cc_moneda,
   @o_n_default                  = cc_default,
   @o_c_tipo_def                 = cc_tipo_def,
   @o_c_rol_ente                 = cc_rol_ente,
   @o_c_tipo_promedio            = cc_tipo_promedio,
   @o_i_saldo_ult_corte          = cc_saldo_ult_corte,
   @o_f_ult_corte                = convert(varchar(12), cc_fecha_ult_corte, @i_formato_fecha),
   @o_f_ultima_capitalizacion    = convert(varchar(12), cc_fecha_ult_capi,  @i_formato_fecha),
   @o_i_saldo_ayer               = cc_saldo_ayer,
   @o_i_bloqueo_valores          = cc_monto_blq,
   @o_i_promedio1                = cc_promedio1,
   @o_i_promedio2                = cc_promedio2,
   @o_i_promedio3                = cc_promedio3,
   @o_i_promedio4                = cc_promedio4,
   @o_i_promedio5                = cc_promedio5,
   @o_i_promedio6                = cc_promedio6,
   @o_m_personalizada            = cc_personalizada,
   @o_p_disponible               = cc_prom_disponible,
   @o_m_cta_funcionario          = case
                                      when cc_cta_funcionario = 'N'
                                         then 'NO'
                                      else
                                              'SI'
                                   end,
   @o_c_tipocta                  = cc_tipocta,
   @o_i_saldo_interes            = cc_saldo_interes,
   @o_m_num_cta_asoc             = cc_num_cta_asoc,
   @o_c_prod_banc                = cc_prod_banc,
   @o_c_origen                   = cc_origen,
   @o_f_prox_capitalizacion      = convert(varchar(12), cc_fecha_prx_capita,  @i_formato_fecha),
   @o_m_deposito_inicial         = cc_dep_ini,
   @o_n_telefono                 = cc_telefono,
   @o_i_interes_hoy              = cc_int_hoy,
   @o_d_tarjeta_debito           = cc_tarjeta_debito,
   @o_c_sector_BCRA              = cc_sector_BCRA,
   @o_c_residencia               = cc_residencia,
   @o_q_forma_firma              = isnull(cc_forma_firma,0),
   @o_c_uso_firma                = cc_uso_firma,
   @o_m_resumen_mag              = cc_resumen_mag,
   @o_m_debitos_otra_cta         = cc_debitos_otra_cta,
   @o_c_tipo_iva                 = cc_tipo_iva,
   @o_p_tasa_exencion            = cc_tasa_exencion,
   @o_f_vencimiento_exencion     = convert(varchar(12), cc_fecha_venc_exencion,  @i_formato_fecha),
   @o_p_tasa_reduccion           = cc_tasa_reduccion,
   @o_f_vencimiento_reduccion    = convert(varchar(12), cc_fecha_venc_reduccion, @i_formato_fecha),
   @o_m_congelada                = case
                                     when cc_congelada = 'N'
                                        then 'NO'
                                     else
                                             'SI'
                                  end,
   @o_m_clasificacion            = cc_clasificacion,
   @o_i_saldo_ayer_idem          = cc_saldo_ayer_idem,
   @o_m_alcanza_impuesto         = cc_alcanza_impuesto,
   @o_n_cbu                      = cc_cbu,
   @o_c_direccion_ch             = cc_direccion_ch,
   @o_i_acum_efectivo            = isnull(cc_acum_efectivo,0),
   @o_c_tipo_gan                 = cc_tipo_gan,
   @o_p_tasa_exencion_gan        = cc_tasa_exencion_gan,
   @o_f_vencimiento_exencion_gan = convert(varchar(12), cc_fecha_venc_exencion_gan, @i_formato_fecha),
   @o_n_paquete                  = cc_paquete,
   @o_m_solidaria                = cc_solidaria,
   @o_c_modo_deposito_cheques    = cc_dep_cheques_granel,
   @o_f_susp_serv_pagoch         = convert(varchar(12), cc_fecha_susp_serv_pagoch,  @i_formato_fecha),
   @o_c_causal_susp_serv_pagoch  = cc_causal_susp_serv_pagoch,
   @o_c_cias_seguros             = cc_cias_seguros,
   @o_q_contador_trx             = cc_contador_trx,
   @o_q_contador_firma           = cc_contador_firma,
   @o_q_contador_deb             = cc_contador_deb,
   @o_q_contador_cre             = cc_contador_cre,
   @o_q_contador_deb_ATM         = cc_contador_deb_ATM,
   @o_q_contador_cre_ATM         = cc_contador_cre_ATM,
   @o_q_retenidos                = isnull(cc_retenidos,0),
   @o_q_num_chq_defectos         = isnull(cc_num_chq_defectos,0),
   @o_q_chequeras                = isnull(cc_chequeras,0),
   @o_n_cheque_inicial           = cc_cheque_inicial,
   @o_i_salario_mensual          = cc_salario_mensual,
   @o_i_tot_ext_salario          = cc_tot_ext_salario,
   @o_p_tasa_exen_sellado        = cc_tasa_exen_sellado,
   @o_f_venc_exen_sellado        = convert(varchar(12), cc_fecha_venc_exen_sellado, @i_formato_fecha),
   @o_p_tasa_acreedora           = isnull(cc_tasa_acreedora,0)
   from  cob_cuentas..cc_ctacte
   where cc_cta_banco  = @i_n_cta_banco

   /* CONTROL DE EXISTENCIA DE CUENTA */
   if @@rowcount != 1
   begin -- NO EXISTE CUENTA_BANCO
      select @w_n_error = 201004

      goto TRATA_ERROR
   end   -- NO EXISTE CUENTA_BANCO

   /* CONSULTA DE DATOS GENERALES */
   if @i_tipo_operacion in( 'D', 'T' )
   begin
      /* SELECCION DE DESCRIPCION DE OFICIAL */
      select @o_d_oficial = substring(fu_nombre,1,25)
      from  cobis..cl_funcionario,
            cobis..cc_oficial
      where  oc_oficial     = @o_c_oficial
      and    fu_funcionario = oc_funcionario

      if @@rowcount <> 1
      begin -- NO EXISTE EL OFICIAL
         select @w_n_error = 149309

         goto TRATA_ERROR
      end   -- NO EXISTE EL OFICIAL

      /* SELECCION DE DESCRIPCION DE USO DE FIRMA */
      select @o_d_uso_firma  = substring(valor,1,25)
      from  cobis..cl_catalogo
      where tabla  =( select cobis..cl_tabla.codigo
                      from   cobis..cl_tabla
                      where  tabla = 'cc_tipofirma' )
      and   codigo = @o_c_uso_firma

      if @@rowcount <> 1
      begin -- NO EXISTE CATEGORIA DE FIRMA
         select @w_n_error = 301016

         goto TRATA_ERROR
      end   -- NO EXISTE CATEGORIA DE FIRMA

      /* SELECCION DE DESCRIPCION DE LA MONEDA */
      select @o_d_moneda = substring(mo_descripcion,1,15)
      from  cobis..cl_moneda
      where mo_moneda = @o_c_moneda

      if @@rowcount <> 1
      begin -- NO EXISTE MONEDA
         select @w_n_error = 101045

         goto TRATA_ERROR
      end   -- NO EXISTE MONEDA

      /* SELECCION DE DESCRIPCION DE LA CATEGORIA */
      select @o_d_categoria = substring(valor,1,30)
      from  cobis..cl_catalogo
      where tabla  =( select cobis..cl_tabla.codigo
                      from   cobis..cl_tabla
                      where  tabla = 'cc_categoria' )
      and   codigo = @o_c_categoria

      if @@rowcount <> 1
      begin -- NO EXISTE CATEGORIA DE CUENTA
         select @w_n_error = 201018

         goto TRATA_ERROR
      end   -- NO EXISTE CATEGORIA DE CUENTA

      /* SELECCION DE DESCRIPCION DE LA OFICINA */
      select @o_d_oficina = substring(valor,1,32)
      from  cobis..cl_catalogo
      where tabla = (select cobis..cl_tabla.codigo
                     from  cobis..cl_tabla
                     where tabla = 'cl_oficina')
      and   codigo = convert(char(10), @o_c_oficina)

      if @@rowcount <> 1
      begin -- NO EXISTE OFICINA
         select @w_n_error = 151604

         goto TRATA_ERROR
      end   -- NO EXISTE OFICINA

      /* SELECCION DE DESCRIPCION DEL PRODUCTO */
      select @o_d_producto = 'CUENTA CORRIENTE'

      /* SELECCION DE DESCRIPCION DE PRODUCTO BANCARIO */
      select @o_d_prod_banc = substring(pb_descripcion,1,32)
      from  cob_remesas..pe_pro_bancario
      where pb_pro_bancario = @o_c_prod_banc
      and   pb_estado       = 'V'

      if @@rowcount <> 1
      begin -- PRODUCTO BANCARIO INEXISTENTE
         select @w_n_error = 201285

         goto TRATA_ERROR
      end   -- PRODUCTO BANCARIO INEXISTENTE

      /* SELECCION DE DESCRIPCION DEL SECTOR BCRA */
      select @o_d_sector_BCRA = substring(valor,1,32)
      from  cobis..cl_catalogo
      where tabla  =( select cobis..cl_tabla.codigo
                      from   cobis..cl_tabla
                      where  tabla = 'cl_sector_compuesto' )
      and   codigo = @o_c_sector_BCRA

      if @@rowcount <> 1
      begin -- TIPO DE PRODUCTO BCRA NO EXISTE
         select @w_n_error = 141231

         goto TRATA_ERROR
      end   -- TIPO DE PRODUCTO BCRA NO EXISTE

      /* SELECCION DEL ESTADO DE LA CUENTA */
      select @o_d_estado = substring(valor,1,20)
      from  cobis..cl_catalogo
      where tabla  =( select cobis..cl_tabla.codigo
                      from  cobis..cl_tabla
                      where tabla = 'cc_estado_cta' )
      and   codigo = @o_c_estado

      if @@rowcount <> 1
      begin -- ERROR CONSULTANDO ESTADO DE LA CUENTA
         select @w_n_error = 2809062

         goto TRATA_ERROR
      end   -- ERROR CONSULTANDO ESTADO DE LA CUENTA

      /* SELECCION DE LA FECHA DE CIERRE PARA CUENTAS CERRADAS */
      select @o_f_cierre = convert(varchar(12), hc_fecha, @i_formato_fecha)
      from  cob_cuentas..cc_his_cierre
      where hc_cuenta = @o_n_ctacte

      /* SELECCION DEL DETALLE DE RESIDENCIA */
      select @o_d_residencia = substring(valor,1,32)
      from  cobis..cl_catalogo
      where tabla  =( select cobis..cl_tabla.codigo
                      from  cobis..cl_tabla
                      where tabla = 'cl_residencia' )
      and   codigo = @o_c_residencia

      if @@rowcount <> 1
      begin -- NO EXISTE RESIDENCIA
         select @w_n_error = 101185

         goto TRATA_ERROR
      end   -- NO EXISTE RESIDENCIA

      /* SELECCION DE DESCRIPCION DE TIPO DE CUENTA */
      select @o_d_tipocta = substring(valor,1,32)
      from  cobis..cl_catalogo
      where tabla  =( select cobis..cl_tabla.codigo
                      from  cobis..cl_tabla
                      where tabla = 'pe_tipo_ente' )
      and   codigo = @o_c_tipocta

      if @@rowcount <> 1
      begin -- NO EXISTE TIPO DE PERSONA
         select @w_n_error = 101021

         goto TRATA_ERROR
      end   -- NO EXISTE TIPO DE PERSONA

      /* SOLO FRONT END [F] */
      if @i_quien_llama = 'F'
      begin
         /*  VERSION COMPLETA DE DATOS GENERALES */
         if @i_tipo_consulta = 'A'
         begin
            /******************************************/
            /* ENVIO AL FRONT END LOS DATOS GENERALES */
            /******************************************/
            select
            'CODIGO CUENTA'                       = @o_n_ctacte,                                   -- 1
            'CUENTA BANCO'                        = @o_n_cta_banco,
            'NOMBRE TITULAR DE LA CUENTA'         = @o_d_nombre,
            'NUMERO DE CLIENTE'                   = @o_n_cliente,
            'NUMERO DE CBU'                       = @o_n_cbu,
            'NUMERO DE FILIAL'                    = @o_n_filial,
            'NUMERO DE CUIT'                      = @o_n_cuit,
            'CODIGO OFICIAL'                      = @o_c_oficial,
            'DESCRIPCION OFICIAL'                 = @o_d_oficial,
            'CODIGO USO FIRMA'                    = @o_c_uso_firma,                                --10
            'DESCRIPCION DE USO FIRMA'            = @o_d_uso_firma,
            'CODIGO DE MONEDA'                    = @o_c_moneda,
            'DESCRIPCION DE MONEDA'               = @o_d_moneda,
            'CODIGO DE CATEGORIA'                 = @o_c_categoria,
            'DESCRIPCION DE CATEGORIA'            = @o_d_categoria,
            'CODIGO DE OFICINA'                   = @o_c_oficina,
            'DESCRIPCION DE OFICINA'              = @o_d_oficina,
            'CODIGO DE PRODUCTO'                  = @o_c_producto,
            'DESCRIPCION DE PRODUCTO'             = @o_d_producto,
            'CODIGO DE PRODUCTO BANC.'            = @o_c_prod_banc,                                -- 20
            'DESCRIPCION DE PROD. BANC.'          = @o_d_prod_banc,
            'CODIGO DE SECTOR BCRA'               = @o_c_sector_BCRA,
            'DESCRIPCION DE SECTOR BCRA'          = @o_d_sector_BCRA,
            'ESTADO DE LA CUENTA'                 = @o_c_estado,
            'DESCRIPCION DE ESTADO DE CTA'        = @o_d_estado,
            'FECHA DE APERTURA'                   = @o_f_apertura,
            'FECHA DE CIERRE'                     = @o_f_cierre,
            'CODIGO DE RESIDENCIA'                = @o_c_residencia,
            'DESCRIPCION COD. DE RESID.'          = @o_d_residencia,
            'ROL DEL TITULAR DE CTA'              = @o_c_rol_ente,                                 -- 30
            'NUMERO DE PARROQUIA'                 = @o_n_parroquia,
            'TIPO DE CUENTA'                      = @o_c_tipocta,
            'DESCRIPCION DE TIPO DE CUENTA'       = @o_d_tipocta,
            'TIPO'                                = @o_m_tipo,                 -- [R]
            'MATENIMIENTO DE FIRMA'               = @o_m_man_firmas,           -- [ S O N ]        -- 35
            'NUMERO DE TELEFONO'                  = @o_n_telefono,
            'CODIGO DE ORIGEN'                    = @o_c_origen,
            'MARCA SOLIDARIA'                     = @o_m_solidaria,            -- [ NULL , 1 O 2 ]
            'NUMERO DE PAQUETE'                   = @o_n_paquete
         end
         else
         begin                                                       -- @i_tipo_consulta = 'R'
            /******************************************/
            /*   VERSION RESUMIDA DE DATOS GENERALES  */
            /******************************************/
            /* ENVIO AL FRONT END LOS DATOS GENERALES */
            /******************************************/
            select
            'CODIGO CUENTA'                       = @o_n_ctacte,                                   --  1
            'CUENTA BANCO'                        = @o_n_cta_banco,
            'NOMBRE TITULAR DE LA CUENTA'         = @o_d_nombre,
            'NUMERO DE CLIENTE'                   = @o_n_cliente,
            'NUMERO DE CBU'                       = @o_n_cbu,
            'NUMERO DE FILIAL'                    = @o_n_filial,
            'NUEMRO DE CUIT'                      = @o_n_cuit,
            'CODIGO OFICIAL'                      = @o_c_oficial,
            'DESCRIPCION OFICIAL'                 = @o_d_oficial,
            'CODIGO DE MONEDA'                    = @o_c_moneda,                                   -- 10
            'DESCRIPCION DE MONEDA'               = @o_d_moneda,
            'CODIGO DE CATEGORIA'                 = @o_c_categoria,
            'DESCRIPCION DE CATEGORIA'            = @o_d_categoria,
            'CODIGO DE OFICINA'                   = @o_c_oficina,
            'DESCRIPCION DE OFICINA'              = @o_d_oficina,
            'CODIGO DE PRODUCTO BANC.'            = @o_c_prod_banc,
            'DESCRIPCION DE PROD. BANC.'          = @o_d_prod_banc,
            'ESTADO DE LA CUENTA'                 = @o_c_estado,
            'DESCRIPCION DE ESTADO DE CTA'        = @o_d_estado,
            'FECHA DE APERTURA'                   = @o_f_apertura                                  -- 20
         end
      end
   end

   /* CONSULTA DE DATOS MONETARIOS */
   if @i_tipo_operacion in( 'M', 'T' )
   begin
      if @w_f_proceso is null
      begin -- LA FECHA DE SOLICIUTUD ES OBLIGATORIA
         select @w_n_error = 24083

         goto TRATA_ERROR
      end   -- LA FECHA DE SOLICIUTUD ES OBLIGATORIA

      if @s_ofi is null
      begin -- EN CASO DE OFICINA NULA, LE PASO LA DE LA CUENTA
         select @s_ofi = @o_c_oficina
      end   -- EN CASO DE OFICINA NULA, LE PASO LA DE LA CUENTA

      /* DECIMALES POR MONEDA */
      select @w_m_usa_decimales = mo_decimales
      from   cobis..cl_moneda
      where  mo_moneda = @o_c_moneda

      if @w_m_usa_decimales = 'S'
      begin
         select @w_q_decimales = pa_tinyint
         from  cobis..cl_parametro
         where pa_producto = 'CTE'
         and   pa_nemonico = 'DCI'

         if @@rowcount <> 1
         begin -- PARAMETRO NO ENCONTRADO
            select @w_n_error = 201196

            goto TRATA_ERROR
         end   -- PARAMETRO NO ENCONTRADO
      end
      else
      begin
         select @w_q_decimales = 0
      end

      /* CONVERSION DE LA FECHA DE INGRESO */
      select @s_date         = convert(varchar(8),@w_f_proceso,1)

      select @w_f_primer_dia = convert(varchar(2),datepart(mm,@s_date)) + '/01/' + convert(varchar(4),datepart(yy,@s_date))

      select @w_n_mes        = datepart(mm, @s_date)

      select @w_n_anio       = datepart(yy, @s_date)

      select @w_q_dias       = datediff(dd,@w_f_primer_dia,@s_date)

      if @w_q_dias = 0
         select @w_q_dias = 1

      /* DETERMINACION DEL PRIMER DIA DEL MES */
      select
      @w_n_mes_actual  = convert(varchar(2), datepart(mm,@s_date)),
      @w_n_anio_actual = convert(varchar(4), datepart(yy,@s_date))

      select @w_f_mes = @w_n_mes_actual + '/01/' + @w_n_anio_actual

      /* CALCULO DEL SALDO CONTABLE Y SALDO PARA GIRAR DE LA CUENTA */
      exec @w_return      = cob_cuentas..sp_calcula_saldo
      @t_debug            = @t_debug,
      @t_file             = @t_file,
      @t_from             = @w_sp_name,
      @i_cuenta           = @o_n_ctacte,
      @i_fecha            = @s_date,
      @i_ofi              = @s_ofi,
      @i_anula_paq        = @i_m_anula_paq,
      @o_saldo_para_girar = @o_i_saldo_para_girar   out,
      @o_saldo_contable   = @o_i_saldo_contable     out

      if @w_return != 0
      begin
         return @w_return
      end

      /* SELECCION DE ACREEDITACION Y MONTO FINAL */
      select @o_i_acreditaciones_diferid  = 0

      /* SELECCION DEL MONTO DE LA TRANSACCION */
      select @w_i_transaccion = isnull(sum(de_efectivo), 0)
      from  cob_cuentas..cc_dif_efectivo
      where de_cta_banco   = @o_n_cta_banco
      and   de_tipo_tran   = 48
      and   de_estado      = null
      and   de_procesada   = null
      and   de_fecha_acred = convert(smalldatetime, @s_date)

      /* SE SUMA EL MONTO DE LA TRANSACCION A LA ACREEDITACION */
      select @o_i_acreditaciones_diferid = @o_i_acreditaciones_diferid + @w_i_transaccion

      /* SELECCION DEL MONTO DE LA TRANSACCION */
      select @w_i_transaccion = isnull(sum(de_efectivo), 0)
      from  cob_cuentas..cc_dif_efectivo
      where de_cta_banco   = @o_n_cta_banco
      and   de_tipo_tran   = 50
      and   de_estado      = null
      and   de_procesada   = null
      and   de_fecha_acred = convert(smalldatetime, @s_date)

      /* SE RESTA EL MONTO DE LA TRANSACCION A LA ACREEDITACION */
      select @o_i_acreditaciones_diferid = @o_i_acreditaciones_diferid - @w_i_transaccion

      /* SELECCION DEL PROMEDIO CONTABLE POSITIVO */
      select @o_p_contable_positivo = round((sum(hd_saldo_contable)/@w_q_dias),@w_q_decimales)
      from  cob_cuentas_his..cc_his_disponible
      where hd_cuenta          = @o_n_ctacte
      and   hd_fecha          >= @w_f_mes
      and   hd_saldo_contable >= 0

      /* SI EL PROMEDIO ES NULL, SE GUARDA EN CERO */
      if @o_p_contable_positivo is null
         select @o_p_contable_positivo = 0

      /* SELECCION DEL PROMEDIO CONTABLE NEGATIVO */
      select @o_p_contable_negativo = round((sum(hd_saldo_contable)/@w_q_dias),@w_q_decimales)
      from  cob_cuentas_his..cc_his_disponible
      where hd_cuenta          =  @o_n_ctacte
      and   hd_fecha          >= @w_f_mes
      and   hd_saldo_contable  <  0

      /* SI EL PROMEDIO ES NULL, SE GUARDA EN CERO */
      if @o_p_contable_negativo is null
         select @o_p_contable_negativo = 0

      /* CALCULO DEL INTERES DEVENGADO */
      select @o_i_interes_deven = sum(isnull(us_interes, 0))
      from  cob_cuentas..cc_uso_sobregiro
      where us_cuenta  = @o_n_ctacte
      and   us_estado != 'L'

      /* SI EL INTERES ES NULL, SE GUARDA EN CERO */
      if @o_i_interes_deven is null
         select @o_i_interes_deven = 0

      /* CALCULO EL MAYOR SALDO DEUDOR EN LO ULTIMOS 6 MESES */
      select @w_f_anterior = dateadd(MM, -6, @w_f_mes)

      select @o_i_saldo_6_meses = isnull(min(hd_saldo_disponible), 0)
      from   cob_cuentas_his..cc_his_disponible
      where  hd_cuenta            = @o_n_ctacte
      and    hd_saldo_disponible  < 0
      and    hd_fecha            >= @w_f_anterior
      and    hd_fecha             < @w_f_mes

      /* SE SACA EL PROMEDIO DE LOS ULTIMOS 6 MESES */
      select @o_i_promedio_6_meses = ( isnull(@o_i_promedio1, 0) + isnull(@o_i_promedio2, 0) +
                                       isnull(@o_i_promedio3, 0) + isnull(@o_i_promedio4, 0) +
                                       isnull(@o_i_promedio5, 0) + isnull(@o_i_promedio6, 0) ) / 6

      /* SELECCION DE DESCRIPCION DE TIPO IVA */
      select @o_d_tipo_iva = substring(iv_descripcion,1,32)
      from cobis..cl_iva
      where iv_codigo = @o_c_tipo_iva
      and   iv_estado = 'V'

      if @@rowcount = 0
      begin -- ERROR EN CONSULTA DE IVA
         select @w_n_error = 82375

         goto TRATA_ERROR
      end   -- ERROR EN CONSULTA DE IVA

      /* SELECCION DE DESCRIPCION DE CONDICION DE GANANCIAS */
      select @o_d_tipo_gan = substring(dg_descripcion,1,60)
      from  cobis..cl_dgi
      where dg_codigo = @o_c_tipo_gan
      and   dg_estado = 'V'

      /* SIEMPRE EL SOBREGIRO OCASIONAL USADO ES CERO */
      select @o_i_sobregiro_ocasional = isnull((us_util_hoy/us_num_dias), 0)
      from  cob_cuentas..cc_uso_sobregiro
      where us_cuenta          = @o_n_ctacte
      and   us_estado          = 'V'
      and   us_tipo_sobregiro  = 'O'
      and   us_num_dias       <> 0
      order by us_fecha_reg desc

      /* SI EL SOBREGIRO ES NULL, SE GRABA EN CERO */
      if @o_i_sobregiro_ocasional is null
         select @o_i_sobregiro_ocasional = 0

      /* SELECCION DE LA FECHA A UTILIZAR PARA EL CALCULO DE SOBREGIRO CONTRATADO */
      select @w_f_registro = max(us_fecha_reg)
      from  cob_cuentas..cc_uso_sobregiro
      where us_cuenta            = @o_n_ctacte
      and   us_estado            = 'V'
      and   us_tipo_sobregiro like 'C%'
      and   us_num_dias         <> 0

      /* SELECCION DEL SOBREGIRO CONTRATADO */
      select @o_i_sobregiro_contratado = isnull(sum(us_util_hoy/us_num_dias), 0)
      from  cob_cuentas..cc_uso_sobregiro
      where us_cuenta            = @o_n_ctacte
      and   us_estado            = 'V'
      and   us_tipo_sobregiro like 'C%'
      and   us_num_dias         <> 0
      and   us_fecha_reg         = @w_f_registro

      /* SI EL SOBREGIRO ES NULL, SE GUARDA EN CERO */
      if @o_i_sobregiro_contratado is null
         select @o_i_sobregiro_contratado = 0

      /* SI EXISTE CONGELAMIENTO, SE VA A BUSCAR LA FECHA DE CONGELAMIENTO */
      if @o_m_congelada = 'SI'
      begin
         /* FECHA DE CONGELAMIENTO DE INTERESES */
         select @o_f_congelamiento = convert(varchar(12), min(us_fecha_reg), @i_formato_fecha)
         from  cob_cuentas..cc_uso_sobregiro
         where us_cuenta = @o_n_ctacte
         and   us_estado = 'C'
      end

      /* SOLO FRONT END [F] */
      if @i_quien_llama = 'F'
      begin
         /* VERSION COMPLETA DE DATOS MONETARIOS */
         if @i_tipo_consulta = 'A'
         begin
            /*******************************************/
            /* ENVIO AL FRONT END LOS DATOS MONETARIOS */
            /*******************************************/
            select
            'IMPORTE REMESAS'               = @o_i_remesas,                                        -- 1
            'IMPORTE REMESAS HOY'           = @o_i_remesas_hoy,
            'IMPORTE REMESAS 24 HS'         = @o_i_24h,
            'IMPORTE REMESAS 12 HS'         = @o_i_12h,
            'SALDO DISPONIBLE'              = @o_i_disponible,
            'PROMEDIO DISPONIBLE'           = @o_p_disponible,
            'SALDO CONTABLE'                = @o_i_saldo_contable,
            'SALDO PARA GIRAR'              = @o_i_saldo_para_girar,
            'MONTO SOBREGIRO OCASIONAL'     = @o_i_sobregiro_ocasional,
            'MONTO SOBREGIRO CONTRATADO'    = @o_i_sobregiro_contratado,                           -- 10
            'CANT. DE DIAS TRANSITORIOS'    = @o_q_dias_sobregiro,
            'MONTO BLOQUEO DE VALORES'      = @o_i_bloqueo_valores,
            'CANT. BLOQUEOS DE MOVIMIENTOS' = @o_q_bloqueos_movimientos,
            'MARCA DE BLOQUEOS DE VALORES'  = @o_m_bloqueos_valores,
            'FECHA ULTIMO MOVIMIENTO'       = @o_f_ultimo_movimiento,
            'PROMEDIO CONTABLE POSITIVO'    = @o_p_contable_positivo,
            'MONTO DEBITO MES'              = @o_i_debitos_mes,
            'MONTO DEBITOS HOY'             = @o_i_debitos_hoy,
            'SALDO AYER'                    = @o_i_saldo_ayer,
            'PROMEDIO CONTABLE NEGATIVO'    = @o_p_contable_negativo,                              -- 20
            'MONTO CREDITO MES'             = @o_i_creditos_mes,
            'MONTO CREDITOS HOY'            = @o_i_creditos_hoy,
            'INTERESES DEVENGADOS'          = @o_i_interes_deven,
            'MARCA CONGELADA'               = @o_m_congelada,                  -- [ S O N ]
            'FECHA CONGELAMIENTO INTERESES' = @o_f_congelamiento,
            'CANT. DE CHEQUERAS'            = @o_q_chequeras,
            'MAYOR SALDO ULT. 6 MESES'      = @o_i_saldo_6_meses,
            'IMPORTE PROMEDIO MES 1'        = @o_i_promedio1,
            'IMPORTE PROMEDIO MES 2'        = @o_i_promedio2,
            'IMPORTE PROMEDIO MES 3'        = @o_i_promedio3,                                      -- 30
            'IMPORTE PROMEDIO MES 4'        = @o_i_promedio4,
            'IMPORTE PROMEDIO MES 5'        = @o_i_promedio5,
            'IMPORTE PROMEDIO MES 6'        = @o_i_promedio6,
            'IMPORTE PROM. ULT. 6 MESES'    = @o_i_promedio_6_meses,
            /* DATOS IMPOSITIVOS */
            'MARCA DE ALCANZA IMPUESTO'     = @o_m_alcanza_impuesto,
            'MARCA DE DOCUMENTO TRIBUTARIO' = @o_m_cred_rem,
            'CODIGO TIPO IVA'               = @o_c_tipo_iva,
            'DESCRIPCION TIPO IVA'          = @o_d_tipo_iva,
            'TASA EXENCION IVA'             = @o_p_tasa_exencion,
            'FECHA VENC. EXENCION IVA'      = @o_f_vencimiento_exencion,                           -- 40
            'TASA REDUCCION IVA'            = @o_p_tasa_reduccion,
            'FECHA VENC. REDUCCION IVA'     = @o_f_vencimiento_reduccion,
            'CODIGO TIPO GANANCIA'          = @o_c_tipo_gan,
            'DESCRIPCION TIPO GANANCIA'     = @o_d_tipo_gan,
            'TASA EXENCION GANANCIAS'       = @o_p_tasa_exencion_gan,
            'FECHA VENC. EXEN.GANANCIAS'    = @o_f_vencimiento_exencion_gan,
            'TASA DE EXENCION SELLADO'      = @o_p_tasa_exen_sellado,
            'FECHA VENC. EXEN.SELLADO'      = @o_f_venc_exen_sellado,
            'PORCENTAJE TASA ACREEDORA'     = @o_p_tasa_acreedora,
            /* OTROS DATOS */
            'DIAS SOBREGIRO CONT'           = @o_q_dias_sobregiro_cont,                            -- 50
            'IMPORTE 12 HS DIFERIDO'        = @o_i_12h_dif,
            'IMPORTE 24 HS DIFERIDO'        = @o_i_24h_dif,
            'IMPORTE 48 HS'                 = @o_i_48h,
            'IMPORTE 72 HS DIFERIDO'        = @o_i_72h_diferido,
            'IMPORTE REMESAS DIFERIDO'      = @o_i_rem_diferido,
            'IMPORTE CONTINGENTE'           = @o_i_contingente,
            'IMPORTE RETENCIONES'           = @o_i_retenciones,
            'TIPO DE PROMEDIO'              = @o_c_tipo_promedio,
            'IMPORTE INTERES HOY'           = @o_i_interes_hoy,
            'IMPORTE ACRED. DIFERIDAS'      = @o_i_acreditaciones_diferid,                         -- 60
            'TOTAL IMP. DEPOSITO EFECTIVO'  = @o_i_acum_efectivo,
            'MARCA DE CREDITO DE 24 HS'     = @o_m_cred_24h,
            'IMPORTE DE SALDO INTERESES'    = @o_i_saldo_interes,
            'CANTIDAD DE SUSPENSOS'         = @o_q_suspensos,
            'FECHA ULTIMO MOVIMIENTO INT'   = @o_f_ultimo_movim_int,
            'FECHA DE ULTIMA ACTUALI.'      = @o_f_ultima_actualizacion,
            'CANTIDAD DE TRANSACCIONES'     = @o_q_contador_trx,
            'CANTIDAD FORMA FIRMA'          = @o_q_contador_firma,
            'CANTIDAD DE DEBITOS'           = @o_q_contador_deb,
            'CANTIDAD DE CREDITOS'          = @o_q_contador_cre,                                   -- 70
            'CONTADOR DEBITOS ATM'          = @o_q_contador_deb_ATM,
            'CONTADOR CREDITOS ATM'         = @o_q_contador_cre_ATM,
            'IMPORTE SALARIO MENSUAL'       = @o_i_salario_mensual,
            'IMPORTE EXTRACCION SALARIO'    = @o_i_tot_ext_salario,
            'MONTO SALDO AYER IDEM'         = @o_i_saldo_ayer_idem,                                -- 75
            'MARCA SOLIDARIA'               = @o_m_solidaria                   -- [ NULL , 1 O 2 ]
         end
         else
         begin                                                       -- @i_tipo_consulta = 'R'
            /*******************************************/
            /*  VERSION RESUMIDA DE DATOS MONETARIOS   */
            /*******************************************/
            /* ENVIO AL FRONT END LOS DATOS MONETARIOS */
            /*******************************************/
            select
            'IMPORTE REMESAS'               = @o_i_remesas,                                        --  1
            'IMPORTE REMESAS HOY'           = @o_i_remesas_hoy,
            'SALDO DISPONIBLE'              = @o_i_disponible,
            'PROMEDIO DISPONIBLE'           = @o_p_disponible,
            'SALDO CONTABLE'                = @o_i_saldo_contable,
            'SALDO PARA GIRAR'              = @o_i_saldo_para_girar,
            'MONTO SOBREGIRO OCASIONAL'     = @o_i_sobregiro_ocasional,
            'MONTO SOBREGIRO CONTRATADO'    = @o_i_sobregiro_contratado,
            'CANT. DE DIAS TRANSITORIOS'    = @o_q_dias_sobregiro,
            'MONTO BLOQUEO DE VALORES'      = @o_i_bloqueo_valores,                                -- 10
            'CANT. BLOQUEOS DE MOVIMIENTOS' = @o_q_bloqueos_movimientos,
            'FECHA ULTIMO MOVIMIENTO'       = @o_f_ultimo_movimiento,
            'PROMEDIO CONTABLE POSITIVO'    = @o_p_contable_positivo,
            'SALDO AYER'                    = @o_i_saldo_ayer,
            'INTERESES DEVENGADOS'          = @o_i_interes_deven,
            'MAYOR SALDO ULT. 6 MESES'      = @o_i_saldo_6_meses,
            'IMPORTE PROM. ULT. 6 MESES'    = @o_i_promedio_6_meses,
            'CODIGO TIPO IVA'               = @o_c_tipo_iva,
            'DESCRIPCION TIPO IVA'          = @o_d_tipo_iva,
            'TASA EXENCION IVA'             = @o_p_tasa_exencion,                                  -- 20
            'FECHA VENC. EXENCION IVA'      = @o_f_vencimiento_exencion,
            'TASA REDUCCION IVA'            = @o_p_tasa_reduccion,
            'FECHA VENC. REDUCCION IVA'     = @o_f_vencimiento_reduccion,
            'CODIGO TIPO GANANCIA'          = @o_c_tipo_gan,
            'DESCRIPCION TIPO GANACIA'      = @o_d_tipo_gan,
            'TASA EXENCION GANANCIAS'       = @o_p_tasa_exencion_gan,
            'FECHA VENC. EXEN.GANANCIAS'    = @o_f_vencimiento_exencion_gan,
            'TASA DE EXENCION SELLADO'      = @o_p_tasa_exen_sellado,
            'FECHA VENC. EXEN.SELLADO'      = @o_f_venc_exen_sellado,
            'CANTIDAD DE SUSPENSOS'         = @o_q_suspensos                                       -- 30
         end
      end
   end

   /* CONSULTA DE DESCUBIERTOS Y CHEQUES */
   if @i_tipo_operacion in( 'C' , 'T' )
   begin
      if @w_f_proceso is null
      begin -- LA FECHA DE SOLICIUTUD ES OBLIGATORIA
         select @w_n_error = 24083

         goto TRATA_ERROR
      end   -- LA FECHA DE SOLICIUTUD ES OBLIGATORIA

      /* CONSULTA DE GRILLA DE DESCUBIERTOS */
      if @i_opcion = 'G'
      begin
         set rowcount 20

         /**************************************************/
         /* ENVIO AL FRONT END LOS REGISTROS SELECCIONADOS */
         /**************************************************/
         select
         'TIPO'                = sb_tipo,
         'LINEA'               = sb_linea_credito,
         'DESCRIPCION'         = lc_descripcion,
         'FECHA AUTORIZACION'  = convert(varchar(10),sb_fecha_aut, @i_formato_fecha),
         'MONTO'               = sb_monto_aut,
         'FECHA VENCIMIENTO'   = convert(varchar(10),sb_fecha_ven, @i_formato_fecha),
         'NRO. ACUERDO'        = sb_secuencial,
         'TASA'                = sb_tasa_int,
         'TIPO TASA'           = case
                                    when sb_tipo_tasa = 'F'
                                       then 'FIJA'
                                    when sb_tipo_tasa = 'V'
                                       then 'VARIABLE'
                                    when sb_tipo_tasa = 'P'
                                       then 'FIJA X PER'
                                    else
                                       sb_tipo_tasa
                                 end,
         'DESVIO'              = sb_desvio,
         'T. DESVIO'           = sb_tipo_desvio,
         'PLAZO'               = sb_plazo,
         'LIQUIDACION'         = sb_liq_fin_mes,
         'RENOV. AUTOMATICA'   = sb_renov_automatica,
         'NRO. RENOV.'         = sb_numero_renov,
         'CANT. RENOV.'        = sb_cantidad_renov,
         '% DISM. CAP.'        = sb_porc_dismin_cap,
         'NRO. ACUERDO ANT.'   = sb_num_acuerdo_ant,
         'NRO. ACUERDO ORIGEN' = sb_num_acuerdo_ori,
         'FECHA ALTA ORIGEN'   = convert(varchar(10),sb_alta_acuerdo_ori, @i_formato_fecha),
         'AUTORIZANTE'         = sb_autorizante,
         'GARANTIA'            = sb_garantia,
         'NRO. CONTRATO'       = sb_contrato
         from cob_cuentas..cc_sobregiro, cob_cuentas..cc_ctacte, cc_linea_credito
         where sb_cuenta         = @o_n_ctacte
         and   sb_fecha_ven     >= convert(char(8),@w_f_proceso,1)
         and   cc_ctacte         = @o_n_ctacte
         and   sb_linea_credito *= lc_linea_credito
         and   cc_estado        <> 'C'
         and   sb_secuencial     > @i_secuencial
         order by sb_secuencial

         set rowcount 0
      end

      /* CONSULTA DE INFORMACION DE CHEQUES */
      if @i_opcion = 'C'
      begin
         /*  SELECCION DE DESCRIPCION DE CAUSA DE SUSPENSION DEL SERVICIO */
         select @o_d_causal_susp_serv_pagoch = substring(valor,1,30)
         from  cobis..cl_catalogo
         where tabla  =( select cobis..cl_tabla.codigo
                         from  cobis..cl_tabla
                         where tabla = 'cc_causa_sspagoche')
         and   codigo = @o_c_causal_susp_serv_pagoch
         and   estado = 'V'

         /* CONSULTA DE CHEQUES DEVUELTOS */
         select @o_q_devueltos = count(*)
         from cob_cuentas..cc_denuncia
         where dn_cuenta                            = @o_n_ctacte
         and   dn_est_actual                        = 'V'
         and   dn_fec_devolucion                   is not null
         and   convert(smalldatetime, dn_fec_alta) > convert(smalldatetime, dateadd(yy, -1, @w_f_proceso))
         group by dn_cuenta

         /* SI CANTIDA DE CHEQUES DEVUELTOS ES NULL, DEVUELVO CERO */
         if @o_q_devueltos is null
            select @o_q_devueltos = 0

         /* SOLO FRONT END [F] */
         if @i_quien_llama = 'F'
         begin
            /**********************************************************/
            /* ENVIO AL FRONT END LOS DATOS DE DESCUBIERTOS Y CHEQUES */
            /**********************************************************/
            select
            'CANT. CHEQUES ORDEN NO PAGAR'   = @o_q_anulados,                                      -- 1
            'CANT. CHEQUES DEVUELTOS'        = @o_q_devueltos,
            'CANT. CHEQUES SIN FONDOS'       = @o_q_protestos,
            'CANT. CHEQUES FORMA FIRMA'      = @o_q_forma_firma,
            'CANT. CHEQUES JUSTIFICADOS'     = @o_q_prot_justificados,
            'CANT. CHEQUES CERTIFICADOS'     = @o_q_certificados,
            'FECHA SUSP. SERV. PAGO CHEQUES' = @o_f_susp_serv_pagoch,
            'CAUSAL SUSP. SERV.PAGO CHEQUES' = @o_c_causal_susp_serv_pagoch,
            'DES.CAU.SUSP.SERV.PAGO CHEQUES' = @o_d_causal_susp_serv_pagoch,
            'CANT. DE PROTESTOS PERI. ANT.'  = @o_q_protestos_periodo_ant,                         -- 10
            'CANT. CHEQUES RETENIDOS'        = @o_q_retenidos,
            'CANT. CHEQUES CON DEFECTO'      = @o_q_num_chq_defectos,
            'CANT. DE CHEQUERAS'             = @o_q_chequeras,
            'NUMERO DE CHEQUE INICIAL'       = @o_n_cheque_inicial,
            'CANT. CHEQUES REVOCADOS'        = @o_q_revocados                                      -- 15
         end
      end
   end

   /* CONSULTA DE DATOS NO MONETARIOS */
   if @i_tipo_operacion in( 'N' , 'T' )
   begin
      /* SELECCION DE PRODUCTO/PRODUCTO BANCARIO /CATEGORIA PARA DETERMINAR SI LA CUENTA POSEE CAPITALIZACION */
      select distinct vc_producto, me_pro_bancario, vc_categoria
      into #capitalizacion_cc
      from  cob_remesas..pe_val_contratado x (index i_solucion_k1),
            cob_remesas..pe_servicio_per,
            cob_remesas..pe_pro_final,
            cob_remesas..pe_mercado
      where x.vc_producto     = 3
      and   x.vc_servicio_per = sp_servicio_per
      and   sp_servicio_dis   = 1
      and   sp_pro_final      = pf_pro_final
      and   pf_mercado        = me_mercado
      and   me_pro_bancario   = @o_c_prod_banc
      and   x.vc_categoria    = @o_c_categoria

      if @@error <> 0
      begin -- ERROR EN TABLA TEMPORAL
         select @w_n_error = 82451

         goto TRATA_ERROR
      end   -- ERROR EN TABLA TEMPORAL

      /* SE ANALIZA QUE EL PRODUCTO / PRODUCTO BANCARIO Y CATEGORIA, COINCIDA CON EL DE LA CUENTA,
         EN CASO DE SER ASI, IMPLICA QUE LA CUENTA POSEE CAPITALIZACION */
      if exists( select 1
                 from #capitalizacion_cc
                 where vc_producto     = @o_c_producto
                 and   me_pro_bancario = @o_c_prod_banc
                 and   vc_categoria    = @o_c_categoria )
      begin
         select
         @o_m_capitalizacion = 'S',
         @o_d_capitalizacion = 'MENSUAL'
      end
      else
      begin
         select
         @o_m_capitalizacion = 'N',
         @o_d_capitalizacion = 'NO APLICA CAPITALIZACION'
      end

      /* SELECCION DE DESCRIPCION DE MODO DE DESCRIPCION DE CHEQUES */
      select @o_d_modo_deposito_cheques = convert(varchar(30), valor)
      from  cobis..cl_catalogo
      where codigo = @o_c_modo_deposito_cheques
      and   tabla  =( select cobis..cl_tabla.codigo
                      from  cobis..cl_tabla
                      where tabla = 'cc_depcheq' )

       /* EN CASO DE QUE EL CAMPO COMPANIA SEA DISTINTO DE NULL, SE VA A LA TABLA CORRESPONDIENTE A BUSCAR LA DESCRIPCION */
      if @o_c_cias_seguros <> null
      begin
         execute @w_return =  cobis..sp_seguros_compania
         @i_opcion         =  10,
         @i_compania       =  @o_c_cias_seguros,
         @i_operacion      =  'Q',
         @i_tipo_seguro    =  '1',
         @i_modulo         =  3,
         @o_desc_compania  =  @o_d_cias_seguros  output

         if @w_return != 0
         begin
            select @w_n_error = @w_return

            goto TRATA_ERROR
         end
      end

      /* SELECCION DE LA DIRECCION DE CHEQUERA */
      select @o_d_direccion_ch = convert(varchar(64),(di_descripcion + ' ' + convert(varchar(5), di_numero) + '  piso ' +
                                 convert(varchar(3), di_piso) + ' "' + di_depto + '" ' + ' CP '    +
                                 di_postal + ' ' + pv_descripcion))
      from  cobis..cl_direccion, cobis..cl_provincia
      where di_ente      = @o_n_cliente
      and   di_provincia = pv_provincia
      and   di_direccion = @o_c_direccion_ch

      /* SELECCION DE LA DESCRIPCION DE LA DIRECCION DE ENVIO */
      select @o_d_tipo_envio = substring(valor,1,40)
      from  cobis..cl_catalogo
      where tabla  =( select cobis..cl_tabla.codigo
                      from  cobis..cl_tabla
                      where tabla = 'cc_tipo_envio' )
      and   codigo =  @o_c_tipo_dir

      /* SELECCION DE DESCRIPCION DE CICLO */
      select @o_d_ciclo = substring(valor,1,30)
      from  cobis..cl_catalogo
      where tabla  = (select cobis..cl_tabla.codigo
                      from  cobis..cl_tabla
                      where tabla = 'cc_ciclo')
      and   codigo = @o_c_ciclo

      /* SELECCION DE DESCRIPCION DE OTRA CUENTA EN CASO DE QUE EXISTA */
      if @o_m_debitos_otra_cta = 'S'
      begin
         /* SELECCION DE OTRA CUENTA Y SU PRODUCTO */
         select
         @o_n_cuenta_gastos       = do_otra_cuenta,
         @o_c_producto_cta_gastos = do_otro_producto
         from  cob_remesas..re_debito_otra_cta
         where do_cuenta = @o_n_cta_banco

         if @@rowcount != 1
         begin -- NO EXISTE CUENTA_BANCO
            select @w_n_error = 201240

            goto TRATA_ERROR
         end   -- NO EXISTE CUENTA_BANCO

         /* SELECCION DEL DETALLE SEGUN EL PRODUCTO DE [OTRA CUENTA] */
         if @o_c_producto_cta_gastos = 3
            select @o_d_producto_cta_gastos = 'CUENTA CORRIENTE'

         if @o_c_producto_cta_gastos = 4
            select @o_d_producto_cta_gastos = 'CAJA DE AHORROS'
      end

      /* PERSONALIZACION */
      if @o_m_personalizada = 'S'
         select @o_d_personalizada = 'SI'
      else
         select @o_d_personalizada = 'NO'

      /* DETERMINACION DEL TIPO DE PERSONALIZACION */
      select @o_d_tipo_def = substring(valor,1,25)
      from  cobis..cl_catalogo
      where tabla  =( select cobis..cl_tabla.codigo
                      from  cobis..cl_tabla
                      where tabla = 'cl_tdefault' )
      and   codigo = @o_c_tipo_def

      if @w_f_proceso is null
      begin -- LA FECHA DE SOLICIUTUD ES OBLIGATORIA
         select @w_n_error = 24083

         goto TRATA_ERROR
      end   -- LA FECHA DE SOLICIUTUD ES OBLIGATORIA

      /* DETERMINACION DE ASOCIACION DE CONTRATO DE TRANSFERENCIAS [S O N ]*/
      if exists( Select 1
                 FROM cob_remesas..tc_cuenta_contrato cc
                 WHERE cc_estado = 'V'
                            And (cc_cta_banco_ori   = @o_n_cta_banco or cc_cta_banco_des = @o_n_cta_banco)
                            And Exists(
                                        Select 1
                                        From cob_remesas..tc_contrato
                                        Where co_contrato = cc.cc_contrato
                                        And co_estado = 'V'
                                        And co_frecuencia > 0)
                            And exists(
                                        Select 1
                                        From cob_remesas..tc_contrato_asociado
                                        Where ca_contrato = cc.cc_contrato
                                        And ca_afiliacion = cc.cc_afiliacion
                                        And ca_estado = 'V'
                                        And ca_fecha_venc >= convert(smalldatetime, @w_f_proceso)))
         select @o_m_contrato_trasferencia = 'SI'
      else
         select @o_m_contrato_trasferencia = 'NO'

      /* SOLO FRONT END [F] */
      if @i_quien_llama = 'F'
      begin
         /* VERSION COMPLETA DE DATOS NO MONETARIOS */
         if @i_tipo_consulta = 'A'
         begin
            /**********************************************/
            /* ENVIO AL FRONT END LOS DATOS NO MONETARIOS */
            /**********************************************/
            select
            'CODIGO DIRECCION DE CHEQUERA'   = @o_c_direccion_ch,                                  -- 1
            'DESC. DIRECCION DE CHEQUERA'    = @o_d_direccion_ch,
            'CODIGO DE DIRECCION EC'         = @o_c_dir_entrega_correspon,
            'DESCRIPCION DE DIRECCION EC'    = @o_d_entrega_correspon,
            'CODIGO DE CICLO'                = @o_c_ciclo,
            'DESCRIPCION CODIGO DE CICLO'    = @o_d_ciclo,
            'MARCA DE TARJETA DE DEBITO'     = @o_d_tarjeta_debito,
            'MARCA DE CUENTA FUNCIONARIO'    = @o_m_cta_funcionario,           -- [ S O N ]
            'NRO OTRA CUENTA(CTA.GASTOS)'    = @o_n_cuenta_gastos,
            'PROD. OTRA CUENTA(CTA.GASTOS)'  = @o_c_producto_cta_gastos,                           -- 10
            'DESC.PROD.OTRA CTA(CTA.GASTOS)' = @o_d_producto_cta_gastos,
            'CODIGO MODO DEPOSITO CHEQUES'   = @o_c_modo_deposito_cheques,
            'DESC. MODO DEPOSITO CHEQUES'    = @o_d_modo_deposito_cheques,
            'MARCA DE PERSONALIZACION'       = @o_m_personalizada,             -- [ S O N ]
            'DETALLE MARCA PERSONALIZACION'  = @o_d_personalizada,             -- [ SI O NO ]
            'TIPO DE PERSONALIZACION'        = @o_c_tipo_def,
            'DETALLE TIPO PERSONALIZACION'   = @o_d_tipo_def,
            'NUMERO DE PAQUETE'              = @o_n_paquete,
            'MARCA CONTRATO TRANSFERENCIA'   = @o_m_contrato_trasferencia,
            'FECHA DE ULTIMO CORTE'          = @o_f_ult_corte,                                     -- 20
            'SALDO DE ULTIMO CORTE'          = @o_i_saldo_ult_corte,
            'TIPO DE DIRECCION'              = @o_c_tipo_dir,
            'DESCRIPCION TIPO DE DIRECCION'  = @o_d_tipo_envio,
            'MARCA DE CAPITALIZACION'        = @o_m_capitalizacion,
            'DESCRIPCION DE CAPITALIZACION'  = @o_d_capitalizacion,
            'CODIGO DE COMPANIA DE SEGUROS'  = @o_c_cias_seguros,
            'DESC. COMPANIA DE SEGUROS'      = @o_d_cias_seguros,
            'CODIGO OFICINA DE RETENCION'    = @o_c_agen_ec,
            'MARCA COBRO PRIMER MANTE.'      = @o_m_cobro_ec,                  -- [ S O N ]
            'MARCA DE DOC. TRIBUTARIA'       = @o_m_cred_rem,                  -- [ S O N ]        -- 30
            'MARCA DE RESUMEN MAGNETICO'     = @o_m_resumen_mag,               -- [ S O N ]
            'MARCA DE DEPOSITO INICIAL'      = @o_m_deposito_inicial,          -- [ S O N ]
            'CANTIDAD DE SOBREGIROS'         = @o_q_sobregiros,
            'MARCA SOBREGIROS A UTILIZAR'    = @o_m_uso_sobregiro,
            'MARCA DEBITOS OTRA CUENTA'      = @o_m_debitos_otra_cta,          -- [ S O N ]
            'MARCA DE NRO CUENTA ASOCIADA'   = @o_m_num_cta_asoc,              -- [ S O N ]
            'MARCA DE USO REMESAS'           = @o_m_uso_remesas,               -- [ S O N ]
            'FECHA ULTIMA CAPITALIZACION'    = @o_f_ultima_capitalizacion,
            'FECHA PROXIMA CAPITALIZACION'   = @o_f_prox_capitalizacion,
            'MARCA DE CLASIFICACION'         = @o_m_clasificacion,                                 -- 40
            'CLIENTE ENTREGA CORRESPON.'     = @o_n_cliente_ec,
            'NUMERO DEFAULT'                 = @o_n_default                    -- PARA TIPO_DEF <> DE "C"/"D"
         end
         else
         begin                                                       -- @i_tipo_consulta = 'R'
            /**********************************************/
            /*  VERSION RESUMIDA DE DATOS NO MONETARIOS   */
            /**********************************************/
            /**********************************************/
            /* ENVIO AL FRONT END LOS DATOS NO MONETARIOS */
            /**********************************************/
            select
            'CODIGO DIRECCION DE CHEQUERA'  = @o_c_direccion_ch,                                   -- 1
            'DESC. DIRECCION DE CHEQUERA'   = @o_d_direccion_ch,
            'TIPO DE DIRECCION'             = @o_c_tipo_dir,
            'DESCRIPCION TIPO DE DIRECCION' = @o_d_tipo_envio,
            'CODIGO DE DIRECCION EC'        = @o_c_dir_entrega_correspon,
            'DESCRIPCION DE DIRECCION EC'   = @o_d_entrega_correspon,
            'CLIENTE ENTREGA CORRESPON.'    = @o_n_cliente_ec,
            'CODIGO DE CICLO'               = @o_c_ciclo,
            'DESCRIPCION CODIGO DE CICLO'   = @o_d_ciclo,
            'MARCA DE TARJETA DE DEBITO'    = @o_d_tarjeta_debito,                                 --10
            'CODIGO MODO DEPOSITO CHEQUES'  = @o_c_modo_deposito_cheques,
            'DESC. MODO DEPOSITO CHEQUES'   = @o_d_modo_deposito_cheques,
            'DETALLE MARCA PERSONALIZACION' = @o_d_personalizada,              -- [ SI O NO ]
            'TIPO DE PERSONALIZACION'       = @o_c_tipo_def,
            'DETALLE TIPO PERSONALIZACION'  = @o_d_tipo_def,
            'NUMERO DE PAQUETE'             = @o_n_paquete,
            'CODIGO DE COMPANIA DE SEGUROS' = @o_c_cias_seguros,
            'DESC. COMPANIA DE SEGUROS'     = @o_d_cias_seguros,
            'CODIGO OFICINA DE RETENCION'   = @o_c_agen_ec,
            'MARCA DE RESUMEN MAGNETICO'    = @o_m_resumen_mag                 -- [ S O N ]        -- 20
         end
      end
   end

   if @i_tipo_operacion = 'P'
   begin  -- CONSULTA DE DATOS PERSONALIZADOS
      if @w_f_proceso is null
      begin -- LA FECHA DE SOLICIUTUD ES OBLIGATORIA
         select @w_n_error = 24083

         goto TRATA_ERROR
      end   -- LA FECHA DE SOLICIUTUD ES OBLIGATORIA

      /* LLAMADA AL SP DE PERSONALIZACION, PARA TRAER DATOS DE LA PANTALLA DE PERSON */
      exec @w_return = cob_cuentas..sp_cons_ctos_person
      @t_trn         = 30443,
      @s_date        = @w_f_proceso,
      @i_n_cta_banco = @o_n_cta_banco,
      @i_secuencial  = @i_secuencial,
      @i_n_producto  = 3

      if @w_return != 0
      begin
         return @w_return
      end
   end   -- CONSULTA DE DATOS PERSONALIZADOS

   if @i_tipo_operacion = 'Z'
   begin -- CONSULTA DE PROPIETARIOS EN BASE A UNA CUENTA
      if @i_opcion = 'G'
      begin -- GRILLA
         set rowcount 30

         /* SELECCION DE LOS INTEGRANTES DE LA CUENTA */
         select
         'CODIGO'    = en_ente,
         'NOMBRE'    = p_p_apellido + ' ' + substring(p_s_apellido, 1, 15) + ' ' + en_nombre,
         'ROL'       = cl_rol,
         'CED/CUIT'  = en_ced_ruc
         from cobis..cl_ente,
              cobis..cl_cliente,
              cobis..cl_det_producto,
              cob_cuentas..cc_ctacte
         where   cl_det_producto = dp_det_producto
         and     en_ente         = cl_cliente
         and     dp_cuenta       = @i_n_cta_banco
         and     cc_cta_banco    = dp_cuenta
         and     dp_producto     = isnull( @i_n_producto_cobis, 3  )
         and     dp_estado_ser   = isnull( @i_e_cuenta, 'V'        )
         and     cc_moneda       = isnull( @i_c_moneda,  cc_moneda )
         and  (( cl_rol         in( 'T', 'A', @i_c_rol ) and @i_m_todos_roles = 'N'  ) or
               ( @i_m_todos_roles    = 'S' ))
         and   en_ente         > isnull( @i_n_cliente , 0        )
         order by en_ente asc

         set rowcount 0
      end   -- GRILLA
      else
      if @i_opcion = 'L'
      begin -- LOTFOCUS
         /* SELECCION DE LOS INTEGRANTES DE LA CUENTA */
         select p_p_apellido + ' ' + substring( p_s_apellido, 1, 15 ) + ' ' + en_nombre
         from cobis..cl_ente,
              cobis..cl_cliente,
              cobis..cl_det_producto,
              cob_cuentas..cc_ctacte
         where   cl_det_producto = dp_det_producto
         and     en_ente         = cl_cliente
         and     dp_cuenta       = @i_n_cta_banco
         and     cc_cta_banco    = dp_cuenta
         and     dp_producto     = isnull( @i_n_producto_cobis, 3  )
         and     en_ente         = @i_n_cliente
         and     dp_estado_ser   = isnull( @i_e_cuenta, 'V'       )
         and     cc_moneda       = isnull( @i_c_moneda, cc_moneda )
         and  (( cl_rol         in( 'T', 'A', @i_c_rol ) and @i_m_todos_roles = 'N'  ) or
               ( @i_m_todos_roles    = 'S' ))
      end   -- LOTFOCUS
   end   -- CONSULTA DE PROPIETARIOS EN BASE A UNA CUENTA
end   -- SE REALIZAN BUSQUEDAS EN BASE A UNA CUENTA
else
if @i_operacion = 'C'
begin -- SE REALIZAN BUSQUEDAS EN BASE A UN CLIENTE
   if @i_tipo_operacion is null
   begin -- TIPO DE OPERACION ES UN PARAMETRO DE INGRESO OBLIGATORIO
      select @w_n_error = 208277

      goto TRATA_ERROR
   end   -- TIPO DE OPERACION ES UN PARAMETRO DE INGRESO OBLIGATORIO

   /* VALIDO QUE EL CLIENTE EXISTA */
   if not exists( select 1
                  from cobis..cl_ente
                  where en_ente = @i_n_cliente )
   begin -- NO EXISTE CLIENTE
      select @w_n_error = 208277

      goto TRATA_ERROR
   end   -- NO EXISTE CLIENTE

   if @i_tipo_operacion = 'I'
   begin -- CONSULTA CUENTAS EN BASE A CLIENTE, SOLO PARA CUENTAS CORRIENTES
      /* DEVOLUCION DE INFORMACION SEGUN LA OPCION INGRESADA */
      if @i_opcion = 'G'
      begin -- GRILLA
         if @i_m_mesa_cambios = 'N'
         begin
            set rowcount 50

            /*************************************************************************************************/
            /* GRILLA CON CUENTAS DE UN CLIENTE DETERMINADO, SE MUESTRAN TITULARES, COTITULARES Y OPCIONALES */
            /*************************************************************************************************/
            select
            'NUMERO DE CUENTA' = dp_cuenta,
            'NOMBRE'           = substring(cc_nombre,1,48),
            'ROL'              = cl_rol
            from cobis..cl_det_producto,
                 cobis..cl_cliente,
                 cobis..cl_ente,                                        -- SE INTRODUCE LA CL_ENTE PORQUE BENEFICIA COSTOS
                 cob_cuentas..cc_ctacte
            where   dp_det_producto     = cl_det_producto
            and     dp_cuenta           = cc_cta_banco
            and     cl_cliente          = @i_n_cliente
            and     en_ente             = cl_cliente
            and     dp_producto         = isnull( @i_n_producto_cobis, 3 )
            and     cc_estado           = 'A'
            and     dp_estado_ser       = 'V'
            and  (( cl_rol             in( 'T', 'A', @i_c_rol ) and @i_m_todos_roles = 'N'  ) or
                  ( @i_m_todos_roles    = 'S' ))
            and  ( ( @i_m_sin_comp_firm  = 'S' and cc_tipocta = 'C' and cl_rol  <>  @i_c_rol ) or
                   ( @i_m_sin_comp_firm  = 'S' and cc_tipocta = 'P' ) or
                   ( @i_m_sin_comp_firm  = null ))
            and     cc_moneda           = isnull( @i_c_moneda,    cc_moneda )
            and     cc_cta_banco        > isnull( @i_n_cta_banco, '0' )
            and   ( @i_m_macro_adelanto = 'S' or  cc_prod_banc <> 26)
            order by cc_cta_banco

            set rowcount 0
         end

         if @i_m_mesa_cambios = 'S'
         begin
            set rowcount 50

            /*************************************************************************************************/
            /* GRILLA CON CUENTAS DE UN CLIENTE DETERMINADO, SE MUESTRAN TITULARES, COTITULARES Y OPCIONALES */
            /*************************************************************************************************/
            select
            'NUMERO DE CUENTA' = dp_cuenta,
            'NOMBRE'           = substring(cc_nombre,1,48),
            'ROL'              = cl_rol
            from cobis..cl_det_producto,
                 cobis..cl_cliente,
                 cobis..cl_ente,                                        -- SE INTRODUCE LA CL_ENTE PORQUE BENEFICIA COSTOS
                 cob_cuentas..cc_ctacte
            where   dp_det_producto     = cl_det_producto
            and     dp_cuenta           = cc_cta_banco
            and     cl_cliente          = @i_n_cliente
            and     en_ente             = cl_cliente
            and     dp_producto         = isnull( @i_n_producto_cobis, 3 )
            and     cc_estado           = 'A'
            and     dp_estado_ser       = 'V'
            and ((((cl_rol             in( 'T', 'A', @i_c_rol ) and @i_m_todos_roles = 'N'  ) or
                  ( @i_m_todos_roles    = 'S' )) and @i_c_moneda <> 2  ) or
                   (@i_c_moneda = 2 and cl_rol = 'T') )
            and  ( ( @i_m_sin_comp_firm  = 'S' and cc_tipocta = 'C' and cl_rol  <>  @i_c_rol ) or
                   ( @i_m_sin_comp_firm  = 'S' and cc_tipocta = 'P' ) or
                   ( @i_m_sin_comp_firm  = null ))
            and     cc_moneda           = isnull( @i_c_moneda,    cc_moneda )
            and     cc_cta_banco        > isnull( @i_n_cta_banco, '0' )
            and   ( @i_m_macro_adelanto = 'S' or  cc_prod_banc <> 26)
            order by cc_cta_banco

            set rowcount 0
         end
      end   -- GRILLA
      else
      if @i_opcion = 'L'
      begin -- LOTFOCUS
         /* VALIDO QUE LA CUENTA POSEA UN CLIENTE TITULAR - COTITULAR U OPCIONAL, ADEMAS DEVUELVO EL NOMBRE DE LA CUENTA */
         select cc_nombre
         from cobis..cl_det_producto,
              cobis..cl_cliente,
              cobis..cl_ente,                                        -- SE INTRODUCE LA CL_ENTE PORQUE BENEFICIA COSTOS
              cob_cuentas..cc_ctacte
         where   dp_det_producto     = cl_det_producto
         and     dp_cuenta           = cc_cta_banco
         and     en_ente             = cl_cliente
         and     cl_cliente          = @i_n_cliente
         and     dp_producto         = isnull( @i_n_producto_cobis, 3 )
         and     cc_estado           = 'A'
         and     dp_estado_ser       = 'V'
         and  (( cl_rol             in( 'T', 'A', @i_c_rol ) and @i_m_todos_roles = 'N'  ) or
               ( @i_m_todos_roles    = 'S' ))
         and  (( @i_m_sin_comp_firm  = 'S' and cc_tipocta = 'C' and cl_rol  <>  @i_c_rol ) or  -- ESTA OPCION INDICA QUE NO SE TRAE EL CLIENTE CON EL ROL QUE SE ENVIO, PERTENCIENTE A COMPANIA
               ( @i_m_sin_comp_firm  = 'S' and cc_tipocta = 'P' ) or
               ( @i_m_sin_comp_firm  = null ))
         and     cc_moneda           = isnull( @i_c_moneda, cc_moneda )
         and     dp_cuenta           = @i_n_cta_banco
         and   ( @i_m_macro_adelanto = 'S' or  cc_prod_banc <> 26)

         if @@rowcount = 0
         begin -- CUENTA NO EXISTENTE O CLIENTE NO APTO PARA OPERACIONES
            select @w_n_error = 208278

            goto TRATA_ERROR
         end   -- CUENTA NO EXISTENTE O CLIENTE NO APTO PARA OPERACIONES
      end   -- LOTFOCUS
   end   -- CONSULTA CUENTAS EN BASE A CLIENTE, SOLO PARA CUENTAS CORRIENTES
   else
   if @i_tipo_operacion = 'A'
   begin -- CONSULTA CUENTAS EN BASE A CLIENTE, PARA CUENTAS CORRIENTES Y CAJA DE AHORROS
      /* DEVOLUCION DE INFORMACION SEGUN LA OPCION INGRESADA */
      if @i_opcion = 'G'
      begin -- GRILLA
         /* CREACION DE TABLA DONDE GUARDO TODAS LAS CUENTAS INVOLUCRADAS */
         create table #cc_ah_ctas(
         cc_ah_cuenta           char(15)      null,
         cc_ah_nombre           varchar(48)   null,
         cc_ah_producto_cobis   tinyint       null,
         cc_ah_rol              char(1)       null )

         if @@error <> 0
         begin -- ERROR EN TABLA TEMPORAL
            select @w_n_error = 82451

            goto TRATA_ERROR
         end   -- ERROR EN TABLA TEMPORAL

         /**********************************************/
         /* INSERTO LOS REGISTROS EN LA TABLA TEMPORAL */
         /**********************************************/
            insert into #cc_ah_ctas(
            cc_ah_cuenta,   cc_ah_nombre,                cc_ah_producto_cobis,
            cc_ah_rol )
            /* CUENTAS CORRIENTES */
            select
            dp_cuenta,      substring(cc_nombre,1,48),   dp_producto,
            cl_rol
            from cobis..cl_det_producto,
                 cobis..cl_cliente,
                 cobis..cl_ente,                                        -- SE INTRODUCE LA CL_ENTE PORQUE BENEFICIA COSTOS
                 cob_cuentas..cc_ctacte
            where   dp_det_producto     = cl_det_producto
            and     dp_cuenta           = cc_cta_banco
            and     cl_cliente          = @i_n_cliente
            and     en_ente             = cl_cliente
            and     dp_producto         = isnull( @i_n_producto_cobis, 3  )
            and     cc_estado           = 'A'
            and     dp_estado_ser       = isnull( @i_e_cuenta,        'V' )
            and  (( cl_rol             in( 'T', 'A', @i_c_rol ) and @i_m_todos_roles = 'N'  ) or
                  ( @i_m_todos_roles    = 'S' ))
            and  (( @i_m_sin_comp_firm  = 'S' and cc_tipocta = 'C' and cl_rol  <>  @i_c_rol ) or  -- ESTA OPCION INDICA QUE NO SE TRAE EL CLIENTE CON EL ROL QUE SE ENVIO, PERTENECIENTE A COMPANIA
                  ( @i_m_sin_comp_firm  = 'S' and cc_tipocta = 'P' ) or
                  ( @i_m_sin_comp_firm  = null ))
            and     cc_moneda           = isnull( @i_c_moneda,    cc_moneda )
            and   ( @i_m_macro_adelanto = 'S' or  cc_prod_banc <> 26)
         union
            /* CAJA DE AHORROS */
            select
            dp_cuenta,      substring(ah_nombre,1,48),   dp_producto,
            cl_rol
            from cobis..cl_det_producto,
                 cobis..cl_cliente,
                 cobis..cl_ente,                                        -- SE INTRODUCE LA CL_ENTE PORQUE BENEFICIA COSTOS
                 cob_ahorros..ah_cuenta
            where   dp_det_producto     = cl_det_producto
            and     dp_cuenta           = ah_cta_banco
            and     cl_cliente          = @i_n_cliente
            and     en_ente             = cl_cliente
            and     dp_producto         = isnull( @i_n_producto_cobis, 4 )
            and     ah_estado           = 'A'
            and     dp_estado_ser       = isnull( @i_e_cuenta,         'V' )
            and  (( cl_rol             in( 'T', 'A', @i_c_rol ) and @i_m_todos_roles = 'N'  ) or
                  ( @i_m_todos_roles    = 'S' ))
            and  (( @i_m_sin_comp_firm  = 'S' and ah_tipocta = 'C' and cl_rol  <>  @i_c_rol ) or  -- ESTA OPCION INDICA QUE NO SE TRAE EL CLIENTE CON EL ROL QUE SE ENVIO, PERTENCIENTE A COMPANIA
                  ( @i_m_sin_comp_firm  = 'S' and ah_tipocta = 'P' ) or
                  ( @i_m_sin_comp_firm  = null ))
            and     ah_moneda           = isnull( @i_c_moneda,    ah_moneda )

         if @@error <> 0
         begin -- ERROR EN TABLA TEMPORAL
            select @w_n_error = 82451

            goto TRATA_ERROR
         end   -- ERROR EN TABLA TEMPORAL

         /* DEVUELVO LOS REGISTROS AL FRONT END, LO HAGO CADA 50 */
         set rowcount 50

         select
         'NUMERO DE CUENTA' = cc_ah_cuenta,
         'NOMBRE'           = cc_ah_nombre,
         'PRODUCTO'         = cc_ah_producto_cobis,
         'ROL'              = cc_ah_rol
         from #cc_ah_ctas
         where cc_ah_cuenta > isnull( @i_n_cta_banco, '0' )
         order by cc_ah_cuenta

         set rowcount 0
      end
      else
      begin
         if @i_opcion = 'L'
         begin -- LOTFOCUS
            /* CUENTAS CORRIENTES */
            select cc_nombre
            from cobis..cl_det_producto,
                 cobis..cl_cliente,
                 cobis..cl_ente,                                        -- SE INTRODUCE LA CL_ENTE PORQUE BENEFICIA COSTOS
                 cob_cuentas..cc_ctacte
            where   dp_det_producto     = cl_det_producto
            and     dp_cuenta           = cc_cta_banco
            and     cl_cliente          = @i_n_cliente
            and     en_ente             = cl_cliente
            and     dp_producto         = isnull( @i_n_producto_cobis, 3 )
            and     cc_estado           = 'A'
            and     dp_estado_ser       = isnull( @i_e_cuenta,         'V' )
            and  (( cl_rol             in( 'T', 'A', @i_c_rol ) and @i_m_todos_roles = 'N'  ) or
                  ( @i_m_todos_roles    = 'S' ))
            and  (( @i_m_sin_comp_firm  = 'S' and cc_tipocta = 'C' and cl_rol  <>  @i_c_rol ) or  -- ESTA OPCION INDICA QUE NO SE TRAE EL CLIENTE CON EL ROL QUE SE ENVIO, PERTENCIENTE A COMPANIA
                  ( @i_m_sin_comp_firm  = 'S' and cc_tipocta = 'P' ) or
                  ( @i_m_sin_comp_firm  = null ))
            and     cc_moneda           = isnull( @i_c_moneda,    cc_moneda )
            and     dp_cuenta           = @i_n_cta_banco
            and   ( @i_m_macro_adelanto = 'S' or  cc_prod_banc <> 26)

            if @@rowcount = 0
            begin -- SI ME DA CERO, VOY A CAJA DE AHORROS
               select ah_nombre
               from cobis..cl_det_producto,
                    cobis..cl_cliente,
                    cobis..cl_ente,                                        -- SE INTRODUCE LA CL_ENTE PORQUE BENEFICIA COSTOS
                    cob_ahorros..ah_cuenta
               where   dp_det_producto     = cl_det_producto
               and     dp_cuenta           = ah_cta_banco
               and     cl_cliente          = @i_n_cliente
               and     en_ente             = cl_cliente
               and     dp_producto         = isnull( @i_n_producto_cobis, 4   )
               and     ah_estado           = 'A'
               and     dp_estado_ser       = isnull( @i_e_cuenta,         'V' )
               and  (( cl_rol             in( 'T', 'A', @i_c_rol ) and @i_m_todos_roles = 'N'  ) or
                     ( @i_m_todos_roles    = 'S' ))
               and  (( @i_m_sin_comp_firm  = 'S' and ah_tipocta = 'C' and cl_rol  <>  @i_c_rol ) or  -- ESTA OPCION INDICA QUE NO SE TRAE EL CLIENTE CON EL ROL QUE SE ENVIO, PERTENCIENTE A COMPANIA
                     ( @i_m_sin_comp_firm  = 'S' and ah_tipocta = 'P' ) or
                     ( @i_m_sin_comp_firm  = null ))
               and     ah_moneda           = isnull( @i_c_moneda, ah_moneda )
               and     dp_cuenta           = @i_n_cta_banco
               and   ( @i_m_macro_adelanto = 'S' or  ah_prod_banc <> 26)

               if @@rowcount = 0
               begin -- CUENTA NO EXISTENTE O CLIENTE NO APTO PARA OPERACIONES
                  select @w_n_error = 208278

                  goto TRATA_ERROR
               end   -- CUENTA NO EXISTENTE O CLIENTE NO APTO PARA OPERACIONES
            end   -- SI ME DA CERO, VOY A CAJA DE AHORROS
         end   -- LOTFOCUS
         if @i_opcion = 'R'
         begin
            /*SE VALIDA EL MAXIMO DE FILAS PERMITIDA PARA EL RESULTSET DE ESTA OPERACION*/
            if @i_n_filas > 49
            begin
               select @w_n_error = 1850300

               goto TRATA_ERROR
            end

            /*SE CREA LA TABLA DE CUENTAS PARA JUNTAR LAS CTACTE CON LAS CAJAS DE AHORRO*/
            create table #cc_ah_cuentas(
            cc_ah_cta_banco        char(15)          null,
            cc_ah_cuenta           int               null,
            cc_ah_estado           char(1)           null,
            cc_ah_producto         tinyint           null,
            cc_ah_moneda           tinyint           null,
            cc_ah_cliente          int               null,
            cc_ah_nombre           varchar(48)       null,
            cc_ah_producto_cobis   tinyint           null,
            cc_ah_rol              char(1)           null,
            cc_ah_cbu              varchar(22)       null,
            cc_ah_saldo            money             null,
            cc_ah_transaccional    char(1)           null )

            if @@error <> 0
            begin -- ERROR EN TABLA TEMPORAL
               select @w_n_error = 82451

               goto TRATA_ERROR
            end   -- ERROR EN TABLA TEMPORAL

            /*GUARDAMOS EN LA TABLA TEMPORAL LOS PRODUCTOS BANCARIOS*/
            select @w_n_tabla = codigo
            from cobis..cl_tabla
            where tabla = 'bv_prod_bancario'

            select codigo
            into #prod_bancario
            from cobis..cl_catalogo
            where tabla = @w_n_tabla
            and estado = 'V'

            if @@error <> 0
            begin -- ERROR EN TABLA TEMPORAL
               select @w_n_error = 82451

               goto TRATA_ERROR
            end   -- ERROR EN TABLA TEMPORAL

            /*GUARDAMOS EN TABLA TEMPORAL LOS PRODUCTOS BANCARIOS NO TRAN*/
            select @w_n_tabla = codigo
            from cobis..cl_tabla
            where tabla = 'bv_prod_banc_no_tran'

            select codigo
            into #prod_banc_no_tran
            from cobis..cl_catalogo
            where tabla = @w_n_tabla
            and estado = 'V'

            if @@error <> 0
            begin -- ERROR EN TABLA TEMPORAL
               select @w_n_error = 82451

               goto TRATA_ERROR
            end   -- ERROR EN TABLA TEMPORAL

            /**********************************************/
            /* INSERTO LOS REGISTROS EN LA TABLA TEMPORAL */
            /**********************************************/
            insert into #cc_ah_cuentas(
            cc_ah_cta_banco,            cc_ah_cuenta,          cc_ah_estado,
            cc_ah_producto,             cc_ah_moneda,          cc_ah_cliente,
            cc_ah_nombre,               cc_ah_producto_cobis,  cc_ah_rol,
            cc_ah_cbu,                  cc_ah_saldo,           cc_ah_transaccional)
            /* CUENTAS CORRIENTES */
            select
            dp_cuenta,                 cc_ctacte,              cc_estado,
            dp_producto,               cc_moneda,              cc_cliente,
            substring(cc_nombre,1,48), cc_prod_banc,           cl_rol,
            cc_cbu,                    null,                   case when convert(char(10),cc_prod_banc) in (select codigo from #prod_banc_no_tran) then 'N'
                                                                    else null
                                                               end
            from cobis..cl_det_producto,
                 cobis..cl_cliente,
                 cobis..cl_ente,                                        -- SE INTRODUCE LA CL_ENTE PORQUE BENEFICIA COSTOS
                 cob_cuentas..cc_ctacte
            where   dp_det_producto     = cl_det_producto
            and     dp_cuenta           = cc_cta_banco
            and     cl_cliente          = @i_n_cliente
            and     en_ente             = cl_cliente
            and     dp_producto         = isnull( @i_n_producto_cobis, 3  )
            and     dp_estado_ser       = isnull( @i_e_cuenta,        'V' )
            and  (( cl_rol             in( 'T', 'A', @i_c_rol ) and @i_m_todos_roles = 'N'  ) or
                  ( @i_m_todos_roles    = 'S' ))
            and     cc_moneda           = isnull( @i_c_moneda,    cc_moneda )
            and     convert(char(10),cc_prod_banc) in ( select codigo from #prod_bancario)
            union
            /* CAJA DE AHORROS */
            select
            dp_cuenta,                  ah_cuenta,              ah_estado,
            dp_producto,                ah_moneda,              ah_cliente,
            substring(ah_nombre,1,48),  ah_prod_banc,           cl_rol,
            ah_cbu,                     null,                   case when convert(char(10),ah_prod_banc) in (select codigo from #prod_banc_no_tran) then 'N'
                                                                     else null
                                                                end
            from cobis..cl_det_producto,
                 cobis..cl_cliente,
                 cobis..cl_ente,                                        -- SE INTRODUCE LA CL_ENTE PORQUE BENEFICIA COSTOS
                 cob_ahorros..ah_cuenta
            where   dp_det_producto     = cl_det_producto
            and     dp_cuenta           = ah_cta_banco
            and     cl_cliente          = @i_n_cliente
            and     en_ente             = cl_cliente
            and     dp_producto         = isnull( @i_n_producto_cobis, 4 )
            and     dp_estado_ser       = isnull( @i_e_cuenta,         'V' )
            and  (( cl_rol             in( 'T', 'A', @i_c_rol ) and @i_m_todos_roles = 'N'  ) or
                  ( @i_m_todos_roles    = 'S' ))
            and     ah_moneda           = isnull( @i_c_moneda,    ah_moneda )
            and     convert(char(10),ah_prod_banc) in (select codigo from #prod_bancario)

            select
            @o_k_total = @@rowcount,
            @w_n_error = @@error

            if @w_n_error <> 0
            begin -- ERROR EN TABLA TEMPORAL
               select @w_n_error = 82451

               goto TRATA_ERROR
            end   -- ERROR EN TABLA TEMPORAL

            declare cur_cuentas cursor for
            select distinct
            cc_ah_cuenta,
            cc_ah_producto
            from #cc_ah_cuentas
            where cc_ah_cta_banco > isnull( @i_n_cta_banco, '0' )
            order by cc_ah_cta_banco
            for read only

            open cur_cuentas

            fetch cur_cuentas into
            @w_n_cuenta,
            @w_n_producto

            while @@sqlstatus != 2
            begin
               if @@sqlstatus = 1
               begin
                  close cur_cuentas
                  deallocate cursor cur_cuentas

                  select @w_n_error = 149090

                  goto TRATA_ERROR
               end

               select
               @w_i_saldo_contable = null,
               @w_i_saldo_contable = null

               if @w_n_producto = 3
               begin
                  exec @w_return = cob_cuentas..sp_calcula_saldo
                  @t_from             = @w_sp_name,
                  @i_cuenta           = @w_n_cuenta,
                  @i_fecha            = @s_date,
                  @i_ofi              = @s_ofi,
                  @i_lock             = 'N',
                  @i_anula_paq        = 'S',
                  @o_saldo_para_girar = @w_i_saldo_girar    out,
                  @o_saldo_contable   = @w_i_saldo_contable out

                  if @w_return != 0
                  begin
                     select @w_n_error = 601065

                     goto TRATA_ERROR
                  end
               end
               else
               begin
                  exec @w_return = cob_ahorros..sp_ahcalcula_saldo
                  @t_debug            = @t_debug,
                  @t_file             = @t_file,
                  @t_from             = @w_sp_name,
                  @i_cuenta           = @w_n_cuenta,
                  @i_fecha            = @s_date,
                  @i_ofi              = @s_ofi,
                  @i_anula_paq        = 'S',
                  @i_lock             = 'N',
                  @o_saldo_para_girar = @w_i_saldo_girar    out,
                  @o_saldo_contable   = @w_i_saldo_contable out

                  if @w_return != 0
                  begin
                     select @w_n_error = 601065

                     goto TRATA_ERROR
                  end
               end

               /*ACTUALIZAMOS EL SALDO A GIRAR EN LA TABLA TEMPORAL*/
               update #cc_ah_cuentas set
               cc_ah_saldo   = @w_i_saldo_girar
               from #cc_ah_cuentas
               where cc_ah_cuenta = @w_n_cuenta

               if @@error != 0
               begin
                  close cur_cuentas
                  deallocate cursor cur_cuentas

                  select @w_n_error = 605036

                  goto TRATA_ERROR
               end

               fetch cur_cuentas into
               @w_n_cuenta,
               @w_n_producto
            end

            close cur_cuentas
            deallocate cursor cur_cuentas

            /* DEVUELVO EL RESULTSET AL SERVICIO, LA CANTIDAD DE FILAS QUE SE DEVUELVEN SE INDICAN POR PARAMETRO */
            set rowcount @i_n_filas

            select
            'CUENTA'              = cc_ah_cta_banco,
            'ESTADO CUENTA'       = cc_ah_estado,
            'PRODUCTO'            = cc_ah_producto,
            'MONEDA'              = cc_ah_moneda,
            'CLIENTE'             = cc_ah_cliente,
            'NOMBRE DE LA CUENTA' = cc_ah_nombre,
            'PRODUCTO BANCARIO'   = cc_ah_producto_cobis,
            'ROL DEL CLIENTE'     = cc_ah_rol,
            'CBU'                 = cc_ah_cbu,
            'SALDO DISPONIBLE'    = cc_ah_saldo,
            'TRANSACCIONAL'       = cc_ah_transaccional
            from #cc_ah_cuentas
            where cc_ah_cta_banco > isnull( @i_n_cta_banco, '0' )
            order by cc_ah_cta_banco

            select @o_k_pagina = @@rowcount

            set rowcount 0

            /*CONTAMOS LA CANTIDAD DE FILAS QUE FALTAN*/
            select @w_k_filas_restantes = count(1)
            from #cc_ah_cuentas
            where cc_ah_cta_banco > isnull( @i_n_cta_banco, '0' )

            /*DEVOLVEMOS POR PARAMETRO DE SALIDA SI QUEDAN MAS REGISTROS*/
            select @o_m_hay_mas = case when @w_k_filas_restantes > @i_n_filas then 'S'
                                       else 'N'
                                  end
         end
      end
   end   -- CONSULTA CUENTAS EN BASE A CLIENTE, PARA CUENTAS CORRIENTES Y CAJA DE AHORROS
   if @i_tipo_operacion = 'B'
   begin  --CONSULTA CUENTAS EN BASE A CLIENTE-MONEDA-PRODUCTO
      if @i_opcion = 'G'
      begin  -- GRILLA

         set rowcount @i_n_filas

         select
         'NRO CTA'       = cc_cta_banco,
         'NOMBRE CUENTA' = substring( cc_nombre, 1, 48),
         'ROL'           = cl_rol,
         'PROD. BANC.'   = cc_prod_banc,
         'CATEGORIA'     = cc_categoria,
         'ESTADO'        = cc_estado
         from cob_cuentas..cc_ctacte,
              cobis..cl_cliente,
              cobis..cl_det_producto,
              cobis..cl_ente
         where cl_cliente      = @i_n_cliente
         and   dp_cuenta       = cc_cta_banco
         and   dp_det_producto = cl_det_producto
         and   dp_producto     = isnull( @i_n_producto_cobis, 3 )
         and   dp_producto     = cc_producto
         and   en_ente         = cl_cliente
         and   en_ente         = @i_n_cliente
         and   cl_rol          = isnull( @i_c_rol, cl_rol    )
         and   cc_estado       = isnull( @i_e_cuenta, cc_estado )
         and   cc_moneda       = isnull( @i_c_moneda, cc_moneda )
         and   cc_cta_banco    > isnull( @i_n_cta_banco, '0' )
         order by cc_cta_banco

         set rowcount 0
      end    -- GRILLA
   end    --CONSULTA CUENTAS EN BASE A CLIENTE-MONEDA-PRODUCTO ALIENTE-MONEDA-PRODUCTO
end   -- SE REALIZAN BUSQUEDAS EN BASE A UN CLIENTE
else
if @i_operacion = 'P'
begin -- SE REALIZAN BUSQUEDAS EN BASE A UN PAQUETE
   if @i_tipo_operacion is null
   begin -- TIPO DE OPERACION ES UN PARAMETRO DE INGRESO OBLIGATORIO
      select @w_n_error = 208277

      goto TRATA_ERROR
   end   -- TIPO DE OPERACION ES UN PARAMETRO DE INGRESO OBLIGATORIO
   else
   if @i_tipo_operacion = 'C'
   begin -- CONSULTA CUENTAS EN BASE A PAQUETE
      /* SE VALIDA QUE LOS PARAMETROS DE INGRESO ESTEN TODOS */
      if @i_n_paquete = null
      begin -- PARAMETRIA DE ENTRADA INCOMPLETA
         select @w_n_error = 209138

         goto TRATA_ERROR
      end   -- PARAMETRIA DE ENTRADA INCOMPLETA

      /* SELECCIONO DE LA TABLA DE PAQUETE LOS DATOS NECESARIOS */
      select @w_e_paquete = gp_estado_pq
      from cob_remesas..pa_gestion_paquete
      where gp_numpq = @i_n_paquete

      if @@rowcount <> 1
      begin -- NO EXISTE EL PAQUETE
         select @w_n_error = 209027

         goto TRATA_ERROR
      end   -- NO EXISTE EL PAQUETE

      /* CONTROLO QUE EL ESTADO DEL PAQUETE ESTE VIGENTE */
      if @w_e_paquete <> 'A'
      begin -- PAQUETE NO VIGENTE
         select @w_n_error = 209001

         goto TRATA_ERROR
      end   -- PAQUETE NO VIGENTE

      /* DEVOLUCION DE INFORMACION SEGUN LA OPCION INGRESADA */
      if @i_opcion = 'G'
      begin -- GRILLA
         set rowcount 30

         /****************************************************************************************/
         /* LEVANTO LOS DATOS NECESARIOS DE LA TABLA DE PAQUETE Y MONEDA Y LO ENVIO COMO SALIDA  */
         /****************************************************************************************/
         select
         'CUENTA'             = substring( np_negocio,     1, 15 ),            -- CUENTA LARGA
         'PRODUCTO_COBIS'     = np_prod_cobis_pr,                              -- PRODUCTO COBIS
         'MONEDA'             = np_moneda_negocio,                             -- MONEDA
         'DESCRIPCION_MONEDA' = substring( mo_descripcion, 1, 32 )             -- DESCRIPCION DE LA MONEDA
         from cob_remesas..pa_negocio_paquete,
              cobis..cl_moneda
         where np_numpq      =  @i_n_paquete
         and   mo_moneda    =*  np_moneda_negocio
         and   mo_moneda     = isnull( @i_c_moneda, mo_moneda )
         and   np_negocio    > isnull( @i_n_cta_banco, '0' )
         order by np_negocio

         set rowcount 0
      end   -- GRILLA
      if @i_opcion = 'L'
      begin -- VALIDA QUE LA CUENTA + PAQUETE EXISTA
         if not exists( select 1
                        from cob_remesas..pa_negocio_paquete,
                             cobis..cl_moneda
                        where np_numpq    =  @i_n_paquete
                        and   mo_moneda  =*  np_moneda_negocio
                        and   np_negocio  =  @i_n_cta_banco
                        and   mo_moneda   = isnull( @i_c_moneda, mo_moneda ))
         begin -- NO SE ENCONTRO CUENTA ASOCIADA AL PAQUETE
            select @w_n_error = 209063

            goto TRATA_ERROR
         end   -- NO SE ENCONTRO CUENTA ASOCIADA AL PAQUETE
      end   -- VALIDA QUE LA CUENTA + PAQUETE EXISTA
   end   -- CONSULTA CUENTAS EN BASE A PAQUETE
end   -- SE REALIZAN BUSQUEDAS EN BASE A UN PAQUETE

return 0

/* TRATAMIENTO DE ERROR Y FINALIZACION DEL PROCESO */
TRATA_ERROR:

if @w_n_error != 0 and @i_quien_llama = 'F'
begin -- EN CASO DE NUMERO DE ERROR DISTINTO A CERO Y SI NO ME INDICAN LA PROCEDENCIA, SE LLAMA AL SP_CERROR
   exec cobis..sp_cerror
   @t_debug = @t_debug,
   @t_file  = @t_file,
   @t_from  = @w_sp_name,
   @i_num   = @w_n_error
end   -- EN CASO DE NUMERO DE ERROR DISTINTO A CERO Y SI NO ME INDICAN LA PROCEDENCIA, SE LLAMA AL SP_CERROR

return @w_n_error

/*<returns>
<return value = "0"        description = "EJECUCION EXITOSA" />

<error value = "101045"    description = "NO EXISTE MONEDA" />
<error value = "201004"    description = "CUENTA NO EXISTE" />
<error value = "151604"    description = "NO EXISTE OFICINA" />
<error value = "101185"    description = "NO EXISTE RESIDENCIA" />
<error value = "149309"    description = "NO EXISTE EL OFICIAL" />
<error value = "82451"     description = "ERROR EN TABLA TEMPORAL" />
<error value = "209001"    description = "PAQUETE NO VIGENTE" />
<error value = "209027"    description = "NO EXISTE EL PAQUETE" />
<error value = "201196"    description = "PARAMETRO NO ENCONTRADO" />
<error value = "82375"     description = "ERROR EN CONSULTA DE IVA" />
<error value = "101021"    description = "NO EXISTE TIPO DE PERSONA" />
<error value = "301016"    description = "NO EXISTE CATEGORIA DE FIRMA" />
<error value = "201018"    description = "NO EXISTE CATEGORIA DE CUENTA" />
<error value = "201285"    description = "PRODUCTO BANCARIO INEXISTENTE" />
<error value = "201048"    description = "ERROR EN CODIGO DE TRANSACCION" />
<error value = "141231"    description = "TIPO DE PRODUCTO BCRA NO EXISTE" />
<error value = "@w_return" description = "VARIABLE GENERICA/DEVOLUCION SP" />
<error value = "209138"    description = "PARAMETRIA DE ENTRADA INCOMPLETA" />
<error value = "2809062"   description = "ERROR CONSULTANDO ESTADO DE LA CUENTA" />
<error value = "201240"    description = "CTA. DEBITA EN OTRA CTA. Y ESTA NO EXISTE" />
<error value = "209063"    description = "NO SE ENCONTRO CUENTA ASOCIADA AL PAQUETE" />
<error value = "720132"    description = "NO EXISTE COMPAðIA DEFAULT PARA EL RUBRO DE SEGURO" />
<error value = "208277"    description = "TIPO DE OPERACION ES UN PARAMETRO DE INGRESO OBLIGATORIO" />
<error value = "208278"    description = "CUENTA CON CLIENTE NO EXISTENTE O NO APTO PARA OPERACIONES" />

<recordset>

<column name="" datatype="" datalength="" description="" />

</recordset>

</returns>*/

--<keyword>sp_cc_cuenta</keyword>

--<keyword>CUENTAS CORRIENTES - CONSULTAS ESPECIFICAS </keyword>
--<keyword>DATOS GENERALES - DATOS MONETARIOS - DATOS NO MONETARIOS </keyword>
--<keyword>DATOS DE INTEGRANTES DE CUENTAS </keyword>
--<keyword>DATOS DE PROPIETARIOS DE CUENTA </keyword>

/* <dependency ObjName=" cobis..sp_cerror"                 xtype="P" dependentObjectName="cob_cuentas..sp_cc_cuenta" dependentObjectType="P" />*/
/* <dependency ObjName=" cob_cuentas..sp_calcula_saldo"    xtype="P" dependentObjectName="cob_cuentas..sp_cc_cuenta" dependentObjectType="P" />*/
/* <dependency ObjName=" cob_cuentas..sp_cons_ctos_person" xtype="P" dependentObjectName="cob_cuentas..sp_cc_cuenta" dependentObjectType="P" />*/
go
