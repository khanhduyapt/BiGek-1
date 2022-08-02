package bsc_scan_binance.entity;

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
public class OrderKey implements Serializable {
    private static final long serialVersionUID = 2487553551545049610L;

    @Column(name = "gecko_id")
    private String geckoid;

    @Column(name = "symbol")
    private String chatId;

    @Column(name = "name")
    private String userName;
}
