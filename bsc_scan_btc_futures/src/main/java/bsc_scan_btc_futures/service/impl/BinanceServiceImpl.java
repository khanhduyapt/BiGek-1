package bsc_scan_btc_futures.service.impl;

import java.io.FileWriter;
import java.io.IOException;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Calendar;
import java.util.Hashtable;
import java.util.List;
import java.util.Objects;
import java.util.stream.Collector;
import java.util.stream.Collectors;

import javax.persistence.EntityManager;
import javax.persistence.PersistenceContext;
import javax.persistence.Query;
import javax.transaction.Transactional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.util.CollectionUtils;
import org.springframework.web.client.RestTemplate;

import bsc_scan_btc_futures.entity.BtcFutures;
import bsc_scan_btc_futures.repository.BtcFuturesRepository;
import bsc_scan_btc_futures.service.BinanceService;
import bsc_scan_btc_futures.utils.Utils;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import response.BtcFuturesResponse;

@Service
@Slf4j
@RequiredArgsConstructor
public class BinanceServiceImpl implements BinanceService {

    @PersistenceContext
    private final EntityManager entityManager;

    @Autowired
    private BtcFuturesRepository btcFuturesRepository;

    private Hashtable<String, String> msg_dict = new Hashtable<String, String>();

    @Transactional
    private void loadData() {
        try {

            String url_price = "https://api.binance.com/api/v3/ticker/price?symbol=BTCUSDT";
            BigDecimal price_at_binance = getBinancePrice(url_price);

            // 30 candle
            final Integer limit = 16;

            // 5m: 30 candle = 1.5h
            // String url_5m =
            // "https://api.binance.com/api/v3/klines?symbol=BTCUSDT&interval=5m&limit=" +
            // limit;
            // List<Object> list = getBinanceData(url_5m, limit);

            // 30 minutes
            String url_1m = "https://api.binance.com/api/v3/klines?symbol=BTCUSDT&interval=1m&limit=" + limit;
            List<Object> list = getBinanceData(url_1m, limit);

            List<BtcFutures> list_entity = new ArrayList<BtcFutures>();
            int id = 0;

            for (int idx = limit - 1; idx >= 0; idx--) {
                Object obj_usdt = list.get(idx);

                @SuppressWarnings("unchecked")
                List<Object> arr_usdt = (List<Object>) obj_usdt;

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
                day.setId(strid);

                if (idx == limit - 1) {
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

            btcFuturesRepository.deleteAll();
            btcFuturesRepository.saveAll(list_entity);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    @Override
    @Transactional
    public void getList() {
        try {
            loadData();

            String sql = "SELECT                                                                                    \n"
                    + "    long_sl,                                                                                 \n"
                    + "    long_tp,                                                                                 \n"
                    + "    low_price,                                                                               \n"
                    + "    min_candle,                                                                              \n"
                    + "    max_candle,                                                                              \n"
                    + "    hight_price,                                                                             \n"
                    + "    short_sl,                                                                                \n"
                    + "    short_tp                                                                                 \n"
                    + "FROM                                                                                         \n"
                    + "    view_btc_futures_result";

            Query query = entityManager.createNativeQuery(sql, "BtcFuturesResponse");

            @SuppressWarnings("unchecked")
            List<BtcFuturesResponse> vol_list = query.getResultList();
            if (!CollectionUtils.isEmpty(vol_list)) {

                List<BtcFutures> list_db = btcFuturesRepository.findAllByOrderByIdAsc();

                if (!CollectionUtils.isEmpty(list_db)) {
                    BtcFuturesResponse dto = vol_list.get(0);

                    processLong(list_db, dto);
                }
            }
        } catch (Exception e) {
        }

    }

    private void processLong(List<BtcFutures> list_db, BtcFuturesResponse dto) {
        String time = Utils.convertDateToString("HH:mm", Calendar.getInstance().getTime());

        BigDecimal candle_height = dto.getMax_candle().subtract(dto.getMin_candle());

        String TP1_percent = Utils.toPercent(
                dto.getMin_candle().add(candle_height.divide(BigDecimal.valueOf(2), 2, RoundingMode.CEILING)),
                dto.getMin_candle(), 2);

        List<String> long_list = new ArrayList<String>();

        String TP2_percent = Utils.toPercent(dto.getMax_candle(), dto.getMin_candle(), 2);

        BigDecimal entry_price = list_db.get(0).getCurrPrice().subtract(BigDecimal.valueOf(18));

        BigDecimal TP1_price = entry_price.multiply(BigDecimal.valueOf(100).add(Utils.getBigDecimalValue(TP1_percent)))
                .divide(BigDecimal.valueOf(100), 1, RoundingMode.CEILING);

        BigDecimal TP2_price = entry_price.multiply(BigDecimal.valueOf(100).add(Utils.getBigDecimalValue(TP2_percent)))
                .divide(BigDecimal.valueOf(100), 1, RoundingMode.CEILING);

        String msg_long_min = Utils.removeLastZero(entry_price.toString()) + "$";
        msg_long_min += "\t TP1: " + Utils.removeLastZero(TP1_price.toString()) + " (" + TP1_percent + "%)";
        msg_long_min += "  TP2: " + Utils.removeLastZero(TP2_price.toString()) + " (" + TP2_percent + "%)";

        BigDecimal SL_price = entry_price
                .multiply(BigDecimal.valueOf(100).subtract(Utils.getBigDecimalValue(TP2_percent)))
                .divide(BigDecimal.valueOf(100), 1, RoundingMode.CEILING);
        msg_long_min += "  SL: " + Utils.removeLastZero(SL_price.toString()) + " (-" + TP2_percent + "%)";

        msg_long_min += " <- Current Price";
        long_list.add(msg_long_min);

        // --------------------------------------

        for (int i = 0; i < 5; i++) {
            BigDecimal range = candle_height.multiply(BigDecimal.valueOf(i)).divide(BigDecimal.valueOf(5), 0,
                    RoundingMode.CEILING);

            entry_price = dto.getMin_candle().add(range);

            TP1_price = entry_price.multiply(BigDecimal.valueOf(100).add(Utils.getBigDecimalValue(TP1_percent)))
                    .divide(BigDecimal.valueOf(100), 1, RoundingMode.CEILING);

            TP2_price = dto.getMax_candle().add(range);

            msg_long_min = Utils.removeLastZero(entry_price.toString()) + "$";
            msg_long_min += "\t TP1: " + Utils.removeLastZero(TP1_price.toString()) + " (" + TP1_percent + "%)";
            msg_long_min += "  TP2: " + Utils.removeLastZero(TP2_price.toString()) + " (" + TP2_percent + "%)";

            SL_price = entry_price.multiply(BigDecimal.valueOf(100).subtract(Utils.getBigDecimalValue(TP2_percent)))
                    .divide(BigDecimal.valueOf(100), 1, RoundingMode.CEILING);
            msg_long_min += "  SL: " + Utils.removeLastZero(SL_price.toString()) + " (-" + TP2_percent + "%)";

            long_list.add(msg_long_min);
        }
        long_list = long_list.stream().sorted().collect(Collectors.toList());

        // --------------------------------------
        String str_short = "Short:   ";
        entry_price = list_db.get(0).getCurrPrice().subtract(BigDecimal.valueOf(18));

        TP1_price = entry_price.multiply(BigDecimal.valueOf(100).subtract(Utils.getBigDecimalValue(TP1_percent)))
                .divide(BigDecimal.valueOf(100), 1, RoundingMode.CEILING);

        TP2_price = entry_price.multiply(BigDecimal.valueOf(100).subtract(Utils.getBigDecimalValue(TP2_percent)))
                .divide(BigDecimal.valueOf(100), 1, RoundingMode.CEILING);

        str_short += Utils.removeLastZero(entry_price.toString()) + "$";
        str_short += "\t TP1: " + Utils.removeLastZero(TP1_price.toString()) + " (" + TP1_percent + "%)";
        str_short += "  TP2: " + Utils.removeLastZero(TP2_price.toString()) + " (" + TP2_percent + "%)";

        SL_price = entry_price.multiply(BigDecimal.valueOf(100).add(Utils.getBigDecimalValue(TP2_percent)))
                .divide(BigDecimal.valueOf(100), 1, RoundingMode.CEILING);
        str_short += "  SL: " + Utils.removeLastZero(SL_price.toString()) + " (-" + TP2_percent + "%)";

        // --------------------------------------
        List<String> results = new ArrayList<String>();
        results.add(time + " Long:");
        for (int i = 0; i < long_list.size(); i++) {
            results.add("Entry " + (i + 1) + ": " + long_list.get(i));
        }
        results.add("");
        results.add(str_short);

        writeToFile(results);
    }

    public void writeToFile(List<String> list) {
        try {
            FileWriter myWriter = new FileWriter("Btc_Long_Short.txt");
            for (String text : list) {
                myWriter.write(text + System.lineSeparator());
            }
            myWriter.close();
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    private BigDecimal getBinancePrice(String url) {
        try {
            RestTemplate restTemplate = new RestTemplate();
            Object result = restTemplate.getForObject(url, Object.class);

            return Utils.getBigDecimal(Utils.getLinkedHashMapValue(result, Arrays.asList("price")));
        } catch (Exception e) {
            return BigDecimal.ZERO;
        }

    }

    private List<Object> getBinanceData(String url, int limit) {
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

    public boolean hasResistance(List<BtcFutures> list_db) {
        try {
            int count = 0;
            for (int index = 1; index < 5; index++) {

                BtcFutures dto = list_db.get(index);

                if (dto.isUptrend()) {
                    count += 1;
                }
            }

            if (count >= 2) {
                return has15MinutesCandleUp();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }

    public boolean has15MinutesCandleUp() {
        try {
            final Integer limit = 4;
            String url_usdt = "https://api.binance.com/api/v3/klines?symbol=BTCUSDT&interval=15m&limit="
                    + String.valueOf(limit);

            List<Object> result_usdt = getBinanceData(url_usdt, limit);
            int count = 0;
            for (int idx = limit - 1; idx >= 0; idx--) {
                Object obj_usdt = result_usdt.get(idx);

                @SuppressWarnings("unchecked")
                List<Object> arr_usdt = (List<Object>) obj_usdt;

                BigDecimal price_open_candle = Utils.getBigDecimal(arr_usdt.get(1));
                BigDecimal price_close_candle = Utils.getBigDecimal(arr_usdt.get(4));
                String open_time = arr_usdt.get(0).toString();

                if (Objects.equals("0", open_time)) {
                    return false;
                }

                if (price_open_candle.compareTo(price_close_candle) < 0) {
                    count += 1;
                    if (idx == limit - 1) {
                        count += 1;
                    }
                }
            }

            if (count >= 2) {
                return true;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }

}
