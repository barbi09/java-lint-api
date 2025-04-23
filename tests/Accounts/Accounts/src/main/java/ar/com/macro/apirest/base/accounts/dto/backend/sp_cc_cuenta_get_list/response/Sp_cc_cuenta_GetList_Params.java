package ar.com.macro.apirest.base.accounts.dto.backend.sp_cc_cuenta_get_list.response;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.io.Serial;
import java.io.Serializable;

@Data
@NoArgsConstructor
@JsonIgnoreProperties(ignoreUnknown = true)
public class Sp_cc_cuenta_GetList_Params implements Serializable {

  @Serial
  private static final long serialVersionUID = -6442368563982278147L;

  @JsonProperty("@o_m_hay_mas")
  private String oMHayMas;

  @JsonProperty("@o_k_total")
  private String oKTotal;

  @JsonProperty("@o_k_pagina")
  private String oKPagina;

  @JsonProperty("@o_n_ultimo_id")
  private String oNUltimoId;

}