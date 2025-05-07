package ar.com.macro.apirest.base.accounts.dto.backend.sp_cc_cuenta_get_list.response;

import java.io.Serial;
import java.io.Serializable;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
public class Sp_cc_cuenta_GetList_Item implements Serializable {

  @Serial
  private static final long serialVersionUID = 9160918755348038144L;

  private String cuenta;

  @JsonProperty("estado cuenta")
  private String estadoCuenta;

  private String moneda;

  private String cbu;

  private String producto;

  @JsonProperty("descripcion cuenta")
  private String descripcionCuenta;

  @JsonProperty("descripcion producto")
  private String descripcionProducto;

  private String categoria;

  private Integer sucursal;

  @JsonProperty("descripcion sucursal")
  private String descripcionSucursal;

  @JsonProperty("producto bancario")
  private String productoBancario;

  @JsonProperty("desc prod bancario")
  private String descProdBancario;

  @JsonProperty("saldo disponible")
  private String saldoDisponible;

  @JsonProperty("saldo a girar")
  private String saldoAGirar;

  @JsonProperty("acuerdo sobregiro")
  private String acuerdoSobregiro;

  private String cliente;

  @JsonProperty("rol del cliente")
  private String rolDelCliente;

  private String transaccional;

}