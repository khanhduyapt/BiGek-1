package bsc_scan_btc_futures.service.impl;

import java.io.FileWriter;
import java.io.IOException;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Calendar;
import java.util.Collection;
import java.util.List;
import java.util.Objects;

import javax.persistence.EntityManager;
import javax.persistence.PersistenceContext;
import javax.persistence.Query;
import javax.transaction.Transactional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.util.CollectionUtils;
import org.springframework.web.client.RestTemplate;

import bsc_scan_btc_futures.entity.BtcFutures;
import bsc_scan_btc_futures.entity.DepthAsks;
import bsc_scan_btc_futures.entity.DepthBids;
import bsc_scan_btc_futures.entity.DepthKey;
import bsc_scan_btc_futures.repository.BtcFuturesRepository;
import bsc_scan_btc_futures.repository.DepthAsksRepository;
import bsc_scan_btc_futures.repository.DepthBidsRepository;
import bsc_scan_btc_futures.service.BinanceService;
import bsc_scan_btc_futures.utils.Utils;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import response.BtcFuturesResponse;
import response.DepthResponse;

@Service
@Slf4j
@RequiredArgsConstructor
public class BinanceServiceImpl implements BinanceService {

    @PersistenceContext
    private final EntityManager entityManager;

    @Autowired
    private BtcFuturesRepository btcFuturesRepository;

    @Autowired
    private DepthBidsRepository depthBidsRepository;

    @Autowired
    private DepthAsksRepository depthAsksRepository;

    private static final String TIME_1m = "1m";
    private static final String TIME_5m = "5m";

    @Transactional
    private List<BtcFutures> loadData(int limit, String time, boolean allowSaveData) {
        try {

            saveDepthData();

            String url_price = "https://api.binance.com/api/v3/ticker/price?symbol=BTCUSDT";
            BigDecimal price_at_binance = getBinancePrice(url_price);
            String url = "https://api.binance.com/api/v3/klines?symbol=BTCUSDT&interval=" + time + "&limit=" + limit;
            List<Object> list = getBinanceData(url, limit);

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

            if (allowSaveData) {
                btcFuturesRepository.deleteAll();
                btcFuturesRepository.saveAll(list_entity);
            }

            return list_entity;
        } catch (

        Exception e) {
            e.printStackTrace();
        }

        return new ArrayList<BtcFutures>();
    }

