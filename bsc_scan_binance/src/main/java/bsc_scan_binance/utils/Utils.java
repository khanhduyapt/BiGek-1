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
import org.springframework.web.servlet.LocaleResolver;

import bsc_scan_binance.entity.PriorityCoin;
import bsc_scan_binance.entity.PriorityCoinHistory;
import bsc_scan_binance.response.CandidateTokenCssResponse;
import bsc_scan_binance.response.OrdersProfitResponse;

public class Utils {
    public static String chatId = "5099224587";

    public static String toString(PriorityCoin tele) {
        return tele.getSymbol() + ":" + tele.getName() + " P:" + tele.getCurrent_price() + "$ Target:"
                + tele.getTarget_percent() + " ema:" + tele.getEma();
    }

    public static String addGoodCoin(PriorityCoinHistory tele) {
        return String.format("[%s]  [%s] [Count: %s]", tele.getSymbol(), tele.getName(),
                getIntValue(tele.getCount_notify()));
    }

    public static String createMsg(OrdersProfitResponse dto) {
        String result = String.format("[%s]_[%s]", dto.getSymbol(), dto.getName()) + "%0A"
                + "Pmua: " + dto.getOrder_price().toString() + "$, "
                + "T: " + Utils.removeLastZero(dto.getAmount().toString()) + "$%0A"
                + "Pnow: " + dto.getPrice_at_binance().toString() + "$, "
                + "Profit: " + Utils.removeLastZero(dto.getTp_amount().toString())
                + "$ (" + dto.getTp_percent() + "%)%0A"
                + "Target: " + dto.getTarget().replace(" L:", "$%0AL:");

        return result;
    }

    public static String createMsg(CandidateTokenCssResponse css) {
        return Utils.convertDateToString("yyyy-MM-dd hh:mm", new Date()) + "%0A"
                + "BTC:" + css.getCurrent_price() + "$" + "%0A"
                + css.getLow_to_hight_price();
    }

    public static String createMsg(PriorityCoin dto) {
        String result = String.format("[%s]_[%s]", dto.getSymbol(), dto.getName()) + "\n"
                + "Price: " + dto.getCurrent_price().toString() + "$, "
                + "Target: " + dto.getTarget_price() + "$=(" + dto.getTarget_percent() + "%)\n"
                + dto.getOco_hight() + "\n"
                + dto.getNote().replace("~", "\n");
        return result;
    }

    public static void sendToTelegram(String text) {
        String urlString = "https://api.telegram.org/bot%s/sendMessage?chat_id=%s&text=";

        //Add Telegram token
        String apiToken = "5349894943:AAE_0-ZnbikN9m1aRoyCI2nkT2vgLnFBA-8";

        urlString = String.format(urlString, apiToken, chatId) + text;

        try {
            URL url = new URL(urlString);
            URLConnection conn = url.openConnection();
            @SuppressWarnings("unused")
            InputStream is = new BufferedInputStream(conn.getInputStream());
        } catch (IOException e) {
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
    }

    public static String removeLastZero(String value) {
        if ((value == null) || (Objects.equals("", value))) {
            return "";
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

    public static String toPercent(BigDecimal value, BigDecimal compareToValue) {
        return toPercent(value, compareToValue, 0);
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

    public static BigDecimal formatPrice(BigDecimal value, int number) {
        @SuppressWarnings("resource")
        Formatter formatter = new Formatter();
        formatter.format("%." + String.valueOf(number) + "f", value);

        return BigDecimal.valueOf(Double.valueOf(formatter.toString()));
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

}
