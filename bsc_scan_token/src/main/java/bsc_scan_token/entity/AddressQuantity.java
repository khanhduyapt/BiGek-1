package bsc_scan_token.entity;

import java.math.BigDecimal;

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
@Table(name = "all_market_address_quantity")

public class AddressQuantity {
    @EmbeddedId
    private AddressQuantityKey id;

    @Column(name = "quantity")
    private BigDecimal quantity;

    @Column(name = "wallet_name")
    private String walletName;
}
