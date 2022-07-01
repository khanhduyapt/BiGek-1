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
@Table(name = "binance_volume_date_time")
public class BinanceVolumeDateTime {
    @EmbeddedId
    private BinanceVolumeDateTimeKey id;

    @Column(name = "volume")
    private BigDecimal volume = BigDecimal.ZERO;

}
