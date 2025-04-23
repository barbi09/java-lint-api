package ar.com.macro.apirest.base.accounts.dto.backend.sp_cc_cuenta_get_list.response;

import java.io.Serial;
import java.io.Serializable;
import java.util.List;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import lombok.Data;
import lombok.NoArgsConstructor;

@NoArgsConstructor
@Data
@JsonIgnoreProperties(ignoreUnknown = true)
public class Sp_cc_cuenta_GetList_Response implements Serializable {

  @Serial
  private static final long serialVersionUID = 5548949640467492221L;
    private List<Sp_cc_cuenta_GetList_Item> data;
}