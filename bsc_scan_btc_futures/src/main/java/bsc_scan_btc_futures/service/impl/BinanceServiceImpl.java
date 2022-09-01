package bsc_scan_btc_futures.service.impl;

import java.math.BigDecimal;
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
import response.BtcFuturesResponse;
import response.DepthResponse;

@Service
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

    private String pre_time_of_btc = "";
    private static final String TIME_15m = "15m";
    private static final int LIMIT_DATA = 30;

    @Override
    @Transactional
    public String doProcess() {

        BigDecimal price_at_binance = loadData();

        saveDepthData();

        monitorBtcPrice(price_at_binance);

        return Utils.removeLastZero(String.valueOf(price_at_binance));
    }

    @Override
    @Transactional
    public List<List<DepthResponse>> getListDepthData() {
        doProcess();

        List<List<DepthResponse>> result = new ArrayList<List<DepthResponse>>();

        List<DepthResponse> list_bids = getDepthDataBtc(2);
        List<DepthResponse> list_asks = getDepthDataBtc(3);

        result.add(list_bids);
        result.add(list_asks);
        return result;
    }

    @Transactional
    private BigDecimal loadData() {
        try {
            String url_price = "https://api.binance.com/api/v3/ticker/price?symbol=BTCUSDT";
            BigDecimal price_at_binance = getBinancePrice(url_price);

            String url = "https://api.binance.com/api/v3/klines?symbol=BTCUSDT&interval=" + TIME_15m + "&limit="
                    + LIMIT_DATA;

            List<Object> list = getBinanceData(url, LIMIT_DATA);

            List<BtcFutures> list_entity = new ArrayList<BtcFutures>();
            int id = 0;

            for (int idx = LIMIT_DATA - 1; idx >= 0; idx--) {
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

            btcFuturesRepository.deleteAll();
            btcFuturesRepository.saveAll(list_entity);

            return price_at_binance;
        } catch (

        Exception e) {
            e.printStackTrace();
        }

        return BigDecimal.ZERO;
    }

    @SuppressWarnings({ "unchecked" })
    @Transactional
    private void saveDepthData() {

        String gecko_id = "bitcoin";
        String symbol = "BTC";

        try {
            List<String> keyList = new ArrayList<String>();

            List<DepthBids> depthBids = depthBidsRepository.findAll();
            if (!CollectionUtils.isEmpty(depthBids)) {
                depthBidsRepository.deleteAll(depthBids);
            }

            List<DepthAsks> depthAsks = depthAsksRepository.findAll();
            if (!CollectionUtils.isEmpty(depthAsks)) {
                depthAsksRepository.deleteAll(depthAsks);
            }

            BigDecimal MIL_VOL = BigDecimal.valueOf(1000);
            if ("BTC".equals(symbol.toUpperCase())) {
                MIL_VOL = BigDecimal.valueOf(10000);
            }

            String url = "https://api.binance.com/api/v3/depth?limit=5000&symbol=" + symbol.toUpperCase() + "USDT";

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

                    BigDecimal volume = price.multiply(qty);
                    if (volume.compareTo(MIL_VOL) < 0) {
                        continue;
                    }

                    DepthBids entity = new DepthBids();
                    DepthKey key = new DepthKey();
                    key.setGeckoId(gecko_id);
                    key.setSymbol(symbol);
                    key.setPrice(price);
                    entity.setId(key);
                    entity.setQty(qty);

                    String str_key = gecko_id + "_" + symbol + "_" + String.valueOf(price);
                    if (!keyList.contains(str_key)) {
                        bids_save_list.add(entity);
                        keyList.add(str_key);
                    }

                }

                if (!CollectionUtils.isEmpty(bids_save_list)) {
                    depthBidsRepository.saveAll(bids_save_list);
                }
            }

            if (obj_asks instanceof Collection) {
                List<Object> obj_asks2 = new ArrayList<>((Collection<Object>) obj_asks);

                List<DepthAsks> asks_save_list = new ArrayList<DepthAsks>();
                for (Object obj : obj_asks2) {
                    List<Double> asks = new ArrayList<>((Collection<Double>) obj);
                    BigDecimal price = Utils.getBigDecimalValue(String.valueOf(asks.get(0)));
                    BigDecimal qty = Utils.getBigDecimalValue(String.valueOf(asks.get(1)));

                    BigDecimal volume = price.multiply(qty);
                    if (volume.compareTo(MIL_VOL) < 0) {
                        continue;
                    }

                    DepthAsks entity = new DepthAsks();
                    DepthKey key = new DepthKey();
                    key.setGeckoId(gecko_id);
                    key.setSymbol(symbol);
                    key.setPrice(price);
                    entity.setId(key);
                    entity.setQty(qty);

                    String str_key = gecko_id + "_" + symbol + "_" + String.valueOf(price);
                    if (!keyList.contains(str_key)) {
                        asks_save_list.add(entity);
                        keyList.add(str_key);
                    }
                }

                if (!CollectionUtils.isEmpty(asks_save_list)) {
                    depthAsksRepository.saveAll(asks_save_list);
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    // 1: all, 2: bids, 3: asks
    private List<DepthResponse> getDepthDataBtc(int type) {
        try {
            if (depthBidsRepository.count() < 1) {
                return new ArrayList<DepthResponse>();
            }

            String view = "view_btc_depth";
            String orderby = "price ASC ";
            if (type == 2) {
                view = "view_btc_depth_bids";
                orderby = "price DESC ";
            }
            if (type == 3) {
                view = "view_btc_depth_asks";
                orderby = "price ASC ";
            }

            String sql = "SELECT                                                                                  \n"
                    + "    gecko_id,                                                                              \n"
                    + "    symbol,                                                                                \n"
                    + "    price,                                                                                 \n"
                    + "    qty,                                                                                   \n"
                    + "    val_million_dolas                                                                      \n"
                    + "FROM " + view + "                                                                          \n"
                    + "WHERE val_million_dolas > 0                                                                \n"
                    + "ORDER BY " + orderby;

            Query query = entityManager.createNativeQuery(sql, "DepthResponse");

            @SuppressWarnings("unchecked")
            List<DepthResponse> list = query.getResultList();

            return list;

        } catch (Exception e) {
            e.printStackTrace();
        }

        return new ArrayList<DepthResponse>();
    }

    @Transactional
    public String getTextDepthData(BigDecimal price_now) {

        String result = "";

        List<DepthResponse> list = getDepthDataBtc(1);

        if (!CollectionUtils.isEmpty(list)) {
            Boolean isAddPriceNow = false;

            for (DepthResponse dto : list) {

                if (!isAddPriceNow) {
                    if (dto.getPrice().compareTo(price_now) > 0) {
                        result += "< NOW >";
                        isAddPriceNow = true;
                    }
                }

                result += dto.toStringMillion(price_now);
            }
        }

        return result.trim();
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

    private BigDecimal getBinancePrice(String url) {
        try {
            RestTemplate restTemplate = new RestTemplate();
            Object result = restTemplate.getForObject(url, Object.class);

            return Utils.getBigDecimal(Utils.getLinkedHashMapValue(result, Arrays.asList("price")));
        } catch (Exception e) {
            return BigDecimal.ZERO;
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

    private void monitorBtcPrice(BigDecimal price_at_binance) {
        try {
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
            if (CollectionUtils.isEmpty(vol_list)) {
                return;
            }

            BtcFuturesResponse dto = vol_list.get(0);
            String msg = "BTC: " + Utils.removeLastZero(String.valueOf(price_at_binance)) + Utils.new_line_from_service;
            msg += "Buy:" + Utils.removeLastZero(String.valueOf(dto.getLow_price()));
            msg += "~" + Utils.removeLastZero(String.valueOf(dto.getMin_candle()));
            msg += " Sell:" + Utils.removeLastZero(String.valueOf(dto.getMax_candle()));
            msg += "~" + Utils.removeLastZero(String.valueOf(dto.getHight_price()));

            msg += Utils.new_line_from_service + Utils.new_line_from_service;
            msg += getTextDepthData(price_at_binance).replace(" ", "");

            String curr_time_of_btc = Utils.convertDateToString("MMdd_HH", Calendar.getInstance().getTime());
            curr_time_of_btc = curr_time_of_btc.substring(0, curr_time_of_btc.length() - 1);

            if (!Objects.equals(curr_time_of_btc, pre_time_of_btc)) {
                // (Good time to buy)
                if (Utils.isGoodPriceForLong(price_at_binance, dto.getLow_price(), dto.getHight_price())) {
                    Utils.sendToMyTelegram("(LONG)..." + msg);
                    pre_time_of_btc = curr_time_of_btc;
                } else if (Utils.isGoodPriceForShort(price_at_binance, dto.getLow_price(), dto.getHight_price())) {
                    Utils.sendToMyTelegram("(SHORT)..." + msg);
                    pre_time_of_btc = curr_time_of_btc;
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
    }

}
