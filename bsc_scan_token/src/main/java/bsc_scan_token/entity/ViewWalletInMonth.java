package bsc_scan_token.entity;

import java.math.BigDecimal;

import javax.persistence.Column;
import javax.persistence.ColumnResult;
import javax.persistence.ConstructorResult;
import javax.persistence.EmbeddedId;
import javax.persistence.Entity;
import javax.persistence.SqlResultSetMapping;
import javax.persistence.Table;

import bsc_scan_token.response.ViewWalletInMonthResponse;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Entity
@AllArgsConstructor
@NoArgsConstructor
@Table(name = "all_market_wallet_in_month")

@SqlResultSetMapping(name = "ViewWalletInMonthResponse", classes = {
        @ConstructorResult(targetClass = ViewWalletInMonthResponse.class, columns = {
                @ColumnResult(name = "gecko_id", type = String.class),
                @ColumnResult(name = "blockchain", type = String.class),
                @ColumnResult(name = "address", type = String.class),
                @ColumnResult(name = "yyyymmdd", type = String.class),
                @ColumnResult(name = "quantity_old", type = BigDecimal.class),
                @ColumnResult(name = "quantity_new", type = BigDecimal.class),
                @ColumnResult(name = "total_value", type = BigDecimal.class),
                @ColumnResult(name = "wallet_name", type = String.class),
                @ColumnResult(name = "percent_up", type = BigDecimal.class),
                @ColumnResult(name = "ape_link", type = String.class), }) })

public class ViewWalletInMonth {
    @EmbeddedId
    private ViewWalletInMonthKey id;

    @Column(name = "quantity_old")
    private BigDecimal quantity01;

    @Column(name = "quantity_new")
    private BigDecimal quantity31;

    @Column(name = "total_value")
    private BigDecimal totalValue;

    @Column(name = "wallet_name")
    private String walletName;

    @Column(name = "percent_up")
    private BigDecimal percentUp;

    @Column(name = "ape_link")
    private String apeLink;
}
