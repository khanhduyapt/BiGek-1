package bsc_scan_binance.entity;

import java.math.BigDecimal;

import javax.persistence.Column;
import javax.persistence.ColumnResult;
import javax.persistence.ConstructorResult;
import javax.persistence.EmbeddedId;
import javax.persistence.Entity;
import javax.persistence.SqlResultSetMapping;
import javax.persistence.Table;

import bsc_scan_binance.response.BitcoinBalancesOnExchangesResponse;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Entity
@AllArgsConstructor
@NoArgsConstructor
@Table(name = "bitcoin_balances_on_exchanges")

@SqlResultSetMapping(name = "BitcoinBalancesOnExchangesResponse", classes = {
        @ConstructorResult(targetClass = BitcoinBalancesOnExchangesResponse.class, columns = {
                @ColumnResult(name = "price_now", type = BigDecimal.class),
                @ColumnResult(name = "change_24h", type = BigDecimal.class),
                @ColumnResult(name = "change_24h_val_million", type = BigDecimal.class),
                @ColumnResult(name = "change_7d", type = BigDecimal.class),
                @ColumnResult(name = "change_7d_val_million", type = BigDecimal.class),
        })
})

public class BitcoinBalancesOnExchanges {
    @EmbeddedId
    private BitcoinBalancesOnExchangesKey id;

    @Column(name = "balance")
    private BigDecimal balance;

    @Column(name = "balance_change")
    private BigDecimal balanceChange;

    @Column(name = "balance_change_percent")
    private BigDecimal balanceChangePercent;

    @Column(name = "d7_balance_change")
    private BigDecimal d7BalanceChange;

    @Column(name = "d7_balance_change_percent")
    private BigDecimal d7BalanceChangePercent;

    @Column(name = "d30_balance_change")
    private BigDecimal d30BalanceChange;

    @Column(name = "d30_balance_change_percent")
    private BigDecimal d30BalanceChangePercent;

    @Column(name = "ex_logo")
    private String exLogo;

}
