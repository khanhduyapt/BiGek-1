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
@Table(name = "priority_coin")

//CREATE TABLE IF NOT EXISTS public.priority_coin
//(
//    gecko_id character varying(255) COLLATE pg_catalog."default" NOT NULL,
//    current_price numeric(10,5) DEFAULT 0,
//    target_price numeric(10,5) DEFAULT 0,
//    target_percent character varying(100) COLLATE pg_catalog."default",
//    is_candidate boolean DEFAULT false,
//    index numeric(3,0),
//    name character varying(255) COLLATE pg_catalog."default",
//    note character varying(200) COLLATE pg_catalog."default",
//    symbol character varying(255) COLLATE pg_catalog."default",
//    ema numeric(10,5) DEFAULT '-999'::integer,
//    CONSTRAINT priority_coin_pkey PRIMARY KEY (gecko_id)
//);

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

}
