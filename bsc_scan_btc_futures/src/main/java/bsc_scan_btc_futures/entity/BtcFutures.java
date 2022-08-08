package bsc_scan_btc_futures.entity;

import java.math.BigDecimal;

import javax.persistence.Column;
import javax.persistence.ColumnResult;
import javax.persistence.ConstructorResult;
import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.SqlResultSetMapping;
import javax.persistence.Table;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import response.BtcFuturesResponse;

@Data
@Entity
@AllArgsConstructor
@NoArgsConstructor
@Table(name = "btc_futures")

@SqlResultSetMapping(name = "BtcFuturesResponse", classes = {
        @ConstructorResult(targetClass = BtcFuturesResponse.class, columns = {
                @ColumnResult(name = "long_sl", type = BigDecimal.class),
                @ColumnResult(name = "long_tp", type = BigDecimal.class),
                @ColumnResult(name = "low_price", type = BigDecimal.class),
                @ColumnResult(name = "min_candle", type = BigDecimal.class),
                @ColumnResult(name = "max_candle", type = BigDecimal.class),
                @ColumnResult(name = "hight_price", type = BigDecimal.class),
                @ColumnResult(name = "short_sl", type = BigDecimal.class),
                @ColumnResult(name = "short_tp", type = BigDecimal.class),
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
}
