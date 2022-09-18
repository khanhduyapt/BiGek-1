package bsc_scan_binance.utils;

import java.io.BufferedInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.math.BigDecimal;
import java.math.BigInteger;
import java.math.RoundingMode;
import java.net.URL;
import java.net.URLConnection;
import java.sql.Timestamp;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.time.Instant;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Calendar;
import java.util.Date;
import java.util.Formatter;
import java.util.Iterator;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Objects;
import java.util.TimeZone;

import javax.servlet.http.HttpServletRequest;

import org.springframework.context.MessageSource;
import org.springframework.util.CollectionUtils;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.servlet.LocaleResolver;

import bsc_scan_binance.BscScanBinanceApplication;
import bsc_scan_binance.entity.BtcFutures;
import bsc_scan_binance.entity.PrepareOrders;
import bsc_scan_binance.entity.PriorityCoin;
import bsc_scan_binance.response.BtcFuturesResponse;
import bsc_scan_binance.response.CandidateTokenCssResponse;
import bsc_scan_binance.response.DepthResponse;
import bsc_scan_binance.response.FundingResponse;
import bsc_scan_binance.response.OrdersProfitResponse;
import bsc_scan_binance.response.PriorityCoinResponse;

public class Utils {
    public static final String chatId_duydk = "5099224587";
    public static final String chatUser_duydk = "tg25251325";

    public static final String chatId_linkdk = "816816414";
    public static final String chatUser_linkdk = "LokaDon";

    public static final String new_line_from_bot = "\n";
    public static final String new_line_from_service = "%0A";

    public static final int const_app_flag_msg_on = 1; // 1: msg_on; 2: msg_off; 3: web only; 4: all coin
    public static final int const_app_flag_msg_off = 2;
    public static final int const_app_flag_webonly = 3;
    public static final int const_app_flag_all_coin = 4;

    public static final String PREPARE_ORDERS_DATA_TYPE_BOT = "1";
    public static final String PREPARE_ORDERS_DATA_TYPE_BINANCE_VOL_UP = "2";
    public static final String PREPARE_ORDERS_DATA_TYPE_GECKO_VOL_UP = "3";
    public static final String PREPARE_ORDERS_DATA_TYPE_MIN14D = "4";
    public static final String PREPARE_ORDERS_DATA_TYPE_MAX14D = "5";

    public static String sql_OrdersProfitResponse = ""
            + " SELECT * from (                                                                             \n"
            + "    SELECT                                                                                   \n"
            + "      od.gecko_id,                                                                           \n"
            + "      od.symbol      as chatId,                                                              \n"
            + "      od.name        as userName,                                                            \n"
            + "      od.order_price,                                                                        \n"
            + "      ROUND(od.qty, 1) qty,                                                                  \n"
            + "      od.amount,                                                                             \n"
            + "      cur.price_at_binance,                                                                  \n"
            + "      (select target_percent from priority_coin po where po.gecko_id = od.gecko_id) target_percent, \n"
            + "      ROUND(((cur.price_at_binance - od.order_price)/od.order_price)*100, 1)  as tp_percent, \n"
            + "      ROUND( (cur.price_at_binance - od.order_price)*od.qty, 1)               as tp_amount,  \n"
            + "      od.low_price,                                                                          \n"
            + "      od.height_price,                                                                       \n"
            + "      (select note from priority_coin pc where pc.gecko_id = od.gecko_id) as target          \n"
            + "    FROM                                                                                     \n"
            + "        orders od,                                                                           \n"
            + "        binance_volumn_day cur                                                               \n"
            + "    WHERE                                                                                    \n"
            + "            cur.hh      = TO_CHAR(NOW(), 'HH24')                                             \n"
            + "        and od.gecko_id = cur.gecko_id                                                       \n"
            + " ) odr ORDER BY odr.tp_amount desc ";

    public static String sql_boll_2_body = ""
            + " (                                                                                           \n"
            + "     select                                                                                  \n"
            + "         tmp.gecko_id,                                                                       \n"
            + "         tmp.symbol,                                                                         \n"
            + "         tmp.name,                                                                           \n"
            + "         tmp.avg_price,                                                                      \n"
            + "         tmp.price_open_candle,                                                              \n"
            + "         tmp.price_close_candle,                                                             \n"
            + "         tmp.low_price,                                                                      \n"
            + "         tmp.hight_price,                                                                    \n"
            + "         tmp.price_can_buy,                                                                  \n"
            + "         tmp.price_can_sell,                                                                 \n"
            + "         (case when (avg_price <= ROUND((price_can_buy  + (ABS(price_close_candle - price_open_candle)/2)), 5) ) then true else false end) is_bottom_area ,    \n"
            + "         (case when (avg_price >= ROUND((price_can_sell - (ABS(price_close_candle - price_open_candle)/2)), 5) ) then true else false end) is_top_area         \n"
            + "     from                                                                                    \n"
            + "     (                                                                                       \n"
            + "         select                                                                              \n"
            + "             can.gecko_id,                                                                   \n"
            + "             can.symbol,                                                                     \n"
            + "             can.name,                                                                       \n"
            + "             min(tok.avg_price) avg_price,                                                   \n"
            + "             min(tok.price_open_candle) price_open_candle,                                   \n"
            + "             min(tok.price_close_candle) price_close_candle,                                 \n"
            + "             (SELECT COALESCE(low_price  , 0) FROM btc_volumn_day where gecko_id = can.gecko_id and hh in (select hh from btc_volumn_day where gecko_id = can.gecko_id order by low_price asc  limit 1))              low_price,     \n"
            + "             (SELECT COALESCE(hight_price, 0) FROM btc_volumn_day where gecko_id = can.gecko_id and hh in (select hh from btc_volumn_day where gecko_id = can.gecko_id order by low_price desc limit 1))              hight_price,   \n"
            + "             (SELECT ROUND(AVG(COALESCE(avg_price, 0)), 5) FROM btc_volumn_day where gecko_id = can.gecko_id and hh in (select hh from btc_volumn_day where gecko_id = can.gecko_id order by avg_price asc  limit 2)) price_can_buy, \n"
            + "             (SELECT ROUND(AVG(COALESCE(avg_price, 0)), 5) FROM btc_volumn_day where gecko_id = can.gecko_id and hh in (select hh from btc_volumn_day where gecko_id = can.gecko_id order by avg_price desc limit 1)) price_can_sell \n"
            + "         from                                                                                \n"
            + "             candidate_coin can,                                                             \n"
            + "             btc_volumn_day tok                                                              \n"
            + "         where 1=1                                                                           \n"
            + "         and can.gecko_id = tok.gecko_id                                                     \n"
            + "         and tok.hh = (case when EXTRACT(MINUTE FROM NOW()) < 3 then TO_CHAR(NOW() - interval '1 hours', 'HH24') else TO_CHAR(NOW(), 'HH24') end) \n"
            + "         group by can.gecko_id\n"
            + "     ) tmp                                                                                   \n"
            + " ) boll                                                                                      \n";

