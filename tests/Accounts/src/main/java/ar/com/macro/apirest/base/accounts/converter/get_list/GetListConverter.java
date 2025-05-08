package ar.com.macro.apirest.base.accounts.converter.get_list;

import ar.com.macro.apirest.base.accounts.dto.app.get_list.response.GetList_Account;
import ar.com.macro.apirest.base.accounts.dto.app.get_list.response.GetList_Response;
import ar.com.macro.apirest.base.accounts.dto.backend.sp_cc_cuenta_get_list.response.Sp_cc_cuenta_GetList_Item;
import ar.com.macro.apirest.base.accounts.dto.backend.sp_cc_cuenta_get_list.response.Sp_cc_cuenta_GetList_Response;
import ar.com.macro.apirest.base.accounts.dto.backend.sp_cc_cuenta_get_list.response.Sp_cc_cuenta_GetList_Params;
import ar.com.macro.utils.Utils;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.Named;
import org.mapstruct.factory.Mappers;

import java.util.List;
import java.util.stream.Collectors;


@Mapper
public abstract class GetListConverter {

    @Mapping(target = "accounts", source = "sourceRs1.data")
    @Mapping(target = "pagination.totalRecords", source = "sourceParams.OKTotal")
    @Mapping(target = "pagination.recordsNumber", source = "sourceParams.OKPagina")
    @Mapping(target = "pagination.additionalRecords", source = "sourceParams.OMHayMas", qualifiedByName = "convertStringToBoolean")
    @Mapping(target = "pagination.lastRecord", source = "sourceParams.ONUltimoId")

    public abstract GetList_Response toGetListResponse(Sp_cc_cuenta_GetList_Response sourceRs1, Sp_cc_cuenta_GetList_Params sourceParams);

    public static GetListConverter INSTANCE = Mappers.getMapper(GetListConverter.class);

    public List<GetList_Account> toAccountsFromData(List<Sp_cc_cuenta_GetList_Item> source){
        return source.stream().map(accounts -> AccountConverter.INSTANCE.toAccountFromItem(accounts)).collect(Collectors.toList());
    }

    @Named("convertStringToBoolean")
    protected boolean convertStringToBoolean(String value) {
        return value == null || value.isEmpty() ? false : Utils.convertStringToBoolean(value, "S");
    }

}
