package bsc_scan_binance.response;

import java.math.BigDecimal;
import java.math.RoundingMode;

import bsc_scan_binance.utils.Utils;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class FundingResponse {
    private BigDecimal high;
    private BigDecimal low;
    private BigDecimal avg_high;
    private BigDecimal avg_low;

    public BigDecimal getHighUp() {
        try {

            if (Utils.getBigDecimal(avg_high).equals(BigDecimal.ZERO)) {
                return BigDecimal.ZERO;
            }
            return high.divide(avg_high, 2, RoundingMode.CEILING).abs();

        } catch (Exception e) {
            return high.divide(BigDecimal.valueOf(0.002), 2, RoundingMode.CEILING).abs();
        }
    }

    public BigDecimal getLowUp() {
        try {

            if (Utils.getBigDecimal(avg_low).equals(BigDecimal.ZERO)) {
                return BigDecimal.ZERO;
            }
            return low.divide(avg_low, 2, RoundingMode.CEILING).abs();

        } catch (Exception e) {
            return low.divide(BigDecimal.valueOf(0.06), 2, RoundingMode.CEILING).abs();
        }
    }
}
