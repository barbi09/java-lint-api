package ar.com.macro.apirest.base.accounts.dto.app.get_movements.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.io.Serial;
import java.io.Serializable;
import java.util.List;

@Builder
@NoArgsConstructor
@AllArgsConstructor
@Data
public class GetMovements_Response implements Serializable {
  @Serial
  private static final long serialVersionUID = 769286830502315505L;

  private List<GetMovements_Movement> movements;

  private GetMovements_Pagination pagination;

}
