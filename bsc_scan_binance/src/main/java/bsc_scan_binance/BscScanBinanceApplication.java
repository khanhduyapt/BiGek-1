package bsc_scan_binance;

import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.Hashtable;
import java.util.List;
import java.util.Objects;
import java.util.concurrent.TimeUnit;

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
    public static String TAKER_TOKENS = "_";
    public static int SLEEP_MINISECONDS = 6000;
    private static Hashtable<String, String> keys_dict = new Hashtable<String, String>();

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
            app_flag = Utils.const_app_flag_all_and_msg;
            // app_flag = Utils.const_app_flag_all_coin;

            System.out.println("app_flag:" + app_flag + " (1: msg_on; 2: msg_off; 3: web only; 4: all coin)");
            // --------------------Init--------------------
            ApplicationContext applicationContext = SpringApplication.run(BscScanBinanceApplication.class, args);
            CoinGeckoService gecko_service = applicationContext.getBean(CoinGeckoService.class);
            BinanceService binance_service = applicationContext.getBean(BinanceService.class);

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
            int pre_blog15minute = -1;
            int cur_blog15minute = -1;

            String curChangeDailyChart = "";
            String preChangeDailyChart = "";

            List<String> INDEXS = new ArrayList<String>();
            INDEXS.addAll(Utils.EPICS_INDEXS);
            INDEXS.addAll(Utils.EPICS_FOREX_EUR);
            INDEXS.addAll(Utils.EPICS_FOREX_AUD);
            INDEXS.addAll(Utils.EPICS_FOREX_GBP);
            INDEXS.addAll(Utils.EPICS_FOREX_CAD);
            INDEXS.addAll(Utils.EPICS_FOREX_DOLLAR);

            if (app_flag != Utils.const_app_flag_webonly) {
                List<CandidateCoin> list = gecko_service.getList(callFormBinance);

                int idx = 0;
                int size = list.size();
                Date start_time = Calendar.getInstance().getTime();
                while (idx < size) {
                    CandidateCoin coin = list.get(idx);

                    try {
                        curChangeDailyChart = Utils.getYyyyMmDdHH_ChangeDailyChart();
                        if (!Objects.equals(curChangeDailyChart, preChangeDailyChart)) {
                            preChangeDailyChart = curChangeDailyChart;

                            System.out.println(Utils.getTimeHHmm() + "init BTC");
                            binance_service.init_DXY_Crypto("BTC");
                            wait(SLEEP_MINISECONDS);

                            System.out.println(Utils.getTimeHHmm() + "init ETH");
                            binance_service.init_DXY_Crypto("ETH");
                            wait(SLEEP_MINISECONDS);

                            System.out.println(Utils.getTimeHHmm() + "init BNB");
                            binance_service.init_DXY_Crypto("BNB");
                            wait(SLEEP_MINISECONDS);

                            System.out.println(Utils.getTimeHHmm() + "init " + coin.getSymbol());
                            binance_service.init_DXY_Crypto(coin.getSymbol());

                            //----------------------------------------------

                            for (String EPIC : INDEXS) {
                                System.out.println(Utils.getTimeHHmm() + "init " + EPIC);
                                binance_service.init_DXY_index(EPIC);
                                wait(SLEEP_MINISECONDS);
                            }

                            //----------------------------------------------

                            try {
                                gecko_service.loadData(coin.getGeckoid());
                            } catch (Exception e) {
                                System.out.println("gecko_service.LoadData:[" + coin.getGeckoid() + "]");
                                e.printStackTrace();
                            }
                        }

                        cur_blog15minute = Utils.getCurrentMinute_Blog15minutes();
                        if (pre_blog15minute != cur_blog15minute) {
                            pre_blog15minute = cur_blog15minute;

                            System.out.println(Utils.getTimeHHmm() + "BTC bitcoin");

                            binance_service.getChartWD("bitcoin", "BTC");
                            wait(SLEEP_MINISECONDS);

                            System.out.println(Utils.getTimeHHmm() + "ETH ethereum");
                            binance_service.getChartWD("ethereum", "ETH");
                            wait(SLEEP_MINISECONDS);

                            System.out.println(Utils.getTimeHHmm() + "BNB binancecoin");
                            binance_service.getChartWD("binancecoin", "BNB");
                            wait(SLEEP_MINISECONDS);

                        }

                        // ----------------------------------------------------------

                        if (idx < INDEXS.size()) {
                            String EPIC = INDEXS.get(idx);
                            binance_service.checkCapital(EPIC);
                        }

                        load(binance_service, coin, idx, size);

                    } catch (Exception e) {
                        e.printStackTrace();
                    }

                    if (Objects.equals(idx, size - 1)) {
                        Date curr_time = Calendar.getInstance().getTime();
                        long diff = curr_time.getTime() - start_time.getTime();
                        start_time = Calendar.getInstance().getTime();

                        System.out.println("reload: " + Utils.getMmDD_TimeHHmm() + ", spend:"
                                + TimeUnit.MILLISECONDS.toMinutes(diff) + " Minutes.");
                        idx = 0;
                    } else {
                        idx += 1;
                    }

                    wait(SLEEP_MINISECONDS);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private static void load(BinanceService binance_service, CandidateCoin coin, int idx, int size) {
        String key = Utils.getStringValue(coin.getGeckoid()) + "_";
        key += Utils.getStringValue(coin.getSymbol()) + "_";
        key += Utils.getCurrentYyyyMmDd_HH();
        boolean reload = false;
        if (keys_dict.containsKey(key)) {
            if (!Objects.equals(key, keys_dict.get(key))) {
                keys_dict.put(key, key);

                reload = true;
            }
        } else {
            keys_dict.put(key, key);
            reload = true;
        }
        if (reload) {
            String msg = "(" + (idx + 1) + "/" + size + ")" + Utils.getTimeHHmm();
            msg += coin.getSymbol() + " " + coin.getGeckoid();
            System.out.println(msg);

            binance_service.getChartWD(coin.getGeckoid(), coin.getSymbol());
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
