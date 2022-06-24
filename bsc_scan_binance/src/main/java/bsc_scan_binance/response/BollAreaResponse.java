package bsc_scan_binance.response;

import java.math.BigDecimal;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class BollAreaResponse {
    private String gecko_id;
    private String symbol;
    private String name;
    private BigDecimal avg_price;
    private BigDecimal price_open_candle;
    private BigDecimal price_close_candle;
    private BigDecimal low_price;
    private BigDecimal price_can_buy;
    private BigDecimal price_can_sell;
    private Boolean is_bottom_area;
    private Boolean is_top_area;
    private BigDecimal profit;
    private Boolean vector_up;
    private String vector_desc;
}
