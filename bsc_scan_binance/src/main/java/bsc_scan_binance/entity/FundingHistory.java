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
@Table(name = "funding_history")

public class FundingHistory {

    @EmbeddedId
    private FundingHistoryKey id;

    @Column(name = "symbol")
    private String symbol;

    @Column(name = "low")
    private BigDecimal low;

    @Column(name = "high")
    private BigDecimal high;

    @Column(name = "avg_low")
    private BigDecimal avgLow;

    @Column(name = "avg_high")
    private BigDecimal avgHigh;

    @Column(name = "count_low")
    private int countLow;

    @Column(name = "count_high")
    private int countHigh;

    @Column(name = "note")
    private String note;

    @Column(name = "pumpdump")
    private boolean pumpdump;

}
