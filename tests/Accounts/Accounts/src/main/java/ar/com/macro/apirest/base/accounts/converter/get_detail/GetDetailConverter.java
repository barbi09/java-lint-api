package ar.com.macro.apirest.base.accounts.converter.get_detail;

import ar.com.macro.apirest.base.accounts.dto.app.get_detail.response.GetDetail_ParticipantsElement;
import ar.com.macro.apirest.base.accounts.dto.app.get_detail.response.GetDetail_Response;
import ar.com.macro.apirest.base.accounts.dto.backend.sp_cc_cuenta_get_detail.response.Sp_cc_cuenta_GetDetail_Item;
import ar.com.macro.apirest.base.accounts.dto.backend.sp_cc_cuenta_get_detail.response.Sp_cc_cuenta_GetDetail_Params;
import ar.com.macro.apirest.base.accounts.dto.backend.sp_cc_cuenta_get_detail.response.Sp_cc_cuenta_GetDetail_Response;
import org.mapstruct.*;
import org.mapstruct.factory.Mappers;
import ar.com.macro.utils.Utils;

import java.util.List;
import java.util.stream.Collectors;

@Mapper
public abstract class GetDetailConverter {
    @Mapping(target = "denomination", source = "params.ODNombre")
    @Mapping(target = "cbu", source = "params.ONCbu")
    @Mapping(target = "officerId", source = "params.OCOficial")
    @Mapping(target = "officerDescription", source = "params.ODOficial")
    @Mapping(target = "currencyId", source = "params.OCMoneda")
    @Mapping(target = "categoryId", source = "params.OCCategoria")
    @Mapping(target = "categoryDescription", source = "params.ODCategoria")
    @Mapping(target = "branchId", source = "params.OCOficina")
    @Mapping(target = "branchDescription", source = "params.ODOficina")
    @Mapping(target = "typeId", source = "params.OCProducto")
    @Mapping(target = "typeDescription", source = "params.ODProducto")
    @Mapping(target = "productBankId", source = "params.OCProdBanc")
    @Mapping(target = "productBankDescription", source = "params.ODProdBanc")
    @Mapping(target = "statusId", source = "params.OCEstado")
    @Mapping(target = "openingDate", source = "params.OFApertura", qualifiedByName = "convertDateFormat")
    @Mapping(target = "legalEntityType", source = "params.OCTipocta")
    @Mapping(target = "lastTransactionDate", source = "params.OFUltimoMovimiento", qualifiedByName = "convertDateFormat")
    @Mapping(target = "depositBlocked", source = "params.OMBloqDeposito", qualifiedByName = "convertStringToBoolean")
    @Mapping(target = "blockedWithdrawal", source = "params.OMBloqRetiro", qualifiedByName = "convertStringToBoolean")
    @Mapping(target = "participants", source = "source.data")

    public abstract GetDetail_Response toGetDetailResponse(Sp_cc_cuenta_GetDetail_Response source, Sp_cc_cuenta_GetDetail_Params params);
    public static GetDetailConverter INSTANCE = Mappers.getMapper(GetDetailConverter.class);

    public List<GetDetail_ParticipantsElement> toParticipantsFromData(List<Sp_cc_cuenta_GetDetail_Item> source){
        return source.stream().map(participants -> ParticipantConverter.INSTANCE.toParticipantFromItem(participants)).collect(Collectors.toList());
    }

    @Named("convertDateFormat")
    protected String convertDateFormat(String date){
        return (date == null || date.isEmpty()) ? null : Utils.convertDateFormat(date, "yyyyMMdd", "yyyy-MM-dd");
    }

    @Named("convertStringToBoolean")
    protected boolean convertStringToBoolean(String value) {
        return (value == null || value.isEmpty()) ? false : Utils.convertStringToBoolean(value, "S");
    }
}
