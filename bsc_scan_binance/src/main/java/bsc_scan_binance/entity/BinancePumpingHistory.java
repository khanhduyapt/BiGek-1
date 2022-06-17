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
public class BinancePumpingHistory {
    @EmbeddedId
    private BinanceVolumnDayKey id;

    @Column(name = "total")
    private Long total;

}
