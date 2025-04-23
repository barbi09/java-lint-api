package ar.com.macro.apirest.base.accounts.converter.get_balance;

import ar.com.macro.apirest.base.accounts.dto.app.get_balance.response.GetBalance_Response;
import ar.com.macro.apirest.base.accounts.dto.backend.sp_cc_cuenta_get_balance.response.Sp_cc_cuenta_GetBalance_Params;
import ar.com.macro.utils.Utils;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.Named;
import org.mapstruct.factory.Mappers;


@Mapper
public abstract class GetBalanceConverter {

    @Mapping(target = "account.currencyId", source = "OCMoneda")
    @Mapping(target = "balance.remittance", source = "OIRemesas", qualifiedByName = "convertFormatToTwoDecimals")
    @Mapping(target = "balance.signed24h", source = "OI24h", qualifiedByName = "convertFormatToTwoDecimals")
    @Mapping(target = "balance.available", source = "OIDisponible", qualifiedByName = "convertFormatToTwoDecimals")
    @Mapping(target = "balance.accounting", source = "OISaldoContable", qualifiedByName = "convertFormatToTwoDecimals")
    @Mapping(target = "balance.bankDraft", source = "OISaldoParaGirar", qualifiedByName = "convertFormatToTwoDecimals")
    @Mapping(target = "balance.blocked", source = "OIBloqueoValores", qualifiedByName = "convertFormatToTwoDecimals")
    @Mapping(target = "balance.signed48h", source = "OI48h", qualifiedByName = "convertFormatToTwoDecimals")
    @Mapping(target = "balance.suspended", source = "OIValoresSuspenso", qualifiedByName = "convertFormatToTwoDecimals")
    @Mapping(target = "balance.agreement", source = "OIAcuerdos", qualifiedByName = "convertFormatToTwoDecimals")

    public abstract GetBalance_Response toGetBalanceResponse(Sp_cc_cuenta_GetBalance_Params source);

    public static GetBalanceConverter INSTANCE = Mappers.getMapper(GetBalanceConverter.class);

    @Named("convertFormatToTwoDecimals")
    protected String formatToTwoDecimals(String value) {
        return value == null || value.isEmpty() ? null : Utils.convertToTwoDecimals(value);
    }

}