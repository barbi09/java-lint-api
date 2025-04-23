package ar.com.macro.apirest.base.accounts.dto.app.get_balance.response;

import lombok.*;
import java.io.Serial;
import java.io.Serializable;

@Builder
@NoArgsConstructor
@AllArgsConstructor
@Data

public class GetBalance_Response implements Serializable {
    @Serial
    private static final long serialVersionUID = 6171626251268356530L;

    private GetBalance_Account account;

    private GetBalance_Balance balance;

}