package ar.com.macro.apirest.base.accounts.webclient;

import ar.com.macro.DTO.Requests.ParamDTO;
import ar.com.macro.RestExecutor;
import ar.com.macro.apirest.base.accounts.Constants;
import ar.com.macro.config.HttpClientsConfig;
import ar.com.macro.domain.ResponseWrapper;
import ar.com.macro.exceptions.BackendErrorStatusHandlerImpl;
import ar.com.macro.exceptions.CustomException;
import ar.com.macro.exceptions.ExceptionDetails;
import ar.com.macro.oauth.Token.Token;
import ar.com.macro.oauth.Token.TokenManager;
import ar.com.macro.utils.CommonRequestUtils;
import ar.com.macro.utils.DateUtils;
import ar.com.macro.utils.Utils;
import ar.com.macro.utils.VContext;
import com.fasterxml.jackson.core.type.TypeReference;
import lombok.RequiredArgsConstructor;
import lombok.SneakyThrows;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.server.reactive.ServerHttpRequest;
import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.client.WebClient;
import reactor.core.publisher.Mono;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

/**Esta clase es la encargada de ejecutar las llamadas a los servicios*/
@Service
@RequiredArgsConstructor
public class WebClientBackends {

    @Value("${http-clients.backends.cts-rest-executor.idTokenInfo}") private String ctsRestExecutorIdTokenInfo;
    @Autowired private TokenManager tm;
    @Autowired private final CommonRequestUtils ru;
    private final HttpClientsConfig clients;
    private static final String clientsData;
    private final BackendErrorStatusHandlerImpl sh = new BackendErrorStatusHandlerImpl();

