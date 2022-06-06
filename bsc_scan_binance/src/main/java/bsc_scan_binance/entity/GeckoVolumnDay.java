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
@Table(name = "gecko_volumn_day")
public class GeckoVolumnDay {
    @EmbeddedId
    private GeckoVolumnDayKey id;

    @Column(name = "total_volume")
    private BigDecimal totalVolume;

}
