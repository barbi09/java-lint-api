package ar.com.macro.apirest.base.accounts.controller;

import static org.springframework.http.MediaType.APPLICATION_JSON_VALUE;

import java.io.IOException;
import java.net.HttpURLConnection;

import java.net.URL;

import ar.com.macro.apirest.base.accounts.dto.app.get_movements.response.GetMovements_Response;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;


import ar.com.macro.Logger.CustomLogger;
import ar.com.macro.apirest.base.accounts.Constants;
import ar.com.macro.apirest.base.accounts.dto.app.get_list.response.GetList_Response;
import ar.com.macro.apirest.base.accounts.dto.app.get_balance.response.GetBalance_Response;
import ar.com.macro.apirest.base.accounts.dto.app.get_detail.response.GetDetail_Response;
import ar.com.macro.exceptions.AppHandler;
import ar.com.macro.utils.CommonRequestUtils;
import ar.com.macro.utils.VContext;
import ar.com.macro.apirest.base.accounts.service.AppService;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.ResponseEntity;
import org.springframework.http.server.reactive.ServerHttpRequest;
import org.springframework.web.bind.annotation.*;
import com.atlassian.oai.validator.OpenApiInteractionValidator;
import reactor.core.publisher.Mono;
import lombok.RequiredArgsConstructor;

/**
 * Esta clase define todos los puntos de entrada a la aplicación
 */
@RestController
@RequiredArgsConstructor
@Tag(name = "${app.name}")
@CrossOrigin(origins = "*")
@RequestMapping("${app.basepath}")
public class AppControllerImpl implements AppController {

    private final AppService appService;
    @Autowired private final CustomLogger customlogger;
    @Autowired private final CommonRequestUtils ru;
    @Value("${app.charset}") private String charset;
    @Value("${app.name}") private String appName;

    private static final Logger logger = LoggerFactory.getLogger(AppControllerImpl.class);

    @GetMapping(value = "${app.operations.getList.path}", produces = APPLICATION_JSON_VALUE)
    @Override
    public Mono<ResponseEntity<GetList_Response>> getList(ServerHttpRequest request) {
        String traceId = VContext.setTraceId(request);
        try {
            return ru.handleRequest(Constants.OP_GET_LIST, traceId, request, appName)
                    .flatMap(validRequestBody -> appService.getList(request)
                            .flatMap(responseBody -> ru.buildBodyResponse(traceId, ResponseEntity.ok(), responseBody)))
                    .doOnError(e -> AppHandler.handleAppException(customlogger, (Exception) e, traceId, request.getPath().toString()));
        } catch (Exception e) {
            AppHandler.handleAppException(customlogger, e, traceId, request.getPath().toString());
            throw e;
        }
    }

    @GetMapping(value = "${app.operations.getBalance.path}", produces = APPLICATION_JSON_VALUE)
    @Override
    public Mono<ResponseEntity<GetBalance_Response>> getBalance(ServerHttpRequest request, @PathVariable(name = "account-number", required = true) String pathAccountNumber) {
        String traceId = VContext.setTraceId(request);
        try {
            return ru.handleRequest(Constants.OP_GET_BALANCE, traceId, request, appName)
                    .flatMap(validRequestBody -> appService.getBalance(request, pathAccountNumber)
                            .flatMap(responseBody -> ru.buildBodyResponse(traceId, ResponseEntity.ok(), responseBody)))
                    .doOnError(e -> AppHandler.handleAppException(customlogger, (Exception) e, traceId, request.getPath().toString()));
        } catch (Exception e) {
            AppHandler.handleAppException(customlogger, e, traceId, request.getPath().toString());
            throw e;
        }
    }
    @GetMapping(value = "${app.operations.getDetail.path}", produces = APPLICATION_JSON_VALUE)
    @Override
    public Mono<ResponseEntity<GetDetail_Response>> getDetail(ServerHttpRequest request, @PathVariable(name = "account-number", required = true) String pathAccountNumber) {
        String traceId = VContext.setTraceId(request);
        try {
            return ru.handleRequest(Constants.OP_GET_DETAIL, traceId, request, appName)
                    .flatMap(validRequestBody -> appService.getDetail(request, pathAccountNumber)
                            .flatMap(responseBody -> ru.buildBodyResponse(traceId, ResponseEntity.ok(), responseBody)))
                    .doOnError(e -> AppHandler.handleAppException(customlogger, (Exception) e, traceId, request.getPath().toString()));
        } catch (Exception e) {
            AppHandler.handleAppException(customlogger, e, traceId, request.getPath().toString());
            throw e;
        }
    }
    @GetMapping(value = "${app.operations.getMovements.path}", produces = APPLICATION_JSON_VALUE)
    @Override
    public Mono<ResponseEntity<GetMovements_Response>> getMovements(ServerHttpRequest request, @PathVariable(name = "account-number", required = true) String pathAccountNumber) {
        String traceId = VContext.setTraceId(request);
        try {
            return ru.handleRequest(Constants.OP_GET_MOVEMENTS, traceId, request, appName)
                    .flatMap(validRequestBody -> appService.getMovements(request, pathAccountNumber)
                            .flatMap(responseBody -> ru.buildBodyResponse(traceId, ResponseEntity.ok(), responseBody)))
                    .doOnError(e -> AppHandler.handleAppException(customlogger, (Exception) e, traceId, request.getPath().toString()));
        } catch (Exception e) {
            AppHandler.handleAppException(customlogger, e, traceId, request.getPath().toString());
            throw e;
        }
    }

    @GetMapping(value = "/opentelemetry", produces = APPLICATION_JSON_VALUE)
    @Override
    public String getOpenTelemetry(ServerHttpRequest request) throws IOException {

        try {
            HttpURLConnection connection = (HttpURLConnection) new URL("http://collector-collector.opentelemetry:4317").openConnection();
            connection.setRequestMethod("GET");
            int responseCode = connection.getResponseCode();
            String responseMsg = connection.getResponseMessage();
            logger.info("Response Code from collector http://collector-collector.opentelemetry:4317:"+ responseCode+ "Response msg: "+ responseMsg);

            /*HttpURLConnection connection1 = (HttpURLConnection) new URL("http://collector-collector.opentelemetry:4318").openConnection();
            connection1.setRequestMethod("GET");
            int responseCode1 = connection1.getResponseCode();
            logger.info("Response from collector http://collector-collector.opentelemetry:4318:"+responseCode1);*/

            String value = "OpenTelemetry test TZ-Accounts";
            logger.debug("This is an debug log message into controller");
            logger.info("This is an info log message into controller");
            logger.error("This is an error log message into controller");
            return value;
        } catch (Exception e) {
            String value = "OpenTelemetry test TZ-Accounts";
            logger.error("Exception:"+ e.toString());
            logger.debug("This is an debug log message into controller");
            logger.info("This is an info log message into controller");
            logger.error("This is an error log message into controller");
            return value;
        }
    }
}