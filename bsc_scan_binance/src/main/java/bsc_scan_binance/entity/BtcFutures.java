package bsc_scan_binance.entity;

import java.math.BigDecimal;

import javax.persistence.Column;
import javax.persistence.ColumnResult;
import javax.persistence.ConstructorResult;
import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.SqlResultSetMapping;
import javax.persistence.Table;

import bsc_scan_binance.response.BtcFuturesResponse;
import bsc_scan_binance.utils.Utils;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Entity
@AllArgsConstructor
@NoArgsConstructor
@Table(name = "btc_futures")

@SqlResultSetMapping(name = "BtcFuturesResponse", classes = {
        @ConstructorResult(targetClass = BtcFuturesResponse.class, columns = {
                @ColumnResult(name = "low_price_1m", type = BigDecimal.class),
                @ColumnResult(name = "min_candle_1m", type = BigDecimal.class),
                @ColumnResult(name = "max_candle_1m", type = BigDecimal.class),
                @ColumnResult(name = "hight_price_1m", type = BigDecimal.class),

                @ColumnResult(name = "low_price_15m", type = BigDecimal.class),
                @ColumnResult(name = "min_candle_15m", type = BigDecimal.class),
                @ColumnResult(name = "max_candle_15m", type = BigDecimal.class),
                @ColumnResult(name = "hight_price_15m", type = BigDecimal.class),

                @ColumnResult(name = "low_price_24h", type = BigDecimal.class),
                @ColumnResult(name = "hight_price_24h", type = BigDecimal.class),
        })
})

public class BtcFutures {

    @Id
    @Column(name = "id")
    private String id;

    @Column(name = "current_price")
    private BigDecimal currPrice = BigDecimal.ZERO;

    @Column(name = "low_price")
    private BigDecimal low_price = BigDecimal.ZERO;

    @Column(name = "hight_price")
    private BigDecimal hight_price = BigDecimal.ZERO;

    @Column(name = "price_open_candle")
    private BigDecimal price_open_candle = BigDecimal.ZERO;

    @Column(name = "price_close_candle")
    private BigDecimal price_close_candle = BigDecimal.ZERO;

    @Column(name = "uptrend")
    private boolean uptrend = true;

    @Override
    public String toString() {
        String change = Utils.toPercent(price_close_candle, price_open_candle, 2);
        String amplitude = Utils
                .removeLastZero(Utils.getBigDecimalValue(Utils.toPercent(hight_price, low_price, 2)).abs().toString());

        return "Btc [O:" + Utils.removeLastZero(price_open_candle.toString()) + ", H:"
                + Utils.removeLastZero(hight_price.toString()) + ", L:=" + Utils.removeLastZero(low_price.toString())
                + ", C:" + Utils.removeLastZero(price_close_candle.toString()) + ", Change:"
                + Utils.removeLastZero(change.toString()) + "%, Amplitude: " + amplitude + "]";
    }

    public boolean isKillLong() {
        BigDecimal change = Utils.getBigDecimalValue(Utils.toPercent(price_close_candle, price_open_candle, 2));

        BigDecimal amplitude = Utils.getBigDecimalValue(Utils.toPercent(hight_price, low_price, 2)).abs();

        if ((change.compareTo(BigDecimal.valueOf(-0.4)) < 0) && (amplitude.compareTo(BigDecimal.valueOf(1)) > 0)) {
            return true;
        }

        return false;
    }
}