    public static List<BtcFutures> loadData(String symbol, String TIME, int LIMIT_DATA) {
        try {
            BigDecimal price_at_binance = Utils.getBinancePrice(symbol);

            String url = "https://api.binance.com/api/v3/klines?symbol=" + symbol.toUpperCase() + "USDT&interval="
                    + TIME + "&limit=" + LIMIT_DATA;

            List<Object> list = Utils.getBinanceData(url, LIMIT_DATA);

            List<BtcFutures> list_entity = new ArrayList<BtcFutures>();
            int id = 0;

            for (int idx = LIMIT_DATA - 1; idx >= 0; idx--) {
                Object obj_usdt = list.get(idx);

                @SuppressWarnings("unchecked")
                List<Object> arr_usdt = (List<Object>) obj_usdt;
                if (CollectionUtils.isEmpty(arr_usdt) || arr_usdt.size() < 4) {
                    return list_entity;
                }

                BigDecimal price_open_candle = Utils.getBigDecimal(arr_usdt.get(1));
                BigDecimal hight_price = Utils.getBigDecimal(arr_usdt.get(2));
                BigDecimal low_price = Utils.getBigDecimal(arr_usdt.get(3));
                BigDecimal price_close_candle = Utils.getBigDecimal(arr_usdt.get(4));
                String open_time = arr_usdt.get(0).toString();

                if (Objects.equals("0", open_time)) {
                    break;
                }

                BtcFutures day = new BtcFutures();

                String strid = String.valueOf(id);
                if (strid.length() < 2) {
                    strid = "0" + strid;
                }
                day.setId(symbol.toUpperCase() + "_" + TIME + "_" + strid);

                if (idx == LIMIT_DATA - 1) {
                    day.setCurrPrice(price_at_binance);
                } else {
                    day.setCurrPrice(BigDecimal.ZERO);
                }

                day.setLow_price(low_price);
                day.setHight_price(hight_price);
                day.setPrice_open_candle(price_open_candle);
                day.setPrice_close_candle(price_close_candle);

                if (price_open_candle.compareTo(price_close_candle) < 0) {
                    day.setUptrend(true);
                } else {
                    day.setUptrend(false);
                }

                list_entity.add(day);

                id += 1;
            }

            return list_entity;
        } catch (

        Exception e) {
            e.printStackTrace();
        }

        return new ArrayList<BtcFutures>();
    }

    public static String toString(PriorityCoin tele) {
        return tele.getSymbol() + ":" + tele.getName() + " P:" + tele.getCurrent_price() + "$ Target:"
                + tele.getTarget_percent() + " ema:" + tele.getEma();
    }

    public static String createMsgBalance(OrdersProfitResponse dto, String newline) {
        String result = String.format("[%s]", dto.getGecko_id()) + newline + "Price: "
                + dto.getPrice_at_binance().toString() + "$, "
                + (dto.getTp_amount().compareTo(BigDecimal.ZERO) > 0 ? "Profit: " : "Loss: ")
                + Utils.removeLastZero(dto.getTp_amount().toString()) + "$ (" + dto.getTp_percent() + "%)" + newline
                + "Bought: " + dto.getOrder_price().toString() + "$, " + "T: "
                + Utils.removeLastZero(dto.getAmount().toString()) + "$" + newline
                + createMsgLowHeight(dto.getPrice_at_binance(), dto.getLow_price(), dto.getHeight_price());

        if (isNotBlank(dto.getTarget()) && dto.getTarget().contains("~v/mc")) {
            result += newline + dto.getTarget().substring(0, dto.getTarget().indexOf("~v/mc"));
        }

        return result;
    }

    public static String createMsg(CandidateTokenCssResponse css) {
        return "BTC: " + css.getCurrent_price() + "$" + "%0A" + css.getLow_to_hight_price() + "%0A"
                + Utils.convertDateToString("MM-dd hh:mm", Calendar.getInstance().getTime());
    }

    public static String createMsgSimple(BigDecimal curr_price, BigDecimal low_price, BigDecimal hight_price) {
        return Utils.removeLastZero(curr_price.toString()) + "$\n"
                + createMsgLowHeight(curr_price, low_price, hight_price);
    }

    public static String createMsgLowHeight(BigDecimal curr_price, BigDecimal low_price, BigDecimal hight_price) {
        return "L:" + Utils.removeLastZero(low_price.toString()) + "(" + Utils.toPercent(low_price, curr_price, 1)
                + "%)" + "-H:" + Utils.removeLastZero(hight_price.toString()) + "("
                + Utils.toPercent(hight_price, curr_price, 1) + "%)" + "$";
    }

    public static String createMsgPriorityToken(PriorityCoin dto, String newline) {
        String result = String.format("[%s]_[%s]", dto.getSymbol(), dto.getGeckoid())
                + whenGoodPrice(dto.getCurrent_price(), dto.getLow_price(), dto.getHeight_price()) + newline + "Price: "
                + dto.getCurrent_price().toString() + "$" + newline + dto.getNote().replace("~", newline) + newline
                + createMsgLowHeight(dto.getCurrent_price(), dto.getLow_price(), dto.getHeight_price());
        return result;
    }

