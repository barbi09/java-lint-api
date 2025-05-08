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
public class GetList_Pagination implements Serializable {

  @Serial
  private static final long serialVersionUID = 4920182664097706217L;

  @JsonProperty("total-records")
  private Integer totalRecords;

  @JsonProperty("records-number")
  private Integer recordsNumber;

  @JsonProperty("additional-records")
  private Boolean additionalRecords;

  @JsonProperty("last-record")
  private String lastRecord;

}