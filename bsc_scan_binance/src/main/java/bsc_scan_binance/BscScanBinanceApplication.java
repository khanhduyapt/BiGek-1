package bsc_scan_binance;

import java.util.Calendar;
import java.util.List;
import java.util.Objects;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.ApplicationContext;
import org.telegram.telegrambots.meta.TelegramBotsApi;
import org.telegram.telegrambots.meta.exceptions.TelegramApiException;
import org.telegram.telegrambots.updatesreceivers.DefaultBotSession;

import bsc_scan_binance.entity.CandidateCoin;
import bsc_scan_binance.service.BinanceService;
import bsc_scan_binance.service.CoinGeckoService;
import bsc_scan_binance.service.impl.WandaBot;
import bsc_scan_binance.utils.Utils;

@SpringBootApplication
public class BscScanBinanceApplication {
    public static int app_flag = Utils.const_app_flag_all_coin; // 1: msg_on; 2: msg_off; 3: web only; 4: all coin; 5:
                                                                // all_and_msg
    public static String callFormBinance = "";
    public static int SLEEP_MINISECONDS = 6000;

    public static void main(String[] args) {
        try {
            System.out.println("Start "
                    + Utils.convertDateToString("yyyy-MM-dd HH:mm:ss", Calendar.getInstance().getTime()) + " ---->");

            if (!Objects.equals(null, args) && args.length > 0) {
                if (Utils.isNotBlank(args[0])) {
                    app_flag = Utils.getIntValue(args[0]);
                }
            }
            if (app_flag == 0) {
                app_flag = Utils.const_app_flag_all_coin;
            }

            // Debug
            // app_flag = Utils.const_app_flag_msg_on;

            System.out.println("app_flag:" + app_flag + " (1: msg_on; 2: msg_off; 3: web only; 4: all coin)");
            // --------------------Init--------------------
            ApplicationContext applicationContext = SpringApplication.run(BscScanBinanceApplication.class, args);
            CoinGeckoService gecko_service = applicationContext.getBean(CoinGeckoService.class);
            BinanceService binance_service = applicationContext.getBean(BinanceService.class);
            // binance_service.loadDataBtcVolumeDay("bitcoin", "BTC");

            if (app_flag == Utils.const_app_flag_msg_on || app_flag == Utils.const_app_flag_all_and_msg) {
                WandaBot wandaBot = applicationContext.getBean(WandaBot.class);

                try {
                    TelegramBotsApi telegramBotsApi = new TelegramBotsApi(DefaultBotSession.class);
                    telegramBotsApi.registerBot(wandaBot);
                    binance_service.clearTrash();
                } catch (TelegramApiException e) {
                    e.printStackTrace();
                }
            }

            // --------------------Debug--------------------

            if (app_flag != Utils.const_app_flag_webonly) {
                List<CandidateCoin> list = gecko_service.getList(callFormBinance);

                String msg;
                int size = list.size();
                int idx = 0;
                boolean startup = true;
                int pre_minute = 0;
                int cur_minute = 0;

                int pre_blog10minute = 0;
                int cur_blog10minute = 0;

                while (idx < size) {
                    CandidateCoin coin = list.get(idx);

                    try {
                        cur_minute = Utils.getCurrentMinute();
                        cur_blog10minute = Utils.getCurrentMinute_Blog10minutes();

                        if (cur_minute != pre_minute) {
                            pre_minute = cur_minute;
                            binance_service.getChartWD("bitcoin", "BTC");
                            wait(SLEEP_MINISECONDS);
                            System.out.println(Utils.getTimeHHmm() + "BTC bitcoin");
                        }

                        if (pre_blog10minute != cur_blog10minute) {
                            pre_blog10minute = cur_blog10minute;

                            binance_service.getChartWD("ethereum", "ETH");
                            wait(SLEEP_MINISECONDS);
                            System.out.println(Utils.getTimeHHmm() + "ETH ethereum");

                            binance_service.getChartWD("binancecoin", "BNB");
                            wait(SLEEP_MINISECONDS);
                            System.out.println(Utils.getTimeHHmm() + "BNB binancecoin");
                        }

                        if (!Utils.attack_mode) {
                            binance_service.loadBinanceData(coin.getGeckoid(), coin.getSymbol().toUpperCase(), startup);
                            binance_service.loadDataVolumeHour(coin.getGeckoid(), coin.getSymbol().toUpperCase());
                            msg = "Binance " + idx + "/" + size + "; id:" + coin.getGeckoid() + "; Symbol: "
                                    + coin.getSymbol();
                            System.out.println(msg);
                        }

                        wait(SLEEP_MINISECONDS);
                    } catch (Exception e) {
                        System.out.println("dkd error LoadData:" + e.getMessage());
                    }

                    if (Objects.equals(idx, size - 1)) {
                        System.out.println("reload: " + Utils.getCurrentYyyyMmDdHH());
                        idx = 0;
                        startup = false;
                    } else {
                        idx += 1;
                    }
                }

                System.out.println("End BscScanBinanceApplication "
                        + Utils.convertDateToString("yyyy-MM-dd HH:mm:ss", Calendar.getInstance().getTime())
                        + " <----");
            }
        } catch (Exception e) {
            System.out.println(e.getMessage());
        }

    }

    public static void wait(int sleep_ms) {
        try {
            java.lang.Thread.sleep(sleep_ms);
        } catch (InterruptedException ex) {
            java.lang.Thread.currentThread().interrupt();
        }
    }

}
