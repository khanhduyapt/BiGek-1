package bsc_scan_binance.entity;

import java.math.BigDecimal;
import java.math.BigInteger;

import javax.persistence.Column;
import javax.persistence.ColumnResult;
import javax.persistence.ConstructorResult;
import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.SqlResultSetMapping;
import javax.persistence.Table;

import bsc_scan_binance.response.DepthResponse;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Entity
@AllArgsConstructor
@NoArgsConstructor
@Table(name = "depth_asks")

@SqlResultSetMapping(name = "DepthResponse", classes = {
        @ConstructorResult(targetClass = DepthResponse.class, columns = {
                @ColumnResult(name = "gecko_id", type = String.class),
                @ColumnResult(name = "symbol", type = String.class),
                @ColumnResult(name = "price", type = BigDecimal.class),
                @ColumnResult(name = "qty", type = BigDecimal.class),
                @ColumnResult(name = "val_million_dolas", type = BigDecimal.class),
        })
})

public class DepthAsks {
    @Id
    @Column(name = "rowidx")
    private BigInteger rowidx;

    @Column(name = "gecko_id")
    private String geckoId;

    @Column(name = "symbol")
    private String symbol;

    @Column(name = "price")
    private BigDecimal price;

    @Column(name = "qty")
    private BigDecimal qty;
}
