package bsc_scan_binance.entity;

import java.math.BigDecimal;

import javax.persistence.Column;
import javax.persistence.ColumnResult;
import javax.persistence.ConstructorResult;
import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.SqlResultSetMapping;
import javax.persistence.Table;

import bsc_scan_binance.response.BollAreaResponse;
import bsc_scan_binance.response.OrdersProfitResponse;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Entity
@AllArgsConstructor
@NoArgsConstructor
@Table(name = "boll_area")

//CREATE TABLE IF NOT EXISTS public.boll_area
//(
//    gecko_id character varying(255) COLLATE pg_catalog."default" NOT NULL,
//    symbol character varying(255) COLLATE pg_catalog."default",
//    name character varying(255) COLLATE pg_catalog."default",
//    avg_price numeric(30,5) DEFAULT 0,
//    price_open_candle numeric(30,5) DEFAULT 0,
//    price_close_candle numeric(30,5) DEFAULT 0,
//    low_price numeric(30,5) DEFAULT 0,
//    price_can_buy numeric(30,5) DEFAULT 0,
//    price_can_sell numeric(30,5) DEFAULT 0,
//    is_bottom_area boolean DEFAULT false,
//    is_top_area boolean DEFAULT false,
//    profit numeric(30,5) DEFAULT 0,
//    vector_up boolean DEFAULT false,
//    order_price numeric(30,5) DEFAULT 0,
//    vector_desc character varying(255),
//    CONSTRAINT boll_area_pkey PRIMARY KEY (gecko_id)
//);


@SqlResultSetMapping(name = "BollAreaResponse", classes = {
        @ConstructorResult(targetClass = BollAreaResponse.class, columns = {
                @ColumnResult(name = "gecko_id", type = String.class),
                @ColumnResult(name = "symbol", type = String.class),
                @ColumnResult(name = "name", type = String.class),
                @ColumnResult(name = "avg_price", type = BigDecimal.class),
                @ColumnResult(name = "price_open_candle", type = BigDecimal.class),
                @ColumnResult(name = "price_close_candle", type = BigDecimal.class),
                @ColumnResult(name = "low_price", type = BigDecimal.class),
                @ColumnResult(name = "price_can_buy", type = BigDecimal.class),
                @ColumnResult(name = "price_can_sell", type = BigDecimal.class),
                @ColumnResult(name = "is_bottom_area", type = Boolean.class),
                @ColumnResult(name = "is_top_area", type = Boolean.class),
                @ColumnResult(name = "profit", type = BigDecimal.class),
                @ColumnResult(name = "vector_up", type = Boolean.class),
                @ColumnResult(name = "vector_desc", type = String.class),
        })
})

public class BollArea {
    @Id
    @Column(name = "gecko_id")
    private String gecko_id;

    @Column(name = "symbol")
    private String symbol;

    @Column(name = "name")
    private String name;

    @Column(name = "avg_price")
    private BigDecimal avg_price;

    @Column(name = "price_open_candle")
    private BigDecimal price_open_candle;

    @Column(name = "price_close_candle")
    private BigDecimal price_close_candle;

    @Column(name = "low_price")
    private BigDecimal low_price;

    @Column(name = "price_can_buy")
    private BigDecimal price_can_buy;

    @Column(name = "price_can_sell")
    private BigDecimal price_can_sell;

    @Column(name = "is_bottom_area")
    private Boolean is_bottom_area;

    @Column(name = "is_top_area")
    private Boolean is_top_area;

    @Column(name = "profit")
    private BigDecimal profit;

    @Column(name = "vector_up")
    private Boolean vector_up;

    @Column(name = "vector_desc")
    private String vector_desc;

}