    //Operation: get-list
    public Mono<ResponseWrapper> CTS_REST_EXECUTOR_sp_cc_cuenta_get_list(ServerHttpRequest request, HashMap<String, ResponseWrapper> responses) {
        String traceId = VContext.getTraceId();
        return tm.getToken(ctsRestExecutorIdTokenInfo, traceId)
                .flatMap(token -> backend_CTS_REST_EXECUTOR_sp_cc_cuenta_get_list(traceId, request, token))
                .doOnNext(response -> responses.put(Constants.RESPONSE_CTS_REST_EXECUTOR_SP_CC_CUENTA_GET_LIST, response));
    }
    @SneakyThrows
    private Mono<ResponseWrapper> backend_CTS_REST_EXECUTOR_sp_cc_cuenta_get_list(String traceId, ServerHttpRequest request, Token token) {
        HashMap<String, String> headers = new HashMap<>();
        headers.put(Constants.HEADER_AUTHORIZATION, token.getAuthorization());

        //Required headers
        String customerId = request.getHeaders().get("x-customer-id").get(0);
        String channel = request.getHeaders().get("x-channel").get(0);
        String recordsNumber = request.getQueryParams().getFirst("records-number");
        String lastRecord = request.getQueryParams().getFirst("last-record");

        RestExecutor re = new RestExecutor();

        ParamDTO t_trn = new ParamDTO("@t_trn", Constants.CTS_REST_EXECUTOR_TRANSACTION_CODE, Constants.CTS_REST_EXECUTOR_DATA_TYPE_SMALLINT);
        ParamDTO i_operacion = new ParamDTO("@i_operacion", Constants.CTS_REST_EXECUTOR_C_OPERATION, Constants.CTS_REST_EXECUTOR_DATA_TYPE_NCHAR);
        ParamDTO i_tipo_operacion = new ParamDTO("@i_tipo_operacion", Constants.CTS_REST_EXECUTOR_OPERATION_A_TYPE, Constants.CTS_REST_EXECUTOR_DATA_TYPE_NCHAR);
        ParamDTO i_opcion = new ParamDTO("@i_opcion", Constants.CTS_REST_EXECUTOR_R_CHOICE, Constants.CTS_REST_EXECUTOR_DATA_TYPE_NCHAR);
        ParamDTO i_n_cliente = new ParamDTO("@i_n_cliente", customerId, Constants.CTS_REST_EXECUTOR_DATA_TYPE_INT);
        ParamDTO i_n_canal = new ParamDTO("@i_n_canal", channel, Constants.CTS_REST_EXECUTOR_DATA_TYPE_SMALLINT);
        ParamDTO i_n_filas = new ParamDTO("@i_n_filas", recordsNumber != null? recordsNumber: Constants.REQUEST_CTS_REST_EXECUTOR_I_N_FILAS_DEFAULT, Constants.CTS_REST_EXECUTOR_DATA_TYPE_TINYINT);
        ParamDTO o_k_total = new ParamDTO("@o_k_total", "", Constants.CTS_REST_EXECUTOR_DATA_TYPE_INT, true);
        ParamDTO o_k_pagina = new ParamDTO("@o_k_pagina", "", Constants.CTS_REST_EXECUTOR_DATA_TYPE_SMALLINT, true);
        ParamDTO o_m_hay_mas = new ParamDTO("@o_m_hay_mas", "", Constants.CTS_REST_EXECUTOR_DATA_TYPE_NCHAR, true);
        ParamDTO o_n_ultimo_id = new ParamDTO("@o_n_ultimo_id", "", Constants.CTS_REST_EXECUTOR_DATA_TYPE_VARCHAR, true);

        List<ParamDTO> paramList;
        if (lastRecord != null){
            ParamDTO i_n_cta_banco = new ParamDTO("@i_n_cta_banco", lastRecord, Constants.CTS_REST_EXECUTOR_DATA_TYPE_VARCHAR);
            paramList = List.of(t_trn, i_operacion, i_tipo_operacion, i_opcion, i_n_cliente, i_n_canal, i_n_filas, i_n_cta_banco, o_k_total, o_k_pagina, o_m_hay_mas, o_n_ultimo_id);
        } else {
            paramList = List.of(t_trn, i_operacion, i_tipo_operacion, i_opcion, i_n_cliente, i_n_canal, i_n_filas, o_k_total, o_k_pagina, o_m_hay_mas, o_n_ultimo_id);
        }

        String requestBody = re.getRequest(Constants.CTS_REST_EXECUTOR_SP_LONG_NAME, paramList);

        WebClient.RequestHeadersSpec<?> req = clients
                .backend(Constants.BACKEND_CTS_REST_EXECUTOR)
                .endpoint(Constants.BACKEND_CTS_REST_EXECUTOR_SP_EXECUTE)
                .getWebClient()
                .post()
                .contentType(MediaType.APPLICATION_JSON)
                .bodyValue(requestBody);
        req = ru.setHeaders(req, headers, traceId);

        // Lista de códigos de error que deben ignorarse (es decir, no lanzar excepción) para ser tratados de manera particular en el service.
        // En caso de no necesitarse, enviar un null o lista vacía.
        List<HttpStatus> ignoredStatusCodes = List.of();

        return ru.execRequest(req, traceId, ru.mapBody(requestBody, new TypeReference<Object>() {}))
                .doOnNext(resp -> {
                    sh.handle(resp.response(), request.getPath().toString(), traceId, ignoredStatusCodes);
                    re.validateMetadata(re.getResponse(resp.body()).getMetadata(), traceId, request.getPath().toString());
                });
    }

    //Operation: get-balance
    public Mono<ResponseWrapper> CTS_REST_EXECUTOR_sp_cc_cuenta_get_balance(ServerHttpRequest request, HashMap<String, ResponseWrapper> responses, String pathAccountNumber) {
        String traceId = VContext.getTraceId();
        return tm.getToken(ctsRestExecutorIdTokenInfo, traceId)
                .flatMap(token -> backend_CTS_REST_EXECUTOR_sp_cc_cuenta_get_balance(traceId, request, token, pathAccountNumber))
                .doOnNext(response -> responses.put(Constants.RESPONSE_CTS_REST_EXECUTOR_SP_CC_CUENTA_GET_BALANCE, response));
    }

