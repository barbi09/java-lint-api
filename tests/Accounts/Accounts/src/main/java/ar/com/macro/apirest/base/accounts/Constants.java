package ar.com.macro.apirest.base.accounts;


public class Constants {
    // Operaciones
    public static final String OP_GET_LIST = "get-list";
    public static final String OP_GET_BALANCE = "get-balance";
    public static final String OP_GET_DETAIL= "get-detail";
    public static final String OP_GET_MOVEMENTS = "get-movements";

    // WebClientBackends constants
    public static final String HEADER_AUTHORIZATION = "Authorization";
    public static final String BACKEND_CTS_REST_EXECUTOR = "cts-rest-executor";
    public static final String BACKEND_CTS_REST_EXECUTOR_SP_EXECUTE ="sp-execute";
    public static final String ERROR_CODE_409 = "ER-409";

    public static final String CTS_REST_EXECUTOR_SP_LONG_NAME = "cob_cuentas..sp_cc_cuenta";
    public static final String CTS_REST_EXECUTOR_SP_LONG_NAME_GET_MOVEMENTS = "cob_cuentas..sp_cc_ah_consulta_millas";

    public static final String CTS_REST_EXECUTOR_TRANSACTION_CODE = "30420";
    public static final String CTS_REST_EXECUTOR_TRANSACTION_CODE_GET_MOVEMENTS = "30774";

    public static final Integer CTS_REST_EXECUTOR_DATA_TYPE_VARCHAR = 39;
    public static final Integer CTS_REST_EXECUTOR_DATA_TYPE_NCHAR = 47;
    public static final Integer CTS_REST_EXECUTOR_DATA_TYPE_TINYINT = 48;
    public static final Integer CTS_REST_EXECUTOR_DATA_TYPE_SMALLINT = 52;
    public static final Integer CTS_REST_EXECUTOR_DATA_TYPE_INT = 56;
    public static final Integer CTS_REST_EXECUTOR_DATA_TYPE_MONEY = 60;
    public static final Integer CTS_REST_EXECUTOR_DATA_TYPE_SMALLDATETIME = 61;

    public static final Integer CTS_REST_EXECUTOR_DATA_VALUE_IKREGISTROS= 50;

    public static final String CTS_REST_EXECUTOR_C_OPERATION = "C";
    public static final String CTS_REST_EXECUTOR_Q_OPERATION = "Q";

    public static final String CTS_REST_EXECUTOR_OPERATION_A_TYPE = "A";
    public static final String CTS_REST_EXECUTOR_OPERATION_C_TYPE = "C";

    public static final String CTS_REST_EXECUTOR_R_CHOICE = "R";
    public static final String CTS_REST_EXECUTOR_S_CHOICE = "S";
    public static final String CTS_REST_EXECUTOR_B_CHOICE = "B";
    public static final String CTS_REST_EXECUTOR_DATE_FORMAT_YYYYMMDD = "112";
    public static final Integer CTS_REST_EXECUTOR_MAX_DATE_RANGE = 30;

    // AppResponseMapper constants
    public static final String RESPONSE_CTS_REST_EXECUTOR_SP_CC_CUENTA_GET_LIST = "sp_cc_cuenta_get_list";
    public static final String RESPONSE_CTS_REST_EXECUTOR_SP_CC_CUENTA_GET_BALANCE = "sp_cc_cuenta_get_balance";
    public static final String RESPONSE_CTS_REST_EXECUTOR_SP_CC_CUENTA_GET_DETAIL = "sp_cc_cuenta_get_detail";
    public static final String RESPONSE_CTS_REST_EXECUTOR_SP_CC_CONSULTA_MILLAS = "sp_cc_ah_consulta_millas";
    public static final String REQUEST_CTS_REST_EXECUTOR_I_N_FILAS_DEFAULT = "20";

    // Message errors
    public static final String MESSAGE_ERROR_DATE_INVALID = "Fecha date-to no puede ser mayor al date-from";
    public static final String MESSAGE_ERROR_DATE_RANGE_INVALID = "Fecha desde / hasta superan 30 dias";

    // Dates
    public static final String DATE_FORMAT_YYMMDD = "yyMMdd";
}
