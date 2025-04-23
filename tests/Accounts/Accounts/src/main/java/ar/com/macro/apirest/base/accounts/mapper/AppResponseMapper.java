package ar.com.macro.apirest.base.accounts.mapper;

import ar.com.macro.apirest.base.accounts.converter.get_balance.GetBalanceConverter;
import ar.com.macro.apirest.base.accounts.converter.get_detail.GetDetailConverter;
import ar.com.macro.apirest.base.accounts.converter.get_list.GetListConverter;
import ar.com.macro.apirest.base.accounts.converter.get_movements.GetMovementsConverter;
import ar.com.macro.apirest.base.accounts.dto.app.get_balance.response.GetBalance_Response;
import ar.com.macro.apirest.base.accounts.dto.app.get_detail.response.GetDetail_Response;
import ar.com.macro.apirest.base.accounts.dto.app.get_list.response.GetList_Response;
import ar.com.macro.apirest.base.accounts.Constants;
import ar.com.macro.apirest.base.accounts.dto.app.get_movements.response.GetMovements_Response;
import ar.com.macro.apirest.base.accounts.dto.backend.sp_cc_cuenta_get_balance.response.Sp_cc_cuenta_GetBalance_Params;
import ar.com.macro.apirest.base.accounts.dto.backend.sp_cc_cuenta_get_detail.response.Sp_cc_cuenta_GetDetail_Item;
import ar.com.macro.apirest.base.accounts.dto.backend.sp_cc_cuenta_get_detail.response.Sp_cc_cuenta_GetDetail_Params;
import ar.com.macro.apirest.base.accounts.dto.backend.sp_cc_cuenta_get_detail.response.Sp_cc_cuenta_GetDetail_Response;
import ar.com.macro.apirest.base.accounts.dto.backend.sp_cc_cuenta_get_list.response.Sp_cc_cuenta_GetList_Item;
import ar.com.macro.apirest.base.accounts.dto.backend.sp_cc_cuenta_get_list.response.Sp_cc_cuenta_GetList_Params;
import ar.com.macro.apirest.base.accounts.dto.backend.sp_cc_cuenta_get_list.response.Sp_cc_cuenta_GetList_Response;
import ar.com.macro.apirest.base.accounts.dto.backend.sp_cc_cuentas_get_movements.response.Sp_cc_cuenta_GetMovements_Item;
import ar.com.macro.apirest.base.accounts.dto.backend.sp_cc_cuentas_get_movements.response.Sp_cc_cuenta_GetMovements_Params;
import ar.com.macro.apirest.base.accounts.dto.backend.sp_cc_cuentas_get_movements.response.Sp_cc_cuenta_GetMovements_Response;
import ar.com.macro.domain.ResponseWrapper;
import ar.com.macro.exceptions.CustomException;
import ar.com.macro.utils.CommonRequestUtils;
import ar.com.macro.utils.VContext;
import com.fasterxml.jackson.core.type.TypeReference;
import lombok.RequiredArgsConstructor;
import lombok.SneakyThrows;
import ar.com.macro.DTO.Responses.RestExecutorResponseDTO;
import ar.com.macro.RestExecutor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.HashMap;
import java.util.List;
import org.springframework.http.server.reactive.ServerHttpRequest;

/**
 * Esta clase hará el mapeo final de los servicios, luego de ralizar todas las invocaciones necesarias.
 *
 */
@Service
@RequiredArgsConstructor
public class AppResponseMapper {

    @Autowired
    private final CommonRequestUtils ru;

    @SneakyThrows
    public GetList_Response map_getListResponse(ServerHttpRequest request, HashMap<String, ResponseWrapper> responses) {
        String traceId = VContext.getTraceId();
        ResponseWrapper responseData = responses.get(Constants.RESPONSE_CTS_REST_EXECUTOR_SP_CC_CUENTA_GET_LIST);

        RestExecutor restExecutor = new RestExecutor();
        RestExecutorResponseDTO responseDTO = restExecutor.getResponse(responseData.body());

       if (responseDTO.getResultSets() == null || responseDTO.getResultSets().isEmpty() || responseDTO.getResultSets().get(0).getData().equals("[]")){
            throw (new CustomException()).errorNotFound(traceId, request.getPath().toString());
        }

        TypeReference<List<Sp_cc_cuenta_GetList_Item>> typeReferenceRs1 = new TypeReference<>() { };
        Sp_cc_cuenta_GetList_Response mappedResponseRs1 = new Sp_cc_cuenta_GetList_Response();
        mappedResponseRs1.setData(ru.mapBody(responseDTO.getResultSets().get(0).getData(), typeReferenceRs1));

        TypeReference<Sp_cc_cuenta_GetList_Params> typeReferenceParams = new TypeReference<>() {};
        Sp_cc_cuenta_GetList_Params mappedResponseParams = ru.mapBody(responseDTO.getParams(), typeReferenceParams);

        return GetListConverter.INSTANCE.toGetListResponse(mappedResponseRs1, mappedResponseParams);
    }

