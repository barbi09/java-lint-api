package ar.com.macro.apirest.base.accounts.controller;

import ar.com.macro.apirest.base.accounts.dto.app.get_list.response.GetList_Response;
import ar.com.macro.apirest.base.accounts.dto.app.get_balance.response.GetBalance_Response;
import ar.com.macro.apirest.base.accounts.dto.app.get_detail.response.GetDetail_Response;
import ar.com.macro.apirest.base.accounts.dto.app.get_movements.response.GetMovements_Response;
import org.springframework.http.ResponseEntity;
import org.springframework.http.server.reactive.ServerHttpRequest;
import org.springframework.web.bind.annotation.PathVariable;
import reactor.core.publisher.Mono;

import java.io.IOException;

public interface AppController {
    public Mono<ResponseEntity<GetList_Response>> getList(ServerHttpRequest request);
    public Mono<ResponseEntity<GetBalance_Response>> getBalance(ServerHttpRequest request, @PathVariable(name = "account-number", required = true) String pathAccountNumber);
    public Mono<ResponseEntity<GetDetail_Response>> getDetail(ServerHttpRequest request, @PathVariable(name = "account-number", required = true) String pathAccountNumber);
    public Mono<ResponseEntity<GetMovements_Response>> get_Movements(ServerHttpRequest request, @PathVariable(name = "account-number", required = true) String pathAccountNumber);
    public String getOpenTelemetry(ServerHttpRequest request) throws IOException;
}