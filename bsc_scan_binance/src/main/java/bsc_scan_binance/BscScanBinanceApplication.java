package bsc_scan_binance;

import java.util.Calendar;
import java.util.List;
import java.util.Objects;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.ApplicationContext;
import org.springframework.util.CollectionUtils;
import org.telegram.telegrambots.meta.TelegramBotsApi;
import org.telegram.telegrambots.meta.exceptions.TelegramApiException;
import org.telegram.telegrambots.updatesreceivers.DefaultBotSession;

import bsc_scan_binance.entity.CandidateCoin;
import bsc_scan_binance.entity.Orders;
import bsc_scan_binance.service.BinanceService;
import bsc_scan_binance.service.CoinGeckoService;
import bsc_scan_binance.service.impl.WandaBot;
import bsc_scan_binance.utils.Utils;

@SpringBootApplication
public class BscScanBinanceApplication {
    public static int app_flag = Utils.const_app_flag_all_coin; // 1: msg_on; 2: msg_off; 3: web only; 4: all coin; 5:
                                                                // all_and_msg
    public static String callFormBinance = "";

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
            app_flag = Utils.const_app_flag_all_and_msg;

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
                } catch (TelegramApiException e) {
                    e.printStackTrace();
                }
            }

            // --------------------Debug--------------------

            if (app_flag != Utils.const_app_flag_webonly) {
                List<CandidateCoin> list = gecko_service.getList(callFormBinance);

                int size = list.size();
                int idx = 0;
                boolean startup = true;
                while (idx < size) {
                    CandidateCoin coin = list.get(idx);

                    try {
                        if (idx == 0) {
                            List<Orders> orders = binance_service.getOrderList();
                            if (!CollectionUtils.isEmpty(orders)) {
                                for (Orders order : orders) {
                                    gecko_service.loadData(order.getId().getGeckoid());
                                    System.out.println("Binance -> Gecko " + " id:" + order.getId().getGeckoid());
                                }
                            }
                        }

                        if (idx % 10 == 0) {
                            binance_service.loadBinanceData("bitcoin", "BTC", startup);
                            binance_service.loadDataVolumeHour("bitcoin", "BTC");
                            binance_service.monitorBtcPrice();
                            wait(6000); // 6000ms=1minute
                        }

                        binance_service.loadBinanceData(coin.getGeckoid(), coin.getSymbol().toUpperCase(), startup);
                        binance_service.loadDataVolumeHour(coin.getGeckoid(), coin.getSymbol().toUpperCase());

                        System.out.println("Binance " + idx + "/" + size + "; id:" + coin.getGeckoid() + "; Symbol: "
                                + coin.getSymbol());

                    } catch (Exception e) {
                        System.out.println("dkd error LoadData:" + e.getMessage());
                    }

                    // wait(1800);// 200ms=300 * 2 request/minus; 300ms=200 * 2 request/minus
                    wait(6000);

                    if (Objects.equals(idx, size - 1)) {

                        int minus = Utils
                                .getIntValue(Utils.convertDateToString("mm", Calendar.getInstance().getTime()));
                        if ((minus > 5) && (minus < 59)) {
                            binance_service.monitorProfit();
                            binance_service.monitorBollingerBandwidth(false);
                        }

                        binance_service.getList(false); // ~3p 1 lan

                        System.out.println("reload: "
                                + Utils.convertDateToString("yyyy-MM-dd HH:mm:ss", Calendar.getInstance().getTime()));
                        idx = 0;
                        list.clear();
                        list = gecko_service.getList(callFormBinance);
                        size = list.size();

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

    public static void wait(int ms) {
        try {
            // 360000ms=6minute
            java.lang.Thread.sleep(ms);
        } catch (InterruptedException ex) {
            java.lang.Thread.currentThread().interrupt();
        }
    }

}
