package ar.com.macro.apirest.base.accounts.handler;

import ar.com.macro.domain.ResponseWrapper;
import lombok.SneakyThrows;

/**
 * Esta clase se utiliza en el SERVICE para analizar las respuestas de las llamadas al backend y realizar acciones si corresponden.
 * Ej: Analizar un response, transformar una exception en otra, invocar otros servicios.
 */
public class AppResponseHandler {

    @SneakyThrows
    public ResponseWrapper handleResponse_sp_cc_cuenta_get_list(ResponseWrapper response) {
      /*  if (response.response() != null)
            switch(HttpStatus.valueOf(response.response().statusCode().value())){
                case OK -> System.out.println("OK");
                case BAD_REQUEST -> throw new CustomException().errorForbidden(VContext.getTraceId(), "ASD");
                // Transforma el BAD_REQUEST en FORBIDDEN
            }*/
        return response;
    }

    @SneakyThrows
    public ResponseWrapper handleResponse_sp_cc_cuenta_get_balance(ResponseWrapper response) {
      /*  if (response.response() != null)
            switch(HttpStatus.valueOf(response.response().statusCode().value())){
                case OK -> System.out.println("OK");
                case BAD_REQUEST -> throw new CustomException().errorForbidden(VContext.getTraceId(), "ASD");
                // Transforma el BAD_REQUEST en FORBIDDEN
            }*/
        return response;
    }
    @SneakyThrows
    public ResponseWrapper handleResponse_sp_cc_cuenta_get_detail(ResponseWrapper response) {
        return response;
    }

    @SneakyThrows
    public ResponseWrapper handleResponse_sp_cc_cuenta_get_movements(ResponseWrapper response) {
        return response;
    }
}