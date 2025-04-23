package ar.com.macro.apirest.base.accounts.dto.app.get_detail.response;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.*;
import java.io.Serial;
import java.io.Serializable;

@Builder
@NoArgsConstructor
@AllArgsConstructor
@Data
public class GetDetail_ParticipantsElement implements Serializable {
    @Serial
    private static final long serialVersionUID = -4829343275810101255L;

    @JsonProperty("full-name")
    private String fullName;

    @JsonProperty("taxpayer-number")
    private String taxpayerNJumber;

    @JsonProperty("party-role-id")
    private String partyRoleId;

    @JsonProperty("party-role-description")
    private String partyRoleDescription;

}