    public static String createMsgPriorityCoinResponse(PriorityCoinResponse dto, String newline) {
        String result = String.format("[%s]_[%s]", dto.getSymbol(), dto.getGecko_id())
                + whenGoodPrice(dto.getCurrent_price(), dto.getLow_price(), dto.getHeight_price()) + newline + "Price: "
                + dto.getCurrent_price().toString() + "$" + newline + dto.getNote() + newline
                + createMsgLowHeight(dto.getCurrent_price(), dto.getLow_price(), dto.getHeight_price());

        return result;
    }

    public static String getDataType(PrepareOrders entity) {
        String result = "";

        switch (getStringValue(entity.getDataType())) {
        case PREPARE_ORDERS_DATA_TYPE_BOT:
            result = "(Bot)";
            break;
        case PREPARE_ORDERS_DATA_TYPE_BINANCE_VOL_UP:
            result = "(BinanceVol)";
            break;
        case PREPARE_ORDERS_DATA_TYPE_GECKO_VOL_UP:
            result = "(GeckoVol)";
            break;
        case PREPARE_ORDERS_DATA_TYPE_MIN14D:
            result = "(Min14d)";
            break;
        case PREPARE_ORDERS_DATA_TYPE_MAX14D:
            result = "(Max14d)";
            break;
        default:
            break;
        }

        return result;
    }

    public static boolean isUptrend(List<BtcFutures> list) {
        BtcFutures item00 = list.get(0);
        BtcFutures item99 = list.get(list.size() - 1);

        if (Utils.isAGreaterB(item00.getLow_price(), item99.getHight_price())) {
            return true;
        }

        if (item00.isUptrend() && Utils.isAGreaterB(item00.getPrice_open_candle(), item99.getPrice_close_candle())
                && Utils.isAGreaterB(item00.getPrice_open_candle(), item99.getPrice_open_candle())) {
            return true;
        }

        if (item00.isUptrend() && (Utils.isAGreaterB(item00.getPrice_open_candle(), item99.getPrice_close_candle())
                || Utils.isAGreaterB(item00.getPrice_open_candle(), item99.getPrice_open_candle()))) {
            return true;
        }

        return item00.isUptrend();
    }

    public static boolean isAGreaterB(BigDecimal a, BigDecimal b) {
        if (getBigDecimal(a).compareTo(getBigDecimal(b)) > 0) {
            return true;
        }
        return false;
    }

    public static List<Object> getBinanceData(String url, int limit) {
        try {
            RestTemplate restTemplate = new RestTemplate();
            Object[] result = restTemplate.getForObject(url, Object[].class);

            if (result.length < limit) {
                List<Object> list = new ArrayList<Object>();
                for (int idx = 0; idx < limit - result.length; idx++) {
                    List<Object> data = new ArrayList<Object>();
                    for (int i = 0; i < limit; i++) {
                        data.add(0);
                    }
                    list.add(data);
                }

                for (Object obj : result) {
                    list.add(obj);
                }

                return list;

            } else {
                return Arrays.asList(result);
            }
        } catch (Exception e) {
            List<Object> list = new ArrayList<Object>();
            for (int idx = 0; idx < limit; idx++) {
                List<Object> data = new ArrayList<Object>();
                for (int i = 0; i < limit; i++) {
                    data.add(0);
                }
                list.add(data);
            }

            return list;
        }

    }

    public static BigDecimal getBinancePrice(String symbol) {
        try {
            String url = "https://api.binance.com/api/v3/ticker/price?symbol=" + symbol + "USDT";
            RestTemplate restTemplate = new RestTemplate();
            Object result = restTemplate.getForObject(url, Object.class);

            return Utils.getBigDecimal(Utils.getLinkedHashMapValue(result, Arrays.asList("price")));
        } catch (Exception e) {
            return BigDecimal.ZERO;
        }

    }

    public static boolean isNotBlank(String value) {
        if (Objects.equals(null, value) || Objects.equals("", value)) {
            return false;
        }
        return true;
    }

    public static String appendSpace(String value, int length) {
        int len = value.length();
        if (len > length) {
            return value + "..";
        }

        int target = length - len;
        String val = value + "..";
        for (int i = 0; i < target; i++) {
            val += "..";
        }

        for (int i = 0; i < len; i++) {
            String alpha = value.substring(i, i + 1);
            if (Objects.equals(alpha, "I")) {
                val += "..";
            }

            if (Objects.equals(alpha, "J")) {
                val += "..";
            }

            if (Objects.equals(alpha, "M")) {
                val = val.substring(0, val.length() - 1);
            }

            if (Objects.equals(alpha, "W")) {
                val = val.substring(0, val.length() - 1);
            }
        }

        return val + ".";
    }

    public static BigDecimal getMidPrice(BigDecimal low_price, BigDecimal hight_price) {
        BigDecimal mid_price = (getBigDecimal(hight_price).add(getBigDecimal(low_price)));
        mid_price = mid_price.divide(BigDecimal.valueOf(2), 5, RoundingMode.CEILING);

        return mid_price;
    }

    public static Boolean isDangerPrice(BigDecimal curr_price, BigDecimal low_price, BigDecimal hight_price) {
        BigDecimal mid_price = getMidPrice(low_price, hight_price);

        BigDecimal danger_range = (hight_price.subtract(mid_price));
        danger_range = danger_range.divide(BigDecimal.valueOf(3), 5, RoundingMode.CEILING);

        BigDecimal danger_price = mid_price.subtract(danger_range);

        return (danger_price.compareTo(curr_price) > 0);
    }

    public static Boolean isVectorUp(BigDecimal vector) {
        return (vector.compareTo(BigDecimal.ZERO) >= 0);
    }

    public static String whenGoodPrice(BigDecimal curr_price, BigDecimal low_price, BigDecimal hight_price) {
        return (isGoodPriceLong(curr_price, low_price, hight_price) ? "*5*" : "");
    }

