package bsc_scan_binance.entity;

import java.math.BigDecimal;

import javax.persistence.Column;
import javax.persistence.ColumnResult;
import javax.persistence.ConstructorResult;
import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.SqlResultSetMapping;
import javax.persistence.Table;

import bsc_scan_binance.response.OrdersProfitResponse;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Entity
@AllArgsConstructor
@NoArgsConstructor
@Table(name = "orders")

//CREATE TABLE IF NOT EXISTS public.orders
//(
//    gecko_id character varying(255) COLLATE pg_catalog."default" NOT NULL,
//    symbol character varying(255) COLLATE pg_catalog."default",
//    name character varying(255) COLLATE pg_catalog."default",
//    order_price numeric(10,5) DEFAULT 0,
//    qty numeric(10,5) DEFAULT 0,
//    amount numeric(30,5) DEFAULT 0,
//    CONSTRAINT orders_pkey PRIMARY KEY (gecko_id)
//)

@SqlResultSetMapping(name = "OrdersProfitResponse", classes = {
        @ConstructorResult(targetClass = OrdersProfitResponse.class, columns = {
                @ColumnResult(name = "gecko_id", type = String.class),
                @ColumnResult(name = "symbol", type = String.class),
                @ColumnResult(name = "name", type = String.class),

                @ColumnResult(name = "order_price", type = BigDecimal.class),
                @ColumnResult(name = "qty", type = BigDecimal.class),
                @ColumnResult(name = "amount", type = BigDecimal.class),
                @ColumnResult(name = "price_at_binance", type = BigDecimal.class),
                @ColumnResult(name = "tp_percent", type = BigDecimal.class),
                @ColumnResult(name = "tp_amount", type = BigDecimal.class),

                @ColumnResult(name = "target", type = String.class),
        })
})

public class Orders {
    @Id
    @Column(name = "gecko_id")
    private String geckoid;

    @Column(name = "symbol")
    private String symbol;

    @Column(name = "name")
    private String name;

    @Column(name = "order_price")
    private BigDecimal order_price = BigDecimal.ZERO;

    @Column(name = "qty")
    private BigDecimal qty = BigDecimal.ZERO;

    @Column(name = "amount")
    private BigDecimal amount = BigDecimal.ZERO;

}
