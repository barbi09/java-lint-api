package ar.com.macro.apirest.base.accounts.dto.app.get_detail.response;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.*;
import java.io.Serial;
import java.io.Serializable;
import java.util.List;

@Builder
@NoArgsConstructor
@AllArgsConstructor
@Data
public class GetDetail_Response implements Serializable {
    @Serial
    private static final long serialVersionUID = -6264296528112585362L;

    private String denomination;

    private String cbu;

    @JsonProperty("officer-id")
    private Integer officerId;

    @JsonProperty("officer-description")
    private String officerDescription;

    @JsonProperty("currency-id")
    private Integer currencyId;

    @JsonProperty("category-id")
    private String categoryId;

    @JsonProperty("category-description")
    private String categoryDescription;

    @JsonProperty("branch-id")
    private Integer branchId;

    @JsonProperty("branch-description")
    private String branchDescription;

    @JsonProperty("type-id")
    private Integer typeId;

    @JsonProperty("type-description")
    private String typeDescription;

    @JsonProperty("product-bank-id")
    private Integer productBankId;

    @JsonProperty("sub-product-description")
    private String productBankDescription;

    @JsonProperty("status-id")
    private String statusId;

    @JsonProperty("opening-date")
    private String openingDate;

    @JsonProperty("legal-entity-type")
    private String legalEntityType;

    @JsonProperty("last-transaction-date")
    private String lastTransactionDate;

    @JsonProperty("deposit-blocked")
    private Boolean depositBlocked;

    @JsonProperty("blocked-withdrawal")
    private Boolean blockedWithdrawal;

    private List<GetDetail_ParticipantsElement> participants;

}