    public static boolean isCandidate(CandidateTokenCssResponse css) {

        if (css.getStar().toLowerCase().contains("uptrend")) {
            return true;
        }

        return false;
    }

    public static void sendToMyTelegram(String text) {
        if (BscScanBinanceApplication.app_flag != const_app_flag_msg_on) {
            return;
        }

        sendToChatId(Utils.chatId_duydk, text);
    }

    public static void sendToTelegram(String text) {
        if (BscScanBinanceApplication.app_flag != const_app_flag_msg_on) {
            return;
        }

        if (!isBusinessTime()) {
            // return;
        }

        sendToChatId(Utils.chatId_duydk, text);
        sendToChatId(Utils.chatId_linkdk, text);
    }

    public static boolean isBusinessTime() {
        int hh = Utils.getIntValue(Utils.convertDateToString("HH", Calendar.getInstance().getTime()));
        if ((23 <= hh && hh <= 7)) {
            return false;
        }

        return true;
    }

    public static String getChatId(String userName) {
        if (Objects.equals(userName, chatUser_linkdk)) {
            return chatId_linkdk;
        }
        return chatId_duydk;
    }

    public static void sendToChatId(String chat_id, String text) {
        try {
            String urlString = "https://api.telegram.org/bot%s/sendMessage?chat_id=%s&text=";

            // Telegram token
            String apiToken = "5349894943:AAE_0-ZnbikN9m1aRoyCI2nkT2vgLnFBA-8";

            urlString = String.format(urlString, apiToken, chat_id) + text;
            try {
                URL url = new URL(urlString);
                URLConnection conn = url.openConnection();
                @SuppressWarnings("unused")
                InputStream is = new BufferedInputStream(conn.getInputStream());
            } catch (IOException e) {
                e.printStackTrace();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public static BigDecimal getBigDecimal(Object value) {
        if (Objects.equals(null, value)) {
            return BigDecimal.ZERO;
        }

        if (Objects.equals("", value.toString())) {
            return BigDecimal.ZERO;
        }

        BigDecimal ret = null;
        try {
            if (value != null) {
                if (value instanceof BigDecimal) {
                    ret = (BigDecimal) value;
                } else if (value instanceof String) {
                    ret = new BigDecimal((String) value);
                } else if (value instanceof BigInteger) {
                    ret = new BigDecimal((BigInteger) value);
                } else if (value instanceof Number) {
                    ret = new BigDecimal(((Number) value).doubleValue());
                } else {
                    throw new ClassCastException("Not possible to coerce [" + value + "] from class " + value.getClass()
                            + " into a BigDecimal.");
                }
            }
            return ret;
        } catch (Exception e) {
            return BigDecimal.ZERO;
        }

    }

    public static String toMillions(Object value) {
        BigDecimal val = getBigDecimal(value);
        val = val.divide(BigDecimal.valueOf(1000000), 2, RoundingMode.CEILING);

        return String.format("%,.0f", val) + "M$";
    }

    public static String removeLastZero(BigDecimal value) {
        return removeLastZero(Utils.getStringValue(value));
    }

    public static String getNextBidsOrAsksWall(BigDecimal price_at_binance, List<DepthResponse> bidsOrAsksList) {

        String next_bids_price = Utils.removeLastZero(price_at_binance) + "(now)";
        int count = 1;
        for (DepthResponse res : bidsOrAsksList) {
            if (Objects.equals("BTC", res.getSymbol())) {
                if (res.getVal_million_dolas().compareTo(BigDecimal.valueOf(2)) > 0) {
                    next_bids_price += "->" + res.getPrice() + "(" + res.getVal_million_dolas() + "m$)";
                    count += 1;
                }
            }
            if (count > 3) {
                break;
            }
        }

        return next_bids_price;
    }

    public static String removeLastZero(String value) {
        if ((value == null) || (Objects.equals("", value))) {
            return "";
        }

        BigDecimal val = getBigDecimalValue(value);
        if (val.compareTo(BigDecimal.valueOf(500)) > 0) {
            return String.format("%.0f", val);
        }

        if (Objects.equals("0", value.subSequence(value.length() - 1, value.length()))) {
            String str = value.substring(0, value.length() - 1);
            return removeLastZero(str);
        }

        if (value.indexOf(".") == value.length() - 1) {
            return value + "0";
        }

        return value;
    }

    public static Integer getCurrentHH() {
        int HH = Utils.getIntValue(Utils.convertDateToString("HH", Calendar.getInstance().getTime()));
        return HH;
    }

    public static Integer getCurrentMinute() {
        int mm = Utils.getIntValue(Utils.convertDateToString("mm", Calendar.getInstance().getTime()));
        return mm;
    }

    public static Integer getCurrentSeconds() {
        int ss = Utils.getIntValue(Utils.convertDateToString("ss", Calendar.getInstance().getTime()));
        return ss;
    }

    public static Integer getIntValue(Object value) {
        try {
            if (Objects.equals(null, value)) {
                return 0;
            }

            return Integer.valueOf(value.toString().trim());
        } catch (Exception e) {
            return 0;
        }
    }

    public static String getStringValue(Object value) {
        if (Objects.equals(null, value)) {
            return "";
        }
        if (Objects.equals("", value.toString())) {
            return "";
        }

        return value.toString();
    }

    public static String lossPer1000(BigDecimal entry, BigDecimal take_porfit_price) {
        BigDecimal fee = BigDecimal.valueOf(2);

        BigDecimal loss = BigDecimal.valueOf(1000).multiply(entry.subtract(take_porfit_price))
                .divide(entry, 0, RoundingMode.CEILING).subtract(fee);

        return "1000$/" + Utils.removeLastZero(String.valueOf(loss)) + "$";
    }

    public static String toPercent(BigDecimal value, BigDecimal compareToValue) {
        return toPercent(value, compareToValue, 1);
    }

    public static String toPercent(BigDecimal value, BigDecimal compareToValue, int scale) {
        if (Objects.equals("", getStringValue(compareToValue))) {
            return "0";
        }

        if (compareToValue.compareTo(BigDecimal.ZERO) == 0) {
            return "[dvz]";
        }
        BigDecimal percent = (value.subtract(compareToValue)).divide(compareToValue, 2 + scale, RoundingMode.CEILING)
                .multiply(BigDecimal.valueOf(100));

        return removeLastZero(percent.toString());
    }

    public static BigDecimal getPercent(BigDecimal value, BigDecimal compareToValue) {
        BigDecimal percent = (value.subtract(compareToValue)).divide(compareToValue, 4, RoundingMode.CEILING)
                .multiply(BigDecimal.valueOf(100));

        return percent;
    }

    public static BigDecimal getBigDecimalValue(String value) {
        try {
            if (Objects.equals(null, value)) {
                return BigDecimal.ZERO;
            }
            if (Objects.equals("", value.toString())) {
                return BigDecimal.ZERO;
            }

            return BigDecimal.valueOf(Double.valueOf(value.toString()));
        } catch (Exception e) {
            return BigDecimal.ZERO;
        }
    }

    public static String getTextCss(String value) {
        if (Objects.equals(null, value)) {
            return "";
        }

        if (value.contains("-")) {
            return "text-danger";
        } else {
            return "text-primary";
        }
    }

    public static BigDecimal formatPriceLike(BigDecimal value, BigDecimal des_value) {
        return formatPrice(value, getDecimalNumber(des_value));
    }

    public static BigDecimal formatPrice(BigDecimal value, int number) {
        @SuppressWarnings("resource")
        Formatter formatter = new Formatter();
        formatter.format("%." + String.valueOf(number) + "f", value);

        return BigDecimal.valueOf(Double.valueOf(formatter.toString()));
    }

    public static int getDecimalNumber(BigDecimal value) {

        String val = removeLastZero(getStringValue(value));
        if (!val.contains(".")) {
            return 0;
        }
        int number = val.length() - val.indexOf(".") - 1;

        return number;
    }

    public static Date getDate(String unix_time) {
        String temp = unix_time.substring(0, unix_time.length() - 3);

        Instant instant = Instant.ofEpochSecond(Long.valueOf(temp));
        Date date = Date.from(instant);

        return date;
    }

    public static Object getLinkedHashMapValue(Object root, List<String> childs) {
        int index = 0;
        Object obj_key = root;

        for (String key : childs) {
            @SuppressWarnings("unchecked")
            LinkedHashMap<String, Object> linkedHashMap = (LinkedHashMap<String, Object>) obj_key;
            obj_key = linkedHashMap.get(key);
            index += 1;

            if (index == childs.size()) {
                return obj_key;
            }
        }

        return null;
    }

    public static String getMessage(HttpServletRequest request, LocaleResolver localeResolver, MessageSource messages,
            String key) {
        final Locale locale = localeResolver.resolveLocale(request);
        String message = messages.getMessage(key, null, locale);
        return message;
    }

    public static String getMessage2(MessageSource messages, String key, String lang) {
        String message = messages.getMessage(key, null, Locale.forLanguageTag(lang));
        return message;
    }

    public static final String generateCollectionString(List<?> list) {
        if (list == null || list.isEmpty())
            return "()";
        StringBuilder result = new StringBuilder();
        result.append("(");
        for (Iterator<?> it = list.iterator(); it.hasNext();) {
            Object ob = it.next();
            result.append("'");
            result.append(ob.toString());
            result.append("'");
            if (it.hasNext())
                result.append(" , ");
        }
        result.append(")");
        return result.toString();
    }

    public static final String generateCollectionStringLikeArray(List<?> list) {
        if (list == null || list.isEmpty())
            return "[]";
        StringBuilder result = new StringBuilder();
        result.append("[");
        for (Iterator<?> it = list.iterator(); it.hasNext();) {
            Object ob = it.next();
            result.append("'%");
            result.append(ob.toString());
            result.append("%'");
            if (it.hasNext())
                result.append(" , ");
        }
        result.append("]");
        return result.toString();
    }

    public static final String generateCollectionNumber(List<?> list) {
        if (list == null || list.isEmpty())
            return "()";
        StringBuilder result = new StringBuilder();
        result.append("(");
        for (Iterator<?> it = list.iterator(); it.hasNext();) {
            Object ob = it.next();
            result.append(ob.toString());
            if (it.hasNext())
                result.append(" , ");
        }
        result.append(")");
        return result.toString();
    }

    public static String convertDateToString(String pattern, Date date) {
        SimpleDateFormat sdf = new SimpleDateFormat(pattern);
        return sdf.format(date);
    }

    public static Date convertStringToDate(String pattern, String date) {
        try {
            return new SimpleDateFormat(pattern).parse(date);
        } catch (Exception e) {
            return null;
        }
    }

    public static String convertStringISOToString(String patternIn, String dateIso, String patternOut) {
        // IN :yyyy-MM-dd'T'HH:mm:ss.SSSXXX
        // OUT : yyyy-MM-dd
        try {
            DateFormat dateFormat = new SimpleDateFormat(patternIn);
            dateFormat.setTimeZone(TimeZone.getTimeZone("UTC"));
            Date date = dateFormat.parse(dateIso);
            DateFormat formatter = new SimpleDateFormat(patternOut);
            return formatter.format(date);
        } catch (Exception e) {
            return null;
        }
    }

    public static Timestamp convertStringToTimeStamp(String pattern, String date) {
        try {
            DateFormat df = new SimpleDateFormat(pattern);
            Date dates = df.parse(date);
            long time = dates.getTime();
            Timestamp ts = new Timestamp(time);
            return ts;
        } catch (Exception e) {
            return null;
        }
    }

    public static final String generateCollectionStringLikeArray(List<?> list, String columnName) {
        StringBuilder result = new StringBuilder();
        for (Iterator<?> it = list.iterator(); it.hasNext();) {
            Object ob = it.next();
            result.append(" LOWER(").append(columnName).append(")").append(" LIKE '%");
            result.append(ob.toString());
            result.append("%'");
            if (it.hasNext()) {
                result.append(" OR ");
            }
        }
        return result.toString();
    }

    public static final String generateCollectionStringToArray(List<?> list) {
        StringBuilder result = new StringBuilder();
        result.append("[");
        for (Iterator<?> it = list.iterator(); it.hasNext();) {
            Object ob = it.next();
            result.append("'%");
            result.append(ob.toString());
            result.append("%'");
            if (it.hasNext())
                result.append(" , ");
        }
        result.append("]");
        return result.toString();
    }

    public static BigDecimal getGoodPriceLong(BigDecimal low_price, BigDecimal hight_price) {
        BigDecimal good_price = (hight_price.subtract(low_price));

        good_price = good_price.divide(BigDecimal.valueOf(5), 5, RoundingMode.CEILING);
        good_price = low_price.add(good_price);

        return good_price;
    }

    public static BigDecimal getStopLossForLong(BigDecimal low_price, BigDecimal open_candle) {
        if (getBigDecimal(low_price).equals(BigDecimal.ZERO)) {
            return BigDecimal.valueOf(1000000);
        }
        if (getBigDecimal(open_candle).equals(BigDecimal.ZERO)) {
            return BigDecimal.valueOf(1000000);
        }

        BigDecimal candle_beard_length = open_candle.subtract(low_price);
        candle_beard_length = candle_beard_length.divide(BigDecimal.valueOf(2), 5, RoundingMode.CEILING);

        BigDecimal stop_loss = low_price.subtract(candle_beard_length);
        return stop_loss;
    }

    public static BigDecimal getPriceAtMidCandle(BigDecimal open_candle, BigDecimal close_candle) {
        BigDecimal candle_beard_length = close_candle.subtract(open_candle);
        candle_beard_length = candle_beard_length.divide(BigDecimal.valueOf(2), 5, RoundingMode.CEILING);

        BigDecimal mid = open_candle.add(candle_beard_length);
        return mid;
    }

    public static BigDecimal getStopLossForShort(BigDecimal hight_price, BigDecimal close_candle) {
        if (getBigDecimal(hight_price).equals(BigDecimal.ZERO)) {
            return BigDecimal.valueOf(1000000);
        }
        if (getBigDecimal(close_candle).equals(BigDecimal.ZERO)) {
            return BigDecimal.valueOf(1000000);
        }

        BigDecimal candle_beard_length = hight_price.subtract(close_candle);
        candle_beard_length = candle_beard_length.divide(BigDecimal.valueOf(2), 5, RoundingMode.CEILING);

        BigDecimal stop_loss = hight_price.add(candle_beard_length);
        return stop_loss;
    }

    public static BigDecimal getGoodPriceLongByPercent(BigDecimal cur_price, BigDecimal low_price,
            BigDecimal open_candle, BigDecimal stop_loss_percent) {
        BigDecimal stop_loss = getStopLossForLong(low_price, open_candle);

        BigDecimal good_price = cur_price;
        while (true) {
            BigDecimal stop_loss_percent_curr = getPercent(good_price, stop_loss);
            if (stop_loss_percent_curr.compareTo(stop_loss_percent) < 0) {
                break;
            } else {
                good_price = good_price.subtract(BigDecimal.valueOf(10));
            }
        }

        return good_price;
    }

    public static BigDecimal getGoodPriceShortByPercent(BigDecimal cur_price, BigDecimal hight_price,
            BigDecimal close_candle, BigDecimal stop_loss_percent) {
        BigDecimal stop_loss = getStopLossForShort(hight_price, close_candle);

        BigDecimal good_price = cur_price;
        while (true) {
            BigDecimal stop_loss_percent_curr = getPercent(stop_loss, good_price);
            if (stop_loss_percent_curr.compareTo(stop_loss_percent) < 0) {
                break;
            } else {
                good_price = good_price.add(BigDecimal.valueOf(10));
            }
        }

        return good_price;
    }

    public static Boolean isGoodPriceLong(BigDecimal cur_price, BigDecimal lo_price, BigDecimal hi_price) {
        BigDecimal curr_price = Utils.getBigDecimal(cur_price);
        BigDecimal low_price = Utils.getBigDecimal(lo_price);
        BigDecimal hight_price = Utils.getBigDecimal(hi_price);

        BigDecimal good_price = getGoodPriceLong(low_price, hight_price);

        if (curr_price.compareTo(good_price) < 0) {
            return true;
        }
        return false;
    }

    public static Boolean isGoodPriceShort(BigDecimal cur_price, BigDecimal lo_price, BigDecimal hi_price) {
        BigDecimal curr_price = Utils.getBigDecimal(cur_price);
        BigDecimal low_price = Utils.getBigDecimal(lo_price);
        BigDecimal hight_price = Utils.getBigDecimal(hi_price);

        BigDecimal range = (hight_price.subtract(low_price));
        range = range.divide(BigDecimal.valueOf(8), 5, RoundingMode.CEILING);

        BigDecimal mid_price = hight_price.subtract(range);

        if (curr_price.compareTo(mid_price) > 0) {
            return true;
        }

        return false;
    }

    public static BigDecimal getNextEntry(BtcFuturesResponse dto_1h) {
        BigDecimal entry0 = dto_1h.getOpen_price_half1().subtract(dto_1h.getOpen_price_half2());

        BigDecimal percent_angle = Utils.getPercent(dto_1h.getOpen_price_half2(), dto_1h.getOpen_price_half1()).abs();
        if (percent_angle.compareTo(BigDecimal.valueOf(2)) > 0) {
            return null;
        }
        entry0 = entry0.multiply(Utils.getBigDecimal(dto_1h.getId_half1()));
        int id_haft1 = Utils.getIntValue(dto_1h.getId_half1().replaceAll("BTC_1h_", ""));
        int id_haft2 = Utils.getIntValue(dto_1h.getId_half2().replaceAll("BTC_1h_", ""));
        entry0 = entry0.divide(BigDecimal.valueOf(id_haft2 - id_haft1), 0, RoundingMode.CEILING);
        entry0 = dto_1h.getOpen_price_half1().add(entry0);

        return entry0;
    }

    public static String checkTrend(BtcFuturesResponse dto) {
        BigDecimal percent_angle = Utils.getPercent(dto.getOpen_price_half1(), dto.getOpen_price_half2());

        // Uptrend
        if (percent_angle.compareTo(BigDecimal.valueOf(0.5)) > 0) {
            return "1:Uptrend";
        }

        // Downtrend
        if (percent_angle.compareTo(BigDecimal.valueOf(-0.5)) < 0) {
            return "2:Downtrend";
        }

        // Sideway
        return "3:Sideway";
    }

    public static String getMsgLong(String symbol, BigDecimal entry, BigDecimal low, BigDecimal open, BigDecimal hig) {

        BigDecimal stop_loss = Utils.getStopLossForLong(low, open);
        BigDecimal candle_height = hig.subtract(entry);
        BigDecimal mid_candle = candle_height.divide(BigDecimal.valueOf(2), 5, RoundingMode.CEILING);
        BigDecimal take_porfit_1 = entry.add(mid_candle);
        BigDecimal take_porfit_2 = hig;

        BigDecimal fee = BigDecimal.valueOf(2);
        BigDecimal loss = BigDecimal.valueOf(1000).multiply(stop_loss.subtract(entry))
                .divide(entry, 0, RoundingMode.CEILING).subtract(fee);
        BigDecimal tp1 = BigDecimal.valueOf(1000).multiply(take_porfit_1.subtract(entry))
                .divide(entry, 0, RoundingMode.CEILING).subtract(fee);
        BigDecimal tp2 = BigDecimal.valueOf(1000).multiply(take_porfit_2.subtract(entry))
                .divide(entry, 0, RoundingMode.CEILING).subtract(fee);

        String msg = "(Long) Scalping: " + symbol + Utils.new_line_from_service;

        msg += "E: " + Utils.removeLastZero(entry.toString()) + "$" + Utils.new_line_from_service;

        msg += "SL: " + Utils.removeLastZero(String.valueOf(stop_loss)) + "(" + Utils.toPercent(stop_loss, entry)
                + "%) 1000$/" + loss + "$";
        msg += Utils.new_line_from_service;

        msg += "L: " + Utils.removeLastZero(String.valueOf(low)) + "(" + Utils.toPercent(low, entry) + "%)";
        msg += Utils.new_line_from_service;

        msg += "TP1: " + Utils.removeLastZero(String.valueOf(take_porfit_1)) + "("
                + Utils.toPercent(take_porfit_1, entry) + "%) 1000$/" + tp1 + "$";
        msg += Utils.new_line_from_service;

        msg += "TP2: " + Utils.removeLastZero(String.valueOf(take_porfit_2)) + "("
                + Utils.toPercent(take_porfit_2, entry) + "%) 1000$/" + tp2 + "$";

        return msg;
    }

    public static String getMsgLowHeight(BigDecimal price_at_binance, BtcFuturesResponse dto) {
        String low_height = "";

        String btc_now = Utils.removeLastZero(String.valueOf(price_at_binance)) + " (now)"
                + Utils.new_line_from_service;

        BigDecimal SL_short = Utils.getStopLossForShort(dto.getHight_price_h(), dto.getClose_candle_h());

        low_height += "SL: " + Utils.removeLastZero(SL_short) + " (" + Utils.toPercent(SL_short, price_at_binance)
                + "%)" + Utils.new_line_from_service;

        low_height += "H: " + dto.getHight_price_h() + " (" + Utils.toPercent(dto.getHight_price_h(), price_at_binance)
                + "%)" + Utils.new_line_from_service;

        if (price_at_binance.compareTo(dto.getClose_candle_h()) > 0) {
            low_height += btc_now;
        }

        low_height += "C: " + Utils.removeLastZero(dto.getClose_candle_h()) + " ("
                + Utils.toPercent(dto.getClose_candle_h(), price_at_binance) + "%)" + Utils.new_line_from_service;

        if (price_at_binance.compareTo(dto.getClose_candle_h()) < 0
                && price_at_binance.compareTo(dto.getOpen_candle_h()) > 0) {
            low_height += btc_now;
        }

        low_height += "O: " + Utils.removeLastZero(dto.getOpen_candle_h()) + " ("
                + Utils.toPercent(dto.getOpen_candle_h(), price_at_binance) + "%)" + Utils.new_line_from_service;

        if (price_at_binance.compareTo(dto.getOpen_candle_h()) < 0) {
            low_height += btc_now;
        }

        low_height += "L: " + Utils.removeLastZero(dto.getLow_price_h()) + " ("
                + Utils.toPercent(dto.getLow_price_h(), price_at_binance) + "%)" + Utils.new_line_from_service;

        BigDecimal SL_long = Utils.getStopLossForLong(dto.getLow_price_h(), dto.getOpen_candle_h());

        low_height += "SL: " + Utils.removeLastZero(SL_long) + " (" + Utils.toPercent(SL_long, price_at_binance) + "%)";

        return low_height;
    }

    public static String getMsgLong(BigDecimal entry, BtcFuturesResponse dto) {
        String msg = "";

        BigDecimal stop_loss = Utils.getStopLossForLong(dto.getLow_price_h(), dto.getOpen_candle_h());

        BigDecimal candle_height = dto.getClose_candle_h().subtract(dto.getOpen_candle_h());
        BigDecimal mid_candle = candle_height.divide(BigDecimal.valueOf(2), 0, RoundingMode.CEILING);
        BigDecimal take_porfit_1 = dto.getOpen_candle_h().add(mid_candle);
        BigDecimal take_porfit_2 = dto.getHight_price_h().subtract(BigDecimal.valueOf(10));

        BigDecimal fee = BigDecimal.valueOf(2);
        BigDecimal loss = BigDecimal.valueOf(1000).multiply(stop_loss.subtract(entry))
                .divide(entry, 0, RoundingMode.CEILING).subtract(fee);
        BigDecimal tp1 = BigDecimal.valueOf(1000).multiply(take_porfit_1.subtract(entry))
                .divide(entry, 0, RoundingMode.CEILING).subtract(fee);
        BigDecimal tp2 = BigDecimal.valueOf(1000).multiply(take_porfit_2.subtract(entry))
                .divide(entry, 0, RoundingMode.CEILING).subtract(fee);

        msg += "E: " + Utils.removeLastZero(entry.toString()) + "$" + Utils.new_line_from_service;

        msg += "SL: " + Utils.removeLastZero(stop_loss) + "(" + Utils.toPercent(stop_loss, entry) + "%) 1000$/" + loss
                + "$";
        msg += Utils.new_line_from_service;

        msg += "L: " + Utils.removeLastZero(dto.getLow_price_h()) + "(" + Utils.toPercent(dto.getLow_price_h(), entry)
                + "%)";
        msg += Utils.new_line_from_service;

        msg += "TP1: " + Utils.removeLastZero(take_porfit_1) + "(" + Utils.toPercent(take_porfit_1, entry) + "%) 1000$/"
                + tp1 + "$";
        msg += Utils.new_line_from_service;

        msg += "TP2: " + Utils.removeLastZero(take_porfit_2) + "(" + Utils.toPercent(take_porfit_2, entry) + "%) 1000$/"
                + tp2 + "$";

        return msg;
    }

    public static String getMsgShort(BigDecimal entry, BtcFuturesResponse dto) {
        String msg = "";
        BigDecimal stop_loss = Utils.getStopLossForShort(dto.getHight_price_h(), dto.getClose_candle_h());

        BigDecimal candle_height = dto.getClose_candle_h().subtract(dto.getOpen_candle_h());
        BigDecimal mid_candle = candle_height.divide(BigDecimal.valueOf(2), 0, RoundingMode.CEILING);
        BigDecimal take_porfit_1 = dto.getOpen_candle_h().add(mid_candle);
        BigDecimal take_porfit_2 = dto.getOpen_candle_h().add(BigDecimal.valueOf(10));

        BigDecimal fee = BigDecimal.valueOf(2);
        BigDecimal loss = BigDecimal.valueOf(1000).multiply(entry.subtract(stop_loss))
                .divide(entry, 0, RoundingMode.CEILING).subtract(fee);
        BigDecimal tp1 = BigDecimal.valueOf(1000).multiply(entry.subtract(take_porfit_1))
                .divide(entry, 0, RoundingMode.CEILING).subtract(fee);
        BigDecimal tp2 = BigDecimal.valueOf(1000).multiply(entry.subtract(take_porfit_2))
                .divide(entry, 0, RoundingMode.CEILING).subtract(fee);

        msg += "E: " + Utils.removeLastZero(entry.toString()) + "$" + Utils.new_line_from_service;

        msg += "SL: " + Utils.removeLastZero(stop_loss) + "(" + Utils.toPercent(entry, stop_loss) + "%) 1000$/" + loss
                + "$";

        msg += Utils.new_line_from_service;

        msg += "H: " + dto.getHight_price_h() + "(" + Utils.toPercent(entry, dto.getHight_price_h()) + "%)";

        msg += Utils.new_line_from_service;

        msg += "TP1: " + Utils.removeLastZero(take_porfit_1) + "(" + Utils.toPercent(entry, take_porfit_1) + "%) 1000$/"
                + tp1 + "$";

        msg += Utils.new_line_from_service;

        msg += "TP2: " + Utils.removeLastZero(take_porfit_2) + "(" + Utils.toPercent(entry, take_porfit_2) + "%) 1000$/"
                + tp2 + "$";

        return msg;
    }

    public static FundingResponse loadFundingRate(String symbol) {
        FundingResponse dto = new FundingResponse();
        int limit = 4;
        BigDecimal high = BigDecimal.valueOf(-100);
        BigDecimal low = BigDecimal.valueOf(100);

        // https://www.binance.com/fapi/v1/marketKlines?interval=15m&limit=4&symbol=pBTCUSDT
        String url = "https://www.binance.com/fapi/v1/marketKlines?interval=15m&limit=" + limit + "&symbol=p" + symbol
                + "USDT";
        List<Object> funding_rate_objs = Utils.getBinanceData(url, limit);
        if (CollectionUtils.isEmpty(funding_rate_objs)) {
            dto.setHigh(high);
            dto.setLow(low);
            dto.setAvg_high(high);
            dto.setAvg_low(low);

            return dto;
        }

        BigDecimal total_high = BigDecimal.ZERO;
        BigDecimal total_low = BigDecimal.ZERO;
        for (int index = 0; index < funding_rate_objs.size(); index++) {
            Object obj = funding_rate_objs.get(index);

            @SuppressWarnings("unchecked")
            List<Object> arr_ = (List<Object>) obj;
            if (CollectionUtils.isEmpty(arr_) || arr_.size() < 4) {
                continue;
            }
            // BigDecimal open = Utils.getBigDecimal(arr_.get(1));
            BigDecimal tmp_high = Utils.getBigDecimal(arr_.get(2)).multiply(BigDecimal.valueOf(100));
            BigDecimal tmp_low = Utils.getBigDecimal(arr_.get(3)).multiply(BigDecimal.valueOf(100));
            // BigDecimal close = Utils.getBigDecimal(arr_.get(4));

            if (tmp_high.compareTo(high) > 0) {
                high = tmp_high;
            }

            if (tmp_low.compareTo(low) < 0) {
                low = tmp_low;
            }

            if (index < limit) {
                total_high = total_high.add(tmp_high);
                total_low = total_low.add(tmp_low);
            }
        }

        BigDecimal avg_high = total_high.divide(BigDecimal.valueOf(limit - 1), 5, RoundingMode.CEILING);
        BigDecimal avg_low = total_low.divide(BigDecimal.valueOf(limit - 1), 5, RoundingMode.CEILING);

        dto.setHigh(high);
        dto.setLow(low);
        dto.setAvg_high(avg_high);
        dto.setAvg_low(avg_low);

        return dto;
    }
}
