package ar.com.macro.apirest.base.accounts.dto.backend.sp_cc_cuentas_get_movements.response;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.io.Serial;
import java.io.Serializable;

@Data
@NoArgsConstructor
@JsonIgnoreProperties(ignoreUnknown = true)
public class Sp_cc_cuenta_GetMovements_Item implements Serializable {

    @Serial
    private static final long serialVersionUID = 1429990074418041399L;

    private String fecha;

    private String secuencial;

    @JsonProperty("cod_alterno")
    private String codAlterno;

    @JsonProperty("ofi_cod")
    private String ofiCod;

    private String oficina;

    private String transaccion;

    @JsonProperty("d_c")
    private String dc;

    private String valor;

    @JsonProperty("cheque_causa")
    private String chequeCausa;

    private String hora;

    @JsonProperty("sec_his")
    private String secHis;

    @JsonProperty("referencia_nro")
    private String referenciaNumero;

    private String usuario;

    @JsonProperty("cod_causa")
    private String codCausa;

    private String cuit;

    @JsonProperty("sec_unico")
    private String secUnico;

}
