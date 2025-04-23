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
public class GetMovements_Pagination implements Serializable {
    @Serial
    private static final long serialVersionUID = -6072604689100247043L;

    @JsonProperty("total-records")
    private Integer totalRecords;

    @JsonProperty("records-number")
    private Integer recordsNumber;

    @JsonProperty("additional-records")
    private Boolean additionalRecords;

    @JsonProperty("last-record")
    private Integer lastRecord;

}
