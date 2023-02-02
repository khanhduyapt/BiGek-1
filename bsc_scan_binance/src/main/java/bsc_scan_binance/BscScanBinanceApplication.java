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
    public static Hashtable<String, String> forex_naming_dict = new Hashtable<String, String>();

    private static int pre_blog15minute = -1;
    private static int cur_blog15minute = -1;

    public static void main(String[] args) {
        try {
            initForex_naming_dict();

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

    private static void initForex_naming_dict() {
        forex_naming_dict.put("AUDCAD", "Australian Dollar / Canadian Dollar");
        forex_naming_dict.put("AUDCHF", "Australian Dollar / Swiss Franc");
        forex_naming_dict.put("AUDCNH", "Australian Dollar / Chinese Yuan");
        forex_naming_dict.put("AUDHKD", "Australian Dollar / Hong Kong Dollar");
        forex_naming_dict.put("AUDJPY", "Australian Dollar / Japanese Yen");
        forex_naming_dict.put("AUDMXN", "Australian Dollar / Mexican Peso");
        forex_naming_dict.put("AUDNZD", "Australian Dollar / New Zealand Dollar");
        forex_naming_dict.put("AUDPLN", "Australian Dollar / Polish Zloty");
        forex_naming_dict.put("AUDSGD", "Australian Dollar / Singapore Dollar");
        forex_naming_dict.put("AUDUSD", "Australian Dollar / US Dollar");
        forex_naming_dict.put("AUDZAR", "Australian Dollar / Rand");
        forex_naming_dict.put("CADCHF", "Canadian dollar / Swiss Franc");
        forex_naming_dict.put("CADCNH", "Canadian Dollar / Chinese yuan");
        forex_naming_dict.put("CADHKD", "Canadian Dollar / Hong Kong Dollar");
        forex_naming_dict.put("CADJPY", "Canadian dollar / Japanese Yen");
        forex_naming_dict.put("CADMXN", "Canadian Dollar / Mexican Peso");
        forex_naming_dict.put("CADNOK", "Canadian dollar / Norwegian Krone");
        forex_naming_dict.put("CADPLN", "Canadian dollar / Polish Zloty");
        forex_naming_dict.put("CADSGD", "Canadian Dollar / Singapore Dollar");
        forex_naming_dict.put("CADTRY", "Canadian Dollar / Turkish Lira");
        forex_naming_dict.put("CADZAR", "Canadian Dollar / Rand");
        forex_naming_dict.put("CHFCNH", "Swiss Franc / Chinese yuan");
        forex_naming_dict.put("CHFCZK", "Swiss Franc / Czech Koruna");
        forex_naming_dict.put("CHFDKK", "Swiss Franc / Danish Krone");
        forex_naming_dict.put("CHFHKD", "Swiss Franc / Hong Kong Dollar");
        forex_naming_dict.put("CHFJPY", "Swiss Franc / Japanese Yen");
        forex_naming_dict.put("CHFMXN", "Swiss Franc / Mexican Peso");
        forex_naming_dict.put("CHFNOK", "Swiss Franc / Norwegian Krone");
        forex_naming_dict.put("CHFPLN", "Swiss Franc / Polish Zloty");
        forex_naming_dict.put("CHFSEK", "Swiss Franc / Swedish Krona");
        forex_naming_dict.put("CHFSGD", "Swiss Franc / Singapore Dollar");
        forex_naming_dict.put("CHFTRY", "Swiss Franc / Turkish Lira");
        forex_naming_dict.put("CHFZAR", "Swiss Franc / Rand");
        forex_naming_dict.put("CNHHKD", "Chinese yuan / Hong Kong Dollar");
        forex_naming_dict.put("CNHJPY", "Chinese Yuan / Japanese Yen");
        forex_naming_dict.put("DKKJPY", "Danish Krone / Yen");
        forex_naming_dict.put("EURAUD", "Euro / Australian Dollar");
        forex_naming_dict.put("EURCAD", "Euro / Canadian dollar");
        forex_naming_dict.put("EURCHF", "Euro / Swiss Franc");
        forex_naming_dict.put("EURCZK", "Euro / Czech Koruna");
        forex_naming_dict.put("EURDKK", "Euro / Danish Krone");
        forex_naming_dict.put("EURGBP", "Euro / British Pound");
        forex_naming_dict.put("EURILS", "Euro / New Israeli Sheqel");
        forex_naming_dict.put("EURJPY", "Euro / Japanese Yen");
        forex_naming_dict.put("EURMXN", "Euro / Mexican Peso");
        forex_naming_dict.put("EURNZD", "Euro / New Zealand Dollar");
        forex_naming_dict.put("EURPLN", "Euro / Polish Zloty");
        forex_naming_dict.put("EURRON", "Euro / Romanian Leu");
        forex_naming_dict.put("EURSGD", "Euro / Singapore Dollar");
        forex_naming_dict.put("EURUSD", "Euro / US Dollar");
        forex_naming_dict.put("GBPAUD", "British Pound / Australian Dollar");
        forex_naming_dict.put("GBPCAD", "British Pound / Canadian dollar");
        forex_naming_dict.put("GBPCHF", "British Pound / Swiss Franc");
        forex_naming_dict.put("GBPCNH", "Pound Sterling / Chinese yuan");
        forex_naming_dict.put("GBPCZK", "British Pound / Czech Koruna");
        forex_naming_dict.put("GBPDKK", "British Pound / Danish Krone");
        forex_naming_dict.put("GBPHKD", "British Pound / Hong Kong Dollar");
        forex_naming_dict.put("GBPHUF", "British Pound / Hungarian Forint");
        forex_naming_dict.put("GBPJPY", "British Pound / Japanese Yen");
        forex_naming_dict.put("GBPMXN", "British Pound / Mexican Peso");
        forex_naming_dict.put("GBPNOK", "British Pound / Norwegian Krone");
        forex_naming_dict.put("GBPNZD", "British Pound / New Zealand Dollar");
        forex_naming_dict.put("GBPPLN", "British Pound / Polish Zloty");
        forex_naming_dict.put("GBPSEK", "British Pound / Swedish Krona");
        forex_naming_dict.put("GBPSGD", "British Pound / Singapore Dollar");
        forex_naming_dict.put("GBPTRY", "British Pound / Turkish lira");
        forex_naming_dict.put("GBPUSD", "British Pound / US Dollar");
        forex_naming_dict.put("GBPZAR", "British Pound / South African Rand");
        forex_naming_dict.put("HKDMXN", "Hong Kong Dollar / Mexican Peso");
        forex_naming_dict.put("HKDTRY", "Hong Kong Dollar / Turkish Lira");
        forex_naming_dict.put("NOKSEK", "Norwegian Krone / Swedish Krona");
        forex_naming_dict.put("NOKTRY", "Norwegian Krone / Turkish Lira");
        forex_naming_dict.put("NZDCAD", "New Zealand Dollar / Canadian dollar");
        forex_naming_dict.put("NZDCHF", "New Zealand Dollar / Swiss Franc");
        forex_naming_dict.put("NZDCNH", "New Zealand Dollar / Chinese yuan");
        forex_naming_dict.put("NZDHKD", "New Zealand Dollar / Hong Kong Dollar");
        forex_naming_dict.put("NZDJPY", "New Zealand Dollar / Japanese Yen");
        forex_naming_dict.put("NZDMXN", "New Zealand Dollar / Mexican Peso");
        forex_naming_dict.put("NZDPLN", "New Zealand Dollar / Zloty");
        forex_naming_dict.put("NZDSEK", "New Zealand Dollar / Swedish Krona");
        forex_naming_dict.put("NZDSGD", "New Zealand Dollar / Singapore Dollar");
        forex_naming_dict.put("NZDTRY", "New Zealand Dollar / Turkish Lira");
        forex_naming_dict.put("NZDUSD", "New Zealand Dollar / US Dollar");
        forex_naming_dict.put("PLNSEK", "Zloty / Swedish Krona");
        forex_naming_dict.put("PLNTRY", "Zloty / Turkish Lira");
        forex_naming_dict.put("SEKMXN", "Swedish Krona / Mexican Peso");
        forex_naming_dict.put("SEKTRY", "Swedish Krona / Turkish Lira");
        forex_naming_dict.put("SGDHKD", "Singapore Dollar / Hong Kong Dollar");
        forex_naming_dict.put("SGDMXN", "Singapore Dollar / Mexican Peso");
        forex_naming_dict.put("TRYJPY", "Turkish Lira / Japanese Yen");
        forex_naming_dict.put("USDCAD", "US Dollar / Canadian dollar");
        forex_naming_dict.put("USDCHF", "US Dollar / Swiss Franc");
        forex_naming_dict.put("USDCNH", "US Dollar / Chinese Yuan");
        forex_naming_dict.put("USDCZK", "US Dollar / Czech Koruna");
        forex_naming_dict.put("USDDKK", "US Dollar / Danish Krone");
        forex_naming_dict.put("USDHKD", "US Dollar / Hong Kong Dollar");
        forex_naming_dict.put("USDILS", "US Dollar / Israeli New Shekel");
        forex_naming_dict.put("USDJPY", "US Dollar / Japanese Yen");
        forex_naming_dict.put("USDRON", "US Dollar / Romanian Leu");
        forex_naming_dict.put("USDTRY", "US Dollar / Turkish Lira");
    }

    public static void wait(int sleep_ms) {
        try {
            java.lang.Thread.sleep(sleep_ms);
        } catch (InterruptedException ex) {
            java.lang.Thread.currentThread().interrupt();
        }
    }

}
