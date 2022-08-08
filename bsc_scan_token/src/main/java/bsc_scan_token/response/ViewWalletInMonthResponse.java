package bsc_scan_token.response;

import java.math.BigDecimal;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class ViewWalletInMonthResponse {
    private String gecko_id;
    private String blockchain;
    private String address;
    private String yyyymmdd;
    private BigDecimal quantity_old;
    private BigDecimal quantity_new;
    private BigDecimal total_value;
    private String wallet_name;
    private BigDecimal percent_up;
    private String ape_link;
}
