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
public class GetBalance_Balance implements Serializable {

  @Serial
  private static final long serialVersionUID = -8034871678761899853L;

  private String remittance;

  @JsonProperty("signed_24h")
  private String signed24h;

  private String available;

  private String accounting;

  @JsonProperty("bank-draft")
  private String bankDraft;

  private String blocked;

  @JsonProperty("signed_48h")
  private String signed48h;

  private String suspended;

  private String agreement;
}