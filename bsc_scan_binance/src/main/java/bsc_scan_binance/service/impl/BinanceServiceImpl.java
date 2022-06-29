package bsc_scan_binance.service.impl;

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

import org.modelmapper.ModelMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.util.CollectionUtils;
import org.springframework.web.client.RestTemplate;

import bsc_scan_binance.entity.BinanceVolumnDay;
import bsc_scan_binance.entity.BinanceVolumnDayKey;
import bsc_scan_binance.entity.BinanceVolumnWeek;
import bsc_scan_binance.entity.BinanceVolumnWeekKey;
import bsc_scan_binance.entity.BollArea;
import bsc_scan_binance.entity.BtcVolumeDay;
import bsc_scan_binance.entity.GeckoVolumeUpPre4h;
import bsc_scan_binance.entity.Orders;
import bsc_scan_binance.entity.PriorityCoin;
import bsc_scan_binance.repository.BinanceVolumnDayRepository;
import bsc_scan_binance.repository.BinanceVolumnWeekRepository;
import bsc_scan_binance.repository.BollAreaRepository;
import bsc_scan_binance.repository.BtcVolumeDayRepository;
import bsc_scan_binance.repository.GeckoVolumeUpPre4hRepository;
import bsc_scan_binance.repository.OrdersRepository;
import bsc_scan_binance.repository.PriorityCoinRepository;
import bsc_scan_binance.response.BollAreaResponse;
import bsc_scan_binance.response.CandidateTokenCssResponse;
import bsc_scan_binance.response.CandidateTokenResponse;
import bsc_scan_binance.response.GeckoVolumeUpPre4hResponse;
import bsc_scan_binance.response.OrdersProfitResponse;
import bsc_scan_binance.service.BinanceService;
import bsc_scan_binance.utils.Utils;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Service
@Slf4j
@RequiredArgsConstructor
public class BinanceServiceImpl implements BinanceService {
    @PersistenceContext
    private final EntityManager entityManager;

    @Autowired
    private BinanceVolumnDayRepository binanceVolumnDayRepository;

    @Autowired
    private BinanceVolumnWeekRepository binanceVolumnWeekRepository;

    @Autowired
    private PriorityCoinRepository priorityCoinRepository;

    @Autowired
    private BtcVolumeDayRepository btcVolumeDayRepository;

    @Autowired
    private GeckoVolumeUpPre4hRepository geckoVolumeUpPre4hRepository;

    @Autowired
    private BollAreaRepository bollAreaRepository;

    @Autowired
    private OrdersRepository ordersRepository;

    Hashtable<String, String> msg_send_dict = new Hashtable<String, String>();

    @Override
    @Transactional
    public void loadDataBtcVolumeDay(String gecko_id, String symbol) {
        {
            final Integer limit = 24;
            final String url_usdt = "https://api.binance.com/api/v3/klines?symbol=" + symbol + "USDT"
                    + "&interval=1h&limit=" + String.valueOf(limit);

            List<Object> result_usdt = getBinanceData(url_usdt, limit);

            List<BtcVolumeDay> list_day = new ArrayList<BtcVolumeDay>();

            int hh_index = 0;
            for (int idx = limit - 1; idx >= 0; idx--) {
                Object obj_usdt = result_usdt.get(idx);

                @SuppressWarnings("unchecked")
                List<Object> arr_usdt = (List<Object>) obj_usdt;

                BigDecimal price_open_candle = Utils.getBigDecimal(arr_usdt.get(1));
                BigDecimal price_high = Utils.getBigDecimal(arr_usdt.get(2));
                BigDecimal price_low = Utils.getBigDecimal(arr_usdt.get(3));
                BigDecimal price_close_candle = Utils.getBigDecimal(arr_usdt.get(4));
                String open_time = arr_usdt.get(0).toString();

                if (Objects.equals("0", open_time)) {
                    break;
                }

                BigDecimal avgPrice = price_low.add(price_high).add(price_open_candle).add(price_close_candle)
                        .divide(BigDecimal.valueOf(4), 5, RoundingMode.CEILING);

                BtcVolumeDay day = new BtcVolumeDay();
                Calendar calendar = Calendar.getInstance();
                calendar.add(Calendar.HOUR_OF_DAY, -hh_index);
                day.setId(
                        new BinanceVolumnDayKey(gecko_id, symbol, Utils.convertDateToString("HH", calendar.getTime())));
                day.setAvg_price(avgPrice);
                day.setLow_price(price_low);
                day.setHight_price(price_high);
                day.setPrice_open_candle(price_open_candle);
                day.setPrice_close_candle(price_close_candle);
                list_day.add(day);

                hh_index += 1;
            }
            btcVolumeDayRepository.saveAll(list_day);
        }
    }