    @Override
    @Transactional
    public String getList() {
        try {
            loadData(30, TIME_1m, true);

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

                    return processLong(list_db, dto);
                }
            }
        } catch (Exception e) {
            return e.getMessage();
        }

        return "";
    }

    private String processLong(List<BtcFutures> list_db, BtcFuturesResponse dto) {
        String time = Utils.convertDateToString("HH:mm", Calendar.getInstance().getTime());

        BigDecimal SL_percent = BigDecimal.valueOf(0.9);
        // --------------------------------------
        List<String> long_list = new ArrayList<String>();
        for (int i = 0; i < 3; i++) {

            BigDecimal entry_price = dto.getLow_price();
            String header = ".Low    :  ";
            if (i == 0) {
                header = ".Now    :  ";
                entry_price = list_db.get(0).getCurrPrice();
            } else if (i == 1) {
                header = ".Candle :  ";
                entry_price = dto.getMin_candle();
            }

            String TP_percent = Utils.toPercent(dto.getMax_candle(), entry_price, 2);

            BigDecimal TP_price = dto.getMax_candle().multiply(BigDecimal.valueOf(0.9995));

            String msg_long = Utils.removeLastZero(entry_price.toString()) + "$";
            msg_long += "  TP: " + Utils.removeLastZero(TP_price.toString()) + " (" + TP_percent + "%)";

            BigDecimal SL_price = entry_price
                    .multiply(BigDecimal.valueOf(100).subtract(SL_percent))
                    .divide(BigDecimal.valueOf(100), 1, RoundingMode.CEILING);

            msg_long += "  SL: " + Utils.removeLastZero(SL_price.toString()) + " (-" + SL_percent + "%)";

            long_list.add((i + 1) + header + msg_long);
        }

        // --------------------------------------
        List<String> short_list = new ArrayList<String>();
        for (int i = 0; i < 3; i++) {

            BigDecimal entry_price;
            String header = ".Hight  :  ";
            if (i == 0) {
                header = ".Now    :  ";
                entry_price = list_db.get(0).getCurrPrice();
            } else if (i == 1) {
                header = ".Candle :  ";
                entry_price = dto.getMax_candle().multiply(BigDecimal.valueOf(1.0005));
            } else {
                entry_price = dto.getHight_price();
            }

            String TP_percent = Utils.toPercent(entry_price, dto.getMin_candle(), 2);

            BigDecimal TP_price = dto.getMin_candle();

            String str_short = Utils.removeLastZero(entry_price.toString()) + "$";
            str_short += "  TP: " + Utils.removeLastZero(TP_price.toString()) + " (" + TP_percent + "%)";

            BigDecimal SL_price = entry_price
                    .multiply(BigDecimal.valueOf(100).add(SL_percent))
                    .divide(BigDecimal.valueOf(100), 1, RoundingMode.CEILING);
            str_short += "  SL: " + Utils.removeLastZero(SL_price.toString()) + " (-" + SL_percent + "%)";

            short_list.add((i + 1) + header + str_short);
        }

        // --------------------------------------
        List<BtcFutures> list_candle_5m = loadData(6, TIME_5m, false);

        List<String> results = new ArrayList<String>();
        String btc = " Btc:  " + Utils.removeLastZero(list_db.get(0).getCurrPrice().toString());
        results.add("(" + time + ")" + btc + "   30m");

        if (isUptrend(list_candle_5m)) {
            results.add("Chart 5m: Uptrend");
        } else {
            results.add("");
        }

        results.add("--------------------------------------------------------");
        results.add("Long");
        for (int i = 0; i < long_list.size(); i++) {
            results.add(long_list.get(i));
        }
        results.add("--------------------------------------------------------");
        results.add("Short");
        for (int i = 0; i < short_list.size(); i++) {
            results.add(short_list.get(i));
        }

        writeToFile(results);

        return btc;
    }

    private boolean isUptrend(List<BtcFutures> list) {
        BtcFutures item00 = list.get(0);
        //BtcFutures item01 = list.get(1);
        BtcFutures item99 = list.get(list.size() - 1);

        if (Utils.isAGreaterB(item00.getLow_price(), item99.getHight_price())) {
            return true;
        }

        if (item00.isUptrend() && Utils.isAGreaterB(item00.getPrice_open_candle(), item99.getPrice_close_candle()) &&
                Utils.isAGreaterB(item00.getPrice_open_candle(), item99.getPrice_open_candle())) {
            return true;
        }

        if (item00.isUptrend() && (Utils.isAGreaterB(item00.getPrice_open_candle(), item99.getPrice_close_candle()) ||
                Utils.isAGreaterB(item00.getPrice_open_candle(), item99.getPrice_open_candle()))) {
            return true;
        }

        return item00.isUptrend();
    }

    public void writeToFile(List<String> list) {
        try {
            FileWriter myWriter = new FileWriter("Btc_Long_Short.txt");
            for (String text : list) {
                myWriter.write(text + System.lineSeparator());
            }

            myWriter.write(System.lineSeparator());
            myWriter.write(System.lineSeparator());
            myWriter.write(System.lineSeparator());
            List<DepthResponse> depth_list = getDepthData();
            int size = depth_list.size();
            for (int index = 0; index < size; index++) {
                DepthResponse dto = depth_list.get(index);

                if (index == size / 2) {
                    myWriter.write(System.lineSeparator());
                }

                myWriter.write(dto.toString(7) + System.lineSeparator());

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

    @SuppressWarnings({ "unchecked" })
    private void saveDepthData() {
        try {
            String url = "https://api.binance.com/api/v3/depth?limit=5000&symbol=BTCUSDT";

            RestTemplate restTemplate = new RestTemplate();
            Object result = restTemplate.getForObject(url, Object.class);

            Object obj_bids = Utils.getLinkedHashMapValue(result, Arrays.asList("bids"));
            Object obj_asks = Utils.getLinkedHashMapValue(result, Arrays.asList("asks"));

            if (obj_bids instanceof Collection) {
                List<Object> obj_bids2 = new ArrayList<>((Collection<Object>) obj_bids);

                List<DepthBids> bids_save_list = new ArrayList<DepthBids>();
                for (Object obj : obj_bids2) {
                    List<Double> bids = new ArrayList<>((Collection<Double>) obj);
                    BigDecimal price = Utils.getBigDecimalValue(String.valueOf(bids.get(0)));
                    BigDecimal qty = Utils.getBigDecimalValue(String.valueOf(bids.get(1)));

                    DepthBids entity = new DepthBids();
                    DepthKey key = new DepthKey();
                    key.setGeckoId("bitcoin");
                    key.setSymbol("BTC");
                    key.setPrice(price);
                    entity.setId(key);
                    entity.setQty(qty);

                    bids_save_list.add(entity);
                }
                depthBidsRepository.deleteAll();
                depthBidsRepository.saveAll(bids_save_list);
            }

            if (obj_asks instanceof Collection) {
                List<Object> obj_asks2 = new ArrayList<>((Collection<Object>) obj_asks);

                List<DepthAsks> asks_save_list = new ArrayList<DepthAsks>();
                for (Object obj : obj_asks2) {
                    List<Double> asks = new ArrayList<>((Collection<Double>) obj);
                    BigDecimal price = Utils.getBigDecimalValue(String.valueOf(asks.get(0)));
                    BigDecimal qty = Utils.getBigDecimalValue(String.valueOf(asks.get(1)));

                    DepthAsks entity = new DepthAsks();
                    DepthKey key = new DepthKey();
                    key.setGeckoId("bitcoin");
                    key.setSymbol("BTC");
                    key.setPrice(price);
                    entity.setId(key);
                    entity.setQty(qty);

                    asks_save_list.add(entity);
                }
                depthAsksRepository.deleteAll();
                depthAsksRepository.saveAll(asks_save_list);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private List<DepthResponse> getDepthData() {
        try {
            String sql = "SELECT                                                                                    \n"
                    + "    gecko_id,                                                                                \n"
                    + "    symbol,                                                                                  \n"
                    + "    price,                                                                                   \n"
                    + "    qty,                                                                                     \n"
                    + "    val_million_dolas                                                                        \n"
                    + "FROM                                                                                         \n"
                    + "    view_btc_depth_resistant ";

            Query query = entityManager.createNativeQuery(sql, "DepthResponse");

            @SuppressWarnings("unchecked")
            List<DepthResponse> list = query.getResultList();
            if (!CollectionUtils.isEmpty(list)) {
                return list;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return new ArrayList<DepthResponse>();
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
