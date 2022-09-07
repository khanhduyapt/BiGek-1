package bsc_scan_binance.response;

import java.math.BigDecimal;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class BitcoinBalancesOnExchangesResponse {
    private BigDecimal price_now;
    private BigDecimal change_24h;
    private BigDecimal change_24h_val_million;
    private BigDecimal change_7d;
    private BigDecimal change_7d_val_million;
}
