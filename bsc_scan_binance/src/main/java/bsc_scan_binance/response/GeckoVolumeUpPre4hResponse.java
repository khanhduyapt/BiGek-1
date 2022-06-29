package bsc_scan_binance.response;

import java.math.BigDecimal;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class GeckoVolumeUpPre4hResponse {
    private String gecko_id;
    private String symbol;
    private String hh;

    private BigDecimal curr_voulme;
    private BigDecimal avg_vol_pre4h;
    private BigDecimal vol_up_rate;
}
