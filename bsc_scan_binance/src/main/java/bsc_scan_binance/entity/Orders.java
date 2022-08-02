package bsc_scan_binance.entity;

import java.math.BigDecimal;

import javax.persistence.Column;
import javax.persistence.ColumnResult;
import javax.persistence.ConstructorResult;
import javax.persistence.EmbeddedId;
import javax.persistence.Entity;
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
                @ColumnResult(name = "chatId", type = String.class),
                @ColumnResult(name = "userName", type = String.class),

                @ColumnResult(name = "order_price", type = BigDecimal.class),
                @ColumnResult(name = "qty", type = BigDecimal.class),
                @ColumnResult(name = "amount", type = BigDecimal.class),
                @ColumnResult(name = "price_at_binance", type = BigDecimal.class),
                @ColumnResult(name = "target_percent", type = BigDecimal.class),
                @ColumnResult(name = "tp_percent", type = BigDecimal.class),
                @ColumnResult(name = "tp_amount", type = BigDecimal.class),
                @ColumnResult(name = "low_price", type = BigDecimal.class),
                @ColumnResult(name = "height_price", type = BigDecimal.class),
                @ColumnResult(name = "target", type = String.class),
        })
})

public class Orders {
    @EmbeddedId
    private OrderKey id;

    @Column(name = "order_price")
    private BigDecimal order_price = BigDecimal.ZERO;

    @Column(name = "qty")
    private BigDecimal qty = BigDecimal.ZERO;

    @Column(name = "amount")
    private BigDecimal amount = BigDecimal.ZERO;

    @Column(name = "low_price")
    private BigDecimal low_price = BigDecimal.ZERO;

    @Column(name = "height_price")
    private BigDecimal height_price = BigDecimal.ZERO;

    @Column(name = "note")
    private String note;
}
