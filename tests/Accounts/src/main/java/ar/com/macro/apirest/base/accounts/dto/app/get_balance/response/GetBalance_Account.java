package ar.com.macro.apirest.base.accounts.dto.app.get_balance.response;


import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.io.Serial;
import java.io.Serializable;

@Data
@NoArgsConstructor
@JsonIgnoreProperties(ignoreUnknown = true)
public class GetBalance_Account implements Serializable {

  @Serial
  private static final long serialVersionUID = -2429618439137674209L;

  @JsonProperty("currency-id")
  private String currencyId;

}