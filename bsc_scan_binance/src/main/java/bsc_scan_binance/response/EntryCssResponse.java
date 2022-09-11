package bsc_scan_binance.response;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class EntryCssResponse {
    private String symbol = "";
    private String tradingview;

    private String futures_msg;

    private String entry;
    private String stop_loss;
    private String low;
    private String tp1;
    private String tp2;
}
