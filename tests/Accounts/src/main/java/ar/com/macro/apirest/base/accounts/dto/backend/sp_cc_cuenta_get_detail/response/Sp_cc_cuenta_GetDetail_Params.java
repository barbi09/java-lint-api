package ar.com.macro.apirest.base.accounts.dto.backend.sp_cc_cuenta_get_detail.response;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.io.Serial;
import java.io.Serializable;
import java.util.List;

@Data
@NoArgsConstructor
@JsonIgnoreProperties(ignoreUnknown = true)
public class Sp_cc_cuenta_GetDetail_Params implements Serializable {

    @Serial
    private static final long serialVersionUID = 5210615145838161774L;

    @JsonProperty("@o_d_nombre")
    private String oDNombre;

    @JsonProperty("@o_n_cbu")
    private String oNCbu;

    @JsonProperty("@o_c_oficial")
    private Integer oCOficial;

    @JsonProperty("@o_d_oficial")
    private String oDOficial;

    @JsonProperty("@o_c_moneda")
    private Integer oCMoneda;

    @JsonProperty("@o_c_categoria")
    private String oCCategoria;

    @JsonProperty("@o_d_categoria")
    private String oDCategoria;

    @JsonProperty("@o_c_oficina")
    private Integer oCOficina;

    @JsonProperty("@o_d_oficina")
    private String oDOficina;

    @JsonProperty("@o_c_producto")
    private Integer oCProducto;

    @JsonProperty("@o_d_producto")
    private String oDProducto;

    @JsonProperty("@o_c_prod_banc")
    private Integer o_CProdBanc;

    @JsonProperty("@o_d_prod_banc")
    private String PDProdBanc;

    @JsonProperty("@o_c_estado")
    private String oCEstado;

    @JsonProperty("@o_f_apertura")
    private String oFApertura;

    @JsonProperty("@o_c_tipocta")
    private String oCTipocta;

    @JsonProperty("@o_f_ultimo_movimiento")
    private String oFUltimoMovimiento;

    @JsonProperty("@o_m_bloq_deposito")
    private String oMBloqDeposito;

    @JsonProperty("@o_m_bloq_retiro")
    private String oMBloqRetiro;

}
