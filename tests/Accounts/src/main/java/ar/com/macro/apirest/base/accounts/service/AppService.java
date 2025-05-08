package ar.com.macro.apirest.base.accounts.service;

import ar.com.macro.apirest.base.accounts.dto.app.get_list.response.GetList_Response;
import ar.com.macro.apirest.base.accounts.dto.app.get_balance.response.GetBalance_Response;
import ar.com.macro.apirest.base.accounts.dto.app.get_detail.response.GetDetail_Response;
import ar.com.macro.apirest.base.accounts.dto.app.get_movements.response.GetMovements_Response;
import ar.com.macro.apirest.base.accounts.handler.AppResponseHandler;
import ar.com.macro.apirest.base.accounts.mapper.AppResponseMapper;
import ar.com.macro.apirest.base.accounts.webclient.WebClientBackends;
import ar.com.macro.domain.ResponseWrapper;
import ar.com.macro.utils.CommonRequestUtils;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.server.reactive.ServerHttpRequest;
import org.springframework.stereotype.Service;
import reactor.core.publisher.Mono;
import java.util.HashMap;

@Service
@RequiredArgsConstructor
public class AppService {

    @Autowired private WebClientBackends webClientBackends;
    @Autowired private final CommonRequestUtils ru;
    @Autowired private AppResponseMapper responseMapper;

    public Mono<GetList_Response> getList_(ServerHttpRequest request) {
        // En esta variable se guardaran todas las respuestas de los servicios consumidos, que luego serán utilizadas en el mapper.
        HashMap<String, ResponseWrapper> responses = new HashMap<>();
        AppResponseHandler handler = new AppResponseHandler();

        return webClientBackends
                .CTS_REST_EXECUTOR_sp_cc_cuenta_get_list(request, responses)
                .doOnNext(handler::handleResponse_sp_cc_cuenta_get_list)
                .map( x -> responseMapper.map_getListResponse(request, responses));
    }

    public Mono<GetBalance_Response> getBalance(ServerHttpRequest request, String pathAccountNumber) {
        HashMap<String, ResponseWrapper> responses = new HashMap<>();
        AppResponseHandler handler = new AppResponseHandler();

        return webClientBackends
                .CTS_REST_EXECUTOR_sp_cc_cuenta_get_balance(request, responses, pathAccountNumber)
                .doOnNext(handler::handleResponse_sp_cc_cuenta_get_balance)
                .map( x -> responseMapper.map_getBalanceResponse(request, responses));
    }

    public Mono<GetDetail_Response> getDetail(ServerHttpRequest request, String pathAccountNumber) {
        HashMap<String, ResponseWrapper> responses = new HashMap<>();
        AppResponseHandler handler = new AppResponseHandler();

        return webClientBackends
                .CTS_REST_EXECUTOR_sp_cc_cuenta_get_detail(request, responses, pathAccountNumber)
                .doOnNext(handler::handleResponse_sp_cc_cuenta_get_detail)
                .map( x -> responseMapper.map_getDetailResponse(request, responses));
    }

    public Mono<GetMovements_Response> getMovements(ServerHttpRequest request, String pathAccountNumber) {
        HashMap<String, ResponseWrapper> responses = new HashMap<>();
        AppResponseHandler handler = new AppResponseHandler();

        return webClientBackends
                .CTS_REST_EXECUTOR_sp_cc_cuenta_get_movements(request, responses, pathAccountNumber)
                .doOnNext(handler::handleResponse_sp_cc_cuenta_get_movements)
                .map( x -> responseMapper.map_getMovementsResponse(request, responses));
    }

}