package ar.com.macro.apirest.base.accounts.converter.get_list;

import ar.com.macro.apirest.base.accounts.dto.app.get_list.response.GetList_Account;
import ar.com.macro.apirest.base.accounts.dto.backend.sp_cc_cuenta_get_list.response.Sp_cc_cuenta_GetList_Item;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.Named;
import org.mapstruct.factory.Mappers;
import ar.com.macro.utils.Utils;

@Mapper
public abstract class AccountConverter {
    @Mapping(target = "number", source = "cuenta")
    @Mapping(target = "statusId", source = "estadoCuenta")
    @Mapping(target = "currencyId", source = "moneda")
    @Mapping(target = "cbu", source = "cbu")
    @Mapping(target = "typeId", source = "producto")
    @Mapping(target = "typeDescription", source = "descripcionCuenta")
    @Mapping(target = "productDescription", source = "descripcionProducto")
    @Mapping(target = "categoryId", source = "categoria")
    @Mapping(target = "branch", source = "sucursal")
    @Mapping(target = "branchDescription", source = "descripcionSucursal")
    @Mapping(target = "productBankId", source = "productoBancario")
    @Mapping(target = "productBankDescription", source = "descProdBancario")
    @Mapping(target = "balance.available", source = "saldoDisponible", qualifiedByName = "convertFormatToTwoDecimals")
    @Mapping(target = "balance.bankDraft", source = "saldoAGirar", qualifiedByName = "convertFormatToTwoDecimals")
    @Mapping(target = "customer.accountHolder", source = "rolDelCliente")
    @Mapping(target = "overdraftAgreement", source = "acuerdoSobregiro", qualifiedByName = "convertFormatToTwoDecimals")
    @Mapping(target = "conductTransaction", source = "transaccional", qualifiedByName = "convertStringToBoolean")

    public abstract GetList_Account toAccountFromItem(Sp_cc_cuenta_GetList_Item source);
    static AccountConverter INSTANCE = Mappers.getMapper(AccountConverter.class);

    @Named("convertFormatToTwoDecimals")
    protected String formatToTwoDecimals(String value) {
        return value == null || value.isEmpty() ? null : Utils.convertToTwoDecimals(value);
    }

    @Named("convertStringToBoolean")
    protected boolean convertStringToBoolean(String value) {
        return (value == null || value.isEmpty()) ? false : Utils.convertStringToBoolean(value, "S");
    }

}