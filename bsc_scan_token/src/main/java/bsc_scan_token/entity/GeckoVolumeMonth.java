package bsc_scan_token.entity;

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
@Table(name = "all_market_volume_month")
public class GeckoVolumeMonth {
    @EmbeddedId
    private GeckoVolumeMonthKey id;

    @Column(name = "total_volume")
    private BigDecimal totalVolume = BigDecimal.ZERO;

    @Column(name = "price")
    private BigDecimal price = BigDecimal.ZERO;

}
