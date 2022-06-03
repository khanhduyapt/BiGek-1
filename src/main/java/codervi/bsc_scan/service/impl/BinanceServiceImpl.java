package codervi.bsc_scan.service.impl;

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

import codervi.bsc_scan.entity.BinanceVolumnDay;
import codervi.bsc_scan.entity.BinanceVolumnDayKey;
import codervi.bsc_scan.entity.BinanceVolumnWeek;
import codervi.bsc_scan.entity.BinanceVolumnWeekKey;
import codervi.bsc_scan.repository.BinanceVolumnDayRepository;
import codervi.bsc_scan.repository.BinanceVolumnWeekRepository;
import codervi.bsc_scan.response.CandidateTokenCssResponse;
import codervi.bsc_scan.response.CandidateTokenResponse;
import codervi.bsc_scan.service.BinanceService;
import codervi.bsc_scan.utils.Utils;
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

    @Override
    public void loadData(String gecko_id, String symbol) {
        final Integer limit = 14;
        final String url_usdt = "https://api.binance.com/api/v3/klines?symbol=" + symbol + "USDT"
                + "&interval=1d&limit="
                + String.valueOf(limit);

        final String url_busd = "https://api.binance.com/api/v3/klines?symbol=" + symbol + "BUSD"
                + "&interval=1d&limit="
                + String.valueOf(limit);

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

            BigDecimal price_high = Utils.getBigDecimal(arr_usdt.get(2));
            BigDecimal price_low = Utils.getBigDecimal(arr_usdt.get(3));
            String close_time = arr_usdt.get(6).toString();

            if (Objects.equals("0", close_time)) {
                price_high = Utils.getBigDecimal(arr_busd.get(2));
                price_low = Utils.getBigDecimal(arr_busd.get(3));
                close_time = arr_busd.get(6).toString();
            }

            if (!Objects.equals("0", close_time)) {
                BigDecimal avgPrice = price_low.add(price_high).divide(BigDecimal.valueOf(2), 5, RoundingMode.CEILING);
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
    public List<CandidateTokenCssResponse> getList() {
        try {
            log.info("Start getList ---->");
            String sql = " select                                                                               \n" +
                    "   can.gecko_id,                                                                           \n" +
                    "   can.symbol,                                                                             \n" +
                    "   can.name,                                                                               \n" +
                    "                                                                                           \n" +
                    "   ROUND(can.volumn_div_marketcap * 100, 0) volumn_div_marketcap,                          \n" +

                    " ROUND((cur.total_volume / COALESCE ((SELECT pre.total_volume FROM public.binance_volumn_day pre WHERE cur.gecko_id = pre.gecko_id AND cur.symbol = pre.symbol AND hh=TO_CHAR((NOW() - interval '4 hours'), 'HH24')), cur.total_volume) * 100 - 100), 0) pre_4h_total_volume_up, \n"
                    +
                    " coalesce((SELECT ROUND(pre.total_volume/1000000, 1) FROM public.binance_volumn_day pre WHERE cur.gecko_id = pre.gecko_id AND cur.symbol = pre.symbol AND hh=TO_CHAR((NOW()), 'HH24')), 0)                      as vol_now, \n"
                    +
                    " coalesce((SELECT ROUND(pre.total_volume/1000000, 1) FROM public.binance_volumn_day pre WHERE cur.gecko_id = pre.gecko_id AND cur.symbol = pre.symbol AND hh=TO_CHAR((NOW() - interval '1 hours'), 'HH24')), 0) as vol_pre_1h, \n"
                    +
                    " coalesce((SELECT ROUND(pre.total_volume/1000000, 1) FROM public.binance_volumn_day pre WHERE cur.gecko_id = pre.gecko_id AND cur.symbol = pre.symbol AND hh=TO_CHAR((NOW() - interval '2 hours'), 'HH24')), 0) as vol_pre_2h, \n"
                    +
                    " coalesce((SELECT ROUND(pre.total_volume/1000000, 1) FROM public.binance_volumn_day pre WHERE cur.gecko_id = pre.gecko_id AND cur.symbol = pre.symbol AND hh=TO_CHAR((NOW() - interval '3 hours'), 'HH24')), 0) as vol_pre_3h, \n"
                    +
                    " coalesce((SELECT ROUND(pre.total_volume/1000000, 1) FROM public.binance_volumn_day pre WHERE cur.gecko_id = pre.gecko_id AND cur.symbol = pre.symbol AND hh=TO_CHAR((NOW() - interval '4 hours'), 'HH24')), 0) as vol_pre_4h, \n"
                    +

                    "   coalesce((SELECT pre.price_at_binance FROM public.binance_volumn_day pre WHERE cur.gecko_id = pre.gecko_id AND cur.symbol = pre.symbol AND hh=TO_CHAR((NOW()), 'HH24')), 0)                      as price_now, \n"
                    +
                    "   coalesce((SELECT pre.price_at_binance FROM public.binance_volumn_day pre WHERE cur.gecko_id = pre.gecko_id AND cur.symbol = pre.symbol AND hh=TO_CHAR((NOW() - interval '1 hours'), 'HH24')), 0) as price_pre_1h, \n"
                    +
                    "   coalesce((SELECT pre.price_at_binance FROM public.binance_volumn_day pre WHERE cur.gecko_id = pre.gecko_id AND cur.symbol = pre.symbol AND hh=TO_CHAR((NOW() - interval '2 hours'), 'HH24')), 0) as price_pre_2h, \n"
                    +
                    "   coalesce((SELECT pre.price_at_binance FROM public.binance_volumn_day pre WHERE cur.gecko_id = pre.gecko_id AND cur.symbol = pre.symbol AND hh=TO_CHAR((NOW() - interval '3 hours'), 'HH24')), 0) as price_pre_3h, \n"
                    +
                    "   coalesce((SELECT pre.price_at_binance FROM public.binance_volumn_day pre WHERE cur.gecko_id = pre.gecko_id AND cur.symbol = pre.symbol AND hh=TO_CHAR((NOW() - interval '4 hours'), 'HH24')), 0) as price_pre_4h, \n"
                    +

                    "                                                                                           \n" +
                    "   can.market_cap ,                                                                        \n" +
                    "   can.current_price,                                                                      \n" +
                    "   can.total_volume                as gecko_total_volume,                                  \n" +

                    " coalesce((SELECT ROUND(pre.total_volume/1000000, 1) FROM public.gecko_volumn_day pre WHERE cur.gecko_id = pre.gecko_id AND cur.symbol = pre.symbol AND hh=TO_CHAR((NOW() - interval '1 hours'), 'HH24')), 0) as gec_vol_pre_1h, \n"
                    +
                    " coalesce((SELECT ROUND(pre.total_volume/1000000, 1) FROM public.gecko_volumn_day pre WHERE cur.gecko_id = pre.gecko_id AND cur.symbol = pre.symbol AND hh=TO_CHAR((NOW() - interval '2 hours'), 'HH24')), 0) as gec_vol_pre_2h, \n"
                    +
                    " coalesce((SELECT ROUND(pre.total_volume/1000000, 1) FROM public.gecko_volumn_day pre WHERE cur.gecko_id = pre.gecko_id AND cur.symbol = pre.symbol AND hh=TO_CHAR((NOW() - interval '3 hours'), 'HH24')), 0) as gec_vol_pre_3h, \n"
                    +
                    " coalesce((SELECT ROUND(pre.total_volume/1000000, 1) FROM public.gecko_volumn_day pre WHERE cur.gecko_id = pre.gecko_id AND cur.symbol = pre.symbol AND hh=TO_CHAR((NOW() - interval '4 hours'), 'HH24')), 0) as gec_vol_pre_4h, \n"
                    +

                    "   can.price_change_percentage_24h,                                                        \n" +
                    "   can.price_change_percentage_7d,                                                         \n" +
                    "   can.price_change_percentage_14d,                                                        \n" +
                    "   can.price_change_percentage_30d,                                                        \n" +
                    "                                                                                           \n" +
                    "   can.category,                                                                           \n" +
                    "   can.trend,                                                                              \n" +
                    "   can.total_supply,                                                                       \n" +
                    "   can.max_supply,                                                                         \n" +
                    "   can.circulating_supply,                                                                 \n" +
                    "   can.binance_trade,                                                                      \n" +
                    "   can.coin_gecko_link,                                                                    \n" +
                    "   can.backer,                                                                             \n" +
                    "                                                                                           \n" +
                    "   (select concat(w.total_volume, '~', w.avg_price) from binance_volumn_week w where w.gecko_id = can.gecko_id and w.symbol = can.symbol and yyyymmdd = TO_CHAR(NOW() + interval '1 days', 'yyyyMMdd')) as today, \n"
                    +
                    "   (select concat(w.total_volume, '~', w.avg_price) from binance_volumn_week w where w.gecko_id = can.gecko_id and w.symbol = can.symbol and yyyymmdd = TO_CHAR(NOW(), 'yyyyMMdd'))                     as day_0, \n"
                    +
                    "   (select concat(w.total_volume, '~', w.avg_price) from binance_volumn_week w where w.gecko_id = can.gecko_id and w.symbol = can.symbol and yyyymmdd = TO_CHAR(NOW() - interval '1 days', 'yyyyMMdd')) as day_1, \n"
                    +
                    "   (select concat(w.total_volume, '~', w.avg_price) from binance_volumn_week w where w.gecko_id = can.gecko_id and w.symbol = can.symbol and yyyymmdd = TO_CHAR(NOW() - interval '2 days', 'yyyyMMdd')) as day_2, \n"
                    +
                    "   (select concat(w.total_volume, '~', w.avg_price) from binance_volumn_week w where w.gecko_id = can.gecko_id and w.symbol = can.symbol and yyyymmdd = TO_CHAR(NOW() - interval '3 days', 'yyyyMMdd')) as day_3, \n"
                    +
                    "   (select concat(w.total_volume, '~', w.avg_price) from binance_volumn_week w where w.gecko_id = can.gecko_id and w.symbol = can.symbol and yyyymmdd = TO_CHAR(NOW() - interval '4 days', 'yyyyMMdd')) as day_4, \n"
                    +
                    "   (select concat(w.total_volume, '~', w.avg_price) from binance_volumn_week w where w.gecko_id = can.gecko_id and w.symbol = can.symbol and yyyymmdd = TO_CHAR(NOW() - interval '5 days', 'yyyyMMdd')) as day_5, \n"
                    +
                    "   (select concat(w.total_volume, '~', w.avg_price) from binance_volumn_week w where w.gecko_id = can.gecko_id and w.symbol = can.symbol and yyyymmdd = TO_CHAR(NOW() - interval '6 days', 'yyyyMMdd')) as day_6, \n"
                    +
                    "   (select concat(w.total_volume, '~', w.avg_price) from binance_volumn_week w where w.gecko_id = can.gecko_id and w.symbol = can.symbol and yyyymmdd = TO_CHAR(NOW() - interval '7 days', 'yyyyMMdd')) as day_7, \n"
                    +
                    "   (select concat(w.total_volume, '~', w.avg_price) from binance_volumn_week w where w.gecko_id = can.gecko_id and w.symbol = can.symbol and yyyymmdd = TO_CHAR(NOW() - interval '8 days', 'yyyyMMdd')) as day_8, \n"
                    +
                    "   (select concat(w.total_volume, '~', w.avg_price) from binance_volumn_week w where w.gecko_id = can.gecko_id and w.symbol = can.symbol and yyyymmdd = TO_CHAR(NOW() - interval '9 days', 'yyyyMMdd')) as day_9, \n"
                    +
                    "   (select concat(w.total_volume, '~', w.avg_price) from binance_volumn_week w where w.gecko_id = can.gecko_id and w.symbol = can.symbol and yyyymmdd = TO_CHAR(NOW() - interval '10 days', 'yyyyMMdd')) as day_10, \n"
                    +
                    "   (select concat(w.total_volume, '~', w.avg_price) from binance_volumn_week w where w.gecko_id = can.gecko_id and w.symbol = can.symbol and yyyymmdd = TO_CHAR(NOW() - interval '11 days', 'yyyyMMdd')) as day_11, \n"
                    +
                    "   (select concat(w.total_volume, '~', w.avg_price) from binance_volumn_week w where w.gecko_id = can.gecko_id and w.symbol = can.symbol and yyyymmdd = TO_CHAR(NOW() - interval '12 days', 'yyyyMMdd')) as day_12 \n"
                    +
                    "                                                                                           \n" +
                    " from                                                                                      \n" +
                    "   candidate_coin can,                                                                     \n" +
                    "   binance_volumn_day cur                                                                  \n" +
                    "                                                                                           \n" +
                    " where                                                                                     \n" +
                    "       cur.hh = TO_CHAR(NOW(), 'HH24')                                                     \n" +
                    "   and can.gecko_id = cur.gecko_id                                                         \n" +
                    "   and can.symbol = cur.symbol                                                             \n" +
                    " order by                                                                                  \n" +
                    "   can.volumn_div_marketcap desc                                                           \n";

            Query query = entityManager.createNativeQuery(sql, "CandidateTokenResponse");

            @SuppressWarnings("unchecked")
            List<CandidateTokenResponse> results = query.getResultList();

            List<CandidateTokenCssResponse> list = new ArrayList<CandidateTokenCssResponse>();
            ModelMapper mapper = new ModelMapper();
            for (CandidateTokenResponse dto : results) {
                CandidateTokenCssResponse css = new CandidateTokenCssResponse();
                mapper.map(dto, css);

                css.setPre_4h_total_volume_up(dto.getPre_4h_total_volume_up() + "%");

                if (getValue(dto.getPre_4h_total_volume_up()) > Long.valueOf(200)) {
                    css.setPre_4h_total_volume_up_css("text-primary font-weight-bold");
                }

                String pre_vol_history = dto.getVol_now() +
                        "←" + dto.getVol_pre_1h() +
                        "← " + dto.getVol_pre_2h() +
                        "←" + dto.getVol_pre_3h() +
                        "←" + dto.getVol_pre_4h() + "M";
                css.setPre_vol_history(pre_vol_history);

                String pre_price_history = removeLastZero(dto.getPrice_now()) +
                        "←" + removeLastZero(dto.getPrice_pre_1h()) +
                        "← " + removeLastZero(dto.getPrice_pre_2h()) +
                        "←" + removeLastZero(dto.getPrice_pre_3h()) +
                        "←" + removeLastZero(dto.getPrice_pre_4h());
                css.setPre_price_history(pre_price_history);

                if (getValue(css.getVolumn_div_marketcap()) > Long.valueOf(100)) {
                    css.setVolumn_div_marketcap_css("text-primary bg-light");
                }
                css.setCurrent_price(removeLastZero(dto.getCurrent_price()));
                css.setPrice_change_24h_css(Utils.getTextCss(css.getPrice_change_percentage_24h()));
                css.setPrice_change_07d_css(Utils.getTextCss(css.getPrice_change_percentage_7d()));
                css.setPrice_change_14d_css(Utils.getTextCss(css.getPrice_change_percentage_14d()));
                css.setPrice_change_30d_css(Utils.getTextCss(css.getPrice_change_percentage_30d()));

                String gecko_volumn_history = dto.getGec_vol_pre_1h() +
                        "←" + dto.getGec_vol_pre_2h() +
                        " ←" + dto.getGec_vol_pre_3h() +
                        "←" + dto.getGec_vol_pre_4h() + "M";
                css.setGecko_volumn_history(gecko_volumn_history);

                List<String> volList = new ArrayList<String>();
                List<String> priceList = new ArrayList<String>();

                List<String> temp = splitVolAndPrice(css.getToday());
                css.setToday_vol(temp.get(0));
                css.setToday_price(temp.get(1));
                volList.add("");
                priceList.add(temp.get(1));
                BigDecimal vol_today = Utils.getBigDecimal(temp.get(0).replace(",", ""));

                temp = splitVolAndPrice(css.getDay_0());
                css.setDay_0_vol(temp.get(0));
                css.setDay_0_price(temp.get(1));
                volList.add(temp.get(0));
                priceList.add(temp.get(1));
                BigDecimal vol_yesterday = Utils.getBigDecimal(temp.get(0).replace(",", ""));

                if (vol_yesterday.compareTo(BigDecimal.ZERO) == 1) {
                    BigDecimal vol_up = vol_today.divide(vol_yesterday, 1, RoundingMode.CEILING);
                    if (BigDecimal.valueOf(1).compareTo(vol_up) == -1) {
                        css.setStar("※Up:" + String.valueOf(vol_up));
                        css.setStar_css("bg-light");
                    }
                }

                temp = splitVolAndPrice(css.getDay_1());
                css.setDay_1_vol(temp.get(0));
                css.setDay_1_price(temp.get(1));
                volList.add(temp.get(0));
                priceList.add(temp.get(1));

                temp = splitVolAndPrice(css.getDay_2());
                css.setDay_2_vol(temp.get(0));
                css.setDay_2_price(temp.get(1));
                volList.add(temp.get(0));
                priceList.add(temp.get(1));

                temp = splitVolAndPrice(css.getDay_3());
                css.setDay_3_vol(temp.get(0));
                css.setDay_3_price(temp.get(1));
                volList.add(temp.get(0));
                priceList.add(temp.get(1));

                temp = splitVolAndPrice(css.getDay_4());
                css.setDay_4_vol(temp.get(0));
                css.setDay_4_price(temp.get(1));
                volList.add(temp.get(0));
                priceList.add(temp.get(1));

                temp = splitVolAndPrice(css.getDay_5());
                css.setDay_5_vol(temp.get(0));
                css.setDay_5_price(temp.get(1));
                volList.add(temp.get(0));
                priceList.add(temp.get(1));

                temp = splitVolAndPrice(css.getDay_6());
                css.setDay_6_vol(temp.get(0));
                css.setDay_6_price(temp.get(1));
                volList.add(temp.get(0));
                priceList.add(temp.get(1));

                temp = splitVolAndPrice(css.getDay_7());
                css.setDay_7_vol(temp.get(0));
                css.setDay_7_price(temp.get(1));
                volList.add(temp.get(0));
                priceList.add(temp.get(1));

                temp = splitVolAndPrice(css.getDay_8());
                css.setDay_8_vol(temp.get(0));
                css.setDay_8_price(temp.get(1));
                volList.add(temp.get(0));
                priceList.add(temp.get(1));

                temp = splitVolAndPrice(css.getDay_9());
                css.setDay_9_vol(temp.get(0));
                css.setDay_9_price(temp.get(1));
                volList.add(temp.get(0));
                priceList.add(temp.get(1));

                temp = splitVolAndPrice(css.getDay_10());
                css.setDay_10_vol(temp.get(0));
                css.setDay_10_price(temp.get(1));
                volList.add(temp.get(0));
                priceList.add(temp.get(1));

                temp = splitVolAndPrice(css.getDay_11());
                css.setDay_11_vol(temp.get(0));
                css.setDay_11_price(temp.get(1));
                volList.add(temp.get(0));
                priceList.add(temp.get(1));

                temp = splitVolAndPrice(css.getDay_12());
                css.setDay_12_vol(temp.get(0));
                css.setDay_12_price(temp.get(1));
                volList.add(temp.get(0));
                priceList.add(temp.get(1));

                int idx_vol_max = getIndexMax(volList);
                int idx_price_max = getIndexMax(priceList);
                int idx_vol_min = getIndexMin(volList);
                int idx_price_min = getIndexMin(priceList);

                setVolumnDayCss(css, idx_vol_max, "text-primary"); //     Max Volumn
                setPriceDayCss(css, idx_price_max, "text-primary"); //    Max Price
                setVolumnDayCss(css, idx_vol_min, "text-danger"); //      Min Volumn
                setPriceDayCss(css, idx_price_min, "text-danger"); //     Min Price

                if (idx_price_min == 0) {
                    setPriceDayCss(css, idx_price_min, "text-danger font-weight-bold"); //     Min Price
                    if (!Objects.equals(null, css.getStar()) && !Objects.equals("", String.valueOf(css.getStar()))) {
                        css.setStar("※Sale※" + " " + css.getStar());
                    } else {
                        css.setStar("※Sale※");
                    }
                    css.setStar_css("bg-light text-primary font-weight-bold");
                }

                list.add(css);
            }

            log.info("End getList <--");

            return list;
        } catch (Exception e) {
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

    private void setPriceDayCss(CandidateTokenCssResponse css, int index, String css_class) {
        switch (index) {
        case 0:
            css.setToday_price_css(css_class);
            break;
        case 1:
            css.setDay_0_price_css(css_class);
            break;
        case 2:
            css.setDay_1_price_css(css_class);
            break;
        case 3:
            css.setDay_2_price_css(css_class);
            break;
        case 4:
            css.setDay_3_price_css(css_class);
            break;
        case 5:
            css.setDay_4_price_css(css_class);
            break;
        case 6:
            css.setDay_5_price_css(css_class);
            break;
        case 7:
            css.setDay_6_price_css(css_class);
            break;
        case 8:
            css.setDay_7_price_css(css_class);
            break;
        case 9:
            css.setDay_8_price_css(css_class);
            break;
        case 10:
            css.setDay_9_price_css(css_class);
            break;
        case 11:
            css.setDay_10_price_css(css_class);
            break;
        case 12:
            css.setDay_11_price_css(css_class);
            break;
        case 13:
            css.setDay_12_price_css(css_class);
            break;
        }
    }

    private List<String> splitVolAndPrice(String value) {
        if (Objects.isNull(value)) {
            return Arrays.asList("", "");
        }
        String[] arr = value.split("~");
        if (arr.length != 2) {
            return Arrays.asList(value, "");
        }

        String volumn = arr[0];
        String price = arr[1];
        volumn = String.format("%,.0f", Utils.getBigDecimal(volumn));
        return Arrays.asList(volumn, removeLastZero(price));
    }

    private String removeLastZero(String value) {
        if ((value == null) || (Objects.equals("", value))) {
            return "";
        }
        if (Objects.equals("0", value.subSequence(value.length() - 1, value.length()))) {
            String str = value.substring(0, value.length() - 1);
            return removeLastZero(str);
        } else {
            return value;
        }
    }
}
