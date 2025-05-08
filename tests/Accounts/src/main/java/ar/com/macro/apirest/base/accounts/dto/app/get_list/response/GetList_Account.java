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
public class GetList_Account implements Serializable {

  @Serial
  private static final long serialVersionUID = -4644963507081519252L;

  private String number;

  @JsonProperty("status-id")
  private String statusId;

  @JsonProperty("currency-id")
  private Integer currencyId;

  private String cbu;

  @JsonProperty("type-id")
  private Integer typeId;

  @JsonProperty("type-description")
  private String typeDescription;

  @JsonProperty("product-description")
  private String productDescription;

  @JsonProperty("category-id")
  private String categoryId;

  private Integer branch;

  @JsonProperty("branch-description")
  private String branchDescription;

  @JsonProperty("product-bank-id")
  private Integer productBankId;

  @JsonProperty("product-bank-description")
  private String productBankDescription;

  private GetList_Balance balance;

  @JsonProperty("overdraft-agreement")
  private String overdraftAgreement;

  private GetList_Customer customer;

  @JsonProperty("conduct-transaction")
  private Boolean conductTransaction;

}