    @SneakyThrows
    private Mono<ResponseWrapper> backend_CTS_REST_EXECUTOR_sp_cc_cuenta_get_balance(String traceId, ServerHttpRequest request, Token token, String pathAccountNumber) {
        HashMap<String, String> headers = new HashMap<>();
        headers.put(Constants.HEADER_AUTHORIZATION, token.getAuthorization());

        //Required headers
        String channel = request.getHeaders().get("x-channel").get(0);
        String customerId = request.getHeaders().get("x-customer-id").get(0);

        RestExecutor re = new RestExecutor();

        ParamDTO t_trn = new ParamDTO("@t_trn", Constants.CTS_REST_EXECUTOR_TRANSACTION_CODE, Constants.CTS_REST_EXECUTOR_DATA_TYPE_SMALLINT);
        ParamDTO i_operacion = new ParamDTO("@i_operacion", Constants.CTS_REST_EXECUTOR_Q_OPERATION, Constants.CTS_REST_EXECUTOR_DATA_TYPE_NCHAR);
        ParamDTO i_tipo_operacion = new ParamDTO("@i_tipo_operacion", Constants.CTS_REST_EXECUTOR_OPERATION_C_TYPE, Constants.CTS_REST_EXECUTOR_DATA_TYPE_NCHAR);
        ParamDTO i_opcion = new ParamDTO("@i_opcion", Constants.CTS_REST_EXECUTOR_S_CHOICE, Constants.CTS_REST_EXECUTOR_DATA_TYPE_NCHAR);
        ParamDTO i_n_cta_banco = new ParamDTO("@i_n_cta_banco", pathAccountNumber, Constants.CTS_REST_EXECUTOR_DATA_TYPE_VARCHAR);
        ParamDTO i_n_cliente = new ParamDTO("@i_n_cliente", customerId, Constants.CTS_REST_EXECUTOR_DATA_TYPE_INT);
        ParamDTO i_n_canal = new ParamDTO("@i_n_canal", channel, Constants.CTS_REST_EXECUTOR_DATA_TYPE_SMALLINT);
        ParamDTO o_c_moneda = new ParamDTO("@o_c_moneda", "", Constants.CTS_REST_EXECUTOR_DATA_TYPE_TINYINT, true);
        ParamDTO o_i_remesas = new ParamDTO("@o_i_remesas", "", Constants.CTS_REST_EXECUTOR_DATA_TYPE_MONEY, true);
        ParamDTO o_i_24h = new ParamDTO("@o_i_24h", "", Constants.CTS_REST_EXECUTOR_DATA_TYPE_MONEY, true);
        ParamDTO o_i_disponible = new ParamDTO("@o_i_disponible", "", Constants.CTS_REST_EXECUTOR_DATA_TYPE_MONEY, true);
        ParamDTO o_i_saldo_contable = new ParamDTO("@o_i_saldo_contable", "", Constants.CTS_REST_EXECUTOR_DATA_TYPE_MONEY, true);
        ParamDTO o_i_saldo_para_girar = new ParamDTO("@o_i_saldo_para_girar", "", Constants.CTS_REST_EXECUTOR_DATA_TYPE_MONEY, true);
        ParamDTO o_i_bloqueo_valores = new ParamDTO("@o_i_bloqueo_valores", "", Constants.CTS_REST_EXECUTOR_DATA_TYPE_MONEY, true);
        ParamDTO o_i_48h = new ParamDTO("@o_i_48h", "", Constants.CTS_REST_EXECUTOR_DATA_TYPE_MONEY, true);
        ParamDTO o_i_valores_suspenso = new ParamDTO("@o_i_valores_suspenso", "", Constants.CTS_REST_EXECUTOR_DATA_TYPE_MONEY, true);
        ParamDTO o_i_acuerdos = new ParamDTO("@o_i_acuerdos", "", Constants.CTS_REST_EXECUTOR_DATA_TYPE_MONEY, true);

        List<ParamDTO> paramList;
        paramList = List.of(t_trn, i_operacion, i_tipo_operacion, i_opcion, i_n_cta_banco, i_n_cliente, i_n_canal, o_c_moneda, o_i_remesas, o_i_24h, o_i_disponible, o_i_saldo_contable, o_i_saldo_para_girar, o_i_bloqueo_valores, o_i_48h, o_i_valores_suspenso, o_i_acuerdos);

        String requestBody = re.getRequest(Constants.CTS_REST_EXECUTOR_SP_LONG_NAME, paramList);

        WebClient.RequestHeadersSpec<?> req = clients
                .backend(Constants.BACKEND_CTS_REST_EXECUTOR)
                .endpoint(Constants.BACKEND_CTS_REST_EXECUTOR_SP_EXECUTE)
                .getWebClient()
                .post()
                .contentType(MediaType.APPLICATION_JSON)
                .bodyValue(requestBody);
        req = ru.setHeaders(req, headers, traceId);

        // Lista de códigos de error que deben ignorarse (es decir, no lanzar excepción) para ser tratados de manera particular en el service.
        // En caso de no necesitarse, enviar un null o lista vacía.
        List<HttpStatus> ignoredStatusCodes = List.of();

        return ru.execRequest(req, traceId, ru.mapBody(requestBody, new TypeReference<Object>() {}))
                .doOnNext(resp -> {
                    sh.handle(resp.response(), request.getPath().toString(), traceId, ignoredStatusCodes);
                    re.validateMetadata(re.getResponse(resp.body()).getMetadata(), traceId, request.getPath().toString());
                });
    }

