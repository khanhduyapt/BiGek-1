package codervi.bsc_scan.response;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class CandidateTokenCssResponse {
    private String gecko_id;
    private String symbol;
    private String name;

    private String volumn_div_marketcap;
    private String volumn_div_marketcap_css = "";
    private String volumn_binance_div_marketcap;
    private String volumn_binance_div_marketcap_css;

    private String pre_4h_total_volume_up;
    private String pre_4h_total_volume_up_css;
    private String pre_vol_history;

    private String market_cap;
    private String current_price;
    private String pre_price_history;
    private String gecko_total_volume;
    private String gecko_volumn_history;

    private String price_change_percentage_24h;
    private String price_change_percentage_7d;
    private String price_change_percentage_14d;
    private String price_change_percentage_30d;

    private String price_change_24h_css = "";
    private String price_change_07d_css = "";
    private String price_change_14d_css = "";
    private String price_change_30d_css = "";

    private String category;
    private String trend;
    private String total_supply;
    private String max_supply;
    private String circulating_supply;
    private String binance_trade;
    private String coin_gecko_link;
    private String backer;

    private String star = "";
    private String star_css = "";

    private String today;
    private String day_0;
    private String day_1;
    private String day_2;
    private String day_3;
    private String day_4;
    private String day_5;
    private String day_6;
    private String day_7;
    private String day_8;
    private String day_9;
    private String day_10;
    private String day_11;
    private String day_12;

    private String today_vol;
    private String day_0_vol;
    private String day_1_vol;
    private String day_2_vol;
    private String day_3_vol;
    private String day_4_vol;
    private String day_5_vol;
    private String day_6_vol;
    private String day_7_vol;
    private String day_8_vol;
    private String day_9_vol;
    private String day_10_vol;
    private String day_11_vol;
    private String day_12_vol;

    private String today_price;
    private String day_0_price;
    private String day_1_price;
    private String day_2_price;
    private String day_3_price;
    private String day_4_price;
    private String day_5_price;
    private String day_6_price;
    private String day_7_price;
    private String day_8_price;
    private String day_9_price;
    private String day_10_price;
    private String day_11_price;
    private String day_12_price;

    private String today_vol_css = "";
    private String day_0_vol_css = "";
    private String day_1_vol_css = "";
    private String day_2_vol_css = "";
    private String day_3_vol_css = "";
    private String day_4_vol_css = "";
    private String day_5_vol_css = "";
    private String day_6_vol_css = "";
    private String day_7_vol_css = "";
    private String day_8_vol_css = "";
    private String day_9_vol_css = "";
    private String day_10_vol_css = "";
    private String day_11_vol_css = "";
    private String day_12_vol_css = "";

    private String today_price_css = "";
    private String day_0_price_css = "";
    private String day_1_price_css = "";
    private String day_2_price_css = "";
    private String day_3_price_css = "";
    private String day_4_price_css = "";
    private String day_5_price_css = "";
    private String day_6_price_css = "";
    private String day_7_price_css = "";
    private String day_8_price_css = "";
    private String day_9_price_css = "";
    private String day_10_price_css = "";
    private String day_11_price_css = "";
    private String day_12_price_css = "";

}
