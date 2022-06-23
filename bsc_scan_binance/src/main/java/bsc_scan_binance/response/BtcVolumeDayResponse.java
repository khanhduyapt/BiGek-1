package bsc_scan_binance.response;

import java.math.BigDecimal;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class BtcVolumeDayResponse {
    private BigDecimal vector_now;
    private BigDecimal vector_pre4h;
    private BigDecimal vector_pre8h;

    private BigDecimal price_now;
    private BigDecimal price_pre4h;
    private BigDecimal price_pre8h;
    private BigDecimal price_pre12h;
}
