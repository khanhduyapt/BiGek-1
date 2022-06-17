package bsc_scan_binance.entity;

import javax.persistence.Column;
import javax.persistence.EmbeddedId;
import javax.persistence.Entity;
import javax.persistence.Table;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Entity
@AllArgsConstructor
@NoArgsConstructor
@Table(name = "binance_pumping_history")

//CREATE TABLE IF NOT EXISTS public.binance_pumping_history
//(
//    gecko_id character varying(255) COLLATE pg_catalog."default" NOT NULL,
//    symbol character varying(225) COLLATE pg_catalog."default" NOT NULL,
//    hh character varying(2) COLLATE pg_catalog."default" NOT NULL,
//    total numeric(5,0),
//    CONSTRAINT binance_pumping_history_pkey PRIMARY KEY (gecko_id, symbol, hh)
//);

public class BinancePumpingHistory {
    @EmbeddedId
    private BinanceVolumnDayKey id;

    @Column(name = "total")
    private Long total;

}
