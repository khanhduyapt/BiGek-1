package bsc_scan_binance.response;

import java.math.BigDecimal;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class OrdersProfitResponse {

    private String gecko_id;
    private String symbol;
    private String name;

    private BigDecimal order_price;
    private BigDecimal qty;
    private BigDecimal amount;
    private BigDecimal price_at_binance;
    private BigDecimal target_percent;
    private BigDecimal tp_percent;
    private BigDecimal tp_amount;
    private String target;
}
