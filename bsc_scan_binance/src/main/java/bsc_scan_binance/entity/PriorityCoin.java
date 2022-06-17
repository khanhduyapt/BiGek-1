package bsc_scan_binance.entity;

import java.math.BigDecimal;

import javax.persistence.Column;
import javax.persistence.ColumnResult;
import javax.persistence.ConstructorResult;
import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.SqlResultSetMapping;
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
//    oco_hight character varying(200) COLLATE pg_catalog."default",
//    is_candidate boolean DEFAULT false,
//    index numeric(3,0),
//    name character varying(255) COLLATE pg_catalog."default",
//    note character varying(200) COLLATE pg_catalog."default",
//    symbol character varying(255) COLLATE pg_catalog."default",
//    ema numeric(10,5) DEFAULT '-999'::integer,
//    CONSTRAINT priority_coin_pkey PRIMARY KEY (gecko_id)
//);

@SqlResultSetMapping(name = "PriorityCoin", classes = {
        @ConstructorResult(targetClass = PriorityCoin.class, columns = {
                @ColumnResult(name = "geckoid", type = String.class),
                @ColumnResult(name = "current_price", type = BigDecimal.class),
                @ColumnResult(name = "target_price", type = BigDecimal.class),
                @ColumnResult(name = "target_percent", type = Integer.class),
                @ColumnResult(name = "vmc", type = Integer.class),
                @ColumnResult(name = "oco_hight", type = String.class),
                @ColumnResult(name = "candidate", type = Boolean.class),
                @ColumnResult(name = "index", type = Integer.class),
                @ColumnResult(name = "name", type = String.class),
                @ColumnResult(name = "note", type = String.class),
                @ColumnResult(name = "symbol", type = String.class),
                @ColumnResult(name = "ema", type = BigDecimal.class),
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

    @Column(name = "oco_hight")
    private String oco_hight;

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
}
