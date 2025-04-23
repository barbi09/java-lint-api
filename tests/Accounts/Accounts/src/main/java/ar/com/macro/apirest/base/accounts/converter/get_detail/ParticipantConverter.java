package ar.com.macro.apirest.base.accounts.converter.get_detail;

import ar.com.macro.apirest.base.accounts.dto.app.get_detail.response.GetDetail_ParticipantsElement;
import ar.com.macro.apirest.base.accounts.dto.backend.sp_cc_cuenta_get_detail.response.Sp_cc_cuenta_GetDetail_Item;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.factory.Mappers;

@Mapper
public abstract class ParticipantConverter {
    @Mapping(target = "fullName", source = "nombreApellido")
    @Mapping(target = "taxpayerNJumber", source = "cuitCuil")
    @Mapping(target = "partyRoleId", source = "rol")
    @Mapping(target = "partyRoleDescription", source = "descriptionRol")

    public abstract GetDetail_ParticipantsElement toParticipantFromItem(Sp_cc_cuenta_GetDetail_Item source);
    static ParticipantConverter INSTANCE = Mappers.getMapper(ParticipantConverter.class);

}