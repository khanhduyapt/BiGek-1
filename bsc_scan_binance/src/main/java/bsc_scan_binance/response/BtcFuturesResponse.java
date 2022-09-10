package bsc_scan_binance.response;

import java.math.BigDecimal;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class BtcFuturesResponse {
    private BigDecimal low_price_h;
    private BigDecimal open_candle_h;
    private BigDecimal close_candle_h;
    private BigDecimal hight_price_h;
}
