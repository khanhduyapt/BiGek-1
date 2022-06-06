package codervi.bsc_scan.request;

import lombok.Data;

@Data
public class CoinGeckoTokenRequest {
    private String id;
    private String symbol;
    private String name;
    private String note;
    private Integer priority;
}
