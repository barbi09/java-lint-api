package ar.com.macro.apirest.base.accounts.dto.backend.sp_cc_cuenta_get_balance.request;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.io.Serial;
import java.io.Serializable;

@XmlRootElement(name = "Envelope", namespace = "http://schemas.xmlsoap.org/soap/envelope/")
@XmlAccessorType(XmlAccessType.FIELD)
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Data
public class Sp_cc_cuenta_GetBalance_Params_request implements Serializable {

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
    private String oISaldoParaGirar;

    @JsonProperty("@o_i_bloqueo_valores")
    private String oIBloqueoValores;

    @JsonProperty("@o_i_48h")
    private String oI48h;

    @JsonProperty("@o_i_valores_suspenso")
    private String oIValoresSuspenso;

    @JsonProperty("@o_i_acuerdos")
    private String oIAcuerdos;
}
