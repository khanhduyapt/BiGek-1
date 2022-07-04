package bsc_scan_binance.entity;

import java.math.BigDecimal;

import javax.persistence.Column;
import javax.persistence.ColumnResult;
import javax.persistence.ConstructorResult;
import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.SqlResultSetMapping;
import javax.persistence.Table;

import bsc_scan_binance.response.PriorityCoinResponse;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Entity
@AllArgsConstructor
@NoArgsConstructor
@Table(name = "priority_coin")

//CREATE TABLE IF NOT EXISTS public.priority_coin
//(
//    gecko_id character varying(255) COLLATE pg_catalog."default" NOT NULL,
//    current_price numeric(10,5) DEFAULT 0,
//    target_price numeric(10,5) DEFAULT 0,
//    target_percent numeric(10,0),
//    vmc numeric(10,0),
//    is_candidate boolean DEFAULT false,
//    index numeric(3,0),
//    name character varying(255) COLLATE pg_catalog."default",
//    note character varying(200) COLLATE pg_catalog."default",
//    symbol character varying(255) COLLATE pg_catalog."default",
//    ema numeric(10,5) DEFAULT '-999'::integer,
//    low_price numeric(10,5) DEFAULT 0,
//    height_price numeric(10,5) DEFAULT 0,
//    discovery_date_time character varying(50) COLLATE pg_catalog."default" DEFAULT ''::character varying,
//    mute boolean DEFAULT false,
//    predict boolean DEFAULT false,
//    inspect_mode boolean DEFAULT false,
//    good_price boolean DEFAULT false,
//    CONSTRAINT priority_coin_pkey PRIMARY KEY (gecko_id)
//)

@SqlResultSetMapping(name = "PriorityCoinResponse", classes = {
        @ConstructorResult(targetClass = PriorityCoinResponse.class, columns = {
                @ColumnResult(name = "gecko_id", type = String.class),
                @ColumnResult(name = "current_price", type = BigDecimal.class),
                @ColumnResult(name = "target_price", type = BigDecimal.class),
                @ColumnResult(name = "target_percent", type = BigDecimal.class),
                @ColumnResult(name = "vmc", type = BigDecimal.class),
                @ColumnResult(name = "is_candidate", type = Boolean.class),
                @ColumnResult(name = "index", type = BigDecimal.class),
                @ColumnResult(name = "name", type = String.class),
                @ColumnResult(name = "note", type = String.class),
                @ColumnResult(name = "symbol", type = String.class),
                @ColumnResult(name = "ema", type = BigDecimal.class),
                @ColumnResult(name = "low_price", type = BigDecimal.class),
                @ColumnResult(name = "height_price", type = BigDecimal.class),
                @ColumnResult(name = "discovery_date_time", type = String.class),
                @ColumnResult(name = "mute", type = Boolean.class),
                @ColumnResult(name = "predict", type = Boolean.class),
                @ColumnResult(name = "inspect_mode", type = Boolean.class),
                @ColumnResult(name = "good_price", type = Boolean.class),
        })
})

public class PriorityCoin {
    @Id
    @Column(name = "gecko_id")
    private String geckoid;

    @Column(name = "current_price")
    private BigDecimal current_price = BigDecimal.ZERO;

    @Column(name = "target_price")
    private BigDecimal target_price = BigDecimal.ZERO;

    @Column(name = "target_percent")
    private Integer target_percent = 0;

    @Column(name = "vmc")
    private Integer vmc;

    @Column(name = "low_price")
    private BigDecimal low_price = BigDecimal.ZERO;

    @Column(name = "height_price")
    private BigDecimal height_price = BigDecimal.ZERO;

    @Column(name = "is_candidate")
    private Boolean candidate;

    @Column(name = "index")
    private Integer index = 0;

    @Column(name = "name")
    private String name;

    @Column(name = "note")
    private String note;

    @Column(name = "symbol")
    private String symbol;

    @Column(name = "ema")
    private BigDecimal ema = BigDecimal.ZERO;

    @Column(name = "discovery_date_time")
    private String discovery_date_time;

    @Column(name = "mute")
    private Boolean mute = false;

    @Column(name = "predict")
    private Boolean predict = false;

    @Column(name = "inspect_mode")
    private Boolean inspectMode = false;

    @Column(name = "good_price")
    private Boolean goodPrice = false;

    @Column(name = "min_price_14d")
    private BigDecimal min_price_14d = BigDecimal.ZERO;

    @Column(name = "max_price_14d")
    private BigDecimal max_price_14d = BigDecimal.ZERO;
}