    @SneakyThrows
    public GetBalance_Response map_getBalance_Response(ServerHttpRequest request, HashMap<String, ResponseWrapper> responses) {
        String traceId = VContext.getTraceId();
        ResponseWrapper responseData = responses.get(Constants.RESPONSE_CTS_REST_EXECUTOR_SP_CC_CUENTA_GET_BALANCE);

        RestExecutor restExecutor = new RestExecutor();
        RestExecutorResponseDTO responseDTO = restExecutor.getResponse(responseData.body());

        if (responseDTO.getParams() == null || responseDTO.getParams().equals("{}")) {
            throw (new CustomException()).errorNotFound(traceId, request.getPath().toString());
        }

        TypeReference<Sp_cc_cuenta_GetBalance_Params> typeReferenceParams = new TypeReference<>() {};
        Sp_cc_cuenta_GetBalance_Params mappedResponseParams = ru.mapBody(responseDTO.getParams(), typeReferenceParams);

        return GetBalanceConverter.INSTANCE.toGetBalanceResponse(mappedResponseParams);
    }

    @SneakyThrows
    public GetDetail_Response map_getDetailResponse(ServerHttpRequest request, HashMap<String, ResponseWrapper> responses) {
        String traceId = VContext.getTraceId();
        ResponseWrapper responseData = responses.get(Constants.RESPONSE_CTS_REST_EXECUTOR_SP_CC_CUENTA_GET_DETAIL);

        RestExecutor restExecutor = new RestExecutor();
        RestExecutorResponseDTO responseDTO = restExecutor.getResponse(responseData.body());

        if (responseDTO.getParams() == null || responseDTO.getParams().equals("{}")) {
            throw (new CustomException()).errorNotFound(traceId, request.getPath().toString());
        }

        if (responseDTO.getResultSets() == null || responseDTO.getResultSets().equals("{}")) {
            throw (new CustomException()).errorNotFound(traceId, request.getPath().toString());
        }

        TypeReference<List<Sp_cc_cuenta_GetDetail_Item>> typeReferenceRs1 = new TypeReference<>() { };
        Sp_cc_cuenta_GetDetail_Response mappedResponseRs1 = new Sp_cc_cuenta_GetDetail_Response();
        mappedResponseRs1.setData(ru.mapBody(responseDTO.getResultSets().get(0).getData(), typeReferenceRs1));

        TypeReference<Sp_cc_cuenta_GetDetail_Params> typeReferenceParams = new TypeReference<>() {};
        Sp_cc_cuenta_GetDetail_Params mappedResponseParams = ru.mapBody(responseDTO.getParams(), typeReferenceParams);

        return GetDetailConverter.INSTANCE.toGetDetailResponse(mappedResponseRs1, mappedResponseParams);
    }

    @SneakyThrows
    public GetMovements_Response map_getMovementsResponse(ServerHttpRequest request, HashMap<String, ResponseWrapper> responses) {
        String traceId = VContext.getTraceId();
        ResponseWrapper responseData = responses.get(Constants.RESPONSE_CTS_REST_EXECUTOR_SP_CC_CONSULTA_MILLAS);

        RestExecutor restExecutor = new RestExecutor();
        RestExecutorResponseDTO responseDTO = restExecutor.getResponse(responseData.body());

        if (responseDTO.getResultSets() == null || responseDTO.getResultSets().isEmpty() || responseDTO.getResultSets().get(0).getData().equals("[]")){
            throw (new CustomException()).errorNotFound(traceId, request.getPath().toString());
        }

        TypeReference<List<Sp_cc_cuenta_GetMovements_Item>> typeReferenceRs1 = new TypeReference<>() { };
        Sp_cc_cuenta_GetMovements_Response mappedResponseRs1 = new Sp_cc_cuenta_GetMovements_Response();
        mappedResponseRs1.setData(ru.mapBody(responseDTO.getResultSets().get(0).getData(), typeReferenceRs1));

        TypeReference<Sp_cc_cuenta_GetMovements_Params> typeReferenceParams = new TypeReference<>() {};
        Sp_cc_cuenta_GetMovements_Params mappedResponseParams = ru.mapBody(responseDTO.getParams(), typeReferenceParams);

        return GetMovementsConverter.INSTANCE.toGetMovementsResponse(mappedResponseRs1, mappedResponseParams);
    }

}