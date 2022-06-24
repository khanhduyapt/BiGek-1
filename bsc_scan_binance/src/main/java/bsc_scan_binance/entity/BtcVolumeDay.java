package bsc_scan_binance.entity;

import java.math.BigDecimal;

import javax.persistence.Column;
import javax.persistence.ColumnResult;
import javax.persistence.ConstructorResult;
import javax.persistence.EmbeddedId;
import javax.persistence.Entity;
import javax.persistence.SqlResultSetMapping;
import javax.persistence.Table;

import bsc_scan_binance.response.BollAreaResponse;
import bsc_scan_binance.response.BtcVolumeDayResponse;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Entity
@AllArgsConstructor
@NoArgsConstructor
@Table(name = "btc_volumn_day")

//CREATE TABLE IF NOT EXISTS public.btc_volumn_day
//(
//    gecko_id character varying(255) COLLATE pg_catalog."default" NOT NULL,
//    symbol character varying(225) COLLATE pg_catalog."default" NOT NULL,
//    hh character varying(2) COLLATE pg_catalog."default" NOT NULL,
//    avg_price numeric(30,5),
//    low_price numeric(30,5),
//    hight_price numeric(30,5),
//    ema numeric(10,5) DEFAULT 0,
//    CONSTRAINT btc_volumn_day_pkey PRIMARY KEY (gecko_id, symbol, hh)
//)

@SqlResultSetMapping(name = "BtcVolumeDayByBollingerResponse", classes = {
        @ConstructorResult(targetClass = BollAreaResponse.class, columns = {
                @ColumnResult(name = "gecko_id", type = String.class),
                @ColumnResult(name = "symbol", type = String.class),
                @ColumnResult(name = "name", type = String.class),

                @ColumnResult(name = "avg_price", type = BigDecimal.class),
                @ColumnResult(name = "price_can_buy", type = BigDecimal.class),
                @ColumnResult(name = "price_can_sell", type = BigDecimal.class),

                @ColumnResult(name = "is_bottom_area", type = Boolean.class),
                @ColumnResult(name = "is_top_area", type = Boolean.class),
                @ColumnResult(name = "profit", type = BigDecimal.class),

                @ColumnResult(name = "vector_up", type = Boolean.class),
                @ColumnResult(name = "vector_desc", type = String.class),
        })
})

@SqlResultSetMapping(name = "BtcVolumeDayResponse", classes = {
        @ConstructorResult(targetClass = BtcVolumeDayResponse.class, columns = {
                @ColumnResult(name = "vector_now", type = BigDecimal.class),
                @ColumnResult(name = "vector_pre4h", type = BigDecimal.class),
                @ColumnResult(name = "vector_pre8h", type = BigDecimal.class),
                @ColumnResult(name = "price_now", type = BigDecimal.class),
                @ColumnResult(name = "price_pre4h", type = BigDecimal.class),
                @ColumnResult(name = "price_pre8h", type = BigDecimal.class),
                @ColumnResult(name = "price_pre12h", type = BigDecimal.class),
        })
})

public class BtcVolumeDay {
    @EmbeddedId
    private BinanceVolumnDayKey id;

    @Column(name = "avg_price")
    private BigDecimal avg_price;

    @Column(name = "low_price")
    private BigDecimal low_price;

    @Column(name = "hight_price")
    private BigDecimal hight_price;

    @Column(name = "ema")
    private BigDecimal ema = BigDecimal.ZERO;

    @Column(name = "price_open_candle")
    private BigDecimal price_open_candle = BigDecimal.ZERO;

    @Column(name = "price_close_candle")
    private BigDecimal price_close_candle = BigDecimal.ZERO;
}
