package ar.com.macro.apirest.base.accounts.dto.app.get_list.response;

import lombok.*;
import java.io.Serial;
import java.io.Serializable;
import java.util.List;

@Builder
@NoArgsConstructor
@AllArgsConstructor
@Data
public class GetList_Response implements Serializable {
  @Serial
  private static final long serialVersionUID = 7499122293139520348L;

  private List<GetList_Account> accounts;

  private GetList_Pagination pagination;

}
