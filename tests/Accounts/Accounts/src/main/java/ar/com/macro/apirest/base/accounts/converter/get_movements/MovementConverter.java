package ar.com.macro.apirest.base.accounts.converter.get_movements;

import ar.com.macro.apirest.base.accounts.dto.app.get_movements.response.*;
import ar.com.macro.apirest.base.accounts.dto.backend.sp_cc_cuentas_get_movements.response.*;
import ar.com.macro.utils.Utils;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.Named;
import org.mapstruct.factory.Mappers;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.Locale;

@Mapper
public abstract class MovementConverter {
    @Mapping(target = "date", source = "fecha", qualifiedByName = "convertDateFormat")
    @Mapping(target = "receipt", source = "secuencial")
    @Mapping(target = "alternReceipt", source = "codAlterno")
    @Mapping(target = "branchId", source = "ofiCod")
    @Mapping(target = "branchDescription", source = "oficina")
    @Mapping(target = "concept", source = "transaccion")
    @Mapping(target = "type", source = "dc")
    @Mapping(target = "amount", source = "valor", qualifiedByName = "convertFormatToTwoDecimals")
    @Mapping(target = "checkCause", source = "chequeCausa")
    @Mapping(target = "dateTime", source = "hora", qualifiedByName = "convertSmallDateTimeFormat")
    @Mapping(target = "internalNumber", source = "secHis")
    @Mapping(target = "referenceCode", source = "referenciaNumero")
    @Mapping(target = "beUser", source = "usuario")
    @Mapping(target = "causalId", source = "codCausa")
    @Mapping(target = "cuitOrigin", source = "cuit")
    @Mapping(target = "sequenceNumber", source = "secUnico")

    public abstract GetMovements_Movement toMovementFromItem(Sp_cc_cuenta_GetMovements_Item source);
    static MovementConverter INSTANCE = Mappers.getMapper(MovementConverter.class);

    @Named("convertFormatToTwoDecimals")
    protected String formatToTwoDecimals(String value) {
        return value == null || value.isEmpty() ? null : Utils.convertToTwoDecimals(value);
    }

    @Named("convertDateFormat")
    protected String convertDateFormat(String date){
        return (date == null || date.isEmpty()) ? null : Utils.convertDateFormat(date, "yyyyMMdd", "yyyy-MM-dd");
    }

    @Named("convertSmallDateTimeFormat")
    protected String convertSmallDateTimeFormat(String date) {
        String inputDateTime = date.replaceAll("\\s+", " ").trim();
        DateTimeFormatter inputFormatter = DateTimeFormatter
                .ofPattern("yyyyMMdd h:mm a")
                .withLocale(Locale.ENGLISH);  // Agregamos el Locale

        LocalDateTime dateTime = LocalDateTime.parse(inputDateTime, inputFormatter);

        DateTimeFormatter outputFormatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");
        return dateTime.format(outputFormatter);
    }

}
