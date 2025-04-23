package ar.com.macro.apirest.base.accounts.dto.backend.sp_cc_cuentas_get_movements.response;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.io.Serial;
import java.io.Serializable;
import java.util.List;

@NoArgsConstructor
@Data
@JsonIgnoreProperties(ignoreUnknown = true)
public class Sp_cc_cuenta_GetMovements_Response implements Serializable {
    @Serial
    private static final long serialVersionUID = 3415530831071630160L;

    private List<Sp_cc_cuenta_GetMovements_Item> data;
}
