package bsc_scan_binance.response;

import java.math.BigDecimal;
import java.math.RoundingMode;

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
        BigDecimal value = BigDecimal.ZERO;
        try {
            value = high.divide(avg_high, 2, RoundingMode.CEILING).abs();

        } catch (Exception e) {
            value = high.divide(BigDecimal.valueOf(0.002), 2, RoundingMode.CEILING).abs();
        }

        if (value.compareTo(BigDecimal.valueOf(100)) > 0) {
            return BigDecimal.valueOf(100);
        }

        return value;

    }

    public BigDecimal getLowUp() {
        BigDecimal value = BigDecimal.ZERO;

        try {

            value = low.divide(avg_low, 2, RoundingMode.CEILING).abs();

        } catch (Exception e) {
            value = low.divide(BigDecimal.valueOf(0.06), 2, RoundingMode.CEILING).abs();
        }

        if (value.compareTo(BigDecimal.valueOf(100)) > 0) {
            return BigDecimal.valueOf(100);
        }

        return value;
    }
}
