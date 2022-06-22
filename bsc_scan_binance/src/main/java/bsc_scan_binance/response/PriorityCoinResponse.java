package bsc_scan_binance.response;

import java.math.BigDecimal;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class PriorityCoinResponse {
    private String gecko_id;
    private BigDecimal current_price;
    private BigDecimal target_price;
    private BigDecimal target_percent;
    private BigDecimal vmc;
    private Boolean is_candidate;
    private BigDecimal index;
    private String name;
    private String note;
    private String symbol;
    private BigDecimal ema;
    private BigDecimal low_price;
    private BigDecimal height_price;
    private String discovery_date_time;
    private Boolean mute;
    private Boolean predict;
    private Boolean inspect_mode;
    private Boolean good_price;
}
