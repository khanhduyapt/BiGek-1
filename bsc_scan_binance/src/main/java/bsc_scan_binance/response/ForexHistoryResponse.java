package bsc_scan_binance.response;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class ForexHistoryResponse {
    private String epic = "";
    private String trend_d = "";
    private String trend_h1 = "";
}
