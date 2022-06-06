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
    private BigDecimal totalVolume;

    @Column(name = "total_trasaction")
    private BigDecimal totalTrasaction;

    @Column(name = "price_at_binance")
    private BigDecimal priceAtBinance;

}