    @Override
    @Transactional
    public void loadData(String gecko_id, String symbol) {
        final Integer limit = 14;
        final String url_usdt = "https://api.binance.com/api/v3/klines?symbol=" + symbol + "USDT"
                + "&interval=1d&limit=" + String.valueOf(limit);

        final String url_busd = "https://api.binance.com/api/v3/klines?symbol=" + symbol + "BUSD"
                + "&interval=1d&limit=" + String.valueOf(limit);

        final String url_price = "https://api.binance.com/api/v3/ticker/price?symbol=" + symbol + "USDT";
        BigDecimal price_at_binance = getBinancePrice(url_price);

        List<Object> result_usdt = getBinanceData(url_usdt, limit);
        List<Object> result_busd = getBinanceData(url_busd, limit);

        List<BinanceVolumnDay> list_day = new ArrayList<BinanceVolumnDay>();
        List<BinanceVolumnWeek> list_week = new ArrayList<BinanceVolumnWeek>();
        String sql_pump_dump = "";

        int day_index = 0;
        for (int idx = limit - 1; idx >= 0; idx--) {
            Object obj_usdt = result_usdt.get(idx);
            Object obj_busd = result_busd.get(idx);

            @SuppressWarnings("unchecked")
            List<Object> arr_usdt = (List<Object>) obj_usdt;
            @SuppressWarnings("unchecked")
            List<Object> arr_busd = (List<Object>) obj_busd;

            BigDecimal price_open_candle = Utils.getBigDecimal(arr_usdt.get(1));
            BigDecimal price_high = Utils.getBigDecimal(arr_usdt.get(2));
            BigDecimal price_low = Utils.getBigDecimal(arr_usdt.get(3));
            BigDecimal price_close_candle = Utils.getBigDecimal(arr_usdt.get(4));
            String open_time = arr_usdt.get(0).toString();

            if (Objects.equals("0", open_time)) {
                price_open_candle = Utils.getBigDecimal(arr_busd.get(1));
                price_high = Utils.getBigDecimal(arr_busd.get(2));
                price_low = Utils.getBigDecimal(arr_busd.get(3));
                price_close_candle = Utils.getBigDecimal(arr_busd.get(4));

                open_time = arr_busd.get(0).toString();
            }

            if (!Objects.equals("0", open_time)) {
                BigDecimal avgPrice = price_low.add(price_high).add(price_open_candle).add(price_close_candle)
                        .divide(BigDecimal.valueOf(4), 5, RoundingMode.CEILING);

                BigDecimal quote_asset_volume1 = Utils.getBigDecimal(arr_usdt.get(7));
                BigDecimal number_of_trades1 = Utils.getBigDecimal(arr_usdt.get(8));

                BigDecimal quote_asset_volume2 = Utils.getBigDecimal(arr_busd.get(7));
                BigDecimal number_of_trades2 = Utils.getBigDecimal(arr_busd.get(8));

                BigDecimal total_volume = quote_asset_volume1.add(quote_asset_volume2);
                BigDecimal total_trans = number_of_trades1.add(number_of_trades2);

                if (idx == limit - 1) {
                    BinanceVolumnDay day = new BinanceVolumnDay();
                    Calendar calendar = Calendar.getInstance();

                    day.setId(new BinanceVolumnDayKey(gecko_id, symbol,
                            Utils.convertDateToString("HH", calendar.getTime())));
                    day.setTotalVolume(total_volume);
                    day.setTotalTrasaction(total_trans);
                    day.setPriceAtBinance(price_at_binance);
                    day.setLow_price(price_low);
                    day.setHight_price(price_high);
                    day.setPrice_open_candle(price_open_candle);
                    day.setPrice_close_candle(price_close_candle);

                    list_day.add(day);

                    calendar.add(Calendar.HOUR_OF_DAY, -2);
                    BinanceVolumnDay pre2h = binanceVolumnDayRepository.findById(new BinanceVolumnDayKey(gecko_id,
                            symbol, Utils.convertDateToString("HH", calendar.getTime()))).orElse(null);

                    if (!Objects.equals(null, pre2h)
                            && (Utils.getBigDecimal(pre2h.getPriceAtBinance()).compareTo(BigDecimal.ZERO) > 0)) {

                        String str_pump_dump = "";
                        if (price_at_binance
                                .compareTo(pre2h.getPriceAtBinance().multiply(BigDecimal.valueOf(1.1))) > 0) {

                            str_pump_dump = " total_pump = total_pump + 1 ";

                        } else if (price_at_binance
                                .compareTo(pre2h.getPriceAtBinance().multiply(BigDecimal.valueOf(0.9))) < 0) {

                            str_pump_dump = " total_dump = total_dump + 1 ";
                        }

                        if (!Objects.equals("", str_pump_dump)) {
                            sql_pump_dump = " WITH UPD AS (UPDATE binance_pumping_history SET " + str_pump_dump
                                    + " WHERE gecko_id='" + gecko_id + "' AND symbol='" + symbol
                                    + "' AND HH=TO_CHAR(NOW(), 'HH24') \n" + " RETURNING gecko_id, symbol, hh), \n"
                                    + " INS AS (SELECT '" + gecko_id + "', '" + symbol
                                    + "', TO_CHAR(NOW(), 'HH24'), 1, 1 WHERE NOT EXISTS (SELECT * FROM UPD)) \n"
                                    + " INSERT INTO binance_pumping_history(gecko_id, symbol, hh, total_pump, total_dump) SELECT * FROM INS; \n";
                        }
                    }

                }

                BinanceVolumnWeek entity = new BinanceVolumnWeek();
                Calendar calendar_day = Calendar.getInstance();
                calendar_day.add(Calendar.DAY_OF_MONTH, -day_index);
                entity.setId(new BinanceVolumnWeekKey(gecko_id, symbol,
                        Utils.convertDateToString("yyyyMMdd", calendar_day.getTime())));
                entity.setAvgPrice(avgPrice);
                entity.setTotalVolume(total_volume);
                entity.setTotalTrasaction(total_trans);
                entity.setMin_price(price_low);
                entity.setMax_price(price_high);
                list_week.add(entity);
            }
            day_index += 1;
        }

        binanceVolumnDayRepository.saveAll(list_day);
        binanceVolumnWeekRepository.saveAll(list_week);
        if (!Objects.equals("", sql_pump_dump)) {
            Query query = entityManager.createNativeQuery(sql_pump_dump);
            query.executeUpdate();
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

    @Override
    @Transactional
    public List<CandidateTokenCssResponse> getList(Boolean isOrderByBynaceVolume) {
        try {
            log.info("Start getList ---->");
            String sql = " select                                                                                 \n"
                    + "   can.gecko_id,                                                                           \n"
                    + "   can.symbol,                                                                             \n"
                    + "   can.name,                                                                               \n"

                    + "    boll.price_can_buy,         \n" + "    boll.price_can_sell,        \n"
                    + "    boll.is_bottom_area,        \n" + "    boll.is_top_area,           \n"
                    + "    (case when boll.price_can_buy > 0 then ROUND(100*(boll.price_can_sell - boll.price_can_buy)/boll.price_can_buy, 2) else 0 end) as profit,    \n"
                    + "                                                                                           \n"
                    + "    (select count(w.gecko_id) from binance_volumn_week w where w.ema > 0 and w.gecko_id = can.gecko_id and w.symbol = can.symbol and yyyymmdd between TO_CHAR(NOW() - interval  '6 days', 'yyyyMMdd') and TO_CHAR(NOW(), 'yyyyMMdd')) as count_up, "
                    + "    concat('Pump:', coalesce((select string_agg(his1.hh, '<') from (select * from binance_pumping_history his1 where his1.gecko_id = can.gecko_id and his1.symbol = can.symbol and his1.total_pump > 3 order by his1.total_pump desc limit 5) as his1), ''), 'h', ' ', \n"
                    + "           'Dump:', coalesce((select string_agg(his2.hh, '<') from (select * from binance_pumping_history his2 where his2.gecko_id = can.gecko_id and his2.symbol = can.symbol and his2.total_dump > 3 order by his2.total_dump desc limit 5) as his2), ''), 'h' \n"
                    + "          ) as pumping_history,                                                            \n"

                    + "   ROUND(can.volumn_div_marketcap * 100, 0) volumn_div_marketcap,                          \n"
                    + "                                                                                           \n"
                    + "   ROUND((cur.total_volume / COALESCE ((SELECT (case when pre.total_volume = 0.0 then 1000000000 else pre.total_volume end) FROM public.binance_volumn_day pre WHERE cur.gecko_id = pre.gecko_id AND cur.symbol = pre.symbol AND hh=TO_CHAR((NOW() - interval '4 hours'), 'HH24')), 1000000000) * 100 - 100), 0) pre_4h_total_volume_up, \n"
                    + "   coalesce((SELECT ROUND(pre.total_volume/1000000, 1) FROM public.binance_volumn_day pre WHERE cur.gecko_id = pre.gecko_id AND cur.symbol = pre.symbol AND hh=TO_CHAR((NOW()), 'HH24')), 0)                  as vol_now,      \n"
                    + "                                                                                           \n"
                    + "   ROUND(coalesce((SELECT pre.price_at_binance FROM public.binance_volumn_day pre WHERE cur.gecko_id = pre.gecko_id AND cur.symbol = pre.symbol AND hh=TO_CHAR((NOW()), 'HH24')), 0)                     , 3) as price_now,    \n"
                    + "   ROUND(coalesce((SELECT pre.price_at_binance FROM public.binance_volumn_day pre WHERE cur.gecko_id = pre.gecko_id AND cur.symbol = pre.symbol AND hh=TO_CHAR((NOW() - interval '1 hours'), 'HH24')), 0), 3) as price_pre_1h, \n"
                    + "   ROUND(coalesce((SELECT pre.price_at_binance FROM public.binance_volumn_day pre WHERE cur.gecko_id = pre.gecko_id AND cur.symbol = pre.symbol AND hh=TO_CHAR((NOW() - interval '2 hours'), 'HH24')), 0), 3) as price_pre_2h, \n"
                    + "   ROUND(coalesce((SELECT pre.price_at_binance FROM public.binance_volumn_day pre WHERE cur.gecko_id = pre.gecko_id AND cur.symbol = pre.symbol AND hh=TO_CHAR((NOW() - interval '3 hours'), 'HH24')), 0), 3) as price_pre_3h, \n"
                    + "   ROUND(coalesce((SELECT pre.price_at_binance FROM public.binance_volumn_day pre WHERE cur.gecko_id = pre.gecko_id AND cur.symbol = pre.symbol AND hh=TO_CHAR((NOW() - interval '4 hours'), 'HH24')), 0), 3) as price_pre_4h, \n"
                    + "                                                                                           \n"
                    + "   can.market_cap ,                                                                        \n"
                    + "   cur.price_at_binance            as current_price,                                       \n"
                    + "   can.total_volume                as gecko_total_volume,                                  \n"
                    + "   (case when can.gecko_id in (SELECT pre4h.gecko_id FROM gecko_volume_up_pre4h pre4h order by vol_up_rate desc limit 20)  then true else false end) as top10_vol_up, \n"
                    + "   (SELECT coalesce(vol_up_rate, 0) FROM gecko_volume_up_pre4h pre4h WHERE can.gecko_id = pre4h.gecko_id )                                           as vol_up_rate,  \n"
                    + "                                                                                           \n"
                    + "   coalesce((SELECT ROUND(pre.total_volume/1000000, 1) FROM public.gecko_volumn_day pre WHERE cur.gecko_id = pre.gecko_id AND cur.symbol = pre.symbol AND hh=TO_CHAR((NOW() - interval '1 hours'), 'HH24')), 0) as gec_vol_pre_1h, \n"
                    + "   coalesce((SELECT ROUND(pre.total_volume/1000000, 1) FROM public.gecko_volumn_day pre WHERE cur.gecko_id = pre.gecko_id AND cur.symbol = pre.symbol AND hh=TO_CHAR((NOW() - interval '2 hours'), 'HH24')), 0) as gec_vol_pre_2h, \n"
                    + "   coalesce((SELECT ROUND(pre.total_volume/1000000, 1) FROM public.gecko_volumn_day pre WHERE cur.gecko_id = pre.gecko_id AND cur.symbol = pre.symbol AND hh=TO_CHAR((NOW() - interval '3 hours'), 'HH24')), 0) as gec_vol_pre_3h, \n"
                    + "   coalesce((SELECT ROUND(pre.total_volume/1000000, 1) FROM public.gecko_volumn_day pre WHERE cur.gecko_id = pre.gecko_id AND cur.symbol = pre.symbol AND hh=TO_CHAR((NOW() - interval '4 hours'), 'HH24')), 0) as gec_vol_pre_4h, \n"
                    + "                                                                                           \n"
                    + "   can.price_change_percentage_24h,                                                        \n"
                    + "   can.price_change_percentage_7d,                                                         \n"
                    + "   can.price_change_percentage_14d,                                                        \n"
                    + "   can.price_change_percentage_30d,                                                        \n"
                    + "                                                                                           \n"
                    + "   can.category,                                                                           \n"
                    + "   can.trend,                                                                              \n"
                    + "   can.total_supply,                                                                       \n"
                    + "   can.max_supply,                                                                         \n"
                    + "   can.circulating_supply,                                                                 \n"
                    + "   can.binance_trade,                                                                      \n"
                    + "   can.coin_gecko_link,                                                                    \n"
                    + "   can.backer,                                                                             \n"
                    + "   can.note,                                                                               \n"
                    + "                                                                                           \n"
                    + "   (select concat(w.total_volume, '~', ROUND(w.avg_price, 4), '~', ROUND(w.min_price, 4), '~', ROUND(w.max_price, 4), '~', ROUND(w.ema, 5), '~', coalesce(price_change_24h, 0), '~', ROUND(gecko_volume, 1) ) from binance_volumn_week w where w.gecko_id = can.gecko_id and w.symbol = can.symbol and yyyymmdd = TO_CHAR(NOW(), 'yyyyMMdd'))                     as today,  \n"
                    + "   (select concat(w.total_volume, '~', ROUND(w.avg_price, 4), '~', ROUND(w.min_price, 4), '~', ROUND(w.max_price, 4), '~', ROUND(w.ema, 5), '~', coalesce(price_change_24h, 0), '~', ROUND(gecko_volume, 1) ) from binance_volumn_week w where w.gecko_id = can.gecko_id and w.symbol = can.symbol and yyyymmdd = TO_CHAR(NOW() - interval '1 days', 'yyyyMMdd')) as day_0,  \n"
                    + "   (select concat(w.total_volume, '~', ROUND(w.avg_price, 4), '~', ROUND(w.min_price, 4), '~', ROUND(w.max_price, 4), '~', ROUND(w.ema, 5), '~', coalesce(price_change_24h, 0), '~', ROUND(gecko_volume, 1) ) from binance_volumn_week w where w.gecko_id = can.gecko_id and w.symbol = can.symbol and yyyymmdd = TO_CHAR(NOW() - interval '2 days', 'yyyyMMdd')) as day_1,  \n"
                    + "   (select concat(w.total_volume, '~', ROUND(w.avg_price, 4), '~', ROUND(w.min_price, 4), '~', ROUND(w.max_price, 4), '~', ROUND(w.ema, 5), '~', coalesce(price_change_24h, 0), '~', ROUND(gecko_volume, 1) ) from binance_volumn_week w where w.gecko_id = can.gecko_id and w.symbol = can.symbol and yyyymmdd = TO_CHAR(NOW() - interval '3 days', 'yyyyMMdd')) as day_2,  \n"
                    + "   (select concat(w.total_volume, '~', ROUND(w.avg_price, 4), '~', ROUND(w.min_price, 4), '~', ROUND(w.max_price, 4), '~', ROUND(w.ema, 5), '~', coalesce(price_change_24h, 0), '~', ROUND(gecko_volume, 1) ) from binance_volumn_week w where w.gecko_id = can.gecko_id and w.symbol = can.symbol and yyyymmdd = TO_CHAR(NOW() - interval '4 days', 'yyyyMMdd')) as day_3,  \n"
                    + "   (select concat(w.total_volume, '~', ROUND(w.avg_price, 4), '~', ROUND(w.min_price, 4), '~', ROUND(w.max_price, 4), '~', ROUND(w.ema, 5), '~', coalesce(price_change_24h, 0), '~', ROUND(gecko_volume, 1) ) from binance_volumn_week w where w.gecko_id = can.gecko_id and w.symbol = can.symbol and yyyymmdd = TO_CHAR(NOW() - interval '5 days', 'yyyyMMdd')) as day_4,  \n"
                    + "   (select concat(w.total_volume, '~', ROUND(w.avg_price, 4), '~', ROUND(w.min_price, 4), '~', ROUND(w.max_price, 4), '~', ROUND(w.ema, 5), '~', coalesce(price_change_24h, 0), '~', ROUND(gecko_volume, 1) ) from binance_volumn_week w where w.gecko_id = can.gecko_id and w.symbol = can.symbol and yyyymmdd = TO_CHAR(NOW() - interval '6 days', 'yyyyMMdd')) as day_5,  \n"
                    + "   (select concat(w.total_volume, '~', ROUND(w.avg_price, 4), '~', ROUND(w.min_price, 4), '~', ROUND(w.max_price, 4), '~', ROUND(w.ema, 5), '~', coalesce(price_change_24h, 0), '~', ROUND(gecko_volume, 1) ) from binance_volumn_week w where w.gecko_id = can.gecko_id and w.symbol = can.symbol and yyyymmdd = TO_CHAR(NOW() - interval '7 days', 'yyyyMMdd')) as day_6,  \n"
                    + "   (select concat(w.total_volume, '~', ROUND(w.avg_price, 4), '~', ROUND(w.min_price, 4), '~', ROUND(w.max_price, 4), '~', ROUND(w.ema, 5), '~', coalesce(price_change_24h, 0), '~', ROUND(gecko_volume, 1) ) from binance_volumn_week w where w.gecko_id = can.gecko_id and w.symbol = can.symbol and yyyymmdd = TO_CHAR(NOW() - interval '8 days', 'yyyyMMdd')) as day_7,  \n"
                    + "   (select concat(w.total_volume, '~', ROUND(w.avg_price, 4), '~', ROUND(w.min_price, 4), '~', ROUND(w.max_price, 4), '~', ROUND(w.ema, 5), '~', coalesce(price_change_24h, 0), '~', ROUND(gecko_volume, 1) ) from binance_volumn_week w where w.gecko_id = can.gecko_id and w.symbol = can.symbol and yyyymmdd = TO_CHAR(NOW() - interval '9 days', 'yyyyMMdd')) as day_8,  \n"
                    + "   (select concat(w.total_volume, '~', ROUND(w.avg_price, 4), '~', ROUND(w.min_price, 4), '~', ROUND(w.max_price, 4), '~', ROUND(w.ema, 5), '~', coalesce(price_change_24h, 0), '~', ROUND(gecko_volume, 1) ) from binance_volumn_week w where w.gecko_id = can.gecko_id and w.symbol = can.symbol and yyyymmdd = TO_CHAR(NOW() - interval '10 days', 'yyyyMMdd')) as day_9, \n"
                    + "   (select concat(w.total_volume, '~', ROUND(w.avg_price, 4), '~', ROUND(w.min_price, 4), '~', ROUND(w.max_price, 4), '~', ROUND(w.ema, 5), '~', coalesce(price_change_24h, 0), '~', ROUND(gecko_volume, 1) ) from binance_volumn_week w where w.gecko_id = can.gecko_id and w.symbol = can.symbol and yyyymmdd = TO_CHAR(NOW() - interval '11 days', 'yyyyMMdd')) as day_10, \n"
                    + "   (select concat(w.total_volume, '~', ROUND(w.avg_price, 4), '~', ROUND(w.min_price, 4), '~', ROUND(w.max_price, 4), '~', ROUND(w.ema, 5), '~', coalesce(price_change_24h, 0), '~', ROUND(gecko_volume, 1) ) from binance_volumn_week w where w.gecko_id = can.gecko_id and w.symbol = can.symbol and yyyymmdd = TO_CHAR(NOW() - interval '12 days', 'yyyyMMdd')) as day_11, \n"
                    + "   (select concat(w.total_volume, '~', ROUND(w.avg_price, 4), '~', ROUND(w.min_price, 4), '~', ROUND(w.max_price, 4), '~', ROUND(w.ema, 5), '~', coalesce(price_change_24h, 0), '~', ROUND(gecko_volume, 1) ) from binance_volumn_week w where w.gecko_id = can.gecko_id and w.symbol = can.symbol and yyyymmdd = TO_CHAR(NOW() - interval '13 days', 'yyyyMMdd')) as day_12, \n"
                    + "   can.priority,                                                                           \n"

                    + "   macd.ema07d,                                                                            \n"
                    + "   macd.ema14d,                                                                            \n"
                    + "   macd.ema21d,                                                                            \n"
                    + "   macd.ema28d,                                                                            \n"
                    + "   macd.avg07d,                                                                            \n"
                    + "   macd.avg14d,                                                                            \n"
                    + "   macd.avg21d,                                                                            \n"
                    + "   macd.avg28d,                                                                            \n"
                    // Bottleneck -> maybe up trend
                    + "   (CASE WHEN  (select gecko_id from boll_area b where can.gecko_id = b.gecko_id) IS NOT NULL THEN true ELSE false END) AS uptrend,   \n"
                    + "   vol.vol0d,                                                                              \n"
                    + "   vol.vol1d,                                                                              \n"
                    + "   vol.vol7d                                                                               \n"
                    + "                                                                                           \n"
                    + " from                                                                                      \n"
                    + "   candidate_coin can,                                                                     \n"
                    + "   binance_volumn_day cur,                                                                 \n"
                    + "                                                                                           \n"
                    + " (                                                                                         \n"
                    + "    select                                                                                 \n"
                    + "       xyz.gecko_id,                                                                       \n"
                    + "       xyz.symbol,                                                                         \n"
                    + "       COALESCE(price_today   - price_pre_07d*1.05, -99) as ema07d,                        \n"
                    + "       COALESCE(price_pre_07d - price_pre_14d, -99) as ema14d,                             \n"
                    + "       COALESCE(price_pre_14d - price_pre_21d, -99) as ema21d,                             \n"
                    + "       COALESCE(price_pre_21d - price_pre_28d, -99) as ema28d,                             \n"
                    + "       COALESCE(avg07d, -99) avg07d,                                                       \n"
                    + "       COALESCE(avg14d, -99) avg14d,                                                       \n"
                    + "       COALESCE(avg21d, -99) avg21d,                                                       \n"
                    + "       COALESCE(avg28d, -99) avg28d                                                        \n"
                    + "    from                                                                                   \n"
                    + "      (                                                                                    \n"
                    + "          select                                                                           \n"
                    + "              can.gecko_id,                                                                \n"
                    + "              can.symbol,                                                                  \n"
                    + "              can.name,                                                                    \n"
                    + "             (select COALESCE(w.avg_price, 0) from binance_volumn_week w where w.gecko_id = can.gecko_id and w.symbol = can.symbol and yyyymmdd = TO_CHAR(NOW(), 'yyyyMMdd')) as price_today,      \n"
                    + "             (select COALESCE(w.avg_price, 0) from binance_volumn_week w where w.gecko_id = can.gecko_id and w.symbol = can.symbol and yyyymmdd = TO_CHAR(NOW() - interval  '6 days', 'yyyyMMdd')) as price_pre_07d,  \n"
                    + "             (select COALESCE(w.avg_price, 0) from binance_volumn_week w where w.gecko_id = can.gecko_id and w.symbol = can.symbol and yyyymmdd = TO_CHAR(NOW() - interval '13 days', 'yyyyMMdd')) as price_pre_14d,  \n"
                    + "             (select COALESCE(w.avg_price, 0) from binance_volumn_week w where w.gecko_id = can.gecko_id and w.symbol = can.symbol and yyyymmdd = TO_CHAR(NOW() - interval '20 days', 'yyyyMMdd')) as price_pre_21d,  \n"
                    + "             (select COALESCE(w.avg_price, 0) from binance_volumn_week w where w.gecko_id = can.gecko_id and w.symbol = can.symbol and yyyymmdd = TO_CHAR(NOW() - interval '28 days', 'yyyyMMdd')) as price_pre_28d,  \n"
                    + "             ROUND((select AVG(COALESCE(w.avg_price, 0)) from binance_volumn_week w where w.gecko_id = can.gecko_id and w.symbol = can.symbol and yyyymmdd between TO_CHAR(NOW() - interval  '6 days', 'yyyyMMdd') and TO_CHAR(NOW(), 'yyyyMMdd')), 5) as avg07d,      \n"
                    + "             ROUND((select AVG(COALESCE(w.avg_price, 0)) from binance_volumn_week w where w.gecko_id = can.gecko_id and w.symbol = can.symbol and yyyymmdd between TO_CHAR(NOW() - interval '13 days', 'yyyyMMdd') and TO_CHAR(NOW(), 'yyyyMMdd')), 5) as avg14d,      \n"
                    + "             ROUND((select AVG(COALESCE(w.avg_price, 0)) from binance_volumn_week w where w.gecko_id = can.gecko_id and w.symbol = can.symbol and yyyymmdd between TO_CHAR(NOW() - interval '20 days', 'yyyyMMdd') and TO_CHAR(NOW(), 'yyyyMMdd')), 5) as avg21d,      \n"
                    + "             ROUND((select AVG(COALESCE(w.avg_price, 0)) from binance_volumn_week w where w.gecko_id = can.gecko_id and w.symbol = can.symbol and yyyymmdd between TO_CHAR(NOW() - interval '27 days', 'yyyyMMdd') and TO_CHAR(NOW(), 'yyyyMMdd')), 5) as avg28d  \n"
                    + "                                                                                           \n"
                    + "          from                                                                             \n"
                    + "              candidate_coin can                                                           \n"
                    + "    ) xyz                                                                                  \n"
                    + " ) macd                                                                                    \n"
                    + " , ("
                    + "     select                                                                                \n"
                    + "        gecko_id,                                                                          \n"
                    + "        symbol,                                                                            \n"
                    + "        ROUND((COALESCE(volume_today  , 0))/1000000, 1) as vol0d, \n"
                    + "        ROUND((COALESCE(volume_pre_01d, 0))/1000000, 1) as vol1d, \n"
                    + "        ROUND((COALESCE(volume_pre_07d, 0))/1000000, 1) as vol7d  \n"
                    + "     from                                                                                  \n"
                    + "       (                                                                                   \n"
                    + "           select                                                                          \n"
                    + "               can.gecko_id,                                                               \n"
                    + "               can.symbol,                                                                 \n"
                    + "               can.name,                                                                   \n"
                    + "              (select COALESCE(w.total_volume, 0) from gecko_volume_month w where w.gecko_id = can.gecko_id and w.symbol = can.symbol and dd = TO_CHAR(NOW(), 'dd'))                      as volume_today,  \n"
                    + "              (select COALESCE(w.total_volume, 0) from gecko_volume_month w where w.gecko_id = can.gecko_id and w.symbol = can.symbol and dd = TO_CHAR(NOW() - interval  '1 days', 'dd')) as volume_pre_01d, \n"
                    + "              (select COALESCE(w.total_volume, 0) from gecko_volume_month w where w.gecko_id = can.gecko_id and w.symbol = can.symbol and dd = TO_CHAR(NOW() - interval  '6 days', 'dd')) as volume_pre_07d  \n"
                    + "           from                                                                            \n"
                    + "               candidate_coin can                                                          \n"
                    + "     ) tmp                                                                                 \n"
                    + ") vol                                                                                      \n"
                    + ", " + Utils.sql_boll_2_body

                    + "                                                                                           \n"
                    + " where                                                                                     \n"
                    + "       cur.hh = (case when EXTRACT(MINUTE FROM NOW()) < 3 then TO_CHAR(NOW() - interval '1 hours', 'HH24') else TO_CHAR(NOW(), 'HH24') end) \n"
                    + "   and can.gecko_id = cur.gecko_id                                                         \n"
                    + "   and can.symbol = cur.symbol                                                             \n"
                    + "   and can.gecko_id = macd.gecko_id                                                        \n"
                    + "   and can.gecko_id = boll.gecko_id                                                        \n"
                    + "   and can.gecko_id = vol.gecko_id                                                         \n"
                    + " order by                                                                                  \n"
                    + "   coalesce(can.priority, 3) asc,                                            		      \n"
                    + "   can.volumn_div_marketcap desc                                                           \n";

            Query query = entityManager.createNativeQuery(sql, "CandidateTokenResponse");

            @SuppressWarnings("unchecked")
            List<CandidateTokenResponse> results = query.getResultList();
            List<CandidateTokenCssResponse> list = new ArrayList<CandidateTokenCssResponse>();
            ModelMapper mapper = new ModelMapper();
            Integer index = 1;
            String sql_update_ema = "";
            Boolean btc_is_good_price = false;
            Boolean this_token_is_good_price = false;
            List<PriorityCoin> listPriorityCoin = priorityCoinRepository.findAll();

            for (CandidateTokenResponse dto : results) {

                PriorityCoin priorityCoin = listPriorityCoin.stream()
                        .filter(item -> Objects.equals(item.getGeckoid(), dto.getGecko_id())).findFirst()
                        .orElse(new PriorityCoin());

                priorityCoin.setGeckoid(dto.getGecko_id());

                CandidateTokenCssResponse css = new CandidateTokenCssResponse();
                mapper.map(dto, css);

                BigDecimal price_now = Utils.getBigDecimal(dto.getPrice_now());
                BigDecimal market_cap = Utils.getBigDecimal(dto.getMarket_cap());
                BigDecimal gecko_total_volume = Utils.getBigDecimal(dto.getGecko_total_volume());

                if ((market_cap.compareTo(BigDecimal.valueOf(36000001)) < 0)
                        && (market_cap.compareTo(BigDecimal.valueOf(1000000)) > 0)) {
                    css.setMarket_cap_css("highlight");
                }

                String volumn_vector1d = "vec1: " + dto.getVol1d();
                css.setVector_vol1d(volumn_vector1d);
                if (dto.getVol1d().compareTo(BigDecimal.ZERO) > 0) {
                    css.setVector_vol1d_css("text-primary");
                } else {
                    css.setVector_vol1d_css("text-danger");
                }

                String volumn_vector7d = "vec7: " + dto.getVol7d();
                css.setVector_vol2d(volumn_vector7d);
                if (dto.getVol7d().compareTo(BigDecimal.ZERO) > 0) {
                    css.setVector_vol2d_css("text-primary");
                } else {
                    css.setVector_vol2d_css("text-danger");
                }

                BigDecimal volumn_binance_div_marketcap = BigDecimal.ZERO;
                String volumn_binance_div_marketcap_str = "";
                if (market_cap.compareTo(BigDecimal.ZERO) > 0) {
                    volumn_binance_div_marketcap = Utils.getBigDecimal(dto.getVol_now()).divide(
                            market_cap.divide(BigDecimal.valueOf(100000000), 5, RoundingMode.CEILING), 1,
                            RoundingMode.CEILING);
                } else if (gecko_total_volume.compareTo(BigDecimal.ZERO) > 0) {
                    volumn_binance_div_marketcap = Utils.getBigDecimal(dto.getVol_now()).divide(
                            gecko_total_volume.divide(BigDecimal.valueOf(100000000), 5, RoundingMode.CEILING), 1,
                            RoundingMode.CEILING);
                }

                if (volumn_binance_div_marketcap.compareTo(BigDecimal.valueOf(30)) > 0) {
                    volumn_binance_div_marketcap_str = "B:" + volumn_binance_div_marketcap.toString();
                    css.setVolumn_binance_div_marketcap_css("font-weight-bold");

                } else if (volumn_binance_div_marketcap.compareTo(BigDecimal.valueOf(20)) > 0) {
                    volumn_binance_div_marketcap_str = "B:" + volumn_binance_div_marketcap.toString();
                    css.setVolumn_binance_div_marketcap_css("text-primary");

                } else if (volumn_binance_div_marketcap.compareTo(BigDecimal.valueOf(10)) > 0) {
                    volumn_binance_div_marketcap_str = "B:" + volumn_binance_div_marketcap.toString();

                } else {
                    volumn_binance_div_marketcap_str = volumn_binance_div_marketcap.toString();
                }

                css.setVolumn_binance_div_marketcap(volumn_binance_div_marketcap_str);
                css.setPumping_history(dto.getPumping_history().replace("Pump:h", "").replace("Dump:h", ""));

                // Price
                String pre_price_history = Utils.removeLastZero(dto.getPrice_now()) + "←"
                        + Utils.removeLastZero(dto.getPrice_pre_1h()) + "← "
                        + Utils.removeLastZero(dto.getPrice_pre_2h()) + "←"
                        + Utils.removeLastZero(dto.getPrice_pre_3h()) + "←"
                        + Utils.removeLastZero(dto.getPrice_pre_4h());
                if (pre_price_history.length() > 35) {
                    pre_price_history = pre_price_history.substring(0, 35);
                }
                css.setPre_price_history(pre_price_history);

                if (getValue(css.getVolumn_div_marketcap()) > Long.valueOf(100)) {
                    css.setVolumn_div_marketcap_css("text-primary");
                }
                css.setCurrent_price(Utils.removeLastZero(dto.getCurrent_price()));
                css.setPrice_change_24h_css(Utils.getTextCss(css.getPrice_change_percentage_24h()));
                css.setPrice_change_07d_css(Utils.getTextCss(css.getPrice_change_percentage_7d()));
                css.setPrice_change_14d_css(Utils.getTextCss(css.getPrice_change_percentage_14d()));
                css.setPrice_change_30d_css(Utils.getTextCss(css.getPrice_change_percentage_30d()));

                String gecko_volumn_history = dto.getGec_vol_pre_1h() + "←" + dto.getGec_vol_pre_2h() + " ←"
                        + dto.getGec_vol_pre_3h() + "←" + dto.getGec_vol_pre_4h() + "M";
                if (gecko_volumn_history.length() > 35) {
                    gecko_volumn_history = gecko_volumn_history.substring(0, 35);
                }
                css.setGecko_volumn_history(gecko_volumn_history);

                List<String> volList = new ArrayList<String>();
                List<String> avgPriceList = new ArrayList<String>();
                List<String> lowPriceList = new ArrayList<String>();
                List<String> hightPriceList = new ArrayList<String>();

                List<String> temp = splitVolAndPrice(css.getToday());
                css.setToday_vol(temp.get(0));
                css.setToday_price(temp.get(1));
                css.setToday_gecko_vol(
                        temp.get(6) + " (Vol4h: " + Utils.getBigDecimal(dto.getVol_up_rate()).toString() + ")");
                String today_ema = "";
                if (temp.get(4).contains("-")) {
                    today_ema = "(" + (7 - Utils.getIntValue(dto.getCount_up())) + "Down, " + dto.getCount_up()
                            + "Up )";
                } else {
                    today_ema = "(" + dto.getCount_up() + "Up" + ", " + (7 - Utils.getIntValue(dto.getCount_up()))
                            + "Down) ";

                }
                today_ema += temp.get(4) + " (" + temp.get(5) + "%)";
                css.setToday_ema(today_ema);

                volList.add("");
                avgPriceList.add(temp.get(1));
                lowPriceList.add(temp.get(2));
                hightPriceList.add(temp.get(3));

                BigDecimal lowest_price_today = Utils.getBigDecimalValue(temp.get(2));
                BigDecimal highest_price_today = Utils.getBigDecimalValue(temp.get(3));
                BigDecimal vol_today = Utils.getBigDecimal(temp.get(0).replace(",", ""));

                temp = splitVolAndPrice(css.getDay_0());
                css.setDay_0_vol(temp.get(0));
                css.setDay_0_price(temp.get(1));
                css.setDay_0_ema(temp.get(4) + " (" + temp.get(5) + "%)");
                css.setDay_0_gecko_vol(temp.get(6));

                volList.add(temp.get(0));
                avgPriceList.add(temp.get(1));
                lowPriceList.add(temp.get(2));
                hightPriceList.add(temp.get(3));
                BigDecimal vol_yesterday = Utils.getBigDecimal(temp.get(0).replace(",", ""));

                if (vol_yesterday.compareTo(BigDecimal.ZERO) == 1) {
                    BigDecimal vol_up = vol_today.divide(vol_yesterday, 1, RoundingMode.CEILING);
                    if (BigDecimal.valueOf(1).compareTo(vol_up) == -1) {
                        css.setStar("※Up:" + String.valueOf(vol_up));
                        css.setStar_css("text-primary");
                    }
                }
                temp = splitVolAndPrice(css.getDay_1());
                css.setDay_1_vol(temp.get(0));
                css.setDay_1_price(temp.get(1));
                css.setDay_1_ema(temp.get(4) + " (" + temp.get(5) + "%)");
                css.setDay_1_gecko_vol(temp.get(6));

                volList.add(temp.get(0));
                avgPriceList.add(temp.get(1));
                lowPriceList.add(temp.get(2));
                hightPriceList.add(temp.get(3));

                temp = splitVolAndPrice(css.getDay_2());
                css.setDay_2_vol(temp.get(0));
                css.setDay_2_price(temp.get(1));
                css.setDay_2_ema(temp.get(4) + " (" + temp.get(5) + "%)");
                css.setDay_2_gecko_vol(temp.get(6));

                volList.add(temp.get(0));
                avgPriceList.add(temp.get(1));
                lowPriceList.add(temp.get(2));
                hightPriceList.add(temp.get(3));

                temp = splitVolAndPrice(css.getDay_3());
                css.setDay_3_vol(temp.get(0));
                css.setDay_3_price(temp.get(1));
                css.setDay_3_ema(temp.get(4) + " (" + temp.get(5) + "%)");
                css.setDay_3_gecko_vol(temp.get(6));

                volList.add(temp.get(0));
                avgPriceList.add(temp.get(1));
                lowPriceList.add(temp.get(2));
                hightPriceList.add(temp.get(3));

                temp = splitVolAndPrice(css.getDay_4());
                css.setDay_4_vol(temp.get(0));
                css.setDay_4_price(temp.get(1));
                css.setDay_4_ema(temp.get(4) + " (" + temp.get(5) + "%)");
                css.setDay_4_gecko_vol(temp.get(6));

                volList.add(temp.get(0));
                avgPriceList.add(temp.get(1));
                lowPriceList.add(temp.get(2));
                hightPriceList.add(temp.get(3));

                temp = splitVolAndPrice(css.getDay_5());
                css.setDay_5_vol(temp.get(0));
                css.setDay_5_price(temp.get(1));
                css.setDay_5_ema(temp.get(4) + " (" + temp.get(5) + "%)");
                css.setDay_5_gecko_vol(temp.get(6));

                volList.add(temp.get(0));
                avgPriceList.add(temp.get(1));
                lowPriceList.add(temp.get(2));
                hightPriceList.add(temp.get(3));

                temp = splitVolAndPrice(css.getDay_6());
                css.setDay_6_vol(temp.get(0));
                css.setDay_6_price(temp.get(1));
                css.setDay_6_ema(temp.get(4) + " (" + temp.get(5) + "%)");
                css.setDay_6_gecko_vol(temp.get(6));

                volList.add(temp.get(0));
                avgPriceList.add(temp.get(1));
                lowPriceList.add(temp.get(2));
                hightPriceList.add(temp.get(3));

                temp = splitVolAndPrice(css.getDay_7());
                css.setDay_7_vol(temp.get(0));
                css.setDay_7_price(temp.get(1));
                css.setDay_7_ema(temp.get(4) + " (" + temp.get(5) + "%)");
                css.setDay_7_gecko_vol(temp.get(6));

                volList.add(temp.get(0));
                avgPriceList.add(temp.get(1));
                lowPriceList.add(temp.get(2));
                hightPriceList.add(temp.get(3));

                temp = splitVolAndPrice(css.getDay_8());
                css.setDay_8_vol(temp.get(0));
                css.setDay_8_price(temp.get(1));
                css.setDay_8_ema(temp.get(4) + " (" + temp.get(5) + "%)");
                css.setDay_8_gecko_vol(temp.get(6));

                volList.add(temp.get(0));
                avgPriceList.add(temp.get(1));
                lowPriceList.add(temp.get(2));
                hightPriceList.add(temp.get(3));

                temp = splitVolAndPrice(css.getDay_9());
                css.setDay_9_vol(temp.get(0));
                css.setDay_9_price(temp.get(1));
                css.setDay_9_ema(temp.get(4) + " (" + temp.get(5) + "%)");
                css.setDay_9_gecko_vol(temp.get(6));

                volList.add(temp.get(0));
                avgPriceList.add(temp.get(1));
                lowPriceList.add(temp.get(2));
                hightPriceList.add(temp.get(3));

                temp = splitVolAndPrice(css.getDay_10());
                css.setDay_10_vol(temp.get(0));
                css.setDay_10_price(temp.get(1));
                css.setDay_10_ema(temp.get(4) + " (" + temp.get(5) + "%)");
                css.setDay_10_gecko_vol(temp.get(6));

                volList.add(temp.get(0));
                avgPriceList.add(temp.get(1));
                lowPriceList.add(temp.get(2));
                hightPriceList.add(temp.get(3));

                temp = splitVolAndPrice(css.getDay_11());
                css.setDay_11_vol(temp.get(0));
                css.setDay_11_price(temp.get(1));
                css.setDay_11_ema(temp.get(4) + " (" + temp.get(5) + "%)");
                css.setDay_11_gecko_vol(temp.get(6));

                volList.add(temp.get(0));
                avgPriceList.add(temp.get(1));
                lowPriceList.add(temp.get(2));
                hightPriceList.add(temp.get(3));

                temp = splitVolAndPrice(css.getDay_12());
                css.setDay_12_vol(temp.get(0));
                css.setDay_12_price(temp.get(1));
                css.setDay_12_ema(temp.get(4) + " (" + temp.get(5) + "%)");
                css.setDay_12_gecko_vol(temp.get(6));

                volList.add(temp.get(0));
                avgPriceList.add(temp.get(1));
                lowPriceList.add(temp.get(2));
                hightPriceList.add(temp.get(3));

                int idx_vol_max = getIndexMax(volList);
                int idx_price_max = getIndexMax(avgPriceList);
                int idx_vol_min = getIndexMin(volList);
                int idx_price_min = getIndexMin(avgPriceList);

                setEmaCss(css);

                String str_down = "";
                if (Utils.getBigDecimal(avgPriceList.get(idx_price_min)).compareTo(BigDecimal.ZERO) > 0) {
                    BigDecimal down = Utils.getBigDecimal(avgPriceList.get(idx_price_max))
                            .divide(Utils.getBigDecimal(avgPriceList.get(idx_price_min)), 2, RoundingMode.CEILING)
                            .multiply(BigDecimal.valueOf(100));
                    str_down = "(" + down.subtract(BigDecimal.valueOf(100)).toString().replace(".00", "") + "%)";
                }
                setVolumnDayCss(css, idx_vol_max, "text-primary"); // Max Volumn
                setPriceDayCss(css, idx_price_max, "text-primary", ""); // Max Price
                setVolumnDayCss(css, idx_vol_min, "text-danger"); // Min Volumn
                setPriceDayCss(css, idx_price_min, "text-danger", str_down); // Min Price

                BigDecimal min_add_5_percent = Utils.getBigDecimal(avgPriceList.get(idx_price_min));
                min_add_5_percent = min_add_5_percent.multiply(BigDecimal.valueOf(Double.valueOf(1.05)));

                BigDecimal max_subtract_5_percent = Utils.getBigDecimal(avgPriceList.get(idx_price_max));
                max_subtract_5_percent.multiply(BigDecimal.valueOf(Double.valueOf(0.95)));

                if (idx_price_min == 0) {
                    setPriceDayCss(css, idx_price_min, "text-danger font-weight-bold", ""); // Min Price
                    if (!Objects.equals(null, css.getStar()) && !Objects.equals("", String.valueOf(css.getStar()))) {
                        css.setStar("🤩🤩" + " " + css.getStar());
                    } else {
                        css.setStar("🤩");
                    }
                    css.setStar_css("text-primary font-weight-bold");

                } else if ((price_now.compareTo(BigDecimal.ZERO) > 0)
                        && (max_subtract_5_percent.compareTo(price_now) < 0)) {

                    css.setStar("!Max5%");
                    css.setStar_css("bg-warning rounded-lg");

                } else if ((price_now.compareTo(BigDecimal.ZERO) > 0) && (price_now.compareTo(min_add_5_percent) < 0)) {

                    css.setStar("🤩");
                    css.setStar_css("text-primary font-weight-bold");

                } else if (idx_vol_min == 1) {

                    css.setStar("🤩");

                } else if (idx_price_min == 1) {

                    setPriceDayCss(css, idx_price_min, "text-danger font-weight-bold", ""); // Min Price

                }

                // --------------AVG PRICE---------------
                BigDecimal avg_price = BigDecimal.ZERO;
                BigDecimal total_price = BigDecimal.ZERO;
                for (String price : avgPriceList) {
                    if (!Objects.equals("", price)) {
                        total_price = total_price.add(Utils.getBigDecimalValue(price));
                    }
                }

                avg_price = total_price.divide(BigDecimal.valueOf(avgPriceList.size()), 5, RoundingMode.CEILING);

                price_now = Utils.getBigDecimalValue(css.getCurrent_price());

                BigDecimal taget_percent_lost_today = Utils
                        .getBigDecimalValue(Utils.toPercent(lowest_price_today, price_now, 1));
                BigDecimal taget_percent_profit_today = Utils
                        .getBigDecimalValue(Utils.toPercent(highest_price_today, price_now, 1));

                css.setLow_to_hight_price("L:" + lowest_price_today + "(" + taget_percent_lost_today + "%)_H:"
                        + highest_price_today + "(" + taget_percent_profit_today.toString().replace(".0", "") + "%)"
                        + " " + Utils.whenGoodPrice(price_now, lowest_price_today, highest_price_today));

                this_token_is_good_price = Utils.isGoodPrice(price_now, lowest_price_today, highest_price_today);

                // btc_warning_css
                if (Objects.equals("BTC", dto.getSymbol().toUpperCase())
                        && Utils.getBigDecimalValue(Utils.toPercent(highest_price_today, lowest_price_today, 1))
                                .compareTo(BigDecimal.valueOf(1.8)) > 0) {

                    btc_is_good_price = Utils.isGoodPrice(price_now, lowest_price_today, highest_price_today);

                    if (((lowest_price_today.multiply(BigDecimal.valueOf(1.01))).compareTo(price_now) >= 0)) {

                        css.setBtc_warning_css("bg-success");

                    } else if ((price_now.multiply(BigDecimal.valueOf(1.015)).compareTo(highest_price_today) > 0)) {

                        css.setBtc_warning_css("bg-danger");

                    }
                }

                priorityCoin.setCurrent_price(price_now);

                if ((price_now.compareTo(BigDecimal.ZERO) > 0) && (avg_price.compareTo(BigDecimal.ZERO) > 0)) {

                    if (avg_price.compareTo(price_now) < 1) {
                        css.setAvg_price_css("text-danger font-weight-bold");
                    } else {
                        css.setAvg_price_css("text-primary font-weight-bold");
                    }
                    BigDecimal percent = Utils.getBigDecimalValue(Utils.toPercent(avg_price, price_now, 1));

                    css.setAvg_price(Utils.removeLastZero(avg_price.toString()));
                    css.setAvg_percent(percent.toString().replace(".00", "") + "%");

                    if (Objects.equals("", css.getStar()) && (percent.compareTo(BigDecimal.valueOf(5)) < 1)
                            && ((Utils.getBigDecimalValue(css.getVolumn_div_marketcap())
                                    .compareTo(BigDecimal.valueOf(10)) > -1))) {
                        css.setStar("🤩");
                    }
                } else {
                    css.setAvg_price("0.0");
                }

                {
                    // tp_price: x2:aaa$ or 50%: bbb$ or 20%:ccc$ 10%:ddd$
                    // stop_limit: price_min * 0.95
                    // stop_price: price_min * 0.945

                    // star.contains("🤩")
                    BigDecimal price_min = Utils.getBigDecimal(avgPriceList.get(idx_price_min));
                    BigDecimal price_max = Utils.getBigDecimal(avgPriceList.get(idx_price_max));

                    String min_14d = "Min14d: " + price_min.toString() + "(" + Utils.toPercent(price_min, price_now)
                            + "%)~Max14d: ";

                    String max_14d_percent = Utils.toPercent(price_max, price_now);
                    css.setOco_tp_price(min_14d);
                    css.setOco_tp_price_hight(price_max.toString() + "(" + max_14d_percent + "%)");

                    if (Utils.getBigDecimalValue(max_14d_percent).compareTo(BigDecimal.valueOf(20)) > 0) {
                        css.setOco_tp_price_hight_css("text-primary font-weight-bold");
                    } else if (Utils.getBigDecimalValue(max_14d_percent).compareTo(BigDecimal.valueOf(10)) > 0) {
                        css.setOco_tp_price_hight_css("text-primary");
                    } else {
                        css.setOco_tp_price_hight_css("text-danger");
                    }

                    String ema_history = "vector7: " + dto.getEma07d() + ", vector14: " + dto.getEma14d();
                    css.setEma_history(ema_history);

                    String avg_history = "avg7: " + dto.getAvg07d() + "(" + Utils.toPercent(dto.getAvg07d(), price_now)
                            + "%)" + ", avg14: " + dto.getAvg14d() + "(" + Utils.toPercent(dto.getAvg14d(), price_now)
                            + "%)" + ", avg28: " + dto.getAvg28d() + "(" + Utils.toPercent(dto.getAvg28d(), price_now)
                            + "%)";
                    css.setAvg_history(avg_history);
                }

                if (dto.getUptrend()) {
                    if ((dto.getAvg07d().multiply(BigDecimal.valueOf(1.05))).compareTo(dto.getAvg14d()) > 0) {
                        css.setStar(css.getStar() + " Bottleneck Uptrend");
                    } else {
                        css.setStar(css.getStar() + " Bottleneck");
                    }
                } else if ((dto.getAvg07d().multiply(BigDecimal.valueOf(1.05))).compareTo(dto.getAvg14d()) > 0) {
                    // css.setStar(css.getStar() + " 714");
                }

                BigDecimal avg_percent = Utils.getBigDecimalValue(css.getAvg_percent().replace("%", ""));
                if (avg_percent.compareTo(BigDecimal.valueOf(10)) < 0) {
                    css.setStar(css.getStar().replace("🤩", ""));
                } else if (!css.getStar().contains("🤩")) {
                    css.setStar("🤩" + css.getStar());
                }

                if (dto.getEma07d().compareTo(BigDecimal.ZERO) > 0) {
                    if (css.getStar().contains("Uptrend")) {
                        css.setStar("🤩" + css.getStar() + " Plus");
                    } else {
                        css.setStar("🤩" + css.getStar() + " Plus");
                    }

                    css.setStar_css("text-success");
                }

                priorityCoin.setTarget_price(Utils.getBigDecimalValue(css.getAvg_price()));
                priorityCoin.setVmc(Utils.getIntValue(css.getVolumn_div_marketcap()));
                priorityCoin.setLow_price(lowest_price_today);
                priorityCoin.setHeight_price(highest_price_today);
                priorityCoin.setIndex(index);
                priorityCoin.setSymbol(css.getSymbol());
                priorityCoin.setName(css.getName());
                priorityCoin.setEma(dto.getEma07d());

                if (css.getPumping_history().contains("Dump")) {
                    css.setStar(css.getStar() + " Dump");
                }

                Boolean is_candidate = false;
                Boolean predict = false;
                if (!Objects.equals(null, dto.getPrice_can_buy()) && !Objects.equals(null, dto.getPrice_can_sell())
                        && BigDecimal.ZERO.compareTo(dto.getPrice_can_buy()) != 0
                        && BigDecimal.ZERO.compareTo(dto.getPrice_can_sell()) != 0) {

                    String avg_boll_min = Utils.toPercent(dto.getPrice_can_buy(), price_now, 1);
                    String avg_boll_max = Utils.toPercent(dto.getPrice_can_sell(), price_now, 1);

                    priorityCoin.setTarget_percent(
                            Utils.getIntValue(Utils.getBigDecimalValue(avg_boll_max).toBigInteger()));

                    css.setAvg_boll_min("Buy: " + Utils.removeLastZero(dto.getPrice_can_buy().toString()) + "("
                            + avg_boll_min + "%)");

                    css.setAvg_boll_max("Sell: " + Utils.removeLastZero(dto.getPrice_can_sell().toString()) + "("
                            + avg_boll_max + "%)");

                    if (dto.getIs_bottom_area()
                            || (Utils.getBigDecimalValue(avg_boll_min).compareTo(BigDecimal.valueOf(-3)) > 0
                                    && Utils.getBigDecimalValue(avg_boll_max).compareTo(BigDecimal.valueOf(6)) > 0)) {
                        is_candidate = true;
                        predict = true;

                        if (BigDecimal.ZERO.compareTo(Utils.getBigDecimal(avg_boll_min)) != 0) {
                            css.setStar(css.getStar() + " Boll(" + avg_boll_max + "%)");
                        }

                        css.setStar_css("text-primary");
                    }
                }

                if ((Utils.getBigDecimalValue(dto.getVolumn_div_marketcap()).compareTo(BigDecimal.valueOf(20)) < 0)
                        && (volumn_binance_div_marketcap.compareTo(BigDecimal.valueOf(10)) < 0)) {
                    is_candidate = false;
                    predict = false;
                }

                if (dto.getTop10_vol_up() && dto.getEma07d().compareTo(BigDecimal.ZERO) > 0) {
                    css.setStar(css.getStar() + " TopVolUp");
                }

                priorityCoin.setPredict(predict);
                priorityCoin.setCandidate(is_candidate);

                String note = "Can" + css.getAvg_boll_min() + "~" + "Can" + css.getAvg_boll_max() + "~";

                note += "v/mc:"
                        + Utils.getBigDecimalValue(css.getGecko_total_volume().replaceAll(",", ""))
                                .divide(BigDecimal.valueOf(1000000), 1, RoundingMode.CEILING)
                        + "M (" + css.getVolumn_div_marketcap() + "%)";

                note += ", B:"
                        + Utils.getBigDecimalValue(css.getToday_vol().replaceAll(",", ""))
                                .divide(BigDecimal.valueOf(1000000), 1, RoundingMode.CEILING)
                        + "M (" + css.getVolumn_binance_div_marketcap().replace("B:", "") + "%)";

                note += ", Mc:" + Utils.getBigDecimalValue(css.getMarket_cap().replaceAll(",", ""))
                        .divide(BigDecimal.valueOf(1000000), 1, RoundingMode.CEILING);

                note += "M~24h: " + Utils.formatPrice(Utils.getBigDecimalValue(css.getPrice_change_percentage_24h()), 1)
                        + "%, 7d: "
                        + Utils.formatPrice(Utils.getBigDecimalValue(css.getPrice_change_percentage_7d()), 1)
                        + "%, 14d: "
                        + Utils.formatPrice(Utils.getBigDecimalValue(css.getPrice_change_percentage_14d()), 1) + "%"

                        + ", Vol4h: " + Utils.getBigDecimal(dto.getVol_up_rate()).toString();

                note += (Utils.isNotBlank(Utils.getStringValue(css.getNote()))
                        ? "~" + Utils.getStringValue(css.getNote())
                        : "")

                        + (Utils.isNotBlank(Utils.getStringValue(css.getTrend()))
                                ? "~" + Utils.getStringValue(css.getTrend())
                                : "")

                        + (Utils.isNotBlank(Utils.getStringValue(css.getPumping_history()))
                                ? "~" + Utils.getStringValue(css.getPumping_history())
                                : "");

                priorityCoin.setNote(note);

                priorityCoin.setGoodPrice(false);
                if (this_token_is_good_price || btc_is_good_price) {
                    priorityCoin.setGoodPrice(true);
                }

                index += 1;
                priorityCoinRepository.save(priorityCoin);

                sql_update_ema += String.format(
                        " update binance_volumn_week set ema='%s', price_change_24h='%s', gecko_volume='%s' where gecko_id='%s' and symbol='%s' and yyyymmdd=TO_CHAR(NOW(), 'yyyyMMdd'); \n",
                        dto.getEma07d(), dto.getPrice_change_percentage_24h(), dto.getVol0d(), dto.getGecko_id(),
                        dto.getSymbol());

                if (isOrderByBynaceVolume) {
                    if (is_candidate || (dto.getTop10_vol_up() && dto.getEma07d().compareTo(BigDecimal.ZERO) > 0)) {
                        list.add(css);
                    }
                } else {
                    list.add(css);
                }
            }
            query = entityManager.createNativeQuery(sql_update_ema);
            query.executeUpdate();
            log.info("End getList <--");

            return list;

        } catch (

        Exception e) {
            e.printStackTrace();
            log.info("Get list Inquiry Consigned Delivery error ------->");
            log.error(e.getMessage());
            return new ArrayList<CandidateTokenCssResponse>();
        }
    }

    private void setEmaCss(CandidateTokenCssResponse css) {
        if (!css.getToday_ema().contains("-") && css.getDay_0_ema().contains("-")) {
            css.setToday_ema_css("text-primary font-weight-bold");
        } else if (css.getToday_ema().contains("-")) {
            css.setToday_ema_css("text-danger");
        } else {
            css.setToday_ema_css("text-primary");
        }

        if (!css.getDay_0_ema().contains("-")) {
            css.setDay_0_ema_css("text-primary");
        } else if (css.getDay_0_ema().contains("-")) {
            css.setDay_0_ema_css("text-danger");
        }

        if (!css.getDay_1_ema().contains("-")) {
            css.setDay_1_ema_css("text-primary");
        } else if (css.getDay_1_ema().contains("-")) {
            css.setDay_1_ema_css("text-danger");
        }

        if (!css.getDay_2_ema().contains("-")) {
            css.setDay_2_ema_css("text-primary");
        } else if (css.getDay_2_ema().contains("-")) {
            css.setDay_2_ema_css("text-danger");
        }

        if (!css.getDay_3_ema().contains("-")) {
            css.setDay_3_ema_css("text-primary");
        } else if (css.getDay_3_ema().contains("-")) {
            css.setDay_3_ema_css("text-danger");
        }

        if (!css.getDay_4_ema().contains("-")) {
            css.setDay_4_ema_css("text-primary");
        } else if (css.getDay_4_ema().contains("-")) {
            css.setDay_4_ema_css("text-danger");
        }

        if (!css.getDay_5_ema().contains("-")) {
            css.setDay_5_ema_css("text-primary");
        } else if (css.getDay_5_ema().contains("-")) {
            css.setDay_5_ema_css("text-danger");
        }

        if (!css.getDay_6_ema().contains("-")) {
            css.setDay_6_ema_css("text-primary");
        } else if (css.getDay_6_ema().contains("-")) {
            css.setDay_6_ema_css("text-danger");
        }

        if (!css.getDay_7_ema().contains("-")) {
            css.setDay_7_ema_css("text-primary");
        } else if (css.getDay_7_ema().contains("-")) {
            css.setDay_7_ema_css("text-danger");
        }

        if (!css.getDay_8_ema().contains("-")) {
            css.setDay_8_ema_css("text-primary");
        } else if (css.getDay_8_ema().contains("-")) {
            css.setDay_8_ema_css("text-danger");
        }

        if (!css.getDay_9_ema().contains("-")) {
            css.setDay_9_ema_css("text-primary");
        } else if (css.getDay_9_ema().contains("-")) {
            css.setDay_9_ema_css("text-danger");
        }

        if (!css.getDay_10_ema().contains("-")) {
            css.setDay_10_ema_css("text-primary");
        } else if (css.getDay_10_ema().contains("-")) {
            css.setDay_10_ema_css("text-danger");
        }

        if (!css.getDay_11_ema().contains("-")) {
            css.setDay_11_ema_css("text-primary");
        } else if (css.getDay_11_ema().contains("-")) {
            css.setDay_11_ema_css("text-danger");
        }

    }

    private Long getValue(String value) {
        if (Objects.equals(null, value) || Objects.equals("", value))
            return Long.valueOf(0);

        return Long.valueOf(value);

    }

    private int getIndexMax(List<String> list) {
        int max_idx = 0;
        String str_temp = "";
        BigDecimal temp = BigDecimal.ZERO;
        BigDecimal max_val = BigDecimal.ZERO;

        for (int idx = 0; idx < list.size(); idx++) {
            str_temp = String.valueOf(list.get(idx)).replace(",", "");

            if (!Objects.equals("", str_temp)) {

                temp = Utils.getBigDecimal(str_temp);
                if (temp.compareTo(max_val) == 1) {
                    max_val = temp;
                    max_idx = idx;
                }
            }
        }

        return max_idx;
    }

    private int getIndexMin(List<String> list) {
        int min_idx = 0;
        String str_temp = "";
        BigDecimal temp = BigDecimal.ZERO;
        BigDecimal min_val = BigDecimal.valueOf(Long.MAX_VALUE);

        for (int idx = 0; idx < list.size(); idx++) {
            str_temp = String.valueOf(list.get(idx)).replace(",", "");

            if (!Objects.equals("", str_temp)) {

                temp = Utils.getBigDecimal(str_temp);
                if (temp.compareTo(min_val) == -1) {
                    min_val = temp;
                    min_idx = idx;
                }
            }
        }

        return min_idx;
    }

    private void setVolumnDayCss(CandidateTokenCssResponse css, int index, String css_class) {
        switch (index) {
        case 0:
            css.setToday_vol_css(css_class);
            break;
        case 1:
            css.setDay_0_vol_css(css_class);
            break;
        case 2:
            css.setDay_1_vol_css(css_class);
            break;
        case 3:
            css.setDay_2_vol_css(css_class);
            break;
        case 4:
            css.setDay_3_vol_css(css_class);
            break;
        case 5:
            css.setDay_4_vol_css(css_class);
            break;
        case 6:
            css.setDay_5_vol_css(css_class);
            break;
        case 7:
            css.setDay_6_vol_css(css_class);
            break;
        case 8:
            css.setDay_7_vol_css(css_class);
            break;
        case 9:
            css.setDay_8_vol_css(css_class);
            break;
        case 10:
            css.setDay_9_vol_css(css_class);
            break;
        case 11:
            css.setDay_10_vol_css(css_class);
            break;
        case 12:
            css.setDay_11_vol_css(css_class);
            break;
        case 13:
            css.setDay_12_vol_css(css_class);
            break;
        }
    }

    private void setPriceDayCss(CandidateTokenCssResponse css, int index, String css_class, String percent) {
        switch (index) {
        case 0:
            css.setToday_price_css(css_class);
            css.setToday_price(css.getToday_price() + percent);
            break;
        case 1:
            css.setDay_0_price_css(css_class);
            css.setDay_0_price(css.getDay_0_price() + percent);
            break;
        case 2:
            css.setDay_1_price_css(css_class);
            css.setDay_1_price(css.getDay_1_price() + percent);
            break;
        case 3:
            css.setDay_2_price_css(css_class);
            css.setDay_2_price(css.getDay_2_price() + percent);
            break;
        case 4:
            css.setDay_3_price_css(css_class);
            css.setDay_3_price(css.getDay_3_price() + percent);
            break;
        case 5:
            css.setDay_4_price_css(css_class);
            css.setDay_4_price(css.getDay_4_price() + percent);
            break;
        case 6:
            css.setDay_5_price_css(css_class);
            css.setDay_5_price(css.getDay_5_price() + percent);
            break;
        case 7:
            css.setDay_6_price_css(css_class);
            css.setDay_6_price(css.getDay_6_price() + percent);
            break;
        case 8:
            css.setDay_7_price_css(css_class);
            css.setDay_7_price(css.getDay_7_price() + percent);
            break;
        case 9:
            css.setDay_8_price_css(css_class);
            css.setDay_8_price(css.getDay_8_price() + percent);
            break;
        case 10:
            css.setDay_9_price_css(css_class);
            css.setDay_9_price(css.getDay_9_price() + percent);
            break;
        case 11:
            css.setDay_10_price_css(css_class);
            css.setDay_10_price(css.getDay_10_price() + percent);
            break;
        case 12:
            css.setDay_11_price_css(css_class);
            css.setDay_11_price(css.getDay_11_price() + percent);
            break;
        case 13:
            css.setDay_12_price_css(css_class);
            css.setDay_12_price(css.getDay_12_price() + percent);
            break;
        }
    }

    private List<String> splitVolAndPrice(String value) {
        if (Objects.isNull(value)) {
            return Arrays.asList("", "", "", "", "", "", "");
        }
        String[] arr = value.split("~");

        String volumn = arr[0];
        String avg_price = arr[1];
        String min_price = arr[2];
        String max_price = arr[3];
        volumn = String.format("%,.0f", Utils.getBigDecimal(volumn));

        return Arrays.asList(volumn, Utils.removeLastZero(avg_price), Utils.removeLastZero(min_price),
                Utils.removeLastZero(max_price), arr[4], arr[5], arr[6]);
    }

    @SuppressWarnings("unchecked")
    @Override
    @Transactional
    public void monitorProfit() {
        try {
            log.info("Start monitorProfit ---->");

            Query query = entityManager.createNativeQuery(Utils.sql_OrdersProfitResponse, "OrdersProfitResponse");

            List<OrdersProfitResponse> results = query.getResultList();

            if (!CollectionUtils.isEmpty(results)) {
                int index = 1;
                String msg = "";

                for (OrdersProfitResponse dto : results) {
                    BigDecimal tp_percent = Utils.getBigDecimal(dto.getTp_percent());
                    BigDecimal target_percent = Utils.getBigDecimal(dto.getTarget_percent())
                            .multiply(BigDecimal.valueOf(0.9));

                    if (target_percent.compareTo(BigDecimal.valueOf(5)) < 0) {
                        target_percent = BigDecimal.valueOf(5);
                    }

                    if (tp_percent.compareTo(target_percent) >= 0) {

                        msg += "TakeProfit (target=" + target_percent + "%): "
                                + Utils.createMsgBalance(dto, Utils.new_line_from_service) + Utils.new_line_from_service
                                + Utils.new_line_from_service;

                    } else if (tp_percent.compareTo(BigDecimal.valueOf(-5)) <= 0) {

                        msg += "STOP LOSS 5%: " + Utils.createMsgBalance(dto, Utils.new_line_from_service)
                                + Utils.new_line_from_service + Utils.new_line_from_service;

                    } else if (tp_percent.compareTo(BigDecimal.valueOf(-2.8)) <= 0) {

                        msg += "STOP LOSS 3%: " + Utils.createMsgBalance(dto, Utils.new_line_from_service)
                                + Utils.new_line_from_service + Utils.new_line_from_service;
                    }

                    if (index == 5) {
                        Utils.sendToTelegram(msg);
                        msg = "";
                        index = 1;
                    }
                    index += 1;
                }

                if (Utils.isNotBlank(msg)) {
                    Utils.sendToTelegram(msg);
                    msg = "";
                }
            }

            log.info("End monitorProfit <----");
        } catch (

        Exception e) {
            e.printStackTrace();
            log.info("monitorProfit error ------->");
            log.error(e.getMessage());
        }
    }

    @Override
    @Transactional
    public void monitorBollingerBandwidth() {
        try {
            int minus = Utils.getIntValue(Utils.convertDateToString("mm", Calendar.getInstance().getTime()));

            log.info("Start monitorToken ---->");
            if (minus >= 30) {
                String sql = "" + " select                                                              \n"
                        + "     boll.gecko_id,                                                          \n"
                        + "     boll.symbol,                                                            \n"
                        + "     boll.name,                                                              \n"
                        + "     boll.avg_price,                                                         \n"
                        + "     boll.price_open_candle,                                                 \n"
                        + "     boll.price_close_candle,                                                \n"
                        + "     boll.low_price,                                                         \n"
                        + "     boll.hight_price,                                                       \n"
                        + "     boll.price_can_buy,                                                     \n"
                        + "     boll.price_can_sell,                                                    \n"
                        + "     boll.is_bottom_area,                                                    \n"
                        + "     boll.is_top_area,                                                       \n"
                        + "     ROUND(100*(price_can_sell - price_can_buy)/price_can_buy, 2) as profit,                                             \n"
                        + "     (case when vector.vector_now > 0 then true else false end)   as vector_up,                                          \n"
                        + "     concat('v1h:', cast(vector.vector_now as varchar), ', v4h:' ,cast(vector.vector_pre4h as varchar)) as vector_desc   \n"
                        + " FROM                                                                        \n"
                        + Utils.sql_boll_2_body + " , \n"
                        + " (                                                                                           \n"
                        + "  select                                                                                     \n"
                        + "       pre.gecko_id,                                                                         \n"
                        + "       pre.hh,                                                                               \n"
                        + "       ROUND(100 * (price_now   - price_pre4h) /price_pre4h, 2)  as vector_now,              \n"
                        + "       ROUND(100 * (price_pre4h - price_pre8h) /price_pre8h, 2)  as vector_pre4h             \n"
                        + "   from (                                                                                    \n"
                        + "       select                                                                                \n"
                        + "       tmp.gecko_id,                                                                         \n"
                        + "       tmp.hh,                                                                               \n"
                        + "       (case when price_now is null then price_pre1h else price_now end) as price_now,       \n"
                        + "          price_pre4h,                                                                       \n"
                        + "          price_pre8h                                                                        \n"
                        + "       from (                                                                                \n"
                        + "           select                                                                            \n"
                        + "               d.gecko_id,                                                                   \n"
                        + "               d.hh, \n"
                        + "               (select COALESCE(h.avg_price, 0) from btc_volumn_day h where h.gecko_id = d.gecko_id and h.hh = TO_CHAR(NOW(), 'HH24')) as price_now,                          \n"
                        + "               (select COALESCE(h.avg_price, 0) from btc_volumn_day h where h.gecko_id = d.gecko_id and h.hh = TO_CHAR(NOW() - interval  '1 hours', 'HH24')) as price_pre1h,  \n"
                        + "                                                                                             \n"
                        + "               (select ROUND(AVG(COALESCE(h.avg_price, 0)), 5) from btc_volumn_day h where h.gecko_id = d.gecko_id and h.hh between TO_CHAR(NOW() - interval  '4 hours', 'HH24') and TO_CHAR(NOW() - interval  '1 hours', 'HH24')) as price_pre4h,   \n"
                        + "               (select ROUND(AVG(COALESCE(h.avg_price, 0)), 5) from btc_volumn_day h where h.gecko_id = d.gecko_id and h.hh between TO_CHAR(NOW() - interval  '8 hours', 'HH24') and TO_CHAR(NOW() - interval  '5 hours', 'HH24')) as price_pre8h    \n"
                        + "           from  \n"
                        + "               btc_volumn_day d \n"
                        + "           where d.hh = (case when EXTRACT(MINUTE FROM NOW()) < 3 then TO_CHAR(NOW() - interval '1 hours', 'HH24') else TO_CHAR(NOW(), 'HH24') end) \n"
                        + "           ) as tmp                                                                          \n"
                        + "   ) as pre                                                                                  \n"
                        + " ) vector                                                                                    \n"
                        + "                                                                                             \n"
                        + " where 1=1                                                                                   \n"
                        + " and (abs(price_can_sell-price_can_buy) < 3*abs(price_close_candle-price_open_candle))       \n"
                        + " and vector.gecko_id = boll.gecko_id                                                         \n"
                        + " order by ROUND(100*(price_can_sell - price_can_buy)/price_can_buy, 2) desc                  \n";

                Query query = entityManager.createNativeQuery(sql, "BollAreaResponse");

                @SuppressWarnings("unchecked")
                List<BollAreaResponse> boll_anna_list = query.getResultList();
                if (!CollectionUtils.isEmpty(boll_anna_list)) {

                    List<BollArea> list = new ArrayList<BollArea>();
                    for (BollAreaResponse dto : boll_anna_list) {
                        BollArea entiy = (new ModelMapper()).map(dto, BollArea.class);
                        list.add(entiy);

                        String id = "";
                        if (dto.getIs_bottom_area()
                                && (Utils.getBigDecimal(dto.getProfit()).compareTo(BigDecimal.valueOf(5)) > 0)) {

                            id = dto.getGecko_id();
                        } else {
                            BigDecimal loss_percent = Utils
                                    .getBigDecimalValue(Utils.toPercent(dto.getPrice_can_buy(), dto.getAvg_price(), 1));

                            if (loss_percent.compareTo(BigDecimal.valueOf(-1.5)) > 0) {
                                id = dto.getGecko_id();
                            }
                        }

                        if (Utils.isNotBlank(id)) {
                            //Boolean isRegisted = bollAreaRepository.existsById(id);
                            //PriorityCoin coin = priorityCoinRepository.findById(id).orElse(null);
                            //if (!isRegisted && !Objects.equals(null, coin) && (coin.getVmc() > 25)) {
                            //    Utils.sendToTelegram(
                            //            "(Bollinger) " + Utils.createMsgPriorityToken(coin, Utils.new_line_from_service));
                            //}
                        }
                    }

                    bollAreaRepository.deleteAll();
                    bollAreaRepository.saveAll(list);
                }
            }

            if (minus >= 30) {
                String sql = " select                                                                       \n"
                        + "     gecko_id,                                                                   \n"
                        + "     symbol,                                                                     \n"
                        + "     hh,                                                                         \n"
                        + "     curr_voulme,                                                                \n"
                        + "     avg_vol_pre4h,                                                              \n"
                        + "     ROUND(vol.curr_voulme / avg_vol_pre4h, 1) as vol_up_rate                    \n"
                        + " from                                                                            \n"
                        + " (                                                                               \n"
                        + "     select                                                                      \n"
                        + "         gecko_id,                                                               \n"
                        + "         symbol,                                                                 \n"
                        + "         hh,                                                                     \n"
                        + "         ROUND(total_volume/1000000, 1) as curr_voulme,                          \n"
                        + "         (select ROUND(AVG(COALESCE(h.total_volume, 0))/1000000, 1) from gecko_volumn_day h where h.gecko_id = d.gecko_id and h.hh between TO_CHAR(NOW() - interval  '4 hours', 'HH24') and TO_CHAR(NOW() - interval  '1 hours', 'HH24')) as avg_vol_pre4h \n"
                        + "     from gecko_volumn_day d                                                     \n"
                        + "     where d.hh = (case when EXTRACT(MINUTE FROM NOW()) < 15 then TO_CHAR(NOW() - interval '1 hours', 'HH24') else TO_CHAR(NOW(), 'HH24') end) \n"
                        + " ) vol                                                                           \n"
                        + " where                                                                           \n"
                        + "     avg_vol_pre4h > 0                                                           \n"
                        + " order by                                                                        \n"
                        + "     vol.curr_voulme / avg_vol_pre4h desc                                        \n";

                Query query = entityManager.createNativeQuery(sql, "GeckoVolumeUpPre4hResponse");

                @SuppressWarnings("unchecked")
                List<GeckoVolumeUpPre4hResponse> vol_list = query.getResultList();
                if (!CollectionUtils.isEmpty(vol_list)) {
                    geckoVolumeUpPre4hRepository.deleteAll();
                    List<GeckoVolumeUpPre4h> saveList = new ArrayList<GeckoVolumeUpPre4h>();

                    int index = 0;
                    for (GeckoVolumeUpPre4hResponse dto : vol_list) {
                        GeckoVolumeUpPre4h entity = (new ModelMapper()).map(dto, GeckoVolumeUpPre4h.class);
                        entity.setGeckoid(dto.getGecko_id());
                        saveList.add(entity);
                        index += 1;

                        if (index <= 5) {
                            if (!msg_send_dict.containsKey(dto.getGecko_id())) {

                                PriorityCoin coin = priorityCoinRepository.findById(dto.getGecko_id()).orElse(null);
                                if (!Objects.equals(null, coin)) {
                                    Utils.sendToTelegram(
                                            "(VolumeUp) "
                                                    + Utils.createMsgPriorityToken(coin, Utils.new_line_from_service));
                                }

                                msg_send_dict.put(dto.getGecko_id(), dto.getGecko_id());
                            }
                        }
                    }
                    geckoVolumeUpPre4hRepository.saveAll(saveList);

                }
            } else {
                msg_send_dict.clear();
            }

            log.info("End monitorToken <----");
        } catch (Exception e) {
            e.printStackTrace();
            log.info("monitorToken error ------->");
            log.error(e.getMessage());
        }
    }

    @Override
    public List<Orders> getOrderList() {
        return ordersRepository.findAll();
    }

}
