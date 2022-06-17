package bsc_scan_binance.entity;

import javax.persistence.Column;
import javax.persistence.ColumnResult;
import javax.persistence.ConstructorResult;
import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.SqlResultSetMapping;
import javax.persistence.Table;

import bsc_scan_binance.response.PriorityCoinHistoryResponse;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Entity
@AllArgsConstructor
@NoArgsConstructor
@Table(name = "priority_coin_history")

@SqlResultSetMapping(name = "PriorityCoinHistoryResponse", classes = {
        @ConstructorResult(targetClass = PriorityCoinHistoryResponse.class, columns = {
                @ColumnResult(name = "gecko_id", type = String.class),
                @ColumnResult(name = "symbol", type = String.class),
                @ColumnResult(name = "name", type = String.class),
                @ColumnResult(name = "count_notify", type = Integer.class),
        })
})

//CREATE TABLE IF NOT EXISTS public.priority_coin_history
//(
//    gecko_id character varying(255) COLLATE pg_catalog."default" NOT NULL,
//    symbol character varying(255) COLLATE pg_catalog."default",
//    name character varying(255) COLLATE pg_catalog."default",
//    count_notify numeric(3) DEFAULT 0,
//    CONSTRAINT priority_coin_history_pkey PRIMARY KEY (gecko_id)
//)
public class PriorityCoinHistory {
    @Id
    @Column(name = "gecko_id")
    private String geckoid;

    @Column(name = "symbol")
    private String symbol;

    @Column(name = "name")
    private String name;

    @Column(name = "count_notify")
    private Integer count_notify = 0;
}
