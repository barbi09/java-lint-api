package ar.com.macro.apirest.base.accounts.dto.backend.sp_cc_cuenta_get_detail.response;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.io.Serial;
import java.io.Serializable;

@Data
@NoArgsConstructor
@JsonIgnoreProperties(ignoreUnknown = true)
public class Sp_cc_cuenta_GetDetail_Item implements Serializable {

    @Serial
    private static final long serialVersionUID = 4746659860091930933L;

    @JsonProperty("nombre apellido")
    private String nombreApellido;

    @JsonProperty("cuit cuil")
    private String cuitCuil;

    @JsonProperty("rol")
    private String rol;

    @JsonProperty("descripcion rol")
    private String descriptionRol;

}
