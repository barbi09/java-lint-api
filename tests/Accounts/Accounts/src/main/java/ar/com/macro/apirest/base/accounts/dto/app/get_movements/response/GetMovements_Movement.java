package ar.com.macro.apirest.base.accounts.dto.app.get_movements.response;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.io.Serial;
import java.io.Serializable;

@Builder
@NoArgsConstructor
@AllArgsConstructor
@Data
public class GetMovements_Movement implements Serializable {
    @Serial
    private static final long serialVersionUID = -8223504643129372147L;

    private String date;

    private Integer receipt;

    @JsonProperty("altern-receipt")
    private Integer alternReceipt;

    @JsonProperty("branch-id")
    private Integer branchId;

    @JsonProperty("branch-description")
    private String branchDescription;

    private String concept;

    private String type;

    private String amount;

    @JsonProperty("check-cause")
    private String checkCause;

    @JsonProperty("date-time")
    private String dateTime;

    @JsonProperty("internal-number")
    private Integer internalNumber;

    @JsonProperty("reference-code")
    private Integer referenceCode;

    @JsonProperty("be-user")
    private String beUser;

    @JsonProperty("causal-id")
    private String causalId;

    @JsonProperty("cuit-origin")
    private String cuitOrigin;

    @JsonProperty("sequence-number")
    private Integer sequenceNumber;

}
