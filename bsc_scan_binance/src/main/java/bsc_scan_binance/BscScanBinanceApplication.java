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
    public static int SLEEP_MINISECONDS_INIT = 3000;
    public static int SLEEP_MINISECONDS = 6000;
    private static Hashtable<String, String> keys_dict = new Hashtable<String, String>();

    private static int pre_blog15minute = -1;
    private static int cur_blog15minute = -1;

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
            boolean done_1_round = false;
            int index_forex = 0;
            int index_crypto = 0;

            List<String> capital_list = new ArrayList<String>();
            capital_list.addAll(Utils.EPICS_INDEXS);
            capital_list.addAll(Utils.EPICS_FOREX_EUR);
            capital_list.addAll(Utils.EPICS_FOREX_AUD);
            capital_list.addAll(Utils.EPICS_FOREX_GBP);
            capital_list.addAll(Utils.EPICS_FOREX_CAD);
            capital_list.addAll(Utils.EPICS_FOREX_DOLLAR);
            capital_list.addAll(Utils.EPICS_FOREX_OTHERS);

            if (app_flag != Utils.const_app_flag_webonly) {
                List<CandidateCoin> crypto_list = gecko_service.getList(callFormBinance);

                int crypto_size = crypto_list.size();

                for (index_crypto = 0; index_crypto < crypto_size; index_crypto++) {
                    try {
                        check_Blog15(binance_service);

                        if (index_forex < capital_list.size()) {
                            String EPIC = capital_list.get(index_forex);

                            if (!done_1_round) {
                                binance_service.init_DXY_index(EPIC);
                            }
                            binance_service.checkCapital(EPIC);

                            String msg = Utils.getTimeHHmm() + EPIC;
                            msg += "(" + (index_forex + 1) + "/" + capital_list.size() + ")";
                            System.out.println(msg);

                            index_forex += 1;
                        } else {
                            index_forex = 0;
                            done_1_round = true;
                        }

                        CandidateCoin coin = crypto_list.get(index_crypto);
                        gecko_service.loadData(coin.getGeckoid());
                        binance_service.init_DXY_Crypto(coin.getGeckoid(), coin.getSymbol());
                        check_Crypto_WD(binance_service, coin, index_crypto, crypto_size);

                        wait(SLEEP_MINISECONDS_INIT);
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                }

                //----------------------------------------------
                //----------------------------------------------
                //----------------------------------------------

                index_forex = 0;
                Date start_time = Calendar.getInstance().getTime();
                while (index_crypto < crypto_size) {
                    CandidateCoin coin = crypto_list.get(index_crypto);

                    try {
                        check_Blog15(binance_service);
                        // ----------------------------------------------------------

                        if (index_forex < capital_list.size()) {
                            String EPIC = capital_list.get(index_forex);
                            binance_service.checkCapital(EPIC);

                            index_forex += 1;
                        } else {
                            index_forex = 0;
                        }

                        check_Crypto_WD(binance_service, coin, index_crypto, crypto_size);

                        wait(SLEEP_MINISECONDS);

                    } catch (Exception e) {
                        e.printStackTrace();
                    }

                    if (Objects.equals(index_crypto, crypto_size - 1)) {
                        Date curr_time = Calendar.getInstance().getTime();
                        long diff = curr_time.getTime() - start_time.getTime();
                        start_time = Calendar.getInstance().getTime();

                        System.out.println("reload: " + Utils.getMmDD_TimeHHmm() + ", spend:"
                                + TimeUnit.MILLISECONDS.toMinutes(diff) + " Minutes.");
                        index_crypto = 0;
                    } else {
                        index_crypto += 1;
                    }

                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private static void check_Blog15(BinanceService binance_service) {
        cur_blog15minute = Utils.getCurrentMinute_Blog15minutes();
        if (pre_blog15minute != cur_blog15minute) {
            pre_blog15minute = cur_blog15minute;

            System.out.println(Utils.getTimeHHmm() + "Check BTC(15m)");
            binance_service.getChartWD("bitcoin", "BTC");
            wait(SLEEP_MINISECONDS);

            System.out.println(Utils.getTimeHHmm() + "Check ETH(15m)");
            binance_service.getChartWD("ethereum", "ETH");
            wait(SLEEP_MINISECONDS);

            System.out.println(Utils.getTimeHHmm() + "Check BNB(15m)");
            binance_service.getChartWD("binancecoin", "BNB");
            wait(SLEEP_MINISECONDS);
        }
    }

    private static void check_Crypto_WD(BinanceService binance_service, CandidateCoin coin, int idx, int size) {
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
            String msg = Utils.getTimeHHmm() + coin.getSymbol();
            msg += "(" + (idx + 1) + "/" + size + ")";

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
