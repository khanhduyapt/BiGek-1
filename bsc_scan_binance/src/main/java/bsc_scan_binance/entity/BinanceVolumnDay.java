package bsc_scan_binance.entity;

import java.math.BigDecimal;

import javax.persistence.Column;
import javax.persistence.EmbeddedId;
import javax.persistence.Entity;
import javax.persistence.Table;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Entity
@AllArgsConstructor
@NoArgsConstructor
@Table(name = "binance_volumn_day")
public class BinanceVolumnDay {
    @EmbeddedId
    private BinanceVolumnDayKey id;

    @Column(name = "total_volume")
    private BigDecimal totalVolume = BigDecimal.ZERO;

    @Column(name = "total_trasaction")
    private BigDecimal totalTrasaction = BigDecimal.ZERO;

    @Column(name = "price_at_binance")
    private BigDecimal priceAtBinance = BigDecimal.ZERO;

    @Column(name = "low_price")
    private BigDecimal low_price = BigDecimal.ZERO;

    @Column(name = "hight_price")
    private BigDecimal hight_price = BigDecimal.ZERO;

    @Column(name = "price_open_candle")
    private BigDecimal price_open_candle = BigDecimal.ZERO;

    @Column(name = "price_close_candle")
    private BigDecimal price_close_candle = BigDecimal.ZERO;

    @Column(name = "rsi")
    private BigDecimal rsi = BigDecimal.ZERO;

    @Column(name = "point")
    private String point;

    public BinanceVolumnDay(BinanceVolumnDayKey id) {
        this.id = id;
    }

}
