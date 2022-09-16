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
@Table(name = "binance_volumn_week")
public class BinanceVolumnWeek {
    @EmbeddedId
    private BinanceVolumnWeekKey id;

    @Column(name = "total_volume")
    private BigDecimal totalVolume = BigDecimal.ZERO;

    @Column(name = "total_trasaction")
    private BigDecimal totalTrasaction = BigDecimal.ZERO;

    @Column(name = "avg_price")
    private BigDecimal avgPrice = BigDecimal.ZERO;

    @Column(name = "min_price")
    private BigDecimal min_price = BigDecimal.ZERO;

    @Column(name = "max_price")
    private BigDecimal max_price = BigDecimal.ZERO;

}

