package bsc_scan_token.entity;

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
public class TokenAddressDayKey implements Serializable {
    private static final long serialVersionUID = 2487553551545049610L;

    @Column(name = "blockchain")
    private String blockchain;

    @Column(name = "gecko_id")
    private String geckoid;

    @Column(name = "address")
    private String address;

    @Column(name = "dd")
    private String dd;

}
