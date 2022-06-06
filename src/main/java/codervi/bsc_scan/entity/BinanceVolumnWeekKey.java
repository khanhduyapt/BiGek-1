package codervi.bsc_scan.entity;

import java.io.Serializable;

import javax.persistence.Column;
import javax.persistence.Embeddable;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@NoArgsConstructor
@AllArgsConstructor
@Data
@Embeddable
public class BinanceVolumnWeekKey implements Serializable {
    private static final long serialVersionUID = 2487553551545049610L;

    @Column(name = "gecko_id")
    private String geckoid;

    @Column(name = "symbol")
    private String symbol;

    @Column(name = "yyyymmdd")
    private String yyyyMMdd;

}
