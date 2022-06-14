package bsc_scan_binance.service.impl;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Calendar;
import java.util.Date;
import java.util.List;
import java.util.Objects;

import javax.persistence.EntityManager;
import javax.persistence.PersistenceContext;
import javax.persistence.Query;

import org.modelmapper.ModelMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import bsc_scan_binance.entity.BinanceVolumnDay;
import bsc_scan_binance.entity.BinanceVolumnDayKey;
import bsc_scan_binance.entity.BinanceVolumnWeek;
import bsc_scan_binance.entity.BinanceVolumnWeekKey;
import bsc_scan_binance.entity.PriorityCoin;
import bsc_scan_binance.repository.BinanceVolumnDayRepository;
import bsc_scan_binance.repository.BinanceVolumnWeekRepository;
import bsc_scan_binance.repository.PriorityCoinRepository;
import bsc_scan_binance.response.CandidateTokenCssResponse;
import bsc_scan_binance.response.CandidateTokenResponse;
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

    @Override
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

        for (int idx = limit - 1; idx >= 0; idx--) {
            Object obj_usdt = result_usdt.get(idx);
            Object obj_busd = result_busd.get(idx);

            @SuppressWarnings("unchecked")
            List<Object> arr_usdt = (List<Object>) obj_usdt;
            @SuppressWarnings("unchecked")
            List<Object> arr_busd = (List<Object>) obj_busd;

            BigDecimal price_open = Utils.getBigDecimal(arr_usdt.get(1));
            BigDecimal price_high = Utils.getBigDecimal(arr_usdt.get(2));
            BigDecimal price_low = Utils.getBigDecimal(arr_usdt.get(3));
            BigDecimal price_close = Utils.getBigDecimal(arr_usdt.get(4));
            String close_time = arr_usdt.get(6).toString();

            if (Objects.equals("0", close_time)) {
                price_open = Utils.getBigDecimal(arr_busd.get(1));
                price_high = Utils.getBigDecimal(arr_busd.get(2));
                price_low = Utils.getBigDecimal(arr_busd.get(3));
                price_close = Utils.getBigDecimal(arr_busd.get(4));

                close_time = arr_busd.get(6).toString();
            }

            if (!Objects.equals("0", close_time)) {
                BigDecimal avgPrice = price_low.add(price_high).add(price_open).add(price_close)
                        .divide(BigDecimal.valueOf(4), 5, RoundingMode.CEILING);

                Date date = Utils.getDate(close_time);

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
                    list_day.add(day);
                }

                BinanceVolumnWeek entity = new BinanceVolumnWeek();
                entity.setId(new BinanceVolumnWeekKey(gecko_id, symbol, Utils.convertDateToString("yyyyMMdd", date)));
                entity.setAvgPrice(avgPrice);
                entity.setTotalVolume(total_volume);
                entity.setTotalTrasaction(total_trans);
                entity.setMin_price(price_low);
                entity.setMax_price(price_high);
                list_week.add(entity);
            }
        }

        binanceVolumnDayRepository.saveAll(list_day);
        binanceVolumnWeekRepository.saveAll(list_week);
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
                    for (int i = 0; i < 12; i++) {
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
                for (int i = 0; i < 12; i++) {
                    data.add(0);
                }
                list.add(data);
            }

            return list;
        }

    }

    @Override
    public List<CandidateTokenCssResponse> getList(Boolean isOrderByBynaceVolume) {
        try {
            log.info("Start getList ---->");
            String sql = " select                                                                                 \n"
                    + "   can.gecko_id,                                                                           \n"
                    + "   can.symbol,                                                                             \n"
                    + "   can.name,                                                                               \n"
                    + "                                                                                           \n"
                    + "   ROUND(can.volumn_div_marketcap * 100, 0) volumn_div_marketcap,                          \n"
                    + "                                                                                           \n"
                    + "   ROUND((cur.total_volume / COALESCE ((SELECT (case when pre.total_volume = 0.0 then 1000000000 else pre.total_volume end) FROM public.binance_volumn_day pre WHERE cur.gecko_id = pre.gecko_id AND cur.symbol = pre.symbol AND hh=TO_CHAR((NOW() - interval '4 hours'), 'HH24')), 1000000000) * 100 - 100), 0) pre_4h_total_volume_up, \n"
                    + "   coalesce((SELECT ROUND(pre.total_volume/1000000, 1) FROM public.binance_volumn_day pre WHERE cur.gecko_id = pre.gecko_id AND cur.symbol = pre.symbol AND hh=TO_CHAR((NOW()), 'HH24')), 0)                      as vol_now, 	\n"
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
                    + "   (select concat(w.total_volume, '~', ROUND(w.avg_price, 4), '~', ROUND(w.min_price, 4), '~', ROUND(w.max_price, 4)) from binance_volumn_week w where w.gecko_id = can.gecko_id and w.symbol = can.symbol and yyyymmdd = TO_CHAR(NOW() + interval '1 days', 'yyyyMMdd')) as today,  \n"
                    + "   (select concat(w.total_volume, '~', ROUND(w.avg_price, 4), '~', ROUND(w.min_price, 4), '~', ROUND(w.max_price, 4)) from binance_volumn_week w where w.gecko_id = can.gecko_id and w.symbol = can.symbol and yyyymmdd = TO_CHAR(NOW(), 'yyyyMMdd'))                     as day_0,  \n"
                    + "   (select concat(w.total_volume, '~', ROUND(w.avg_price, 4), '~', ROUND(w.min_price, 4), '~', ROUND(w.max_price, 4)) from binance_volumn_week w where w.gecko_id = can.gecko_id and w.symbol = can.symbol and yyyymmdd = TO_CHAR(NOW() - interval '1 days', 'yyyyMMdd')) as day_1,  \n"
                    + "   (select concat(w.total_volume, '~', ROUND(w.avg_price, 4), '~', ROUND(w.min_price, 4), '~', ROUND(w.max_price, 4)) from binance_volumn_week w where w.gecko_id = can.gecko_id and w.symbol = can.symbol and yyyymmdd = TO_CHAR(NOW() - interval '2 days', 'yyyyMMdd')) as day_2,  \n"
                    + "   (select concat(w.total_volume, '~', ROUND(w.avg_price, 4), '~', ROUND(w.min_price, 4), '~', ROUND(w.max_price, 4)) from binance_volumn_week w where w.gecko_id = can.gecko_id and w.symbol = can.symbol and yyyymmdd = TO_CHAR(NOW() - interval '3 days', 'yyyyMMdd')) as day_3,  \n"
                    + "   (select concat(w.total_volume, '~', ROUND(w.avg_price, 4), '~', ROUND(w.min_price, 4), '~', ROUND(w.max_price, 4)) from binance_volumn_week w where w.gecko_id = can.gecko_id and w.symbol = can.symbol and yyyymmdd = TO_CHAR(NOW() - interval '4 days', 'yyyyMMdd')) as day_4,  \n"
                    + "   (select concat(w.total_volume, '~', ROUND(w.avg_price, 4), '~', ROUND(w.min_price, 4), '~', ROUND(w.max_price, 4)) from binance_volumn_week w where w.gecko_id = can.gecko_id and w.symbol = can.symbol and yyyymmdd = TO_CHAR(NOW() - interval '5 days', 'yyyyMMdd')) as day_5,  \n"
                    + "   (select concat(w.total_volume, '~', ROUND(w.avg_price, 4), '~', ROUND(w.min_price, 4), '~', ROUND(w.max_price, 4)) from binance_volumn_week w where w.gecko_id = can.gecko_id and w.symbol = can.symbol and yyyymmdd = TO_CHAR(NOW() - interval '6 days', 'yyyyMMdd')) as day_6,  \n"
                    + "   (select concat(w.total_volume, '~', ROUND(w.avg_price, 4), '~', ROUND(w.min_price, 4), '~', ROUND(w.max_price, 4)) from binance_volumn_week w where w.gecko_id = can.gecko_id and w.symbol = can.symbol and yyyymmdd = TO_CHAR(NOW() - interval '7 days', 'yyyyMMdd')) as day_7,  \n"
                    + "   (select concat(w.total_volume, '~', ROUND(w.avg_price, 4), '~', ROUND(w.min_price, 4), '~', ROUND(w.max_price, 4)) from binance_volumn_week w where w.gecko_id = can.gecko_id and w.symbol = can.symbol and yyyymmdd = TO_CHAR(NOW() - interval '8 days', 'yyyyMMdd')) as day_8,  \n"
                    + "   (select concat(w.total_volume, '~', ROUND(w.avg_price, 4), '~', ROUND(w.min_price, 4), '~', ROUND(w.max_price, 4)) from binance_volumn_week w where w.gecko_id = can.gecko_id and w.symbol = can.symbol and yyyymmdd = TO_CHAR(NOW() - interval '9 days', 'yyyyMMdd')) as day_9,  \n"
                    + "   (select concat(w.total_volume, '~', ROUND(w.avg_price, 4), '~', ROUND(w.min_price, 4), '~', ROUND(w.max_price, 4)) from binance_volumn_week w where w.gecko_id = can.gecko_id and w.symbol = can.symbol and yyyymmdd = TO_CHAR(NOW() - interval '10 days', 'yyyyMMdd')) as day_10, \n"
                    + "   (select concat(w.total_volume, '~', ROUND(w.avg_price, 4), '~', ROUND(w.min_price, 4), '~', ROUND(w.max_price, 4)) from binance_volumn_week w where w.gecko_id = can.gecko_id and w.symbol = can.symbol and yyyymmdd = TO_CHAR(NOW() - interval '11 days', 'yyyyMMdd')) as day_11, \n"
                    + "   (select concat(w.total_volume, '~', ROUND(w.avg_price, 4), '~', ROUND(w.min_price, 4), '~', ROUND(w.max_price, 4)) from binance_volumn_week w where w.gecko_id = can.gecko_id and w.symbol = can.symbol and yyyymmdd = TO_CHAR(NOW() - interval '12 days', 'yyyyMMdd')) as day_12, \n"

                    + "   can.priority 	                                                                          \n"
                    + "                                                                                           \n"
                    + " from                                                                                      \n"
                    + "   candidate_coin can,                                                                     \n"
                    + "   binance_volumn_day cur                                                                  \n"
                    + "                                                                                           \n"
                    + " where                                                                                     \n"
                    + "       cur.hh = TO_CHAR(NOW(), 'HH24')                                                     \n"
                    + "   and can.gecko_id = cur.gecko_id                                                         \n"
                    + "   and can.symbol = cur.symbol                                                             \n";

            if (isOrderByBynaceVolume) {
                sql = " select * from ( 																		  \n"
                        + sql + " ) can                                                                           \n"
                        + " ORDER BY 																			  \n"
                        + "  COALESCE(can.priority, 3) ASC, 													  \n"
                        + " (CAST(can.vol_now * 1000000 AS money) / (case when CAST(can.market_cap AS money) = CAST(0 AS money) then CAST(can.gecko_total_volume AS money)  else CAST(can.market_cap AS money) end )) desc,  \n"
                        + " can.volumn_div_marketcap desc \n";
            } else {
                sql += " order by                                                                                 \n"
                        + "   coalesce(can.priority, 3) asc,                                            		  \n"
                        + "   can.volumn_div_marketcap desc                                                       \n";
            }

            Query query = entityManager.createNativeQuery(sql, "CandidateTokenResponse");

            @SuppressWarnings("unchecked")
            List<CandidateTokenResponse> results = query.getResultList();
            List<CandidateTokenCssResponse> list = new ArrayList<CandidateTokenCssResponse>();
            ModelMapper mapper = new ModelMapper();
            Integer index = 1;
            for (CandidateTokenResponse dto : results) {
                PriorityCoin coin = new PriorityCoin();
                coin.setGeckoid(dto.getGecko_id());

                CandidateTokenCssResponse css = new CandidateTokenCssResponse();
                mapper.map(dto, css);

                BigDecimal price_now = Utils.getBigDecimal(dto.getPrice_now());
                BigDecimal market_cap = Utils.getBigDecimal(dto.getMarket_cap());
                BigDecimal gecko_total_volume = Utils.getBigDecimal(dto.getGecko_total_volume());

                if ((market_cap.compareTo(BigDecimal.valueOf(36000001)) < 0)
                        && (market_cap.compareTo(BigDecimal.valueOf(1000000)) > 0)) {
                    css.setMarket_cap_css("highlight");
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
                volList.add(temp.get(0));
                avgPriceList.add(temp.get(1));
                lowPriceList.add(temp.get(2));
                hightPriceList.add(temp.get(3));

                temp = splitVolAndPrice(css.getDay_2());
                css.setDay_2_vol(temp.get(0));
                css.setDay_2_price(temp.get(1));
                volList.add(temp.get(0));
                avgPriceList.add(temp.get(1));
                lowPriceList.add(temp.get(2));
                hightPriceList.add(temp.get(3));

                temp = splitVolAndPrice(css.getDay_3());
                css.setDay_3_vol(temp.get(0));
                css.setDay_3_price(temp.get(1));
                volList.add(temp.get(0));
                avgPriceList.add(temp.get(1));
                lowPriceList.add(temp.get(2));
                hightPriceList.add(temp.get(3));

                temp = splitVolAndPrice(css.getDay_4());
                css.setDay_4_vol(temp.get(0));
                css.setDay_4_price(temp.get(1));
                volList.add(temp.get(0));
                avgPriceList.add(temp.get(1));
                lowPriceList.add(temp.get(2));
                hightPriceList.add(temp.get(3));

                temp = splitVolAndPrice(css.getDay_5());
                css.setDay_5_vol(temp.get(0));
                css.setDay_5_price(temp.get(1));
                volList.add(temp.get(0));
                avgPriceList.add(temp.get(1));
                lowPriceList.add(temp.get(2));
                hightPriceList.add(temp.get(3));

                temp = splitVolAndPrice(css.getDay_6());
                css.setDay_6_vol(temp.get(0));
                css.setDay_6_price(temp.get(1));
                volList.add(temp.get(0));
                avgPriceList.add(temp.get(1));
                lowPriceList.add(temp.get(2));
                hightPriceList.add(temp.get(3));

                temp = splitVolAndPrice(css.getDay_7());
                css.setDay_7_vol(temp.get(0));
                css.setDay_7_price(temp.get(1));
                volList.add(temp.get(0));
                avgPriceList.add(temp.get(1));
                lowPriceList.add(temp.get(2));
                hightPriceList.add(temp.get(3));

                temp = splitVolAndPrice(css.getDay_8());
                css.setDay_8_vol(temp.get(0));
                css.setDay_8_price(temp.get(1));
                volList.add(temp.get(0));
                avgPriceList.add(temp.get(1));
                lowPriceList.add(temp.get(2));
                hightPriceList.add(temp.get(3));

                temp = splitVolAndPrice(css.getDay_9());
                css.setDay_9_vol(temp.get(0));
                css.setDay_9_price(temp.get(1));
                volList.add(temp.get(0));
                avgPriceList.add(temp.get(1));
                lowPriceList.add(temp.get(2));
                hightPriceList.add(temp.get(3));

                temp = splitVolAndPrice(css.getDay_10());
                css.setDay_10_vol(temp.get(0));
                css.setDay_10_price(temp.get(1));
                volList.add(temp.get(0));
                avgPriceList.add(temp.get(1));
                lowPriceList.add(temp.get(2));
                hightPriceList.add(temp.get(3));

                temp = splitVolAndPrice(css.getDay_11());
                css.setDay_11_vol(temp.get(0));
                css.setDay_11_price(temp.get(1));
                volList.add(temp.get(0));
                avgPriceList.add(temp.get(1));
                lowPriceList.add(temp.get(2));
                hightPriceList.add(temp.get(3));

                temp = splitVolAndPrice(css.getDay_12());
                css.setDay_12_vol(temp.get(0));
                css.setDay_12_price(temp.get(1));
                volList.add(temp.get(0));
                avgPriceList.add(temp.get(1));
                lowPriceList.add(temp.get(2));
                hightPriceList.add(temp.get(3));

                int idx_vol_max = getIndexMax(volList);
                int idx_price_max = getIndexMax(avgPriceList);
                int idx_vol_min = getIndexMin(volList);
                int idx_price_min = getIndexMin(avgPriceList);
                int idx_lowprice_min = getIndexMin(lowPriceList);
                int idx_hightprice_max = getIndexMax(hightPriceList);

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
                        .getBigDecimalValue(Utils.toPercent(lowest_price_today, price_now));
                BigDecimal taget_percent_profit_today = Utils
                        .getBigDecimalValue(Utils.toPercent(highest_price_today, price_now));

                css.setLow_to_hight_price(
                        "L:" + lowest_price_today + "(" + taget_percent_lost_today + "%)➞H:"
                                + highest_price_today + "(" + taget_percent_profit_today.toString().replace(".0", "")
                                + "%)");

                coin.setCurrent_price(price_now);

                if (avg_price.compareTo(BigDecimal.ZERO) > 0) {

                    if (avg_price.compareTo(price_now) < 1) {
                        css.setAvg_price_css("text-primary font-weight-bold");
                    } else {
                        css.setAvg_price_css("text-danger font-weight-bold");
                    }
                    BigDecimal percent = ((price_now.divide(avg_price, 2, RoundingMode.CEILING)
                            .multiply(BigDecimal.valueOf(100))).subtract(BigDecimal.valueOf(100)));

                    css.setAvg_price(Utils.removeLastZero(avg_price.toString()));
                    css.setAvg_percent(percent.toString().replace(".00", "") + "%");
                    css.setAvg_price(Utils.removeLastZero(avg_price.toString()));
                    css.setMin_price(Utils.removeLastZero(avgPriceList.get(idx_price_min)));
                    css.setMax_price(Utils.removeLastZero(avgPriceList.get(idx_price_max)));

                    if (Objects.equals("", css.getStar()) && (percent.compareTo(BigDecimal.valueOf(5)) < 1)
                            && ((Utils.getBigDecimalValue(css.getVolumn_div_marketcap())
                                    .compareTo(BigDecimal.valueOf(10)) > -1))) {
                        css.setStar("🤩");
                    }
                }

                {
                    // tp_price: x2:aaa$ or 50%: bbb$ or 20%:ccc$ 10%:ddd$
                    // stop_limit: price_min * 0.95
                    // stop_price: price_min * 0.945

                    // star.contains("🤩")
                    BigDecimal price_min = Utils.getBigDecimal(avgPriceList.get(idx_price_min));
                    BigDecimal price_max = Utils.getBigDecimal(avgPriceList.get(idx_price_max));

                    BigDecimal lowprice_min = Utils.getBigDecimal(lowPriceList.get(idx_lowprice_min));
                    BigDecimal hightprice_max = Utils.getBigDecimal(hightPriceList.get(idx_hightprice_max))
                            .multiply(BigDecimal.valueOf(0.9));

                    BigDecimal stop_limit_1 = price_min.multiply(BigDecimal.valueOf(0.95));
                    BigDecimal stop_price_1 = price_min.multiply(BigDecimal.valueOf(0.945));

                    String percent_hightprice_max = Utils.toPercent(hightprice_max, price_now);
                    String percent_stop_limit_1 = Utils.toPercent(stop_limit_1, price_now);

                    String oco_tp_price = "" + "50%:"
                            + Utils.formatPrice(price_now.multiply(BigDecimal.valueOf(1.5)), 5).toString() + "―20%:"
                            + Utils.formatPrice(price_now.multiply(BigDecimal.valueOf(1.2)), 5).toString() + "―10%:"
                            + Utils.formatPrice(price_now.multiply(BigDecimal.valueOf(1.1)), 5).toString() + "―M("
                            + Utils.toPercent(price_max, price_now) + "%):"
                            + Utils.formatPrice(price_max.multiply(BigDecimal.valueOf(0.95)), 5).toString() + "―";

                    css.setOco_tp_price_hight("H(" + percent_hightprice_max + "%):"
                            + Utils.formatPrice(hightprice_max, 5).toString());

                    String oco_stop_limit = "" + " SL1(-10%):"
                            + Utils.formatPrice(price_now.multiply(BigDecimal.valueOf(0.9)), 5).toString()
                            + "―SL_M(" + percent_stop_limit_1 + "%):"
                            + Utils.formatPrice(stop_limit_1, 5).toString() + "―";

                    String oco_stop_price = " SP1(-10%):"
                            + Utils.formatPrice(price_now.multiply(BigDecimal.valueOf(0.895)), 5).toString()
                            + "―SP_M(" + Utils.toPercent(stop_price_1, price_now) + "%):"
                            + Utils.formatPrice(stop_price_1, 5).toString();

                    BigDecimal stop_limit_2 = lowprice_min.multiply(BigDecimal.valueOf(0.95));
                    BigDecimal stop_price_2 = lowprice_min.multiply(BigDecimal.valueOf(0.945));

                    String oco_stop_limit_low_percent = Utils.toPercent(stop_limit_2, price_now);
                    String oco_stop_limit_low = "SL_Low(" + oco_stop_limit_low_percent + "%):"
                            + Utils.formatPrice(stop_limit_2, 5).toString();
                    if (!Objects.equals("[dvz]", oco_stop_limit_low_percent)
                            && Utils.getBigDecimalValue(oco_stop_limit_low_percent)
                                    .compareTo(BigDecimal.valueOf(-10)) > 0) {
                        css.setOco_stop_limit_low_css("text-primary font-weight-bold");
                    }

                    oco_stop_price += "―SP_Low(" + Utils.toPercent(stop_price_2, price_now) + "%):"
                            + Utils.formatPrice(stop_price_2, 5).toString();

                    String oco_low_hight = " (L:" + lowprice_min.toString() + "~M:" + price_min + "~H:"
                            + hightprice_max.toString() + "=" + Utils.toPercent(hightprice_max, lowprice_min)
                            + "%)";

                    if (Utils.getBigDecimalValue(percent_hightprice_max).compareTo(
                            Utils.getBigDecimalValue(percent_stop_limit_1).multiply(BigDecimal.valueOf(1.5))) < 1) {
                        css.setStar("✖");
                        css.setStar_css("text-danger");
                        css.setOco_css("text-white");
                    } else if (Utils.getBigDecimalValue(percent_hightprice_max)
                            .compareTo(BigDecimal.valueOf(50)) >= 0) {
                        css.setOco_tp_price_hight_css("text-primary font-weight-bold");
                    }

                    css.setOco_tp_price(oco_tp_price);
                    css.setOco_stop_limit(oco_stop_limit);
                    css.setOco_stop_limit_low(oco_stop_limit_low);
                    css.setOco_stop_price(oco_stop_price);
                    css.setOco_low_hight(oco_low_hight);
                }

                coin.setTarget_price(Utils.getBigDecimalValue(css.getAvg_price()));
                coin.setTarget_percent(
                        Utils.getStringValue(css.getAvg_percent()).replace("-", "")
                                + "(" + css.getMin_price() + "->" + css.getMax_price() + ")");
                String oco_hight = css.getOco_tp_price() + css.getOco_tp_price_hight();
                oco_hight = oco_hight.substring(oco_hight.indexOf("―M") + 1, oco_hight.length());
                coin.setOco_hight(oco_hight);

                Boolean is_candidate = false;
                if (!Objects.equals("", Utils.getStringValue(css.getOco_tp_price_hight_css()))) {
                    //String avg_percent = css.getAvg_percent().replace("%", "");
                    //if (Utils.getBigDecimalValue(avg_percent).compareTo(BigDecimal.valueOf(-10)) <= 0) {
                        is_candidate = true;
                    //}
                }
                coin.setCandidate(is_candidate);
                coin.setIndex(index);
                coin.setSymbol(css.getSymbol());
                coin.setName(css.getName());
                coin.setNote("(v/mc:" +
                        css.getVolumn_div_marketcap() + "% B:" + css.getVolumn_binance_div_marketcap() + "%) " +
                        Utils.getStringValue(css.getNote()) + " " + Utils.getStringValue(css.getTrend()));

                index += 1;
                priorityCoinRepository.save(coin);

                if (isOrderByBynaceVolume) {
                    if (css.getStar().contains("🤩")) {
                        list.add(css);
                    }
                } else {
                    list.add(css);
                }
            }

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
            return Arrays.asList("", "", "", "");
        }
        String[] arr = value.split("~");
        if (arr.length != 4) {
            return Arrays.asList(value, "", "", "");
        }

        String volumn = arr[0];
        String avg_price = arr[1];
        String min_price = arr[2];
        String max_price = arr[3];
        volumn = String.format("%,.0f", Utils.getBigDecimal(volumn));

        return Arrays.asList(volumn, Utils.removeLastZero(avg_price), Utils.removeLastZero(min_price),
                Utils.removeLastZero(max_price));
    }

}
