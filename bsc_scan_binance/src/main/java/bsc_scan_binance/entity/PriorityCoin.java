package bsc_scan_binance.entity;

import java.math.BigDecimal;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.Table;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Entity
@AllArgsConstructor
@NoArgsConstructor
@Table(name = "priority_coin")

public class PriorityCoin {
    @Id
    @Column(name = "gecko_id")
    private String geckoid;

    @Column(name = "current_price")
    private BigDecimal current_price;

    @Column(name = "target_price")
    private BigDecimal target_price;

    @Column(name = "target_percent")
    private String target_percent;

    @Column(name = "oco_hight")
    private String oco_hight;

    @Column(name = "is_candidate")
    private Boolean candidate;

    @Column(name = "index")
    private Integer index;

    @Column(name = "name")
    private String name;

    @Column(name = "note")
    private String note;

    @Column(name = "symbol")
    private String symbol;

    @Column(name = "ema")
    private BigDecimal ema;
}
