package bsc_scan_binance.response;

import java.math.BigDecimal;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class BtcFuturesResponse {
    private BigDecimal low_price_1m;
    private BigDecimal min_candle_1m;
    private BigDecimal max_candle_1m;
    private BigDecimal hight_price_1m;
    private BigDecimal low_price_15m;
    private BigDecimal min_candle_15m;
    private BigDecimal max_candle_15m;
    private BigDecimal hight_price_15m;
    private BigDecimal low_price_24h;
    private BigDecimal hight_price_24h;
}
