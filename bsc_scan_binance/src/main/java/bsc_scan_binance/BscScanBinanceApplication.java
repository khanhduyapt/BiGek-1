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
import lombok.extern.slf4j.Slf4j;

@Slf4j
@SpringBootApplication
public class BscScanBinanceApplication {
    public static int app_flag = Utils.const_app_flag_msg_off; // 1: msg_on; 2: msg_off; 3: web only; 4: all coin
    public static String callFormBinance = "";

    public static void main(String[] args) {
        try {
            log.info("Start " + Utils.convertDateToString("yyyy-MM-dd HH:mm:ss", Calendar.getInstance().getTime())
                    + " ---->");

            if (!Objects.equals(null, args) && args.length > 0) {
                if (Utils.isNotBlank(args[0])) {
                    app_flag = Utils.getIntValue(args[0]);
                }
            }
            if (app_flag == 0) {
                app_flag = Utils.const_app_flag_msg_off;
            }

            // Debug
            //app_flag = Utils.const_app_flag_msg_on;

            log.info("app_flag:" + app_flag + " (1: msg_on; 2: msg_off; 3: web only; 4: all coin)");
            // --------------------Init--------------------
            ApplicationContext applicationContext = SpringApplication.run(BscScanBinanceApplication.class, args);
            CoinGeckoService gecko_service = applicationContext.getBean(CoinGeckoService.class);
            BinanceService binance_service = applicationContext.getBean(BinanceService.class);
            // binance_service.loadDataBtcVolumeDay("bitcoin", "BTC");

            if (app_flag == Utils.const_app_flag_msg_on) {
                WandaBot wandaBot = applicationContext.getBean(WandaBot.class);

                try {
                    TelegramBotsApi telegramBotsApi = new TelegramBotsApi(DefaultBotSession.class);
                    telegramBotsApi.registerBot(wandaBot);
                } catch (TelegramApiException e) {
                    e.printStackTrace();
                }
            }

            // --------------------Debug--------------------
            // binance_service.loadDataVolumeHour("unlend-finance", "UFT");
            // binance_service.loadData("unlend-finance", "UFT");
            // binance_service.getList(false);
            // binance_service.monitorBollingerBandwidth(false);
            // binance_service.monitorProfit();

            if (app_flag != Utils.const_app_flag_webonly) {
                List<CandidateCoin> list = gecko_service.getList(callFormBinance);
                CandidateCoin btc = new CandidateCoin();
                if (!CollectionUtils.isEmpty(list)) {
                    btc = list.stream().filter(item -> Objects.equals("BTC", item.getSymbol())).findFirst()
                            .orElse(new CandidateCoin());
                }

                int size = list.size();
                int idx = 0;
                while (idx < size) {
                    CandidateCoin coin = list.get(idx);

                    try {
                        if (idx == 0) {
                            List<Orders> orders = binance_service.getOrderList();
                            if (!CollectionUtils.isEmpty(orders)) {
                                for (Orders order : orders) {
                                    gecko_service.loadData(order.getId().getGeckoid());
                                    log.info("Binance -> Gecko " + " id:" + order.getId().getGeckoid());
                                }
                            }
                        }

                        if (idx % 30 == 0) {
                            binance_service.loadBinanceData(btc.getGeckoid(), btc.getSymbol());
                            binance_service.loadDataVolumeHour(btc.getGeckoid(), btc.getSymbol());
                            binance_service.monitorBtcPrice();
                        }

                        String loadBinanceData = binance_service.loadBinanceData(coin.getGeckoid(),
                                coin.getSymbol());
                        binance_service.loadDataVolumeHour(coin.getGeckoid(), coin.getSymbol());

                        log.info("Binance " + idx + "/" + size + "; id:" + coin.getGeckoid() + "; Symbol: "
                                + loadBinanceData);

                    } catch (Exception e) {
                        log.error("dkd error LoadData:" + e.getMessage());
                    }

                    if (BscScanBinanceApplication.app_flag != Utils.const_app_flag_msg_on) {
                        wait(1800);// 200ms=300 * 2 request/minus; 300ms=200 * 2 request/minus
                    } else {
                        wait(1800);
                    }

                    if (Objects.equals(idx, size - 1)) {

                        int minus = Utils
                                .getIntValue(Utils.convertDateToString("mm", Calendar.getInstance().getTime()));
                        if ((minus > 5) && (minus < 59)) {
                            binance_service.monitorProfit();
                            binance_service.monitorBollingerBandwidth(false);
                        }

                        binance_service.getList(false); // ~3p 1 lan

                        log.info("reload: "
                                + Utils.convertDateToString("yyyy-MM-dd HH:mm:ss", Calendar.getInstance().getTime()));
                        idx = 0;
                        list.clear();
                        list = gecko_service.getList(callFormBinance);
                        size = list.size();
                    } else {
                        idx += 1;
                    }
                }

                log.info("End BscScanBinanceApplication "
                        + Utils.convertDateToString("yyyy-MM-dd HH:mm:ss", Calendar.getInstance().getTime())
                        + " <----");
            }
        } catch (Exception e) {
            log.error(e.getMessage());
        }

    }

    public static void wait(int ms) {
        try {
            java.lang.Thread.sleep(ms);
        } catch (InterruptedException ex) {
            java.lang.Thread.currentThread().interrupt();
        }
    }

}
