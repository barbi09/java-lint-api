package ar.com.macro.apirest.base.accounts.dto.backend.sp_cc_cuenta_get_balance.response;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.io.Serial;
import java.io.Serializable;

@Data
@NoArgsConstructor
@JsonIgnoreProperties(ignoreUnknown = true)
public class Sp_cc_cuenta_GetBalance_Params implements Serializable {

    @Serial
    private static final long serialVersionUID = 6358203721285682433L;

    @JsonProperty("@o_c_moneda")
    private String oCMoneda;

    @JsonProperty("@o_d_nombre")
    private String oDNombre;

    @JsonProperty("@o_i_remesas")
    private String oIRemesas;

    @JsonProperty("@o_i_24h")
    private String oI24h;

    @JsonProperty("@o_i_disponible")
    private String oIDisponible;

    @JsonProperty("@o_i_saldo_contable")
    private String oISaldoContable;

    @JsonProperty("@o_i_saldo_para_girar")
    private String oISaldo_ParaGirar;

    @JsonProperty("@o_i_bloqueo_valores")
    private String OIBloqueo-Valores;

    @JsonProperty("@o_i_48h")
    private String oI48h;

    @JsonProperty("@o_i_valores_suspenso")
    private String oIValoresSuspenso;

    @JsonProperty("@o_i_acuerdos")
    private String oIAcuerdos;
}
