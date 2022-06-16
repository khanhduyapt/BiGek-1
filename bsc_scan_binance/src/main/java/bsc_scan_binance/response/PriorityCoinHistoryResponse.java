package bsc_scan_binance.response;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class PriorityCoinHistoryResponse {
    private String gecko_id;
    private String symbol;
    private String name;
    private Integer count_notify;
}
