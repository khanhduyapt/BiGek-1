package codervi.bsc_scan.utils;

import com.fasterxml.jackson.annotation.JsonInclude;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class Response {
    private String status;
    private String message;
    @JsonInclude(JsonInclude.Include.NON_NULL)
    private Long count;
    private Object data;
    private Object error;

    public Response(String status, String message) {
        this.status = status;
        this.message = message;
    }

    public Response(String status, String message, Long count, Object data) {
        this.status = status;
        this.message = message;
        this.count = count;
        this.data = data;
    }

    public Response(String status, String message, Object error) {
        this.status = status;
        this.message = message;
        this.error = error;
    }
}
