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
@Table(name = "binance_futures")

public class BinanceFutures {
    @Id
    @Column(name = "gecko_id")
    private String geckoid;

    @Column(name = "symbol")
    private String symbol;

    @Column(name = "name")
    private String name;

    @Column(name = "futures_msg")
    private String futuresMsg;

    @Column(name = "futures_css")
    private String futuresCss;

    @Column(name = "top_trader_binance_long_rate")
    private BigDecimal topTraderBinanceLongRate;

    @Column(name = "top_trader_okx_long_rate")
    private BigDecimal topTraderOkxLongRate;

    @Column(name = "top_trader_huobi_long_rate")
    private BigDecimal topTraderHuobiLongRate;

    @Column(name = "global_binance_long_rate")
    private BigDecimal globalBinanceLongRate;

    @Column(name = "global_ftx_long_rate")
    private BigDecimal globalFtxLongRate;

    @Column(name = "scalping_today")
    private boolean scalpingToday;

    @Column(name = "scalping_entry")
    private String scalpingEntry;

}