    //Operation: get-detail
    public Mono<ResponseWrapper> CTS_REST_EXECUTOR_sp_cc_cuenta_get_detail(ServerHttpRequest request, HashMap<String, ResponseWrapper> responses, String pathAccountNumber) {
        String traceId = VContext.getTraceId();
        return tm.getToken(ctsRestExecutorIdTokenInfo, traceId)
                .flatMap(token -> backend_CTS_REST_EXECUTOR_sp_cc_cuenta_get_detail(traceId, request, token, pathAccountNumber))
                .doOnNext(response -> responses.put(Constants.RESPONSE_CTS_REST_EXECUTOR_SP_CC_CUENTA_GET_DETAIL, response));
    }

    @SneakyThrows
    private Mono<ResponseWrapper> backend_CTS_REST_EXECUTOR_sp_cc_cuenta_get_detail(String traceId, ServerHttpRequest request, Token token, String pathAccountNumber) {
        HashMap<String, String> headers = new HashMap<>();
        headers.put(Constants.HEADER_AUTHORIZATION, token.getAuthorization());

        //Required headers
        String channel = request.getHeaders().get("x-channel").get(0);
        String customerId = request.getHeaders().get("x-customer-id").get(0);

        RestExecutor re = new RestExecutor();

        ParamDTO t_trn = new ParamDTO("@t_trn", Constants.CTS_REST_EXECUTOR_TRANSACTION_CODE, Constants.CTS_REST_EXECUTOR_DATA_TYPE_SMALLINT);
        ParamDTO i_operacion = new ParamDTO("@i_operacion", Constants.CTS_REST_EXECUTOR_Q_OPERATION, Constants.CTS_REST_EXECUTOR_DATA_TYPE_NCHAR);
        ParamDTO i_tipo_operacion = new ParamDTO("@i_tipo_operacion", Constants.CTS_REST_EXECUTOR_OPERATION_C_TYPE, Constants.CTS_REST_EXECUTOR_DATA_TYPE_NCHAR);
        ParamDTO i_opcion = new ParamDTO("@i_opcion", Constants.CTS_REST_EXECUTOR_B_CHOICE, Constants.CTS_REST_EXECUTOR_DATA_TYPE_NCHAR);
        ParamDTO i_n_cta_banco = new ParamDTO("@i_n_cta_banco", pathAccountNumber, Constants.CTS_REST_EXECUTOR_DATA_TYPE_VARCHAR);
        ParamDTO i_n_cliente = new ParamDTO("@i_n_cliente", customerId, Constants.CTS_REST_EXECUTOR_DATA_TYPE_INT);
        ParamDTO i_formato_fecha = new ParamDTO("@i_formato_fecha", Constants.CTS_REST_EXECUTOR_DATE_FORMAT_YYYYMMDD, Constants.CTS_REST_EXECUTOR_DATA_TYPE_SMALLINT);
        ParamDTO i_n_canal = new ParamDTO("@i_n_canal", channel, Constants.CTS_REST_EXECUTOR_DATA_TYPE_SMALLINT);
        ParamDTO o_d_nombre = new ParamDTO("@o_d_nombre", "", Constants.CTS_REST_EXECUTOR_DATA_TYPE_VARCHAR,true);
        ParamDTO o_n_cbu = new ParamDTO("@o_n_cbu", "", Constants.CTS_REST_EXECUTOR_DATA_TYPE_VARCHAR,true);
        ParamDTO o_c_oficial = new ParamDTO("@o_c_oficial", "", Constants.CTS_REST_EXECUTOR_DATA_TYPE_SMALLINT,true);
        ParamDTO o_d_oficial = new ParamDTO("@o_d_oficial", "", Constants.CTS_REST_EXECUTOR_DATA_TYPE_VARCHAR,true);
        ParamDTO o_c_moneda = new ParamDTO("@o_c_moneda", "", Constants.CTS_REST_EXECUTOR_DATA_TYPE_TINYINT,true);
        ParamDTO o_c_categoria = new ParamDTO("@o_c_categoria", "", Constants.CTS_REST_EXECUTOR_DATA_TYPE_VARCHAR,true);
        ParamDTO o_d_categoria = new ParamDTO("@o_d_categoria", "", Constants.CTS_REST_EXECUTOR_DATA_TYPE_VARCHAR,true);
        ParamDTO o_c_oficina = new ParamDTO("@o_c_oficina", "", Constants.CTS_REST_EXECUTOR_DATA_TYPE_SMALLINT,true);
        ParamDTO o_d_oficina = new ParamDTO("@o_d_oficina", "", Constants.CTS_REST_EXECUTOR_DATA_TYPE_VARCHAR,true);
        ParamDTO o_c_producto = new ParamDTO("@o_c_producto", "", Constants.CTS_REST_EXECUTOR_DATA_TYPE_TINYINT, true);
        ParamDTO o_d_producto = new ParamDTO("@o_d_producto", "", Constants.CTS_REST_EXECUTOR_DATA_TYPE_VARCHAR, true);
        ParamDTO o_c_prod_banc = new ParamDTO("@o_c_prod_banc", "", Constants.CTS_REST_EXECUTOR_DATA_TYPE_SMALLINT, true);
        ParamDTO o_d_prod_banc = new ParamDTO("@o_d_prod_banc", "", Constants.CTS_REST_EXECUTOR_DATA_TYPE_VARCHAR, true);
        ParamDTO o_c_estado = new ParamDTO("@o_c_estado", "", Constants.CTS_REST_EXECUTOR_DATA_TYPE_NCHAR, true);
        ParamDTO o_f_apertura = new ParamDTO("@o_f_apertura", "", Constants.CTS_REST_EXECUTOR_DATA_TYPE_VARCHAR, true);
        ParamDTO o_c_tipocta = new ParamDTO("@o_c_tipocta", "", Constants.CTS_REST_EXECUTOR_DATA_TYPE_NCHAR, true);
        ParamDTO o_f_ultimo_movimiento = new ParamDTO("@o_f_ultimo_movimiento", "", Constants.CTS_REST_EXECUTOR_DATA_TYPE_VARCHAR, true);
        ParamDTO o_m_bloq_deposito = new ParamDTO("@o_m_bloq_deposito", "", Constants.CTS_REST_EXECUTOR_DATA_TYPE_NCHAR, true);
        ParamDTO o_m_bloq_retiro = new ParamDTO("@o_m_bloq_retiro", "", Constants.CTS_REST_EXECUTOR_DATA_TYPE_NCHAR, true);

        List<ParamDTO> paramList;
        paramList = List.of(t_trn, i_operacion, i_tipo_operacion, i_opcion, i_n_cta_banco, i_n_cliente, i_formato_fecha, i_n_canal, o_d_nombre, o_n_cbu, o_c_oficial, o_d_oficial, o_c_moneda, o_c_categoria, o_d_categoria, o_c_oficina, o_d_oficina, o_c_producto, o_d_producto, o_c_prod_banc, o_d_prod_banc, o_c_estado, o_f_apertura, o_c_tipocta, o_f_ultimo_movimiento, o_m_bloq_deposito, o_m_bloq_retiro);

        String requestBody = re.getRequest(Constants.CTS_REST_EXECUTOR_SP_LONG_NAME, paramList);

        WebClient.RequestHeadersSpec<?> req = clients
                .backend(Constants.BACKEND_CTS_REST_EXECUTOR)
                .endpoint(Constants.BACKEND_CTS_REST_EXECUTOR_SP_EXECUTE)
                .getWebClient()
                .post()
                .contentType(MediaType.APPLICATION_JSON)
                .bodyValue(requestBody);
        req = ru.setHeaders(req, headers, traceId);

        // Lista de códigos de error que deben ignorarse (es decir, no lanzar excepción) para ser tratados de manera particular en el service. En caso de no necesitarse, enviar un null o lista vacía.
        List<HttpStatus> ignoredStatusCodes = List.of();

        return ru.execRequest(req, traceId, ru.mapBody(requestBody, new TypeReference<Object>() {}))
                .doOnNext(resp -> {
                    sh.handle(resp.response(), request.getPath().toString(), traceId, ignoredStatusCodes);
                    re.validateMetadata(re.getResponse(resp.body()).getMetadata(), traceId, request.getPath().toString());
                });
    }

