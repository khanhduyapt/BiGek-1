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
@Table(name = "take_profit")

//CREATE SEQUENCE public.take_profit_id_seq
//START WITH 1
//INCREMENT BY 1
//NO MINVALUE
//NO MAXVALUE
//CACHE 1;
//
//CREATE TABLE IF NOT EXISTS public.take_profit
//(
//profit_id bigint DEFAULT nextval('public.take_profit_id_seq'::regclass) NOT NULL,
//gecko_id character varying(255) COLLATE pg_catalog."default" NOT NULL,
//symbol character varying(255) COLLATE pg_catalog."default",
//name character varying(255) COLLATE pg_catalog."default",
//order_price numeric(10,5) DEFAULT 0,
//qty numeric(10,5) DEFAULT 0,
//amount numeric(30,5) DEFAULT 0,
//sale_price numeric(10,5) DEFAULT 0,
//profit numeric(30,5) DEFAULT 0,
//modify_dm time with time zone DEFAULT CURRENT_TIMESTAMP,
//CONSTRAINT take_profit_pkey PRIMARY KEY (profit_id)
//)

public class TakeProfit {

    @Id
    //@GeneratedValue(strategy = GenerationType.SEQUENCE, generator = "take_profit_id_seq")
    //@SequenceGenerator(name = "take_profit_id_seq", sequenceName = "take_profit_id_seq", allocationSize = 1)
    @Column(name = "profit_id")
    private Long profit_id;

    @Column(name = "gecko_id")
    private String geckoid;

    @Column(name = "symbol")
    private String chatId;

    @Column(name = "name")
    private String userName;

    @Column(name = "order_price")
    private BigDecimal order_price = BigDecimal.ZERO;

    @Column(name = "qty")
    private BigDecimal qty = BigDecimal.ZERO;

    @Column(name = "amount")
    private BigDecimal amount = BigDecimal.ZERO;

    @Column(name = "sale_price")
    private BigDecimal sale_price = BigDecimal.ZERO;

    @Column(name = "profit")
    private BigDecimal profit = BigDecimal.ZERO;

}
