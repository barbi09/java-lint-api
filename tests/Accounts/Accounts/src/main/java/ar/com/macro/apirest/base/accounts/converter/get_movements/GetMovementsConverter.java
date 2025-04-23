package ar.com.macro.apirest.base.accounts.converter.get_movements;


import ar.com.macro.apirest.base.accounts.dto.app.get_movements.response.*;
import ar.com.macro.apirest.base.accounts.dto.backend.sp_cc_cuentas_get_movements.response.*;
import ar.com.macro.utils.Utils;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.Named;
import org.mapstruct.factory.Mappers;

import java.util.List;
import java.util.stream.Collectors;

@Mapper
public abstract class GetMovementsConverter {
    @Mapping(target = "movements", source = "sourceRs1.data")
    @Mapping(target = "pagination.totalRecords", source = "sourceParams.OKTotal")
    @Mapping(target = "pagination.recordsNumber", source = "sourceParams.OKPagina")
    @Mapping(target = "pagination.additionalRecords", source = "sourceParams.OMHayMas", qualifiedByName = "convertStringToBoolean")
    @Mapping(target = "pagination.lastRecord", source = "sourceParams.ONUltimoId")

    public abstract GetMovements_Response toGetMovementsResponse(Sp_cc_cuenta_GetMovements_Response sourceRs1, Sp_cc_cuenta_GetMovements_Params sourceParams);
    public static GetMovementsConverter INSTANCE = Mappers.getMapper(GetMovementsConverter.class);

    public List<GetMovements_Movement> toMovementsFromData(List<Sp_cc_cuenta_GetMovements_Item> source){
        return source.stream().map(movements -> MovementConverter.INSTANCE.toMovementFromItem(movements)).collect(Collectors.toList());
    }

    @Named("convertStringToBoolean")
    protected boolean convertStringToBoolean(String value) {
        return (value == null || value.isEmpty()) ? false : Utils.convertStringToBoolean(value, "S");
    }
}
