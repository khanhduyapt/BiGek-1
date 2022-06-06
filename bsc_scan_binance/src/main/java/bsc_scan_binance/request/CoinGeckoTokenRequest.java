package bsc_scan_binance.request;

import lombok.Data;

@Data
public class CoinGeckoTokenRequest {
    private String id;
    private String symbol;
    private String name;
    private String note;
    private Integer priority;
}
