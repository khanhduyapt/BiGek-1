package bsc_scan_binance.entity;

import java.math.BigDecimal;

import javax.persistence.Column;
import javax.persistence.ColumnResult;
import javax.persistence.ConstructorResult;
import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.SqlResultSetMapping;
import javax.persistence.Table;

import bsc_scan_binance.response.GeckoVolumeUpPre4hResponse;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Entity
@AllArgsConstructor
@NoArgsConstructor
@Table(name = "gecko_volume_up_pre4h")

@SqlResultSetMapping(name = "GeckoVolumeUpPre4hResponse", classes = {
        @ConstructorResult(targetClass = GeckoVolumeUpPre4hResponse.class, columns = {
                @ColumnResult(name = "gecko_id", type = String.class),
                @ColumnResult(name = "symbol", type = String.class),
                @ColumnResult(name = "hh", type = String.class),

                @ColumnResult(name = "curr_voulme", type = BigDecimal.class),
                @ColumnResult(name = "avg_vol_pre4h", type = BigDecimal.class),
                @ColumnResult(name = "vol_up_rate", type = BigDecimal.class),
        })
})

public class GeckoVolumeUpPre4h {
    @Id
    @Column(name = "gecko_id")
    private String geckoid;

    @Column(name = "symbol")
    private String symbol;

    @Column(name = "hh")
    private String hh;

    @Column(name = "curr_voulme")
    private BigDecimal curr_voulme = BigDecimal.ZERO;

    @Column(name = "avg_vol_pre4h")
    private BigDecimal avg_vol_pre4h = BigDecimal.ZERO;

    @Column(name = "vol_up_rate")
    private BigDecimal vol_up_rate = BigDecimal.ZERO;

}
