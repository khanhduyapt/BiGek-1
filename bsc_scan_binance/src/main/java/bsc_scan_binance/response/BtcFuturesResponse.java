package bsc_scan_binance.response;

import java.math.BigDecimal;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class BtcFuturesResponse {
    private BigDecimal long_sl;
    private BigDecimal long_tp;
    private BigDecimal low_price;
    private BigDecimal min_candle;
    private BigDecimal max_candle;
    private BigDecimal hight_price;
    private BigDecimal short_sl;
    private BigDecimal short_tp;
}
