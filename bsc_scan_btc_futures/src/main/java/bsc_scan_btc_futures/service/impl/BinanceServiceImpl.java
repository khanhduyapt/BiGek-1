package bsc_scan_btc_futures.service.impl;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Calendar;
import java.util.Hashtable;
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

            //30 candle
            final Integer limit = 10;

            // 5m: 30 candle = 1.5h
            //String url_5m = "https://api.binance.com/api/v3/klines?symbol=BTCUSDT&interval=5m&limit=" + limit;
            //List<Object> list = getBinanceData(url_5m, limit);

            //30 minutes
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
                    processShort(list_db, dto);

                }
            }
        } catch (Exception e) {
        }

    }

    private void processLong(List<BtcFutures> list_db, BtcFuturesResponse dto) {

        BtcFutures pre_00 = list_db.get(0);
        BtcFutures pre_01 = list_db.get(1);
        BtcFutures pre_02 = list_db.get(2);

        boolean isCandidate = pre_00.isUptrend() && !pre_01.isUptrend() && !pre_02.isUptrend();

        if (!isCandidate) {
            isCandidate = pre_00.isUptrend() && !pre_01.isUptrend() && !pre_02.isUptrend();
        }

        if (!isCandidate) {
            isCandidate = pre_00.isUptrend() && pre_01.isUptrend() && !pre_02.isUptrend();
        }

        if (!isCandidate) {
            return;
        }

        String time = "(" + Utils.convertDateToString("HH:mm", Calendar.getInstance().getTime()) + ") ";

        BigDecimal entry_price = pre_00.getCurrPrice();

        BigDecimal take_profit_price = Utils.getGoodPriceForLongTP(entry_price, dto.getMax_candle());

        String TP = Utils.toPercent(take_profit_price, entry_price);

        BigDecimal SL = Utils.getBigDecimal(TP); // Utils.getBigDecimal(TP).divide(BigDecimal.valueOf(2), 1, RoundingMode.CEILING);

        BigDecimal SL_price = entry_price.multiply(BigDecimal.valueOf(100).subtract(SL))
                .divide(BigDecimal.valueOf(100), 1, RoundingMode.CEILING);

        String msg_long = "Long: " + entry_price + "$, TP: " + TP + "%("
                + Utils.removeLastZero(take_profit_price.toString()) + ")" + ", SL: -" + SL + "% ("
                + Utils.removeLastZero(SL_price.toString()) + ")";

        if (Utils.getBigDecimalValue(TP).compareTo(BigDecimal.valueOf(0.1)) > 0) {
            if (!msg_dict.contains(msg_long)) {

                log.info(time + msg_long);

                msg_dict.put(msg_long, msg_long);
            }
        }
    }

    private void processShort(List<BtcFutures> list_db, BtcFuturesResponse dto) {

        BtcFutures pre_00 = list_db.get(0);
        BtcFutures pre_01 = list_db.get(1);
        BtcFutures pre_02 = list_db.get(2);

        boolean isCandidate = !pre_00.isUptrend() && !pre_01.isUptrend() && pre_02.isUptrend();

        if (!isCandidate) {
            isCandidate = !list_db.get(0).isUptrend() && list_db.get(1).isUptrend() && list_db.get(2).isUptrend()
                    && list_db.get(3).isUptrend();
        }

        if (!isCandidate) {
            return;
        }

        String time = "(" + Utils.convertDateToString("HH:mm", Calendar.getInstance().getTime()) + ") ";

        BigDecimal entry_price = dto.getMax_candle();

        BigDecimal take_profit_price = Utils.getGoodPriceForShortTP(dto.getMin_candle(), entry_price);

        String TP = Utils.toPercent(entry_price, take_profit_price);

        BigDecimal SL = Utils.getBigDecimal(TP);//Utils.getBigDecimal(TP).divide(BigDecimal.valueOf(2), 1, RoundingMode.CEILING);

        BigDecimal SL_price = entry_price.multiply(BigDecimal.valueOf(100).add(SL))
                .divide(BigDecimal.valueOf(100), 1, RoundingMode.CEILING);

        String msg_short = "Short: " + entry_price + "$, TP: " + TP + "% ("
                + Utils.removeLastZero(take_profit_price.toString()) + ")" + ", SL: -" + SL + "% ("
                + Utils.removeLastZero(SL_price.toString()) + ")";

        if (Utils.getBigDecimalValue(TP).compareTo(BigDecimal.valueOf(0.3)) > 0) {
            if (!msg_dict.contains(msg_short)) {

                log.info(time + msg_short);

                msg_dict.put(msg_short, msg_short);
            }
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