    //Operation: get-movements
    public Mono<ResponseWrapper> CTS_REST_EXECUTOR_sp_cc_cuenta_get_movements(ServerHttpRequest request, HashMap<String, ResponseWrapper> responses, String pathAccountNumber) {
        String traceId = VContext.getTraceId();
        return tm.getToken(ctsRestExecutorIdTokenInfo, traceId)
                .flatMap(token -> backend_CTS_REST_EXECUTOR_sp_cc_cuenta_get_movements(traceId, request, token, pathAccountNumber))
                .doOnNext(response -> responses.put(Constants.RESPONSE_CTS_REST_EXECUTOR_SP_CC_CONSULTA_MILLAS, response));
    }

    @SneakyThrows
    private Mono<ResponseWrapper> backend_CTS_REST_EXECUTOR_sp_cc_cuenta_get_movements(String traceId, ServerHttpRequest request, Token token, String pathAccountNumber) {
        HashMap<String, String> headers = new HashMap<>();
        headers.put(Constants.HEADER_AUTHORIZATION, token.getAuthorization());

        //Required headers
        String channel = request.getHeaders().get("x-channel").get(0);

        //Query params
        String dateFromRequest = request.getQueryParams().getFirst("date-from");
        String dateToRequest = request.getQueryParams().getFirst("date-to");

        DateTimeFormatter formatter = DateTimeFormatter.ofPattern(Constants.DATE_FORMAT_YYMMDD);

        String dateFrom = dateFromRequest != null
                ? Utils.convertDateFormat(dateFromRequest, "yyyy-MM-dd", Constants.DATE_FORMAT_YYMMDD)
                : LocalDate.now().minusDays(1).format(formatter);

        String dateTo;
        if (dateToRequest != null) {
            dateTo = Utils.convertDateFormat(dateToRequest, "yyyy-MM-dd", Constants.DATE_FORMAT_YYMMDD);
        } else {
            // if date-to is not provided, set it to the next day
            LocalDate parsedDateFrom = LocalDate.parse(dateFrom, DateTimeFormatter.ofPattern(Constants.DATE_FORMAT_YYMMDD));
            dateTo = parsedDateFrom.equals(LocalDate.now()) ? dateFrom : parsedDateFrom.plusDays(1).format(DateTimeFormatter.ofPattern(Constants.DATE_FORMAT_YYMMDD));
        }
        this.validateDates(dateFrom, dateTo, formatter);

        RestExecutor re = new RestExecutor();

        ParamDTO t_trn = new ParamDTO("@t_trn", Constants.CTS_REST_EXECUTOR_TRANSACTION_CODE_GET_MOVEMENTS, Constants.CTS_REST_EXECUTOR_DATA_TYPE_INT);
        ParamDTO i_n_canal = new ParamDTO("@i_n_canal", channel, Constants.CTS_REST_EXECUTOR_DATA_TYPE_INT);
        ParamDTO i_n_cta_banco = new ParamDTO("@i_n_cta_banco", pathAccountNumber, Constants.CTS_REST_EXECUTOR_DATA_TYPE_VARCHAR);
        ParamDTO i_formato_fecha = new ParamDTO("@i_formato_fecha", Constants.CTS_REST_EXECUTOR_DATE_FORMAT_YYYYMMDD, Constants.CTS_REST_EXECUTOR_DATA_TYPE_SMALLINT);

        String recordsNumber = request.getQueryParams().getFirst("records-number");
        Integer recordsNumberInt = recordsNumber != null ? Integer.parseInt(recordsNumber) : Constants.CTS_REST_EXECUTOR_DATA_VALUE_IKREGISTROS;
        ParamDTO i_k_registros = new ParamDTO("@i_k_registros",recordsNumberInt, Constants.CTS_REST_EXECUTOR_DATA_TYPE_INT);

        ParamDTO i_f_desde = new ParamDTO("@i_f_desde", dateFrom, Constants.CTS_REST_EXECUTOR_DATA_TYPE_SMALLDATETIME);
        ParamDTO i_f_hasta = new ParamDTO("@i_f_hasta", dateTo, Constants.CTS_REST_EXECUTOR_DATA_TYPE_SMALLDATETIME);

        List<ParamDTO> paramList;
        paramList = new ArrayList<>(List.of(t_trn, i_n_canal, i_n_cta_banco, i_formato_fecha, i_k_registros));

        // Add optional query parameters
        String sourceTaxpayerNumber = request.getQueryParams().getFirst("source-taxpayer-number");
        if (sourceTaxpayerNumber != null) {
            ParamDTO i_n_cuit = new ParamDTO("@i_n_cuit", sourceTaxpayerNumber, Constants.CTS_REST_EXECUTOR_DATA_TYPE_NCHAR);
            paramList.add(i_n_cuit);
        }

        paramList.add(i_f_desde);
        paramList.add(i_f_hasta);

        String type = request.getQueryParams().getFirst("type");
        if (type != null) {
            ParamDTO i_c_signo = new ParamDTO("@i_c_signo", type, Constants.CTS_REST_EXECUTOR_DATA_TYPE_NCHAR);
            paramList.add(i_c_signo);
        }

        String causalId = request.getQueryParams().getFirst("causal-id");
        if(causalId != null){
            ParamDTO i_n_causal = new ParamDTO("@i_n_causal", causalId, Constants.CTS_REST_EXECUTOR_DATA_TYPE_VARCHAR);
            paramList.add(i_n_causal);
        }

        String catalogId = request.getQueryParams().getFirst("catalog-id");
        if(catalogId != null){   
            ParamDTO i_d_catalogo = new ParamDTO("@i_d_catalogo", catalogId, Constants.CTS_REST_EXECUTOR_DATA_TYPE_VARCHAR);
            paramList.add(i_d_catalogo);
        }

        String conceptFormat = request.getQueryParams().getFirst("concept-format");
        if(conceptFormat != null){   
            ParamDTO i_m_tipo_desc_original_canal = new ParamDTO("@i_m_tipo_desc_original_canal", conceptFormat, Constants.CTS_REST_EXECUTOR_DATA_TYPE_NCHAR);
            paramList.add(i_m_tipo_desc_original_canal);
        }

        String lastRecord = request.getQueryParams().getFirst("last-record");
        if(lastRecord != null){
            Integer lastRecordInt = Integer.parseInt(lastRecord);
            ParamDTO i_n_siguiente_id = new ParamDTO("@i_n_siguiente_id", lastRecordInt, Constants.CTS_REST_EXECUTOR_DATA_TYPE_INT);
            paramList.add(i_n_siguiente_id);
        }

        ParamDTO o_k_total = new ParamDTO("@o_k_total", "", Constants.CTS_REST_EXECUTOR_DATA_TYPE_INT, true);
        ParamDTO o_k_pagina = new ParamDTO("@o_k_pagina", "", Constants.CTS_REST_EXECUTOR_DATA_TYPE_SMALLINT, true);
        ParamDTO o_m_hay_mas = new ParamDTO("@o_m_hay_mas", "", Constants.CTS_REST_EXECUTOR_DATA_TYPE_NCHAR, true);
        ParamDTO o_n_ultimo_id = new ParamDTO("@o_n_ultimo_id", "", Constants.CTS_REST_EXECUTOR_DATA_TYPE_INT, true);

        paramList.add(o_k_total);
        paramList.add(o_k_pagina);
        paramList.add(o_m_hay_mas);
        paramList.add(o_n_ultimo_id);
        
        String requestBody = re.getRequest(Constants.CTS_REST_EXECUTOR_SP_LONG_NAME_GET_MOVEMENTS, paramList);

        WebClient.RequestHeadersSpec<?> req = clients
                .backend(Constants.BACKEND_CTS_REST_EXECUTOR)
                .endpoint(Constants.BACKEND_CTS_REST_EXECUTOR_SP_EXECUTE)
                .getWebClient()
                .post()
                .contentType(MediaType.APPLICATION_JSON)
                .bodyValue(requestBody);
        req = ru.setHeaders(req, headers, traceId);

        // Lista de códigos de error que deben ignorarse (es decir, no lanzar excepción) para ser tratados de manera particular en el service. En caso de no necesitarse, enviar un null o lista vacía.
        List<HttpStatus> ignoredStatusCodes = List.of();

        return ru.execRequest(req, traceId, ru.mapBody(requestBody, new TypeReference<Object>() {}))
                .doOnNext(resp -> {
                    sh.handle(resp.response(), request.getPath().toString(), traceId, ignoredStatusCodes);
                    re.validateMetadata(re.getResponse(resp.body()).getMetadata(), traceId, request.getPath().toString());
                });
    }

