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
@Table(name = "view_opportunity")

public class ViewOpportunity {
    @Id
    @Column(name = "gecko_id")
    private String geckoid;

    @Column(name = "symbol")
    private String symbol;

    @Column(name = "name")
    private String name;

    @Column(name = "vol_today")
    private BigDecimal vol_today;

    @Column(name = "vol_avg_07d")
    private BigDecimal vol_avg_07d;

    @Column(name = "vol_gecko_increate")
    private BigDecimal vol_gecko_increate;

    @Column(name = "avg_price")
    private BigDecimal avg_price;

    @Column(name = "price_can_buy")
    private BigDecimal price_can_buy;

    @Column(name = "price_can_sell")
    private BigDecimal price_can_sell;

    @Column(name = "lost_normal")
    private BigDecimal lost_normal;

    @Column(name = "profit_normal")
    private BigDecimal profit_normal;

    @Column(name = "profit_max")
    private BigDecimal profit_max;

    @Column(name = "opportunity")
    private BigDecimal opportunity;

}
