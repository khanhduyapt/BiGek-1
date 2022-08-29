package bsc_scan_btc_futures.entity;

import java.math.BigDecimal;

import javax.persistence.Column;
import javax.persistence.ColumnResult;
import javax.persistence.ConstructorResult;
import javax.persistence.EmbeddedId;
import javax.persistence.Entity;
import javax.persistence.SqlResultSetMapping;
import javax.persistence.Table;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import response.DepthResponse;

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
    @EmbeddedId
    private DepthKey id;

    @Column(name = "qty")
    private BigDecimal qty;
}