    public void validate_Dates(String dateFromStr, String dateToStr, DateTimeFormatter formatter) throws CustomException {
        LocalDate dateFrom = LocalDate.parse(dateFromStr, formatter);
        LocalDate dateTo = LocalDate.parse(dateToStr, formatter);

        if(DateUtils.isDateOrderInvalid(dateFrom, dateTo)){
            ArrayList<ExceptionDetails> details = new ArrayList<>();
            details.add(new ExceptionDetails(Constants.ERROR_CODE_409, Constants.MESSAGE_ERROR_DATE_INVALID, ""));
            throw new CustomException().errorConflict(VContext.getTraceId(), details);
        }
        if(!DateUtils.validateDateRange(dateFrom, dateTo, Constants.CTS_REST_EXECUTOR_MAX_DATE_RANGE)){
            ArrayList<ExceptionDetails> details = new ArrayList<>();
            details.add(new ExceptionDetails(Constants.ERROR_CODE_409, Constants.MESSAGE_ERROR_DATE_RANGE_INVALID, ""));
            throw new CustomException().errorConflict(VContext.getTraceId(), details);
        }
    }


    private void validate_Dates_2(String dateFromStr, String dateToStr, DateTimeFormatter formatter) throws CustomException {
        LocalDate dateFrom = LocalDate.parse(dateFromStr, formatter);
        LocalDate dateTo = LocalDate.parse(dateToStr, formatter);

        if(DateUtils.isDateOrderInvalid(dateFrom, dateTo)){
            ArrayList<ExceptionDetails> details = new ArrayList<>();
            details.add(new ExceptionDetails(Constants.ERROR_CODE_409, Constants.MESSAGE_ERROR_DATE_INVALID, ""));
            throw new CustomException().errorConflict(VContext.getTraceId(), details);
        }
        if(!DateUtils.validateDateRange(dateFrom, dateTo, Constants.CTS_REST_EXECUTOR_MAX_DATE_RANGE)){
            ArrayList<ExceptionDetails> details = new ArrayList<>();
            details.add(new ExceptionDetails(Constants.ERROR_CODE_409, Constants.MESSAGE_ERROR_DATE_RANGE_INVALID, ""));
            throw new CustomException().errorConflict(VContext.getTraceId(), details);
        }
    }
}