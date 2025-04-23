package ar.com.macro.apirest.base.accounts.dto.app.get_list.response;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.io.Serial;
import java.io.Serializable;

@Data
@NoArgsConstructor
@JsonIgnoreProperties(ignoreUnknown = true)
public class GetList_Customer implements Serializable {

  @Serial
  private static final long serialVersionUID = 5566324635443987741L;

  @JsonProperty("account-holder")
  private String accountHolder;

}