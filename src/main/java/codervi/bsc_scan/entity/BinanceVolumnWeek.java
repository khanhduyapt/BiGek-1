package codervi.bsc_scan.entity;

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
    private BigDecimal totalVolume;

    @Column(name = "total_trasaction")
    private BigDecimal totalTrasaction;

    @Column(name = "avg_price")
    private BigDecimal avgPrice;
}

