package bsc_scan_binance.entity;

import java.math.BigDecimal;

import javax.persistence.Column;
import javax.persistence.ColumnResult;
import javax.persistence.ConstructorResult;
import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.SqlResultSetMapping;
import javax.persistence.Table;

import bsc_scan_binance.response.CandidateTokenResponse;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Entity
@AllArgsConstructor
@NoArgsConstructor
@Table(name = "candidate_coin")

@SqlResultSetMapping(name = "CandidateTokenResponse", classes = {
        @ConstructorResult(targetClass = CandidateTokenResponse.class, columns = {
                @ColumnResult(name = "gecko_id", type = String.class),
                @ColumnResult(name = "symbol", type = String.class),
                @ColumnResult(name = "name", type = String.class),
                @ColumnResult(name = "pumping_history", type = String.class),

                @ColumnResult(name = "volumn_div_marketcap", type = String.class),
                @ColumnResult(name = "pre_4h_total_volume_up", type = String.class),

                @ColumnResult(name = "vol_now", type = String.class),
                @ColumnResult(name = "price_now", type = String.class),
                @ColumnResult(name = "price_pre_1h", type = String.class),
                @ColumnResult(name = "price_pre_2h", type = String.class),
                @ColumnResult(name = "price_pre_3h", type = String.class),
                @ColumnResult(name = "price_pre_4h", type = String.class),

                @ColumnResult(name = "market_cap ", type = String.class),
                @ColumnResult(name = "current_price", type = String.class),

                @ColumnResult(name = "gecko_total_volume", type = String.class),
                @ColumnResult(name = "gec_vol_pre_1h", type = String.class),
                @ColumnResult(name = "gec_vol_pre_2h", type = String.class),
                @ColumnResult(name = "gec_vol_pre_3h", type = String.class),
                @ColumnResult(name = "gec_vol_pre_4h", type = String.class),

                @ColumnResult(name = "price_change_percentage_24h", type = String.class),
                @ColumnResult(name = "price_change_percentage_7d", type = String.class),
                @ColumnResult(name = "price_change_percentage_14d", type = String.class),
                @ColumnResult(name = "price_change_percentage_30d", type = String.class),
                @ColumnResult(name = "category", type = String.class),
                @ColumnResult(name = "trend", type = String.class),
                @ColumnResult(name = "total_supply", type = String.class),
                @ColumnResult(name = "max_supply", type = String.class),
                @ColumnResult(name = "circulating_supply", type = String.class),
                @ColumnResult(name = "binance_trade", type = String.class),
                @ColumnResult(name = "coin_gecko_link", type = String.class),
                @ColumnResult(name = "backer", type = String.class),
                @ColumnResult(name = "note", type = String.class),

                @ColumnResult(name = "today", type = String.class),
                @ColumnResult(name = "day_0", type = String.class),
                @ColumnResult(name = "day_1", type = String.class),
                @ColumnResult(name = "day_2", type = String.class),
                @ColumnResult(name = "day_3", type = String.class),
                @ColumnResult(name = "day_4", type = String.class),
                @ColumnResult(name = "day_5", type = String.class),
                @ColumnResult(name = "day_6", type = String.class),
                @ColumnResult(name = "day_7", type = String.class),
                @ColumnResult(name = "day_8", type = String.class),
                @ColumnResult(name = "day_9", type = String.class),
                @ColumnResult(name = "day_10", type = String.class),
                @ColumnResult(name = "day_11", type = String.class),
                @ColumnResult(name = "day_12", type = String.class),
                @ColumnResult(name = "priority", type = String.class),

                @ColumnResult(name = "ema07d", type = BigDecimal.class),
                @ColumnResult(name = "ema14d", type = BigDecimal.class),
                @ColumnResult(name = "ema21d", type = BigDecimal.class),
                @ColumnResult(name = "ema28d", type = BigDecimal.class),
                @ColumnResult(name = "avg07d", type = BigDecimal.class),
                @ColumnResult(name = "avg14d", type = BigDecimal.class),
                @ColumnResult(name = "avg21d", type = BigDecimal.class),
                @ColumnResult(name = "avg28d", type = BigDecimal.class),
                @ColumnResult(name = "uptrend", type = Boolean.class),
        })
})

public class CandidateCoin {
    @Id
    @Column(name = "gecko_id")
    private String geckoid;

    @Column(name = "symbol")
    private String symbol;

    @Column(name = "name")
    private String name;

    @Column(name = "category")
    private String category;

    @Column(name = "trend")
    private String trend;

    @Column(name = "usdt")
    private String usdt;

    @Column(name = "busd")
    private String busd;

    @Column(name = "total_supply")
    private BigDecimal totalSupply = BigDecimal.ZERO;

    @Column(name = "max_supply")
    private BigDecimal maxSupply = BigDecimal.ZERO;

    @Column(name = "circulating_supply")
    private BigDecimal circulatingSupply = BigDecimal.ZERO;

    @Column(name = "binance_trade")
    private String binanceTrade;

    @Column(name = "coin_gecko_link")
    private String coinGeckoLink;

    @Column(name = "backer")
    private String backer;

    @Column(name = "market_cap")
    private BigDecimal marketCap = BigDecimal.ZERO;

    @Column(name = "current_price")
    private BigDecimal currentPrice = BigDecimal.ZERO;

    @Column(name = "total_volume")
    private BigDecimal totalVolume = BigDecimal.ZERO;

    @Column(name = "price_change_percentage_24h")
    private BigDecimal priceChangePercentage24H = BigDecimal.ZERO;

    @Column(name = "price_change_percentage_7d")
    private BigDecimal priceChangePercentage7D = BigDecimal.ZERO;

    @Column(name = "price_change_percentage_14d")
    private BigDecimal priceChangePercentage14D = BigDecimal.ZERO;

    @Column(name = "price_change_percentage_30d")
    private BigDecimal priceChangePercentage30D = BigDecimal.ZERO;

    @Column(name = "volumn_div_marketcap")
    private BigDecimal volumnDivMarketcap = BigDecimal.ZERO;

    public CandidateCoin(String geckoid, String symbol, String name) {
        this.geckoid = geckoid;
        this.symbol = symbol;
        this.name = name;
    }

}
