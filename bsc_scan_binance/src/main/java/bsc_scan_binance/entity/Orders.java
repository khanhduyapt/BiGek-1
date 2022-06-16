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

public class Orders {
    @Id
    @Column(name = "gecko_id")
    private String geckoid;

    @Column(name = "symbol")
    private String symbol;

    @Column(name = "name")
    private String name;

    @Column(name = "order_price")
    private BigDecimal order_price;

    @Column(name = "qty")
    private BigDecimal qty;

    @Column(name = "amount")
    private BigDecimal amount;

}
