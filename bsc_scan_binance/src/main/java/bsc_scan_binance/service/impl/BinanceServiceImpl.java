package bsc_scan_binance.service.impl;

import java.math.BigDecimal;
import java.math.BigInteger;
import java.math.RoundingMode;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Calendar;
import java.util.Collection;
import java.util.Hashtable;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Objects;

import javax.persistence.EntityManager;
import javax.persistence.PersistenceContext;
import javax.persistence.Query;
import javax.transaction.Transactional;

import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;
import org.jsoup.select.Elements;
import org.modelmapper.ModelMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.util.CollectionUtils;
import org.springframework.web.client.RestTemplate;

import bsc_scan_binance.BscScanBinanceApplication;
import bsc_scan_binance.entity.BinanceVolumeDateTime;
import bsc_scan_binance.entity.BinanceVolumeDateTimeKey;
import bsc_scan_binance.entity.BinanceVolumnDay;
import bsc_scan_binance.entity.BinanceVolumnDayKey;
import bsc_scan_binance.entity.BinanceVolumnWeek;
import bsc_scan_binance.entity.BinanceVolumnWeekKey;
import bsc_scan_binance.entity.BollArea;
import bsc_scan_binance.entity.BtcFutures;
import bsc_scan_binance.entity.BtcVolumeDay;
import bsc_scan_binance.entity.CandidateCoin;
import bsc_scan_binance.entity.DepthAsks;
import bsc_scan_binance.entity.DepthBids;
import bsc_scan_binance.entity.FundingHistory;
import bsc_scan_binance.entity.FundingHistoryKey;
import bsc_scan_binance.entity.GeckoVolumeMonth;
import bsc_scan_binance.entity.GeckoVolumeMonthKey;
import bsc_scan_binance.entity.GeckoVolumeUpPre4h;
import bsc_scan_binance.entity.Orders;
import bsc_scan_binance.entity.PriorityCoinHistory;
import bsc_scan_binance.repository.BinanceFuturesRepository;
import bsc_scan_binance.repository.BinanceVolumeDateTimeRepository;
import bsc_scan_binance.repository.BinanceVolumnDayRepository;
import bsc_scan_binance.repository.BinanceVolumnWeekRepository;
import bsc_scan_binance.repository.BitcoinBalancesOnExchangesRepository;
import bsc_scan_binance.repository.BollAreaRepository;
import bsc_scan_binance.repository.BtcFuturesRepository;
import bsc_scan_binance.repository.BtcVolumeDayRepository;
import bsc_scan_binance.repository.CandidateCoinRepository;
import bsc_scan_binance.repository.DepthAsksRepository;
import bsc_scan_binance.repository.DepthBidsRepository;
import bsc_scan_binance.repository.FundingHistoryRepository;
import bsc_scan_binance.repository.GeckoVolumeMonthRepository;
import bsc_scan_binance.repository.GeckoVolumeUpPre4hRepository;
import bsc_scan_binance.repository.OrdersRepository;
import bsc_scan_binance.repository.PriorityCoinHistoryRepository;
import bsc_scan_binance.response.BollAreaResponse;
import bsc_scan_binance.response.BtcFuturesResponse;
import bsc_scan_binance.response.CandidateTokenCssResponse;
import bsc_scan_binance.response.CandidateTokenResponse;
import bsc_scan_binance.response.DepthResponse;
import bsc_scan_binance.response.EntryCssResponse;
import bsc_scan_binance.response.FundingResponse;
import bsc_scan_binance.response.GeckoVolumeUpPre4hResponse;
import bsc_scan_binance.response.OrdersProfitResponse;
import bsc_scan_binance.service.BinanceService;
import bsc_scan_binance.utils.Utils;
import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class BinanceServiceImpl implements BinanceService {
    @PersistenceContext
    private final EntityManager entityManager;

    @Autowired
    private BinanceVolumnDayRepository binanceVolumnDayRepository;

    @Autowired
    private GeckoVolumeMonthRepository geckoVolumeMonthRepository;

    @Autowired
    private BinanceVolumeDateTimeRepository binanceVolumeDateTimeRepository;

    @Autowired
    private BinanceVolumnWeekRepository binanceVolumnWeekRepository;

    @Autowired
    private BtcVolumeDayRepository btcVolumeDayRepository;

    @Autowired
    private GeckoVolumeUpPre4hRepository geckoVolumeUpPre4hRepository;

    @Autowired
    private BollAreaRepository bollAreaRepository;

    @Autowired
    private OrdersRepository ordersRepository;

    @Autowired
    private BinanceFuturesRepository binanceFuturesRepository;

    @Autowired
    private DepthBidsRepository depthBidsRepository;

    @Autowired
    private DepthAsksRepository depthAsksRepository;

    @Autowired
    private BtcFuturesRepository btcFuturesRepository;

    @Autowired
    private PriorityCoinHistoryRepository priorityCoinHistoryRepository;

    @Autowired
    private CandidateCoinRepository candidateCoinRepository;

    @Autowired
    private FundingHistoryRepository fundingHistoryRepository;

    @Autowired
    private BitcoinBalancesOnExchangesRepository bitcoinBalancesOnExchangesRepository;

    private static final String SYMBOL_BTC = "BTC";

    private static final String TIME_15m = "15m";

    private static final String TIME_1h = "1h";
    private static final String TIME_2h = "2h";
    private static final String TIME_4h = "4h";
    private static final String TIME_1d = "1d";
    private static final String TIME_1w = "1w";

    @SuppressWarnings("unused")
    private static final int LIMIT_DATA_15m = 48;
    private static final int LIMIT_DATA_1h = 50;
    private static final int LIMIT_DATA_4h = 60;

    private static final String EVENT_FUNDING_RATE = "FUNDING_RATE";
    private static final String EVENT_DANGER_CZ_KILL_LONG = "CZ_KILL_LONG";
    private static final String EVENT_BTC_RANGE = "BTC_RANGE";
    private static final String EVENT_BTC_ON_EXCHANGES = "BTC_EXCHANGES";
    private static final String EVENT_FIBO_LONG_SHORT = "FIBO_";
    private static final String EVENT_TREND_1W1D = "1W1D";
    private static final String EVENT_COMPRESSED_CHART = "Ma3_10_20_";
    private static final String EVENT_PUMP = "Pump_1";

    private static final String TREND_LONG = "Long";
    private static final String TREND_SHORT = "Short";
    private static final String TREND_OPPOSITE = "Opposite";
    private static final String TREND_STOP_LONG = "Stop:Long";

    private static final String CSS_PRICE_WARNING = "bg-warning border border-warning rounded px-1";
    private static final String CSS_PRICE_SUCCESS = "border border-success rounded px-1";
    private static final String CSS_PRICE_FOCUS = "border-bottom border-dark";
    private static final String CSS_PRICE_DANGER = "border-bottom border-danger";
    private static final String CSS_PRICE_WHITE = "text-white bg-info rounded-lg px-1";
    private static final String CSS_MIN28_DAYS = "text-white rounded-lg bg-info px-1";

    private Boolean btc_is_uptrend_today = true;
    private String btc_week_day_trending = "";

    private int pre_HH_CheckUSD = 0;
    private String pre_Blog4H_CheckUSD = "";
    private String TREND_CURRENCY_TODAY = TREND_LONG;
    private String TREND_H4_AUD = TREND_LONG;
    private String TREND_H4_EUR = TREND_LONG;
    private String TREND_H4_GBP = TREND_LONG;
    private String TREND_H4_BTC = "";
    private Boolean TREND_H4_BTC_IS_LONG = true;
    private Boolean usd_is_uptrend_today = true;

    private String monitorBitcoinBalancesOnExchanges_temp = "";

    @SuppressWarnings("unused")
    private String pre_monitorBtcPrice_mm = "";
    List<String> monitorBtcPrice_results = new ArrayList<String>();

    private String pre_time_of_saved_data_4h = "";
    private String pre_time_of_btc_kill_long_short = "";
    private String pre_Bitfinex_status = "";
    private String preSaveDepthData;
    private String pre_btc6days = "";
    private String CHART_BTC_4H = "";
    List<BtcFutures> btc6days = new ArrayList<BtcFutures>();

    List<DepthResponse> list_bids_ok = new ArrayList<DepthResponse>();
    List<DepthResponse> list_asks_ok = new ArrayList<DepthResponse>();

    private int pre_HH = 0;
    private String pre_HH_h4 = "";
    private String sp500 = "";
    private Hashtable<String, String> msg_vol_up_dict = new Hashtable<String, String>();

    @Override
    @Transactional
    public List<CandidateTokenCssResponse> getList(Boolean isBynaceUrl) {
        try {
            System.out.println("Start getList ---->");
            String sql = " select                                                                                 \n"
                    + "   can.gecko_id,                                                                           \n"
                    + "   can.symbol,                                                                             \n"
                    + "   concat (can.name, (case when (select gecko_id from binance_futures where gecko_id=can.gecko_id) is not null then ' (Futures)' else '' end) ) as name,  \n"

                    + "    boll.low_price   as low_price_24h,                                                     \n"
                    + "    boll.hight_price as hight_price_24h,                                                   \n"
                    + "    boll.price_can_buy,                                                                    \n"
                    + "    boll.price_can_sell,                                                                   \n"
                    + "    boll.is_bottom_area,                                                                   \n"
                    + "    boll.is_top_area,                                                                      \n"
                    + "    0 as profit,                                                                           \n"
                    + "                                                                                           \n"
                    + "    0 as count_up, "

                    + "   vol.pumping_history,                                                                    \n "

                    + "   ROUND(can.volumn_div_marketcap * 100, 0) volumn_div_marketcap,                          \n"
                    + "                                                                                           \n"
                    + "   ROUND((cur.total_volume / COALESCE ((SELECT (case when pre.total_volume = 0.0 then 1000000000 else pre.total_volume end) FROM public.binance_volumn_day pre WHERE cur.gecko_id = pre.gecko_id AND cur.symbol = pre.symbol AND hh=TO_CHAR((NOW() - interval '4 hours'), 'HH24')), 1000000000) * 100 - 100), 0) pre_4h_total_volume_up, \n"
                    + "   coalesce((SELECT ROUND(pre.total_volume/1000000, 1) FROM public.binance_volumn_day pre WHERE cur.gecko_id = pre.gecko_id AND cur.symbol = pre.symbol AND hh=TO_CHAR((NOW()), 'HH24')), 0)                  as vol_now,      \n"
                    + "                                                                                           \n"
                    + "   ROUND(coalesce((SELECT pre.price_at_binance FROM public.binance_volumn_day pre WHERE cur.gecko_id = pre.gecko_id AND cur.symbol = pre.symbol AND hh=TO_CHAR((NOW()), 'HH24')), 0)                     , 5) as price_now,    \n"
                    + "   ROUND(coalesce((SELECT pre.price_at_binance FROM public.binance_volumn_day pre WHERE cur.gecko_id = pre.gecko_id AND cur.symbol = pre.symbol AND hh=TO_CHAR((NOW() - interval '1 hours'), 'HH24')), 0), 5) as price_pre_1h, \n"
                    + "   ROUND(coalesce((SELECT pre.price_at_binance FROM public.binance_volumn_day pre WHERE cur.gecko_id = pre.gecko_id AND cur.symbol = pre.symbol AND hh=TO_CHAR((NOW() - interval '2 hours'), 'HH24')), 0), 5) as price_pre_2h, \n"
                    + "   ROUND(coalesce((SELECT pre.price_at_binance FROM public.binance_volumn_day pre WHERE cur.gecko_id = pre.gecko_id AND cur.symbol = pre.symbol AND hh=TO_CHAR((NOW() - interval '3 hours'), 'HH24')), 0), 5) as price_pre_3h, \n"
                    + "   ROUND(coalesce((SELECT pre.price_at_binance FROM public.binance_volumn_day pre WHERE cur.gecko_id = pre.gecko_id AND cur.symbol = pre.symbol AND hh=TO_CHAR((NOW() - interval '4 hours'), 'HH24')), 0), 5) as price_pre_4h, \n"
                    + "                                                                                           \n"
                    + "   can.market_cap ,                                                                        \n"
                    + "   can.current_price               as current_price,                                       \n"
                    + "   can.total_volume                as gecko_total_volume,                                  \n"
                    + "   false as top10_vol_up,                                                                  \n"
                    + "   0 as vol_up_rate,                                                                       \n"
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
                    + "   (select concat (w.symbol,' ', w.name) from priority_coin_history w where w.gecko_id = can.gecko_id) as backer,                                                                             \n"
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
                    + "   macd.min60d,                                                                            \n"
                    + "   macd.max28d,                                                                            \n"
                    + "   macd.min14d,                                                                            \n"
                    + "   macd.min28d,                                                                            \n" // min
                    + "   false AS uptrend,                                                                       \n"
                    + "   vol.vol0d,                                                                              \n"
                    + "   vol.vol1d,                                                                              \n"
                    + "   vol.vol7d                                                                               \n"
                    + "   , 0 vol_gecko_increate                                                                  \n"
                    + "   , cur.point AS opportunity                                                              \n"
                    + "                                                                                           \n"
                    + "   , concat('1h: ', rate1h, '%, 2h: ', rate2h, '%, 4h: ', rate4h, '%, 1d0h: ', rate1d0h, '%, 1d4h: ', rate1d4h, '%') as binance_vol_rate \n"
                    + "   , rate1h                                                                                \n"
                    + "   , rate2h                                                                                \n"
                    + "   , rate4h                                                                                \n"
                    + "   , rate1d0h                                                                              \n"
                    + "   , rate1d4h                                                                              \n"
                    + "   , cur.rsi                                                                               \n"
                    + "   , macd.futures as futures                                                               \n"
                    + "   , '' as futures_css       \n"
                    + "                                                                                           \n"
                    + " from                                                                                      \n"
                    + "   candidate_coin can,                                                                     \n"
                    + "   binance_volumn_day cur,                                                                 \n"
                    + "   view_binance_volume_rate vbvr,                                                          \n"
                    + " (                                                                                         \n"
                    + "    select                                                                                 \n"
                    + "       xyz.gecko_id,                                                                       \n"
                    + "       concat(xyz.note, ' ', xyz.symbol) as futures,                                       \n"
                    + "       COALESCE(price_today   - price_pre_07d*1.05, -99) as ema07d,                        \n"
                    + "       COALESCE(price_pre_07d - price_pre_14d, -99) as ema14d,                             \n"
                    + "       COALESCE(price_pre_14d - price_pre_21d, -99) as ema21d,                             \n"
                    + "       COALESCE(price_pre_21d - price_pre_28d, -99) as ema28d,                             \n"
                    + "       COALESCE(min60d, -99) min60d,                                                       \n"
                    + "       COALESCE(max28d, -99) max28d,                                                       \n"
                    + "       COALESCE(min14d, -99) min14d,                                                       \n"
                    + "       COALESCE(min28d, -99) min28d                                                        \n"
                    + "    from                                                                                   \n"
                    + "      (                                                                                    \n"
                    + "          select                                                                           \n"
                    + "             can.gecko_id,                                                                 \n"
                    + "             can.symbol,                                                                   \n"
                    + "             his.note,                                                                     \n"
                    + "             0 as price_today,                                                             \n"
                    + "             0 as price_pre_07d,                                                           \n"
                    + "             0 as price_pre_14d,                                                           \n"
                    + "             0 as price_pre_21d,                                                           \n"
                    + "             0 as price_pre_28d,                                                           \n"
                    + "             ROUND((select MIN(COALESCE(w.min_price, 1000000)) from binance_volumn_week w where w.gecko_id = can.gecko_id and w.symbol = can.symbol and yyyymmdd between TO_CHAR(NOW() - interval '60 days', 'yyyyMMdd') and TO_CHAR(NOW(), 'yyyyMMdd')), 5) as min60d, \n" // min60d
                    + "             ROUND((select MAX(COALESCE(w.max_price, 1000000)) from binance_volumn_week w where w.gecko_id = can.gecko_id and w.symbol = can.symbol and yyyymmdd between TO_CHAR(NOW() - interval '30 days', 'yyyyMMdd') and TO_CHAR(NOW(), 'yyyyMMdd')), 5) as max28d, \n" // max28d
                    + "             ROUND((select MIN(COALESCE(w.min_price, 1000000)) from binance_volumn_week w where w.gecko_id = can.gecko_id and w.symbol = can.symbol and yyyymmdd between TO_CHAR(NOW() - interval '14 days', 'yyyyMMdd') and TO_CHAR(NOW(), 'yyyyMMdd')), 5) as min14d, \n" // min14d
                    + "             ROUND((select MIN(COALESCE(w.min_price, 1000000)) from binance_volumn_week w where w.gecko_id = can.gecko_id and w.symbol = can.symbol and yyyymmdd between TO_CHAR(NOW() - interval '30 days', 'yyyyMMdd') and TO_CHAR(NOW(), 'yyyyMMdd')), 5) as min28d  \n" // min28d
                    + "                                                                                           \n"
                    + "          from                                                                             \n"
                    + "              candidate_coin can                                                           \n"
                    + "          left join funding_history his on  his.event_time like '%1W1D%' and his.pumpdump and his.gecko_id = can.gecko_id  \n"
                    + "    ) xyz                                                                                  \n"
                    + " ) macd                                                                                    \n"
                    + " , ("
                    + "     select                                                                                \n"
                    + "        gecko_id,                                                                          \n"
                    + "        symbol,                                                                            \n"
                    + "        pumping_history,                                                                   \n"
                    + "        ROUND((COALESCE(volume_today  , 0))/1000000, 1) as vol0d, \n"
                    + "        ROUND((COALESCE(volume_pre_01d, 0))/1000000, 1) as vol1d, \n"
                    + "        ROUND((COALESCE(volume_pre_07d, 0))/1000000, 1) as vol7d  \n"
                    + "     from                                                                                  \n"
                    + "       (                                                                                   \n"
                    + "           select                                                                          \n"
                    + "               can.gecko_id,                                                               \n"
                    + "               can.symbol,                                                                 \n"
                    + "               concat('day: '                                                              \n"
                    + "                 , coalesce((select string_agg(dd, ', ') from (SELECT distinct dd FROM (   \n"
                    + "                     select dd from gecko_volume_month where gecko_id = can.gecko_id and symbol = 'GECKO'   and total_volume > (SELECT avg(total_volume)*1.5 FROM public.gecko_volume_month where gecko_id = can.gecko_id and symbol = 'GECKO')      \n"
                    + "                     union                                                                 \n"
                    + "                     select dd from gecko_volume_month where gecko_id = can.gecko_id and symbol = 'BINANCE' and total_volume > (SELECT avg(total_volume)*1.5 FROM public.gecko_volume_month where gecko_id = can.gecko_id and symbol = 'BINANCE')    \n"
                    + "                 ) uni_dd order by dd) pump), '')                                          \n"
                    + "               ) as pumping_history,                                                       \n"

                    + "              (select COALESCE(w.total_volume, 0) from gecko_volume_month w where w.gecko_id = can.gecko_id and w.symbol = 'GECKO' and dd = TO_CHAR(NOW(), 'dd'))                      as volume_today,  \n"
                    + "              (select COALESCE(w.total_volume, 0) from gecko_volume_month w where w.gecko_id = can.gecko_id and w.symbol = 'GECKO' and dd = TO_CHAR(NOW() - interval  '1 days', 'dd')) as volume_pre_01d, \n"
                    + "              (select COALESCE(w.total_volume, 0) from gecko_volume_month w where w.gecko_id = can.gecko_id and w.symbol = 'GECKO' and dd = TO_CHAR(NOW() - interval  '6 days', 'dd')) as volume_pre_07d  \n"
                    + "           from                                                                            \n"
                    + "               candidate_coin can                                                          \n"
                    + "     ) tmp                                                                                 \n"
                    + ") vol                                                                                      \n"
                    + ", " + Utils.sql_boll_2_body
                    + "                                                                                           \n"
                    + " WHERE                                                                                     \n"
                    + "       cur.hh = (case when EXTRACT(MINUTE FROM NOW()) < 15 then TO_CHAR(NOW() - interval '1 hours', 'HH24') else TO_CHAR(NOW(), 'HH24') end) \n"
                    + "   AND can.gecko_id = cur.gecko_id                                                         \n"
                    + "   AND can.gecko_id = vbvr.gecko_id                                                        \n"
                    + "   AND can.symbol = cur.symbol                                                             \n"
                    + "   AND can.gecko_id = macd.gecko_id                                                        \n"
                    + "   AND can.gecko_id = boll.gecko_id                                                        \n"
                    + "   AND can.gecko_id = vol.gecko_id                                                         \n"
                    + (isBynaceUrl ? // " AND (case when can.symbol <> 'BTC' and can.volumn_div_marketcap < 0.25 then
                            " AND macd.futures LIKE '%move↑%'     \n" // AND macd.futures NOT LIKE '%(Spot)%'
                            : "")
                    + (!(((BscScanBinanceApplication.app_flag == Utils.const_app_flag_all_coin)
                            || (BscScanBinanceApplication.app_flag == Utils.const_app_flag_all_and_msg)))
                                    ? "   AND can.gecko_id IN (SELECT gecko_id FROM binance_futures) \n"
                                    : "")
                    + " order by                                                                                    \n"
                    + "     coalesce(can.priority, 3) ASC                                                           \n"
                    + "   , (case when (macd.futures LIKE '%Futures%' AND macd.futures LIKE '%_Position%') then 10 when (macd.futures LIKE '%Futures%' AND macd.futures LIKE '%Long_4h%') then 11 when (macd.futures LIKE '%Futures%' AND macd.futures LIKE '%move↑%') then 15 when macd.futures LIKE '%Futures%' then 19 \n"
                    + "           when (macd.futures LIKE '%Spot%'    AND macd.futures LIKE '%_Position%') then 30 when (macd.futures LIKE '%Spot%'    AND macd.futures LIKE '%Long_4h%') then 31 when (macd.futures LIKE '%Spot%'    AND macd.futures LIKE '%move↑%') then 35 when macd.futures LIKE '%Spot%'    then 39 \n"
                    + "       else 100 end) ASC \n"
                    + "   , (case when can.volumn_div_marketcap >= 0.2 then 1 else 0 end) DESC                      \n"
                    + "   , vbvr.rate1d0h DESC, vbvr.rate4h DESC                                                    \n";

            Query query = entityManager.createNativeQuery(sql, "CandidateTokenResponse");
            @SuppressWarnings("unchecked")
            List<CandidateTokenResponse> results = query.getResultList();

            int weekUp = 0;
            int cutUp = 0;
            for (CandidateTokenResponse dto : results) {
                if (dto.getFutures().contains("W↑")) {
                    weekUp += 1;
                }

                if (dto.getFutures().contains("move↑")) {
                    cutUp += 1;
                }
            }
            String totalMarket = " Total W↑=" + weekUp + "(" + Utils
                    .getPercentStr(BigDecimal.valueOf(results.size() - weekUp), BigDecimal.valueOf(results.size()))
                    .replace("-", "") + ")";
            totalMarket += ", W↓=" + (results.size() - weekUp) + "(" + Utils
                    .getPercentStr(BigDecimal.valueOf(weekUp), BigDecimal.valueOf(results.size())).replace("-", "")
                    + ")";

            totalMarket += ", D↑Ma10=" + cutUp + "(" + Utils
                    .getPercentStr(BigDecimal.valueOf(results.size() - cutUp), BigDecimal.valueOf(results.size()))
                    .replace("-", "") + ")";

            totalMarket += ", AUD_EUR_GBP/USDT: " + TREND_CURRENCY_TODAY;

            List<CandidateTokenCssResponse> list = new ArrayList<CandidateTokenCssResponse>();

            ModelMapper mapper = new ModelMapper();
            Integer index = 1;
            String dd = Utils.getToday_dd();
            String ddAdd1 = Utils.getDdFromToday(1);
            String ddAdd2 = Utils.getDdFromToday(2);
            String msg_position = "";
            int count_stop_long = 0;
            // monitorTokenSales(results);
            for (CandidateTokenResponse dto : results) {
                CandidateTokenCssResponse css = new CandidateTokenCssResponse();
                mapper.map(dto, css);

                BigDecimal price_now = Utils.getBigDecimal(dto.getPrice_now());
                BigDecimal mid_price = Utils.getMidPrice(dto.getPrice_can_buy(), dto.getPrice_can_sell());
                BigDecimal market_cap = Utils.getBigDecimal(dto.getMarket_cap());
                BigDecimal gecko_total_volume = Utils.getBigDecimal(dto.getGecko_total_volume());

                if (css.getName().toUpperCase().contains("FUTURES")) {
                    css.setTrading_view("https://vn.tradingview.com/chart/?symbol=BINANCE%3A"
                            + dto.getSymbol().toUpperCase() + "USDTPERP");
                } else {
                    css.setTrading_view("https://vn.tradingview.com/chart/?symbol=BINANCE%3A"
                            + dto.getSymbol().toUpperCase() + "USDT");
                }

                if ((market_cap.compareTo(BigDecimal.valueOf(36000001)) < 0)
                        && (market_cap.compareTo(BigDecimal.valueOf(1000000)) > 0)) {
                    css.setMarket_cap_css("highlight rounded-lg px-1");
                } else if (market_cap.compareTo(BigDecimal.valueOf(1000000000)) > 0) {
                    css.setMarket_cap_css("bg-warning rounded-lg px-1");
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

                if (getValue(css.getVolumn_div_marketcap()) > Long.valueOf(100)) {
                    css.setVolumn_div_marketcap_css("text-primary highlight rounded-lg");
                } else if (getValue(css.getVolumn_div_marketcap()) >= Long.valueOf(20)) {
                    css.setVolumn_div_marketcap_css("highlight rounded-lg");
                } else {
                    css.setVolumn_div_marketcap_css("text-danger bg-light");
                }

                if (volumn_binance_div_marketcap.compareTo(BigDecimal.valueOf(30)) > 0) {
                    volumn_binance_div_marketcap_str = "B:" + volumn_binance_div_marketcap.toString();
                    // css.setVolumn_div_marketcap_css("highlight rounded-lg");
                } else if (volumn_binance_div_marketcap.compareTo(BigDecimal.valueOf(20)) > 0) {
                    volumn_binance_div_marketcap_str = "B:" + volumn_binance_div_marketcap.toString();
                    // css.setVolumn_binance_div_marketcap_css("text-primary");

                } else if (volumn_binance_div_marketcap.compareTo(BigDecimal.valueOf(10)) > 0) {
                    volumn_binance_div_marketcap_str = "B:" + volumn_binance_div_marketcap.toString();

                } else {
                    volumn_binance_div_marketcap_str = volumn_binance_div_marketcap.toString();
                }

                css.setVolumn_binance_div_marketcap(volumn_binance_div_marketcap_str);
                if (css.getPumping_history().contains(dd)) {
                    css.setPumping_history_css("text-white bg-success rounded-lg");
                } else if (css.getPumping_history().contains(ddAdd1) || css.getPumping_history().contains(ddAdd2)) {
                    css.setPumping_history_css("bg-warning rounded-lg");
                }
                if (css.getPumping_history().length() > 31) {
                    css.setPumping_history(css.getPumping_history().substring(0, 31) + "...");
                }

                if (css.getName().contains("Futures")) {
                    css.setBinance_trade(
                            "https://www.binance.com/en/futures/" + dto.getSymbol().toUpperCase() + "USDT");
                } else {
                    css.setBinance_trade("https://www.binance.com/en/trade/" + dto.getSymbol().toUpperCase() + "USDT");
                }

                // Price
                String pre_price_history = Utils.removeLastZero(dto.getPrice_now()) + "←"
                        + Utils.removeLastZero(dto.getPrice_pre_1h()) + "←"
                        + Utils.removeLastZero(dto.getPrice_pre_2h()) + "←"
                        + Utils.removeLastZero(dto.getPrice_pre_3h()) + "←"
                        + Utils.removeLastZero(dto.getPrice_pre_4h());
                if (pre_price_history.length() > 28) {
                    pre_price_history = Utils.removeLastZero(dto.getPrice_now()) + "←"
                            + Utils.removeLastZero(dto.getPrice_pre_1h()) + "←"
                            + Utils.removeLastZero(dto.getPrice_pre_2h());
                }
                css.setPre_price_history(pre_price_history);

                css.setCurrent_price(Utils.removeLastZero(dto.getCurrent_price()));
                css.setPrice_change_24h_css(Utils.getTextCss(css.getPrice_change_percentage_24h()));
                css.setPrice_change_07d_css(Utils.getTextCss(css.getPrice_change_percentage_7d()));
                css.setPrice_change_14d_css(Utils.getTextCss(css.getPrice_change_percentage_14d()));
                css.setPrice_change_30d_css(Utils.getTextCss(css.getPrice_change_percentage_30d()));

                String gecko_volumn_history = dto.getGec_vol_pre_1h() + "←" + dto.getGec_vol_pre_2h() + " ←"
                        + dto.getGec_vol_pre_3h() + "←" + dto.getGec_vol_pre_4h() + "M";

                if (gecko_volumn_history.length() > 20) {
                    gecko_volumn_history = dto.getGec_vol_pre_1h() + "←" + dto.getGec_vol_pre_2h() + "M";
                }

                css.setGecko_volumn_history(gecko_volumn_history);

                List<String> volList = new ArrayList<String>();
                List<String> avgPriceList = new ArrayList<String>();
                List<String> lowPriceList = new ArrayList<String>();
                List<String> hightPriceList = new ArrayList<String>();

                List<String> temp = splitVolAndPrice(css.getToday());
                css.setToday_vol(temp.get(0));
                String mid_price_percent = Utils.toPercent(mid_price, price_now);
                css.setToday_price(Utils.removeLastZero(mid_price.toString()) + "$ (" + mid_price_percent + "%)");

                if (mid_price_percent.contains("-")) {
                    css.setToday_price_css("text-danger");
                } else {
                    css.setToday_price_css("text-primary");
                }

                css.setToday_gecko_vol(
                        temp.get(6) + " (Vol4h: " + Utils.getBigDecimal(dto.getVol_up_rate()).toString() + ")");

                css.setToday_ema(Utils.getPercentVol2Mc(temp.get(6), dto.getMarket_cap()));

                volList.add("");
                avgPriceList.add(temp.get(1));
                lowPriceList.add(temp.get(2));
                hightPriceList.add(temp.get(3));
                BigDecimal highest_price_today = Utils.getBigDecimalValue(temp.get(3));

                temp = splitVolAndPrice(css.getDay_0());
                css.setDay_0_vol(temp.get(0));
                css.setDay_0_price(temp.get(1));
                css.setDay_0_ema(Utils.getPercentVol2Mc(temp.get(6), dto.getMarket_cap()));
                css.setDay_0_gecko_vol(temp.get(6));

                volList.add(temp.get(0));
                avgPriceList.add(temp.get(1));
                lowPriceList.add(temp.get(2));
                hightPriceList.add(temp.get(3));

                temp = splitVolAndPrice(css.getDay_1());
                css.setDay_1_vol(temp.get(0));
                css.setDay_1_price(temp.get(1));
                // css.setDay_1_ema(temp.get(4) + " (" + temp.get(5).replace("-", "↓") + "%)");
                css.setDay_1_ema(Utils.getPercentVol2Mc(temp.get(6), dto.getMarket_cap()));
                css.setDay_1_gecko_vol(temp.get(6));

                volList.add(temp.get(0));
                avgPriceList.add(temp.get(1));
                lowPriceList.add(temp.get(2));
                hightPriceList.add(temp.get(3));

                temp = splitVolAndPrice(css.getDay_2());
                css.setDay_2_vol(temp.get(0));
                css.setDay_2_price(temp.get(1));
                // css.setDay_2_ema(temp.get(4) + " (" + temp.get(5).replace("-", "↓") + "%)");
                css.setDay_2_ema(Utils.getPercentVol2Mc(temp.get(6), dto.getMarket_cap()));
                css.setDay_2_gecko_vol(temp.get(6));

                volList.add(temp.get(0));
                avgPriceList.add(temp.get(1));
                lowPriceList.add(temp.get(2));
                hightPriceList.add(temp.get(3));

                temp = splitVolAndPrice(css.getDay_3());
                css.setDay_3_vol(temp.get(0));
                css.setDay_3_price(temp.get(1));
                // css.setDay_3_ema(temp.get(4) + " (" + temp.get(5).replace("-", "↓") + "%)");
                css.setDay_3_ema(Utils.getPercentVol2Mc(temp.get(6), dto.getMarket_cap()));
                css.setDay_3_gecko_vol(temp.get(6));

                volList.add(temp.get(0));
                avgPriceList.add(temp.get(1));
                lowPriceList.add(temp.get(2));
                hightPriceList.add(temp.get(3));

                temp = splitVolAndPrice(css.getDay_4());
                css.setDay_4_vol(temp.get(0));
                css.setDay_4_price(temp.get(1));
                // css.setDay_4_ema(temp.get(4) + " (" + temp.get(5).replace("-", "↓") + "%)");
                css.setDay_4_ema(Utils.getPercentVol2Mc(temp.get(6), dto.getMarket_cap()));
                css.setDay_4_gecko_vol(temp.get(6));

                volList.add(temp.get(0));
                avgPriceList.add(temp.get(1));
                lowPriceList.add(temp.get(2));
                hightPriceList.add(temp.get(3));

                temp = splitVolAndPrice(css.getDay_5());
                css.setDay_5_vol(temp.get(0));
                css.setDay_5_price(temp.get(1));
                // css.setDay_5_ema(temp.get(4) + " (" + temp.get(5).replace("-", "↓") + "%)");
                css.setDay_5_ema(Utils.getPercentVol2Mc(temp.get(6), dto.getMarket_cap()));
                css.setDay_5_gecko_vol(temp.get(6));

                volList.add(temp.get(0));
                avgPriceList.add(temp.get(1));
                lowPriceList.add(temp.get(2));
                hightPriceList.add(temp.get(3));

                temp = splitVolAndPrice(css.getDay_6());
                css.setDay_6_vol(temp.get(0));
                css.setDay_6_price(temp.get(1));
                // css.setDay_6_ema(temp.get(4) + " (" + temp.get(5).replace("-", "↓") + "%)");
                css.setDay_6_ema(Utils.getPercentVol2Mc(temp.get(6), dto.getMarket_cap()));
                css.setDay_6_gecko_vol(temp.get(6));

                volList.add(temp.get(0));
                avgPriceList.add(temp.get(1));
                lowPriceList.add(temp.get(2));
                hightPriceList.add(temp.get(3));

                temp = splitVolAndPrice(css.getDay_7());
                css.setDay_7_vol(temp.get(0));
                css.setDay_7_price(temp.get(1));
                // css.setDay_7_ema(temp.get(4) + " (" + temp.get(5).replace("-", "↓") + "%)");
                css.setDay_7_ema(Utils.getPercentVol2Mc(temp.get(6), dto.getMarket_cap()));
                css.setDay_7_gecko_vol(temp.get(6));

                volList.add(temp.get(0));
                avgPriceList.add(temp.get(1));
                lowPriceList.add(temp.get(2));
                hightPriceList.add(temp.get(3));

                temp = splitVolAndPrice(css.getDay_8());
                css.setDay_8_vol(temp.get(0));
                css.setDay_8_price(temp.get(1));
                // css.setDay_8_ema(temp.get(4) + " (" + temp.get(5).replace("-", "↓") + "%)");
                css.setDay_8_ema(Utils.getPercentVol2Mc(temp.get(6), dto.getMarket_cap()));
                css.setDay_8_gecko_vol(temp.get(6));

                volList.add(temp.get(0));
                avgPriceList.add(temp.get(1));
                lowPriceList.add(temp.get(2));
                hightPriceList.add(temp.get(3));

                temp = splitVolAndPrice(css.getDay_9());
                css.setDay_9_vol(temp.get(0));
                css.setDay_9_price(temp.get(1));
                // css.setDay_9_ema(temp.get(4) + " (" + temp.get(5).replace("-", "↓") + "%)");
                css.setDay_9_ema(Utils.getPercentVol2Mc(temp.get(6), dto.getMarket_cap()));
                css.setDay_9_gecko_vol(temp.get(6));

                volList.add(temp.get(0));
                avgPriceList.add(temp.get(1));
                lowPriceList.add(temp.get(2));
                hightPriceList.add(temp.get(3));

                temp = splitVolAndPrice(css.getDay_10());
                css.setDay_10_vol(temp.get(0));
                css.setDay_10_price(temp.get(1));
                // css.setDay_10_ema(temp.get(4) + " (" + temp.get(5).replace("-", "↓") + "%)");
                css.setDay_10_ema(Utils.getPercentVol2Mc(temp.get(6), dto.getMarket_cap()));
                css.setDay_10_gecko_vol(temp.get(6));

                volList.add(temp.get(0));
                avgPriceList.add(temp.get(1));
                lowPriceList.add(temp.get(2));
                hightPriceList.add(temp.get(3));

                temp = splitVolAndPrice(css.getDay_11());
                css.setDay_11_vol(temp.get(0));
                css.setDay_11_price(temp.get(1));
                // css.setDay_11_ema(temp.get(4) + " (" + temp.get(5).replace("-", "↓") + "%)");
                css.setDay_11_ema(Utils.getPercentVol2Mc(temp.get(6), dto.getMarket_cap()));
                css.setDay_11_gecko_vol(temp.get(6));

                volList.add(temp.get(0));
                avgPriceList.add(temp.get(1));
                lowPriceList.add(temp.get(2));
                hightPriceList.add(temp.get(3));

                temp = splitVolAndPrice(css.getDay_12());
                css.setDay_12_vol(temp.get(0));
                css.setDay_12_price(temp.get(1));
                // css.setDay_12_ema(temp.get(4) + " (" + temp.get(5).replace("-", "↓") + "%)");
                css.setDay_12_ema(Utils.getPercentVol2Mc(temp.get(6), dto.getMarket_cap()));
                css.setDay_12_gecko_vol(temp.get(6));

                volList.add(temp.get(0));
                avgPriceList.add(temp.get(1));
                lowPriceList.add(temp.get(2));
                hightPriceList.add(temp.get(3));

                int idx_vol_max = getIndexMax(volList);
                int idx_price_max = getIndexMax(avgPriceList);
                int idx_vol_min = getIndexMin(volList);
                int idx_price_min = getIndexMin(avgPriceList);

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

                if ((price_now.compareTo(BigDecimal.ZERO) > 0) && (avg_price.compareTo(BigDecimal.ZERO) > 0)) {

                    BigDecimal percent = Utils.getBigDecimalValue(Utils.toPercent(avg_price, price_now, 1));
                    css.setAvg_price(Utils.removeLastZero(avg_price.toString()));
                    css.setAvg_percent(percent.toString() + "%");

                } else {
                    css.setAvg_price("0.0");
                }

                {
                    if ((Utils.getBigDecimal(dto.getRate1d0h()).compareTo(BigDecimal.valueOf(1000)) > 0)
                            || (Utils.getBigDecimal(dto.getRate1d4h()).compareTo(BigDecimal.valueOf(1000)) > 0)) {

                        css.setRate1d0h_css("text-primary font-weight-bold");
                        css.setStar(css.getStar() + " Volx10");

                    } else if ((Utils.getBigDecimal(dto.getRate1d0h()).compareTo(BigDecimal.valueOf(500)) > 0)
                            || (Utils.getBigDecimal(dto.getRate1d4h()).compareTo(BigDecimal.valueOf(500)) > 0)) {

                        css.setRate1d0h_css("text-primary font-weight-bold");
                        css.setStar(css.getStar() + " Volx5");

                    } else if (Utils.getBigDecimal(dto.getRate1d0h()).compareTo(BigDecimal.valueOf(200)) > 0) {
                        css.setRate1d0h_css("text-primary font-weight-bold");
                    } else if (Utils.getBigDecimal(dto.getRate1d0h()).compareTo(BigDecimal.valueOf(100)) > 0) {
                        css.setRate1d0h_css("text-primary");
                    } else if (Utils.getBigDecimal(dto.getRate1d0h()).compareTo(BigDecimal.valueOf(-30)) < 0) {
                        css.setRate1d0h_css("text-danger font-weight-bold");
                    } else if (Utils.getBigDecimal(dto.getRate1d0h()).compareTo(BigDecimal.valueOf(0)) < 0) {
                        css.setRate1d0h_css("text-danger");
                    }

                    if (Utils.getBigDecimal(dto.getRate1h()).compareTo(BigDecimal.valueOf(40)) > 0) {
                        css.setRate1h_css("text-primary");
                    } else if (Utils.getBigDecimal(dto.getRate1h()).compareTo(BigDecimal.valueOf(0)) < 0) {
                        css.setRate1h_css("text-danger");
                    }

                    if (Utils.getBigDecimal(dto.getRate2h()).compareTo(BigDecimal.valueOf(30)) > 0) {
                        css.setRate2h_css("text-primary");
                    } else if (Utils.getBigDecimal(dto.getRate2h()).compareTo(BigDecimal.valueOf(0)) < 0) {
                        css.setRate2h_css("text-danger");
                    }

                    if (Utils.getBigDecimal(dto.getRate4h()).compareTo(BigDecimal.valueOf(40)) > 0) {
                        css.setRate4h_css("text-primary");
                    } else if (Utils.getBigDecimal(dto.getRate4h()).compareTo(BigDecimal.valueOf(0)) < 0) {
                        css.setRate4h_css("text-danger");
                    }

                    BigDecimal price_max = Utils.getBigDecimal(avgPriceList.get(idx_price_max));
                    BigDecimal min_14d_per = Utils.getBigDecimalValue(Utils.toPercent(dto.getMin14d(), price_now));
                    String min_14d = "Min14d: " + Utils.removeLastZero(dto.getMin14d().toString()) + "(" + min_14d_per
                            + "%) Max14d: ";

                    if (min_14d_per.compareTo(BigDecimal.valueOf(-0.8)) > 0) {
                        css.setStar("m14d" + css.getStar());
                        // css.setStar_css("text-white rounded-lg bg-info");

                        css.setMin_14d_css("text-primary");

                    } else if (min_14d_per.compareTo(BigDecimal.valueOf(-3)) > 0) {
                        css.setMin_14d_css("text-primary");
                    }

                    String max_14d_percent = Utils.toPercent(price_max, price_now);
                    css.setOco_tp_price(min_14d);
                    css.setOco_tp_price_hight(price_max.toString() + "(" + max_14d_percent + "%)");

                    if (Utils.getBigDecimalValue(max_14d_percent).compareTo(BigDecimal.valueOf(20)) > 0) {
                        css.setOco_tp_price_hight_css("text-primary");
                    } else {
                        css.setOco_tp_price_hight_css("text-danger");
                    }

                    BigDecimal min28d_percent = Utils.getBigDecimalValue(Utils.toPercent(dto.getMin28d(), price_now));
                    BigDecimal max28d_percent = Utils.getBigDecimalValue(Utils.toPercent(dto.getMax28d(), price_now));

                    String avg_history = "Min60d: " + Utils.removeLastZero(dto.getMin60d().toString()) + "("
                            + Utils.toPercent(dto.getMin60d(), price_now) + "%)";

                    avg_history += ", Max28d: " + Utils.removeLastZero(dto.getMax28d().toString()) + "("
                            + max28d_percent + "%)";
                    avg_history += ", Min28d: ";
                    String min28day = Utils.removeLastZero(dto.getMin28d().toString()) + "(" + min28d_percent + "%)";

                    if (min28d_percent.compareTo(BigDecimal.valueOf(-10)) > 0) {
                        css.setMin28day_css(CSS_MIN28_DAYS);
                    }

                    css.setAvg_history(avg_history);
                    css.setMin28day(min28day);
                }
                if (Objects.equals("BETA", dto.getSymbol())) {
                    boolean test = true;
                }
                if (!Objects.equals(null, dto.getPrice_can_buy()) && !Objects.equals(null, dto.getPrice_can_sell())
                        && BigDecimal.ZERO.compareTo(dto.getPrice_can_buy()) != 0
                        && BigDecimal.ZERO.compareTo(dto.getPrice_can_sell()) != 0) {

                    BigDecimal price_can_buy_24h = dto.getPrice_can_buy();
                    BigDecimal price_can_sell_24h = dto.getPrice_can_sell();

                    BigDecimal temp_prire_24h = Utils
                            .formatPrice(dto.getLow_price_24h().multiply(BigDecimal.valueOf(1.008)), 5);
                    if (dto.getPrice_can_buy().compareTo(temp_prire_24h) < 0) {
                        temp_prire_24h = dto.getPrice_can_buy();
                    }
                    temp_prire_24h = Utils.formatPriceLike(temp_prire_24h, price_now);
                    css.setEntry_price(temp_prire_24h);

                    String futu = dto.getFutures().replace("(Futures) ", "") + " ";

                    // volma(h1x2.5) AAVE
                    if (futu.contains("volma{") && futu.contains("}volma")) {
                        try {
                            String volma = futu.substring(futu.indexOf("volma{"), futu.indexOf("}volma"));
                            futu = futu.replace(volma + "}volma", "").replaceAll("  ", "");
                            volma = volma.replace("volma{", "");
                            css.setVolma(volma);

                            if (volma.contains("pump")) {
                                css.setVolma_css("text-primary font-weight-bold");
                            } else if (volma.contains("dump")) {
                                css.setVolma_css("text-danger font-weight-bold");
                            }

                        } catch (Exception e) {
                            css.setRange_move("volma exception");
                        }
                    }

                    if (futu.contains("scap{") && futu.contains("}scap")) {
                        try {
                            String scap = futu.substring(futu.indexOf("scap{"), futu.indexOf("}scap"));
                            futu = futu.replace(scap + "}scap", "").replaceAll("  ", "");
                            scap = scap.replace("scap{", "");
                            css.setRange_scap(scap);

                            if (scap.contains(TREND_LONG)) {
                                css.setRange_scap_css(CSS_PRICE_SUCCESS);
                            } else if (scap.contains(TREND_SHORT)) {
                                css.setRange_scap_css(CSS_PRICE_WARNING);
                            }
                        } catch (Exception e) {
                            css.setRange_move("scap exception");
                        }
                    }

                    if (futu.contains("_ma7(") && futu.contains(")~")) {
                        try {
                            String ma7 = futu.substring(futu.indexOf("_ma7("), futu.indexOf(")~") + 2);
                            futu = futu.replace(ma7, "");
                            ma7 = ma7.replace("_ma7(", "").replace(")~", "");

                            if (Utils.isNotBlank(ma7)) {
                                if (ma7.contains("Above")) {
                                    css.setDt_range_css("text-primary");
                                    ma7 = ma7.replace("Above_", "");
                                } else if (ma7.contains("Below")) {
                                    css.setDt_range_css("text-danger");
                                    ma7 = ma7.replace("Below_", "");
                                }
                            }
                            css.setOco_opportunity(ma7);

                            if (ma7.contains(TREND_LONG)
                                    || (market_cap.compareTo(BigDecimal.valueOf(1000000000)) > 0)) {

                                if (ma7.contains("Long_1h")) {
                                    css.setDt_range_css("text-primary");
                                }
                                if (ma7.contains("Short_1h")) {
                                    css.setDt_range_css("text-danger");
                                }
                                if (ma7.contains(Utils.TREND_DANGER)) {
                                    css.setDt_range_css("text-danger");
                                }

                                css.setOco_opportunity(ma7.replace(Utils.TREND_DANGER, ""));
                            }

                        } catch (Exception e) {
                            css.setRange_move("ma7 exception");
                        }
                    }

                    String history = Utils.getStringValue(dto.getBacker()).replace("_", " ").replace(",,", ",")
                            .replace("   :", ":").replace(" :", ":").replace("...", " ").replace(",", ", ")
                            .replace("  ", " ").replace("Chart:", "");
                    history = Utils.isNotBlank(history) ? "History:" + history : "";
                    css.setRange_backer(history);

                    String m2ma = "";
                    if (futu.contains("m2ma{") && futu.contains("}m2ma")) {
                        try {
                            m2ma = futu.substring(futu.indexOf("m2ma{"), futu.indexOf("}m2ma"));
                            futu = futu.replace(m2ma + "}m2ma", "").replaceAll("  ", "");

                            m2ma = m2ma.replace("m2ma{", "").replace("move", "");

                            if (m2ma.contains("↑D")) {
                                css.setRange_move_css(CSS_PRICE_WHITE);
                            } else if (m2ma.contains("↑W")) {
                                css.setRange_move_css(CSS_PRICE_SUCCESS);
                            } else if (m2ma.contains("↓")) {
                                css.setRange_move_css(CSS_PRICE_WARNING);
                            }
                            css.setRange_move(m2ma);

                        } catch (Exception e) {
                            css.setRange_move("m2ma exception");
                        }

                    }

                    if (futu.contains("sl2ma{") && futu.contains("}sl2ma")) {
                        try {
                            String sl2ma = futu.substring(futu.indexOf("sl2ma{"), futu.indexOf("}sl2ma"));
                            futu = futu.replace(sl2ma + "}sl2ma", "").replaceAll("  ", "");
                            sl2ma = sl2ma.replace("sl2ma{", "");

                            css.setStr_entry_price(sl2ma);

                            String[] sl_e_tp = sl2ma.split(",");
                            if (sl_e_tp.length >= 4) {
                                css.setRange_stoploss(sl_e_tp[0]);
                                css.setRange_entry(sl_e_tp[1]);
                                css.setRange_take_profit(sl_e_tp[2]);
                                css.setRange_volume(sl_e_tp[3]);

                                if (sl_e_tp[3].contains(Utils.TREND_DANGER)) {
                                    css.setRange_volume_css("text-danger font-weight-bold");
                                }

                                if (sl_e_tp[0].contains("SL(Short_")) {
                                    css.setRange_stoploss_css("text-danger");
                                    css.setRange_entry_css("text-danger");
                                    css.setRange_take_profit_css("text-danger");
                                    css.setRange_volume_css("text-danger");
                                } else if (sl_e_tp[0].contains("SL(Long_")) {
                                    css.setRange_stoploss_css("text-primary");
                                    css.setRange_entry_css("text-primary");
                                    css.setRange_take_profit_css("text-primary");
                                    css.setRange_volume_css("text-primary");
                                }
                            } else {
                                css.setRange_stoploss(sl2ma);
                                css.setRange_stoploss_css("text-danger font-weight-bold");
                                if (sl2ma.contains(TREND_STOP_LONG)) {
                                    count_stop_long += 1;
                                }
                            }
                        } catch (Exception e) {
                            css.setRange_move("sl2ma exception");
                        }
                    }

                    if (futu.contains("_GoodPrice")) {
                        futu = futu.replace("_GoodPrice", "");

                        css.setRange_position("Price");
                        css.setRange_position_css(CSS_PRICE_WARNING);
                    }

                    if (futu.contains("_Position")) {
                        futu = futu.replace("_Position", "");

                        msg_position += Utils.getStringValue(dto.getSymbol()) + ", ";

                        css.setRange_position("Long(H4)");
                        css.setRange_position_css(CSS_PRICE_SUCCESS + " bg-success");

                        css.setRange_wdh_css("text-primary");
                        css.setStop_loss_css("text-white bg-success rounded-lg px-1");
                    }

                    if (futu.contains("W↑D↑")) {

                        css.setRange_wdh_css("text-primary font-weight-bold");

                    } else if (futu.contains("W↑ font-weight-bold")) {

                        css.setRange_wdh_css("text-primary");

                    } else if (futu.contains("W↓D↓")) {

                        css.setRange_wdh_css("text-danger font-weight-bold");

                    } else if (futu.contains("W↓")) {

                        css.setRange_wdh_css("text-danger");

                    } else {
                        css.setRange_wdh_css("");
                    }

                    String[] wdh = futu.split(",");
                    if (wdh.length >= 5) {

                        css.setRange_wdh(wdh[0]);
                        css.setRange_L10d(wdh[1]);
                        css.setRange_H10d(wdh[2]);
                        css.setRange_L6w(wdh[3]);
                        css.setRange_type(wdh[4]);

                        BigDecimal range_L10d = Utils.getPercentFromStringPercent(wdh[1]);
                        BigDecimal range_L10w = Utils.getPercentFromStringPercent(wdh[3]);

                        if ((range_L10d.compareTo(BigDecimal.valueOf(10)) < 0)
                                && (range_L10w.compareTo(BigDecimal.valueOf(10)) < 0)) {

                            css.setRange_L10d_css(CSS_PRICE_SUCCESS); // "border border-primary rounded"
                            css.setRange_L6w_css(CSS_PRICE_SUCCESS);
                        }

                        if (range_L10d.compareTo(BigDecimal.valueOf(15)) > 0) {
                            css.setRange_L10d_css(CSS_PRICE_DANGER);
                        }

                        if (range_L10w.compareTo(BigDecimal.valueOf(20)) > 0) {
                            css.setRange_L6w_css(CSS_PRICE_DANGER);
                        }

                    } else {
                        css.setRange_wdh(futu);
                    }

                    // btc_warning_css
                    if (Objects.equals("BTC", dto.getSymbol().toUpperCase())) {

                        String textDepth = getTextDepthData();
                        css.setOco_depth(textDepth);

                        BigDecimal btc_range_b_s = ((price_can_sell_24h.subtract(price_can_buy_24h))
                                .divide(price_can_buy_24h, 3, RoundingMode.CEILING));

                        // take_profit_percent > 3% ?
                        if ((btc_range_b_s.compareTo(BigDecimal.valueOf(0.015)) >= 0)) {

                            if (Utils.isGoodPriceLong(price_now, price_can_buy_24h, price_can_sell_24h)) {

                                css.setBtc_warning_css("bg-success rounded-lg");
                            }

                            if ((price_now.multiply(BigDecimal.valueOf(1.005)).compareTo(highest_price_today) > 0)) {

                                css.setBtc_warning_css("bg-danger rounded-lg");

                            }
                        }

                        css.setRange_wdh_css("");
                        if (btc_is_uptrend_today) {
                            css.setFutures_css("text-white bg-success rounded-lg px-2");
                        } else {
                            css.setFutures_css("text-white bg-danger rounded-lg px-2");
                        }
                    }

                }

                if ((Utils.getBigDecimalValue(dto.getVolumn_div_marketcap()).compareTo(BigDecimal.valueOf(20)) < 0)
                        && (volumn_binance_div_marketcap.compareTo(BigDecimal.valueOf(10)) < 0)) {
                    css.setVolumn_binance_div_marketcap_css("text-danger");
                }

                if (Objects.equals("BTC", dto.getSymbol().toUpperCase())) {
                    // monitorToken(css); // debug

                    if (pre_HH != Utils.getCurrentHH()) {

                        sp500 = loadPremarketSp500().replace(" ", "").replace("Futures", "(Futures)")
                                .replace(Utils.new_line_from_bot, " ");

                        pre_HH = Utils.getCurrentHH();

                        getBitfinexLongShortBtc();
                    }

                    wallToday();
                    css.setNote("");

                    css.setRange_total_w(totalMarket);
                    if (weekUp < (results.size() / 3)) {
                        css.setRange_total_w_css("text-white bg-danger rounded-lg px-2");
                    } else if (weekUp > (2 * results.size() / 3)) {
                        css.setRange_total_w_css("text-white bg-success rounded-lg px-2");
                    }

                    css.setStar(sp500);
                    css.setStar_css("display-tity text-left");
                    if (sp500.contains("-")) {
                        css.setStar_css("bg-danger rounded-lg display-tity text-left text-white");
                    }
                }

                list.add(css);
                index += 1;
            }

            if ((count_stop_long > 0) || Utils.isNotBlank(msg_position)) {
                String EVENT_ID = EVENT_COMPRESSED_CHART + "_POSITION_" + Utils.getCurrentYyyyMmDd_Blog4h();

                sendMsgPerHour(EVENT_ID, "(Long) " + TREND_STOP_LONG + ":" + count_stop_long + "/total(" + list.size()
                        + ")" + Utils.new_line_from_service + "Position:" + Utils.new_line_from_service + msg_position);
            }

            return list;

        } catch (Exception e) {
            e.printStackTrace();
            System.out.println("Get list Inquiry Consigned Delivery error ------->");
            System.out.println(e.getMessage());
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
            System.out.println("Start monitorProfit ---->");

            Query query = entityManager.createNativeQuery(Utils.sql_OrdersProfitResponse, "OrdersProfitResponse");

            List<OrdersProfitResponse> results = query.getResultList();

            if (!CollectionUtils.isEmpty(results)) {

                for (OrdersProfitResponse dto : results) {
                    String msg = "";

                    BigDecimal tp_percent = Utils.getBigDecimalValue(String.valueOf(dto.getTp_percent()));
                    BigDecimal target_percent = Utils.getBigDecimalValue(String.valueOf(dto.getTarget_percent()))
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

                    } else if (tp_percent.compareTo(BigDecimal.valueOf(-1)) <= 0) {

                        msg += "STOP LOSS 1%: " + Utils.createMsgBalance(dto, Utils.new_line_from_service)
                                + Utils.new_line_from_service + Utils.new_line_from_service;
                    }

                    if (Utils.isNotBlank(msg)) {
                        Utils.sendToChatId(dto.getChatId(), msg);
                    }
                }

            }
        } catch (Exception e) {
            e.printStackTrace();
            System.out.println("monitorProfit error ------->");
            System.out.println(e.getMessage());
        }
    }

    @Override
    @Transactional
    public void monitorBollingerBandwidth(Boolean isCallFormBot) {
        try {
            System.out.println("Start monitorBollingerBandwidth ---->");
            {
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
                        + " (                                                                                      \n"
                        + "  select                                                                                \n"
                        + "       pre.gecko_id,                                                                    \n"
                        + "       pre.hh,                                                                          \n"
                        + "       ROUND(100 * (price_now   - price_pre4h) /price_pre4h, 2)  as vector_now,         \n"
                        + "       ROUND(100 * (price_pre4h - price_pre8h) /price_pre8h, 2)  as vector_pre4h        \n"
                        + "   from (                                                                               \n"
                        + "       select                                                                           \n"
                        + "       tmp.gecko_id,                                                                    \n"
                        + "       tmp.hh,                                                                          \n"
                        + "       (case when price_now is null then price_pre1h else price_now end) as price_now,  \n"
                        + "          price_pre4h,                                                                  \n"
                        + "          price_pre8h                                                                   \n"
                        + "       from (                                                                           \n"
                        + "           select                                                                       \n"
                        + "               d.gecko_id,                                                              \n"
                        + "               d.hh, \n"
                        + "               (select COALESCE(h.avg_price, 0) from btc_volumn_day h where h.gecko_id = d.gecko_id and h.hh = TO_CHAR(NOW(), 'HH24')) as price_now,                          \n"
                        + "               (select COALESCE(h.avg_price, 0) from btc_volumn_day h where h.gecko_id = d.gecko_id and h.hh = TO_CHAR(NOW() - interval  '1 hours', 'HH24')) as price_pre1h,  \n"
                        + "                                                                                             \n"
                        + "               (select ROUND(AVG(COALESCE(h.avg_price, 0)), 5) from btc_volumn_day h where h.gecko_id = d.gecko_id and h.hh between TO_CHAR(NOW() - interval  '4 hours', 'HH24') and TO_CHAR(NOW() - interval  '1 hours', 'HH24')) as price_pre4h,   \n"
                        + "               (select ROUND(AVG(COALESCE(h.avg_price, 0)), 5) from btc_volumn_day h where h.gecko_id = d.gecko_id and h.hh between TO_CHAR(NOW() - interval  '8 hours', 'HH24') and TO_CHAR(NOW() - interval  '5 hours', 'HH24')) as price_pre8h    \n"
                        + "           from  \n" + "               btc_volumn_day d \n"
                        + "           where d.hh = (case when EXTRACT(MINUTE FROM NOW()) < 15 then TO_CHAR(NOW() - interval '1 hours', 'HH24') else TO_CHAR(NOW(), 'HH24') end) \n"
                        + "           ) as tmp                                                                     \n"
                        + "   ) as pre                                                                             \n"
                        + " ) vector                                                                               \n"
                        + "                                                                                        \n"
                        + " where 1=1                                                                              \n"
                        + " and vector.gecko_id = boll.gecko_id                                                    \n";

                Query query = entityManager.createNativeQuery(sql, "BollAreaResponse");

                @SuppressWarnings("unchecked")
                List<BollAreaResponse> boll_anna_list = query.getResultList();
                if (!CollectionUtils.isEmpty(boll_anna_list)) {

                    List<BollArea> list = new ArrayList<BollArea>();
                    for (BollAreaResponse dto : boll_anna_list) {
                        BollArea entiy = (new ModelMapper()).map(dto, BollArea.class);
                        list.add(entiy);
                    }

                    bollAreaRepository.deleteAll();
                    bollAreaRepository.saveAll(list);
                }
            }

            {
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

                    for (GeckoVolumeUpPre4hResponse dto : vol_list) {
                        GeckoVolumeUpPre4h entity = (new ModelMapper()).map(dto, GeckoVolumeUpPre4h.class);
                        entity.setGeckoid(dto.getGecko_id());
                        saveList.add(entity);
                    }
                    geckoVolumeUpPre4hRepository.saveAll(saveList);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            System.out.println("monitorBollingerBandwidth error ------->");
            System.out.println(e.getMessage());
        }
    }

    @Override
    public List<Orders> getOrderList() {
        return ordersRepository.findAll();
    }

    @Override
    public String loadPremarket() {
        String sp_500 = getPreMarket("https://markets.businessinsider.com/index/s&p_500");
        String sp500_future = getPreMarket("https://markets.businessinsider.com/futures/s&p-500-futures");

        // String dow_jones =
        // getPreMarket("https://markets.businessinsider.com/index/dow_jones");
        // String dow_jones_future =
        // getPreMarket("https://markets.businessinsider.com/futures/dow-futures");
        //
        // String nasdaq =
        // getPreMarket("https://markets.businessinsider.com/index/nasdaq_100");
        // String nasdaq_future =
        // getPreMarket("https://markets.businessinsider.com/futures/nasdaq-100-futures");

        String value = "";
        value = appendStringForBot(value, sp_500);
        value = appendStringForBot(value, sp500_future);
        // value = appendStringForBot(value, "");
        // value = appendStringForBot(value, dow_jones);
        // value = appendStringForBot(value, dow_jones_future);
        // value = appendStringForBot(value, "");
        // value = appendStringForBot(value, nasdaq);
        // value = appendStringForBot(value, nasdaq_future);

        return value;
    }

    @Override
    public String loadPremarketSp500() {
        String value = "";

        String sp_500 = getPreMarket("https://markets.businessinsider.com/index/s&p_500");
        String sp500_future = getPreMarket("https://markets.businessinsider.com/futures/s&p-500-futures");

        value = appendStringForBot(value, sp_500);
        value = appendStringForBot(value, sp500_future);
        return value;
    }

    private String appendStringForBot(String value, String append) {
        String val = value;
        if (Utils.isNotBlank(append)) {
            if (Utils.isNotBlank(val)) {
                val += Utils.new_line_from_bot;
            }
            val += append.replace("E-mini ", "");
        }

        return val;
    }

    private String getPreMarket(String url) {
        try {
            Document doc = Jsoup.connect(url).get();

            Elements assets1 = doc.getElementsByClass("price-section__label");
            Elements assets2 = doc.getElementsByClass("price-section__absolute-value");
            Elements assets3 = doc.getElementsByClass("price-section__relative-value");

            String sp500 = "";
            if (!Objects.equals(null, assets1) && assets1.size() > 0) {
                sp500 = assets1.get(0).text() + "";
            }
            if (!Objects.equals(null, assets2) && assets2.size() > 0) {
                sp500 += " " + assets2.get(0).text();
            }
            if (!Objects.equals(null, assets3) && assets3.size() > 0) {
                sp500 += " (" + assets3.get(0).text() + ")";
            }
            return sp500;
        } catch (Exception e) {
            System.out.println("BinanceServiceImpl.loadPremarket error --->");
            // e.printStackTrace();
            System.out.println(e.getMessage());
        }
        return "S&P 500 xxx (xxx%), Futures yyy (yyy%)";
    }

    // ------------------------------------------------------------------------------------

    @Override
    @Transactional
    public void loadDataVolumeHour(String gecko_id, String symbol) {
        try {
            final Integer limit = 24;
            String url_usdt = "https://api.binance.com/api/v3/klines?symbol=" + symbol + "USDT" + "&interval=1h&limit="
                    + String.valueOf(limit);

            List<Object> result_usdt = Utils.getBinanceData(url_usdt, limit);

            if (!isHasData(result_usdt, limit - 1)) {
                url_usdt = "https://api.binance.com/api/v3/klines?symbol=" + symbol + "BUSD" + "&interval=1h&limit="
                        + String.valueOf(limit);

                result_usdt = Utils.getBinanceData(url_usdt, limit);
            }

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

                BigDecimal avgPrice = price_open_candle;
                if (price_open_candle.compareTo(price_close_candle) > 0) {
                    avgPrice = price_close_candle;
                }

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
        } catch (Exception e) {
            System.out.println("Error loadDataVolumeHour  ----->");
            e.printStackTrace();
        }
    }

    @SuppressWarnings("unchecked")
    @Override
    @Transactional
    public String loadBinanceData(String gecko_id, String symbol, boolean isStartUp) {
        // debug
        // scalping(gecko_id, symbol);
        loadFundingHistory(gecko_id, symbol);

        try {
            Integer LIMIT = 60;
            if (!isStartUp) {
                LIMIT = 3;
            }

            final String url_usdt = "https://api.binance.com/api/v3/klines?symbol=" + symbol + "USDT" + "&interval="
                    + TIME_1d + "&limit=" + String.valueOf(LIMIT);

            final String url_busd = "https://api.binance.com/api/v3/klines?symbol=" + symbol + "BUSD" + "&interval="
                    + TIME_1d + "&limit=" + String.valueOf(LIMIT);

            List<Object> result_usdt = Utils.getBinanceData(url_usdt, LIMIT);
            List<Object> result_busd = Utils.getBinanceData(url_busd, LIMIT);

            List<GeckoVolumeMonth> list_binance_vol = new ArrayList<GeckoVolumeMonth>();
            List<BinanceVolumnWeek> list_week = new ArrayList<BinanceVolumnWeek>();
            List<BigDecimal> list_price_close_candle = new ArrayList<BigDecimal>();

            BinanceVolumnDay day = new BinanceVolumnDay();

            int day_index = 0;
            for (int idx = LIMIT - 1; idx >= 0; idx--) {
                Object obj_usdt = result_usdt.get(idx);
                Object obj_busd = result_busd.get(idx);

                List<Object> arr_usdt = (List<Object>) obj_usdt;
                if (arr_usdt.size() < 8) {
                    arr_usdt = (List<Object>) obj_busd;
                }

                if (arr_usdt.size() < 8) {
                    continue;
                }

                BigDecimal price_open_candle = Utils.getBigDecimal(arr_usdt.get(1));
                BigDecimal price_high = Utils.getBigDecimal(arr_usdt.get(2));
                BigDecimal price_low = Utils.getBigDecimal(arr_usdt.get(3));
                BigDecimal price_close_candle = Utils.getBigDecimal(arr_usdt.get(4));
                String open_time = arr_usdt.get(0).toString();

                if (!Objects.equals("0", open_time)) {
                    BigDecimal avgPrice = price_open_candle;
                    if (price_open_candle.compareTo(price_close_candle) > 0) {
                        avgPrice = price_close_candle;
                    }

                    BigDecimal quote_asset_volume1 = Utils.getBigDecimal(arr_usdt.get(7));
                    BigDecimal number_of_trades1 = Utils.getBigDecimal(arr_usdt.get(8));

                    BigDecimal quote_asset_volume2 = arr_usdt.size() > 7 ? Utils.getBigDecimal(arr_usdt.get(7))
                            : BigDecimal.ZERO;
                    BigDecimal number_of_trades2 = arr_usdt.size() > 8 ? Utils.getBigDecimal(arr_usdt.get(8))
                            : BigDecimal.ZERO;

                    BigDecimal total_volume = quote_asset_volume1.add(quote_asset_volume2);
                    BigDecimal total_trans = number_of_trades1.add(number_of_trades2);

                    if (idx == LIMIT - 1) {
                        String point = checkWDtrend(gecko_id, symbol);
                        Calendar calendar = Calendar.getInstance();

                        day.setId(new BinanceVolumnDayKey(gecko_id, symbol,
                                Utils.convertDateToString("HH", calendar.getTime())));
                        day.setTotalVolume(total_volume);
                        day.setTotalTrasaction(total_trans);
                        day.setPriceAtBinance(Utils.getBinancePrice(symbol));
                        day.setLow_price(price_low);
                        day.setHight_price(price_high);
                        day.setPrice_open_candle(price_open_candle);
                        day.setPrice_close_candle(price_close_candle);
                        day.setPoint(point);

                        {
                            BinanceVolumeDateTime ddhh = new BinanceVolumeDateTime();
                            BinanceVolumeDateTimeKey key = new BinanceVolumeDateTimeKey();
                            key.setGeckoid(gecko_id);
                            key.setSymbol(symbol);
                            key.setDd(Utils.convertDateToString("dd", calendar.getTime()));
                            key.setHh(Utils.convertDateToString("HH", calendar.getTime()));
                            ddhh.setId(key);
                            ddhh.setVolume(total_volume);

                            binanceVolumeDateTimeRepository.save(ddhh);
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

                    list_price_close_candle.add(avgPrice);

                    GeckoVolumeMonth month = new GeckoVolumeMonth();
                    month.setId(new GeckoVolumeMonthKey(gecko_id, "BINANCE", Utils.getToday_dd()));
                    month.setTotalVolume(total_volume);
                    list_binance_vol.add(month);
                }
                day_index += 1;
            }

            // https://www.omnicalculator.com/finance/rsi#:~:text=Calculate%20relative%20strength%20(RS)%20by,1%20%2D%20RS)%20from%20100.

            int size = list_week.size() - 1;
            if (size > 0) {
                binanceVolumnDayRepository.save(day);
                binanceVolumnWeekRepository.saveAll(list_week);
                geckoVolumeMonthRepository.saveAll(list_binance_vol);
            }

        } catch (Exception e) {
            System.out.println("Error loadBinanceData  ----->");
            e.printStackTrace();
        }
        return "";
    }

    private FundingHistory createPumpDumpEntity(String event, String gecko_id, String symbol, String note,
            boolean pumpdump) {
        FundingHistory entity = new FundingHistory();
        FundingHistoryKey id = new FundingHistoryKey();
        id.setEventTime(event);
        id.setGeckoid(gecko_id);
        entity.setId(id);
        entity.setSymbol(symbol);
        entity.setPumpdump(pumpdump);
        entity.setNote(note);

        return entity;
    }

    private Boolean isHasData(List<Object> result_usdt, int index) {
        Object obj_usdt = result_usdt.get(index);

        @SuppressWarnings("unchecked")
        List<Object> arr_usdt = (List<Object>) obj_usdt;

        String open_time = arr_usdt.get(0).toString();

        if (Objects.equals("0", open_time)) {
            return false;
        }

        return true;
    }

    @SuppressWarnings("unchecked")
    @Override
    public String getBitfinexLongShortBtc() {
        String msg = "";
        String time = Utils.getTimeHHmm();

        // timeType=1 -> 4h
        // timeType=2 -> 1h
        // timeType=3 -> 5m
        String url = "https://fapi.coinglass.com/api/futures/longShortRate?symbol=BTC&timeType=2";
        try {
            RestTemplate restTemplate = new RestTemplate();
            Object result = restTemplate.getForObject(url, Object.class);
            LinkedHashMap<String, Object> resultMap = (LinkedHashMap<String, Object>) result;
            Object obj_key = resultMap.get("data");

            if (obj_key instanceof Collection) {
                List<Object> obj_key_list = new ArrayList<>((Collection<Object>) obj_key);
                Object temp = Utils.getLinkedHashMapValue(obj_key_list.get(0), Arrays.asList("list"));
                if (temp instanceof Collection) {
                    List<Object> exchange_list = new ArrayList<>((Collection<Object>) temp);
                    if (exchange_list.size() > 6) {
                        Object Bitfinex = exchange_list.get(6);
                        Object exchangeName = Utils.getLinkedHashMapValue(Bitfinex, Arrays.asList("exchangeName"));

                        BigDecimal longRate = Utils
                                .getBigDecimal(Utils.getLinkedHashMapValue(Bitfinex, Arrays.asList("longRate")));
                        BigDecimal longVolUsd = Utils
                                .getBigDecimal(Utils.getLinkedHashMapValue(Bitfinex, Arrays.asList("longVolUsd")));
                        longVolUsd = longVolUsd.divide(BigDecimal.valueOf(1000), 1, RoundingMode.CEILING);

                        BigDecimal shortRate = Utils
                                .getBigDecimal(Utils.getLinkedHashMapValue(Bitfinex, Arrays.asList("shortRate")));
                        BigDecimal shortVolUsd = Utils
                                .getBigDecimal(Utils.getLinkedHashMapValue(Bitfinex, Arrays.asList("shortVolUsd")));
                        shortVolUsd = shortVolUsd.divide(BigDecimal.valueOf(1000), 1, RoundingMode.CEILING);

                        msg = time + " " + Utils.getStringValue(exchangeName) + " 1h";

                        msg += " Long: " + Utils.formatPrice(longRate, 1) + "%("
                                + Utils.removeLastZero(Utils.getStringValue(longVolUsd)) + "k)";

                        msg += " Short: " + Utils.formatPrice(shortRate, 1) + "%("
                                + Utils.removeLastZero(Utils.getStringValue(shortVolUsd)) + "k)";

                        String cur_Bitfinex_status = "";
                        if (longRate.compareTo(BigDecimal.valueOf(60)) > 0) {
                            cur_Bitfinex_status = TREND_LONG;

                        }
                        if (shortRate.compareTo(BigDecimal.valueOf(60)) > 0) {
                            cur_Bitfinex_status = TREND_SHORT;
                        }

                        if (!Objects.equals(cur_Bitfinex_status, pre_Bitfinex_status)
                                && !Objects.equals(cur_Bitfinex_status, "")) {
                            pre_Bitfinex_status = cur_Bitfinex_status;
                        }
                    }

                }
            }
        } catch (Exception e) {
            System.out.println("Error getBitfinexLongShortBtc ---->" + e.getMessage());
            e.printStackTrace();
        }

        return msg;
    }

    @SuppressWarnings({ "unchecked" })
    @Transactional
    private void saveDepthData(String gecko_id, String symbol) {
        try {
            // https://binance-docs.github.io/apidocs/spot/en/#websocket-blvt-info-streams

            String curSaveDepthData = symbol + "_" + Utils.getCurrentMinute();
            if (curSaveDepthData == preSaveDepthData) {
                return;
            }
            preSaveDepthData = curSaveDepthData;

            List<DepthBids> depthBidsList = depthBidsRepository.findAll();
            for (DepthBids entity : depthBidsList) {
                entity.setQty(BigDecimal.ZERO);
            }
            depthBidsRepository.saveAll(depthBidsList);

            List<DepthAsks> depthAsksList = depthAsksRepository.findAll();
            for (DepthAsks entity : depthAsksList) {
                entity.setQty(BigDecimal.ZERO);
            }
            depthAsksRepository.saveAll(depthAsksList);

            BigDecimal MIN_VOL = BigDecimal.valueOf(1000);
            if ("BTC".equals(symbol.toUpperCase())) {
                MIN_VOL = BigDecimal.valueOf(10000);
            }

            String url = "https://api.binance.com/api/v3/depth?limit=5000&symbol=" + symbol.toUpperCase() + "USDT";
            RestTemplate restTemplate = new RestTemplate();
            Object result = restTemplate.getForObject(url, Object.class);

            // BIDS
            {
                Object obj_bids = Utils.getLinkedHashMapValue(result, Arrays.asList("bids"));
                if (obj_bids instanceof Collection) {

                    List<Object> obj_bids2 = new ArrayList<>((Collection<Object>) obj_bids);

                    BigDecimal curr_price = BigDecimal.ZERO;
                    {
                        Object obj = obj_bids2.get(0);
                        List<Double> bids = new ArrayList<>((Collection<Double>) obj);
                        curr_price = Utils.getBigDecimalValue(String.valueOf(bids.get(0)));
                    }
                    BigDecimal MIN_PRICE = curr_price.multiply(BigDecimal.valueOf(0.5));

                    List<DepthBids> saveList = new ArrayList<DepthBids>();
                    BigInteger rowidx = BigInteger.ZERO;
                    for (Object obj : obj_bids2) {
                        List<Double> bids = new ArrayList<>((Collection<Double>) obj);
                        BigDecimal price = Utils.getBigDecimalValue(String.valueOf(bids.get(0)));
                        if (price.compareTo(MIN_PRICE) < 0) {
                            break;
                        }

                        BigDecimal qty = Utils.getBigDecimalValue(String.valueOf(bids.get(1)));

                        BigDecimal volume = price.multiply(qty);
                        if (volume.compareTo(MIN_VOL) < 0) {
                            continue;
                        }

                        DepthBids entity = new DepthBids();
                        rowidx = rowidx.add(BigInteger.valueOf(1));
                        entity.setGeckoId(gecko_id);
                        entity.setSymbol(symbol);
                        entity.setPrice(price);
                        entity.setRowidx(rowidx);
                        entity.setQty(qty);
                        saveList.add(entity);

                    }
                    depthBidsRepository.saveAll(saveList);
                }
            }

            // ASKS
            {
                Object obj_asks = Utils.getLinkedHashMapValue(result, Arrays.asList("asks"));
                if (obj_asks instanceof Collection) {
                    List<Object> obj_asks2 = new ArrayList<>((Collection<Object>) obj_asks);

                    BigDecimal curr_price = BigDecimal.ZERO;
                    {
                        Object obj = obj_asks2.get(0);
                        List<Double> ask = new ArrayList<>((Collection<Double>) obj);
                        curr_price = Utils.getBigDecimalValue(String.valueOf(ask.get(0)));
                    }
                    BigDecimal MAX_PRICE = curr_price.multiply(BigDecimal.valueOf(2));

                    List<DepthAsks> saveList = new ArrayList<DepthAsks>();
                    BigInteger rowidx = BigInteger.ZERO;
                    for (Object obj : obj_asks2) {
                        List<Double> asks = new ArrayList<>((Collection<Double>) obj);
                        BigDecimal price = Utils.getBigDecimalValue(String.valueOf(asks.get(0)));

                        if (price.compareTo(MAX_PRICE) > 0) {
                            break;
                        }

                        BigDecimal qty = Utils.getBigDecimalValue(String.valueOf(asks.get(1)));

                        BigDecimal volume = price.multiply(qty);
                        if (volume.compareTo(MIN_VOL) < 0) {
                            continue;
                        }

                        DepthAsks entity = new DepthAsks();
                        rowidx = rowidx.add(BigInteger.valueOf(1));
                        entity.setGeckoId(gecko_id);
                        entity.setSymbol(symbol);
                        entity.setPrice(price);
                        entity.setRowidx(rowidx);
                        entity.setQty(qty);
                        saveList.add(entity);
                    }
                    depthAsksRepository.saveAll(saveList);
                }
            }
        } catch (Exception e) {
            System.out.println("Error saveDepthData  ----->");
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
                    + "    val_million_dolas,                                                                     \n"
                    + "    0 AS percent                                                                           \n"
                    + "FROM " + view + "                                                                          \n"
                    + "WHERE val_million_dolas > 0                                                                \n"
                    + "ORDER BY " + orderby;

            Query query = entityManager.createNativeQuery(sql, "DepthResponse");

            @SuppressWarnings("unchecked")
            List<DepthResponse> list = query.getResultList();

            return list;

        } catch (Exception e) {
            System.out.println("Error getDepthDataBtc  ----->");
            e.printStackTrace();
        }

        return new ArrayList<DepthResponse>();
    }

    @Override
    @Transactional
    public List<List<DepthResponse>> getListDepthData(String symbol) {
        List<List<DepthResponse>> result = new ArrayList<List<DepthResponse>>();
        BigDecimal current_price = Utils.getBinancePrice(symbol);

        // BTC
        if (symbol.toUpperCase().equals("BTC")) {
            saveDepthData("bitcoin", "BTC");
            List<DepthResponse> list_bids = getDepthDataBtc(2);
            List<DepthResponse> list_asks = getDepthDataBtc(3);

            list_bids_ok = new ArrayList<DepthResponse>();
            list_asks_ok = new ArrayList<DepthResponse>();

            BigDecimal WALL_3 = BigDecimal.valueOf(3);

            BigDecimal total_bids = BigDecimal.ZERO;
            for (DepthResponse dto : list_bids) {
                BigDecimal price = dto.getPrice();
                BigDecimal val = dto.getVal_million_dolas();

                if (val.compareTo(WALL_3) < 0) {
                    total_bids = total_bids.add(val);
                }

                if (val.compareTo(WALL_3) >= 0) {
                    DepthResponse real_wall = new DepthResponse();
                    real_wall.setPrice(price);
                    real_wall.setVal_million_dolas(total_bids);
                    real_wall.setPercent(Utils.getPercentStr(current_price, price));
                    list_bids_ok.add(real_wall);
                }

                dto.setPrice(price);
                dto.setPercent(Utils.getPercentStr(current_price, price));
                list_bids_ok.add(dto);
            }

            BigDecimal total_asks = BigDecimal.ZERO;
            for (DepthResponse dto : list_asks) {
                BigDecimal price = dto.getPrice();
                BigDecimal val = dto.getVal_million_dolas();

                if (val.compareTo(WALL_3) < 0) {
                    total_asks = total_asks.add(val);
                }

                if (val.compareTo(WALL_3) >= 0) {
                    DepthResponse real_wall = new DepthResponse();
                    real_wall.setPrice(price);
                    real_wall.setVal_million_dolas(total_asks);
                    real_wall.setPercent(Utils.getPercentStr(price, current_price));
                    list_asks_ok.add(real_wall);
                }

                dto.setPrice(price);
                dto.setPercent(Utils.getPercentStr(price, current_price));
                list_asks_ok.add(dto);
            }

            result.add(list_bids_ok);
            result.add(list_asks_ok);
            return result;
        }

        // Others
        try {
            List<BinanceVolumnDay> temp = binanceVolumnDayRepository.searchBySymbol(symbol);
            if (CollectionUtils.isEmpty(temp)) {
                return new ArrayList<List<DepthResponse>>();
            }

            String geckoId = temp.get(0).getId().getGeckoid();
            saveDepthData(geckoId, symbol.toUpperCase());

            list_bids_ok = getBids(geckoId, current_price);
            list_asks_ok = getAsks(geckoId, current_price);

            result.add(list_bids_ok);
            result.add(list_asks_ok);

            return result;
        } catch (Exception e) {
            System.out.println("Error getListDepthData  ----->");
            e.printStackTrace();
        }

        return result;
    }

    private List<DepthResponse> getBids(String geckoId, BigDecimal current_price) {

        String sql_bids = "                                                                                     \n"
                + " select * from (                                                                             \n"

                + "SELECT                                                                                       \n"
                + "    gecko_id,                                                                                \n"
                + "    symbol,                                                                                  \n"
                + "    price,                                                                                   \n"
                + "    qty,                                                                                     \n"
                + "    round(price * qty / 1000, 1) as val_million_dolas                                        \n"
                + "    , 0 AS percent                                                                           \n"
                + "FROM                                                                                         \n"
                + "    depth_bids                                                                               \n"
                + "WHERE gecko_id = '" + geckoId + "'                                                           \n"
                + " ) depth where depth.val_million_dolas > 10   ORDER BY price DESC                            \n";

        Query query = entityManager.createNativeQuery(sql_bids, "DepthResponse");
        @SuppressWarnings("unchecked")
        List<DepthResponse> list_bids = query.getResultList();

        List<DepthResponse> list_bids_ok = new ArrayList<DepthResponse>();
        for (DepthResponse dto : list_bids) {
            if (dto.getVal_million_dolas().compareTo(BigDecimal.valueOf(50)) > 0) {
                BigDecimal price = Utils.getBigDecimalValue(Utils.removeLastZero(String.valueOf(dto.getPrice())));
                dto.setPrice(price);
                dto.setPercent(Utils.getPercentStr(current_price, price));
                list_bids_ok.add(dto);
            }
        }

        return list_bids_ok;
    }

    private List<DepthResponse> getAsks(String geckoId, BigDecimal current_price) {
        String sql_asks = "                                                                                     \n"
                + " select * from (                                                                             \n"

                + "SELECT                                                                                       \n"
                + "    gecko_id,                                                                                \n"
                + "    symbol,                                                                                  \n"
                + "    price,                                                                                   \n"
                + "    qty,                                                                                     \n"
                + "    round(price * qty / 1000, 1) as val_million_dolas                                        \n"
                + "    , 0 AS percent                                                                           \n"
                + "FROM                                                                                         \n"
                + "    depth_asks                                                                               \n"
                + "WHERE gecko_id = '" + geckoId + "'                                                           \n"

                + " ) depth where depth.val_million_dolas > 10   ORDER BY price ASC                            \n";

        Query query = entityManager.createNativeQuery(sql_asks, "DepthResponse");
        @SuppressWarnings("unchecked")
        List<DepthResponse> list_asks = query.getResultList();
        List<DepthResponse> list_asks_ok = new ArrayList<DepthResponse>();

        for (DepthResponse dto : list_asks) {
            if (dto.getVal_million_dolas().compareTo(BigDecimal.valueOf(50)) > 0) {
                BigDecimal price = Utils.getBigDecimalValue(Utils.removeLastZero(String.valueOf(dto.getPrice())));
                dto.setPrice(price);
                dto.setPercent(Utils.getPercentStr(price, current_price));
                list_asks_ok.add(dto);
            }
        }

        return list_asks_ok;
    }

    @SuppressWarnings("unused")
    private String getSL(List<DepthResponse> list, BigDecimal entry, boolean isLong) {
        if (CollectionUtils.isEmpty(list)) {
            return "";
        }

        BigDecimal max_vol = BigDecimal.ZERO;
        BigDecimal sl = BigDecimal.ZERO;

        for (int index = 0; index < list.size(); index++) {
            DepthResponse dto = list.get(index);

            if (dto.getVal_million_dolas().compareTo(max_vol) > 0) {
                if (isLong) {
                    if (dto.getPrice().compareTo(entry) < 0) {
                        max_vol = dto.getVal_million_dolas();
                        sl = dto.getPrice();
                    }
                } else {
                    if (dto.getPrice().compareTo(entry) > 0) {
                        max_vol = dto.getVal_million_dolas();
                        sl = dto.getPrice();
                    }
                }

            }
        }

        String mySL = "SL: " + Utils.removeLastZero(sl) + "("
                + (isLong ? Utils.getPercentStr(entry, sl) : Utils.getPercentStr(sl, entry)) + ")";
        return mySL;
    }

    @Override
    @Transactional
    public String getTextDepthData() {
        BigDecimal price_now = Utils.getBinancePrice(SYMBOL_BTC);
        saveDepthData("bitcoin", "BTC");

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

    public BtcFuturesResponse getBtcFuturesResponse(String symbol, String TIME) {
        String str_id = "'" + symbol + "_" + TIME + "_%'";
        String header = symbol + "_" + TIME + "_";

        String sql = "SELECT                                                                                            \n"
                + "    (SELECT min(low_price) FROM btc_futures WHERE id like " + str_id + ") AS low_price_h, \n"
                + "    (SELECT                                                                                          \n"
                + "        ROUND(AVG(COALESCE(open_price, 0)), 5) open_candle                                           \n"
                + "    FROM(                                                                                            \n"
                + "        SELECT open_price                                                                            \n"
                + "        FROM                                                                                         \n"
                + "        (                                                                                            \n"
                + "            SELECT case when uptrend then price_open_candle else price_close_candle end as open_price \n"
                + "                  FROM btc_futures WHERE id like" + str_id + "  \n"
                + "        ) low_candle1                                                                                \n"
                + "        ORDER BY open_price asc limit 5                                                              \n"
                + "    ) low_candle) open_candle_h                                                                      \n"
                + "    ,                                                                                                \n"
                + "    (SELECT ROUND(AVG(COALESCE(close_price, 0)), 5) open_candle                                      \n"
                + "     FROM(                                                                                           \n"
                + "        SELECT close_price                                                                           \n"
                + "        FROM                                                                                         \n"
                + "        (                                                                                            \n"
                + "            SELECT case when uptrend then price_close_candle else price_open_candle end as close_price \n"
                + "              FROM btc_futures WHERE id like " + str_id + " \n"
                + "        ) close_candle1                                                                              \n"
                + "        ORDER BY close_price desc limit 5                                                            \n"
                + "    ) close_candle) close_candle_h,                                                                  \n"
                + "    (SELECT max(hight_price) FROM btc_futures WHERE id like " + str_id + ")   AS hight_price_h, \n"
                + "                                                                                                     \n"
                + "    (                                                                                                \n"
                + "        SELECT id as id_half1                                                                        \n"
                + "         FROM btc_futures WHERE id like " + str_id + " and id < '" + header + "24' \n"
                + "        ORDER BY (case when uptrend then price_open_candle else price_close_candle end) asc limit 1  \n"
                + "    )  as id_half1,                                                                                  \n"
                + "    (                                                                                                \n"
                + "        SELECT case when uptrend then price_open_candle else price_close_candle end as open_price_half1 \n"
                + "          FROM btc_futures WHERE id like " + str_id + " and id < '" + header + "24' \n"
                + "        ORDER BY open_price_half1 asc limit 1                                                        \n"
                + "    )  as open_price_half1,                                                                          \n"
                + "    (                                                                                                \n"
                + "        SELECT id as id_half2                                                                        \n"
                + "          FROM btc_futures WHERE id like " + str_id + " and id >= '" + header + "24' \n"
                + "        ORDER BY (case when uptrend then price_open_candle else price_close_candle end) asc limit 1  \n"
                + "    )  as id_half2,                                                                                  \n"
                + "    (                                                                                                \n"
                + "        SELECT case when uptrend then price_open_candle else price_close_candle end as open_price_half2 \n"
                + "          FROM btc_futures WHERE id like " + str_id + " and id >= '" + header + "24' \n"
                + "        ORDER BY open_price_half2 asc limit 1                                                        \n"
                + "    )  as open_price_half2                                                                           \n";

        Query query = entityManager.createNativeQuery(sql, "BtcFuturesResponse");

        @SuppressWarnings("unchecked")
        List<BtcFuturesResponse> vol_list = query.getResultList();
        if (CollectionUtils.isEmpty(vol_list)) {
            return null;
        }

        BtcFuturesResponse dto = vol_list.get(0);
        if (Objects.equals(null, dto.getLow_price_h())) {
            return null;
        }
        return dto;
    }

    @Override
    @Transactional
    public String getLongShortIn48h(String symbol) {
        boolean exit = true;
        if (exit) {
            return "";
        }

        List<BtcFutures> btc1hs = Utils.loadData(symbol, TIME_1h, LIMIT_DATA_1h);
        if (CollectionUtils.isEmpty(btc1hs)) {
            return "";
        }
        btcFuturesRepository.saveAll(btc1hs);
        BtcFuturesResponse dto_1h = getBtcFuturesResponse(symbol, TIME_1h);
        if (Objects.equals(null, dto_1h)) {
            return "";
        }
        BigDecimal price_at_binance = btc1hs.get(0).getCurrPrice();
        String low_height = Utils.getMsgLowHeight(price_at_binance, dto_1h);

        return low_height;
    }

    @Override
    @Transactional
    public List<String> monitorBtcPrice() {
        List<String> results = new ArrayList<String>();
        boolean exit = true;
        if (exit) {
            return results;
        }

        String time = Utils.convertDateToString("(hh:mm)", Calendar.getInstance().getTime());
        monitorBtcPrice_results = new ArrayList<String>();

        String curr_time_of_btc = Utils.convertDateToString("MMdd_HHmm", Calendar.getInstance().getTime());
        curr_time_of_btc = curr_time_of_btc.substring(0, curr_time_of_btc.length() - 1);
        String curr_time_of_btc_pre10m = String.valueOf(curr_time_of_btc);

        try {
            System.out.println(time + " Start monitorBtcPrice ---->");
            List<BtcFutures> btc1hs = Utils.loadData("BTC", TIME_1h, LIMIT_DATA_1h);
            if (CollectionUtils.isEmpty(btc1hs)) {
                return results;
            }
            btcFuturesRepository.saveAll(btc1hs);

            BigDecimal price_at_binance = btc1hs.get(0).getCurrPrice();

            // https://www.binance.com/en-GB/futures/funding-history/3

            String hh = Utils.convertDateToString("HH", Calendar.getInstance().getTime());
            if (!Objects.equals(hh, pre_time_of_saved_data_4h)) {
                List<BtcFutures> btc4hs = Utils.loadData("BTC", TIME_4h, LIMIT_DATA_4h);
                btcFuturesRepository.saveAll(btc4hs);
                pre_time_of_saved_data_4h = hh;
            }

            BtcFuturesResponse dto_1h = getBtcFuturesResponse("BTC", TIME_1h);
            if (Objects.equals(null, dto_1h)) {
                return results;
            }

            BtcFuturesResponse dto_10d = getBtcFuturesResponse("BTC", TIME_4h);
            if (Objects.equals(null, dto_10d)) {
                return results;
            }

            BigDecimal good_price_for_long = Utils.getGoodPriceLongByPercent(price_at_binance, dto_1h.getLow_price_h(),
                    dto_1h.getOpen_candle_h(), BigDecimal.valueOf(1));

            BigDecimal good_price_for_short = Utils.getGoodPriceShortByPercent(price_at_binance,
                    dto_1h.getHight_price_h(), dto_1h.getClose_candle_h(), BigDecimal.valueOf(1));

            String msg = time;

            String low_height = Utils.getMsgLowHeight(price_at_binance, dto_1h);
            low_height += " " + Utils.new_line_from_service;
            low_height += "10d" + Utils.new_line_from_service + Utils.getMsgLowHeight(price_at_binance, dto_10d);

            if (btc_is_uptrend_today) {
                msg += " Uptrend... " + " BTC: " + Utils.removeLastZero(String.valueOf(price_at_binance)) + "$";
                if (Utils.isGoodPriceLong(price_at_binance, dto_1h.getLow_price_h(), dto_1h.getHight_price_h())) {
                    msg += " (Good)";
                }
                msg += Utils.new_line_from_service;
                msg += low_height;
                results.add(Utils.getStringValue(msg));

                results.add("(Long*)" + Utils.new_line_from_service + Utils.getMsgLong(good_price_for_long, dto_1h));
                results.add("(Long now)" + Utils.new_line_from_service + Utils.getMsgLong(price_at_binance, dto_1h));

                results.add("(Short*)" + Utils.new_line_from_service + Utils.getMsgShort(good_price_for_short, dto_1h));
                results.add("(Short now)" + Utils.new_line_from_service + Utils.getMsgShort(price_at_binance, dto_1h));
            } else {
                msg += " Downtrend... " + " BTC: " + Utils.removeLastZero(String.valueOf(price_at_binance)) + "$";
                if (Utils.isGoodPriceShort(price_at_binance, dto_1h.getOpen_candle_h(), dto_1h.getClose_candle_h())) {
                    msg += " (Good)";
                }
                msg += Utils.new_line_from_service;
                msg += low_height;
                results.add(Utils.getStringValue(msg));

                results.add("(Short*)" + Utils.new_line_from_service + Utils.getMsgShort(good_price_for_short, dto_1h));
                results.add("(Short now)" + Utils.new_line_from_service + Utils.getMsgShort(price_at_binance, dto_1h));

                results.add("(Long*)" + Utils.new_line_from_service + Utils.getMsgLong(good_price_for_long, dto_1h));
                results.add("(Long now)" + Utils.new_line_from_service + Utils.getMsgLong(price_at_binance, dto_1h));
            }

            // kill long/short 10m
            if (!Objects.equals(curr_time_of_btc_pre10m, pre_time_of_btc_kill_long_short)) {
                if (price_at_binance.compareTo(dto_1h.getLow_price_h()) <= 0) {
                    Utils.sendToTelegram(" 💔 CZ kill LONG !!!" + Utils.new_line_from_service + wallToday());
                    pre_time_of_btc_kill_long_short = curr_time_of_btc_pre10m;
                }

                if (price_at_binance.compareTo(dto_1h.getHight_price_h()) >= 0) {
                    // kill short: loss 30$ 2022/09/09
                    Utils.sendToTelegram(" 💔 CZ kill SHORT !!!" + Utils.new_line_from_service + wallToday());
                    pre_time_of_btc_kill_long_short = curr_time_of_btc_pre10m;
                }
            }

            monitorBtcPrice_results = new ArrayList<>(results);
            return results;

        } catch (Exception e) {
            System.out.println("ERROR monitorBtcPrice ----->");
            e.printStackTrace();
        }

        return results;
    }

    @Transactional
    private String monitorBitcoinBalancesOnExchanges() {
        // try {
        // String event = EVENT_BTC_ON_EXCHANGES + "_" + Utils.getCurrentHH();
        //
        // if (fundingHistoryRepository.existsPumDump("bitcoin", event)) {
        // return "";
        // }
        //
        // FundingHistory his = new FundingHistory();
        // FundingHistoryKey id = new FundingHistoryKey(event, "bitcoin");
        // his.setId(id);
        // his.setPumpdump(true);
        //
        // System.out.println("Start monitorBitcoinBalancesOnExchanges ---->");
        // try {
        // List<BitcoinBalancesOnExchanges> entities =
        // GoinglassUtils.getBtcExchangeBalance();
        // if (entities.size() > 0) {
        // bitcoinBalancesOnExchangesRepository.saveAll(entities);
        // }
        //
        // String sql = " SELECT \n"
        // + " fun_btc_price_now() as price_now \n"
        // + ", sum(balance_change) as change_24h \n"
        // + ", round(sum(balance_change) * fun_btc_price_now() / 1000000, 0) as
        // change_24h_val_million \n"
        // + ", sum(d7_balance_change) as change_7d \n"
        // + ", round(sum(d7_balance_change) * fun_btc_price_now() / 1000000, 0) as
        // change_7d_val_million \n"
        // + " FROM bitcoin_balances_on_exchanges \n"
        // + " WHERE \n"
        // + " yyyymmdd='" + Utils.convertDateToString("yyyyMMdd",
        // Calendar.getInstance().getTime()) + "'";
        //
        // Query query = entityManager.createNativeQuery(sql,
        // "BitcoinBalancesOnExchangesResponse");
        //
        // List<BitcoinBalancesOnExchangesResponse> vol_list = query.getResultList();
        // if (CollectionUtils.isEmpty(vol_list)) {
        // return "";
        // }
        //
        // BitcoinBalancesOnExchangesResponse dto = vol_list.get(0);
        //
        // String msg = "BTC 24h: " + dto.getChange_24h() + "btc(" +
        // dto.getChange_24h_val_million() + "m$)"
        // + Utils.new_line_from_service;
        //
        // msg += " 07d: " + dto.getChange_7d() + "btc(" +
        // dto.getChange_7d_val_million() + "m$)";
        //
        // return msg;
        //
        // } catch (Exception e) {
        // his.setNote(e.getMessage());
        // System.out.println("Error monitorBitcoinBalancesOnExchanges ---->" +
        // e.getMessage());
        // }
        // fundingHistoryRepository.save(his);
        // } catch (Exception e) {
        // }

        return "";
    }

    @Override
    public String getBtcBalancesOnExchanges() {
        return "";
        // int HH = Utils.getCurrentHH();
        // if (HH != pre_monitorBitcoinBalancesOnExchanges_HH) {
        // monitorBitcoinBalancesOnExchanges_temp = monitorBitcoinBalancesOnExchanges();
        // pre_monitorBitcoinBalancesOnExchanges_HH = HH;
        // return monitorBitcoinBalancesOnExchanges_temp;
        // } else {
        // return monitorBitcoinBalancesOnExchanges_temp;
        // }
    }

    @Override
    public List<EntryCssResponse> findAllScalpingToday() {
        List<EntryCssResponse> results = new ArrayList<EntryCssResponse>();
        try {
            // List<FundingHistory> list = fundingHistoryRepository.findAllByPumpdump(true);
            results.add(new EntryCssResponse());

            for (int loop = 0; loop < 2; loop++) {
                List<FundingHistory> list;
                if (loop == 0) {
                    list = fundingHistoryRepository.findAllFiboLong();

                } else {
                    list = fundingHistoryRepository.findAllFiboShort();
                }

                int count = list.size();
                int MAX_LENGTH = 9;
                if (count > MAX_LENGTH) {
                    count = MAX_LENGTH;
                }
                if (!CollectionUtils.isEmpty(list)) {
                    String symbols = "";
                    for (int index = 0; index < count; index++) {
                        FundingHistory entity = list.get(index);

                        if (symbols.contains(entity.getSymbol())) {
                            continue;
                        }
                        EntryCssResponse dto = new EntryCssResponse();
                        dto.setSymbol(entity.getSymbol());
                        dto.setTradingview(
                                "https://www.binance.com/en/futures/" + entity.getSymbol().toUpperCase() + "USDT");
                        symbols += entity.getSymbol() + ",";
                        results.add(dto);
                    }

                    if (list.size() > MAX_LENGTH) {
                        EntryCssResponse dto = new EntryCssResponse();
                        dto.setSymbol(".........");
                        dto.setFutures_msg("http://localhost:8090/BTC");
                        dto.setTradingview("https://vn.tradingview.com/chart/?symbol=BINANCE%3ABTCUSDTPERP");
                        results.add(dto);
                    } else {
                        for (int j = list.size(); j <= MAX_LENGTH; j++) {
                            results.add(new EntryCssResponse());
                        }
                    }
                }
            }
        } catch (Exception e) {
            System.out.println("Error findAllScalpingToday ---->");
            e.printStackTrace();
        }

        return results;
    }

    // https://www.binance.com/en-GB/futures/funding-history/3
    @SuppressWarnings("unused")
    private void monitorBtcFundingRate(Boolean isUpCandle) {
        try {
            FundingResponse rate = Utils.loadFundingRate("BTC");
            BigDecimal high = rate.getHigh();
            BigDecimal low = rate.getLow();

            String msg = "";
            if (isUpCandle) {
                if (high.compareTo(BigDecimal.valueOf(0.5)) > 0) {

                    msg = " 💔💔 (DANGER DANGER) CZ kill SHORT!!!";

                } else if (high.compareTo(BigDecimal.valueOf(0.2)) > 0) {

                    msg = " 💔 (DANGER) CZ kill SHORT !!! Wait 10~15 minutes.";

                }
            } else {
                if (low.compareTo(BigDecimal.valueOf(-1)) < 0) {

                    msg = " 💔💔💔 (DANGER DANGER DANGER) CZ kill LONG !!!";

                } else if (low.compareTo(BigDecimal.valueOf(-0.5)) < 0) {

                    msg = " 💔💔 (DANGER DANGER) CZ kill LONG !!!";

                } else if (low.compareTo(BigDecimal.valueOf(-0.2)) < 0) {

                    msg = " 💔 (DANGER) CZ kill LONG !!!";
                }
            }

            // -----------------------------------------------------------------------------------------//

            if (Utils.isNotBlank(msg)) {
                String EVENT_ID = EVENT_DANGER_CZ_KILL_LONG + "_" + Utils.getCurrentYyyyMmDd_Blog2h();

                if (!fundingHistoryRepository.existsPumDump("bitcoin", EVENT_ID)) {

                    fundingHistoryRepository.save(createPumpDumpEntity(EVENT_ID, "bitcoin", "BTC",
                            Utils.getToday_YyyyMMdd() + " Long/Short", true));

                    if (Utils.isNotBlank(msg)) {
                        Utils.sendToTelegram(msg + Utils.new_line_from_service + Utils.new_line_from_service
                                + wallToday() + Utils.new_line_from_service + Utils.new_line_from_service
                                + getBitfinexLongShortBtc());
                    }
                }
            }

        } catch (

        Exception e) {
            System.out.println("Error monitorBtcFundingRate ---->");
            e.printStackTrace();
        }
    }

    @Transactional
    private void loadFundingHistory(String gecko_id, String symbol) {
        boolean notusingthismethod = true;
        if (notusingthismethod) {
            return;
        }

        if (Objects.equals("BTC", symbol)) {
            return;
        }
        try {
            BigDecimal CONST_RATE_HIGH = BigDecimal.valueOf(0.2);

            FundingResponse rate = Utils.loadFundingRate(symbol);
            BigDecimal highUp = rate.getHighUp();
            BigDecimal lowUp = rate.getLowUp();

            FundingHistory entity = new FundingHistory();
            FundingHistoryKey id = new FundingHistoryKey();
            id.setEventTime(EVENT_FUNDING_RATE);
            id.setGeckoid(gecko_id);
            entity.setId(id);
            entity.setSymbol(symbol);

            entity.setHigh(rate.getHigh());
            entity.setLow(rate.getLow());
            entity.setAvgHigh(rate.getAvg_high());
            entity.setAvgLow(rate.getAvg_low());
            entity.setCountHigh(highUp.intValue());
            entity.setCountLow(lowUp.intValue());

            entity.setNote("");
            entity.setPumpdump(false);

            if (rate.getHigh().compareTo(CONST_RATE_HIGH) > 0) {
                String time = Utils.convertDateToString("(hh:mm)", Calendar.getInstance().getTime());
                String note = time + " Kill Long/Short";
                entity.setNote(note);
                entity.setPumpdump(true);
            }

            fundingHistoryRepository.save(entity);
        } catch (Exception e) {
            System.out.println("Error loadFundingHistory ---->");
            e.printStackTrace();
        }

    }

    @Override
    @Transactional
    public String wallToday() {
        String key = Utils.getTimeChangeDailyChart();

        BigDecimal WALL_3 = BigDecimal.valueOf(4);

        BigDecimal max_bid = BigDecimal.ZERO;
        BigDecimal max_ask = BigDecimal.ZERO;

        BigDecimal low = BigDecimal.ZERO;
        BigDecimal high = BigDecimal.ZERO;

        for (DepthResponse dto : list_bids_ok) {
            if (!Objects.equals("BTC", dto.getSymbol())) {
                continue;
            }

            if ((dto.getVal_million_dolas().compareTo(max_bid) > 0)
                    && (dto.getVal_million_dolas().compareTo(WALL_3) >= 0)) {
                max_bid = dto.getVal_million_dolas();
                low = dto.getPrice();
            }
        }

        for (DepthResponse dto : list_asks_ok) {
            if (!Objects.equals("BTC", dto.getSymbol())) {
                continue;
            }

            if ((dto.getVal_million_dolas().compareTo(max_ask) > 0)
                    && (dto.getVal_million_dolas().compareTo(WALL_3) >= 0)) {
                max_ask = dto.getVal_million_dolas();
                high = dto.getPrice();
            }
        }

        String EVENT_ID = EVENT_BTC_RANGE + "_" + key;
        FundingHistoryKey id = new FundingHistoryKey();
        id.setEventTime(EVENT_ID);
        id.setGeckoid("bitcoin");

        String note = low + "~" + high;
        if (!fundingHistoryRepository.existsPumDump("bitcoin", EVENT_ID)) {
            FundingHistory coin = new FundingHistory();
            coin.setId(id);
            coin.setSymbol("BTC");
            coin.setNote(note);
            coin.setPumpdump(true);

            coin.setLow(low);
            coin.setHigh(high);

            coin.setAvgLow(max_bid);
            coin.setAvgHigh(max_ask);

            fundingHistoryRepository.save(coin);
        } else {
            FundingHistory coin = fundingHistoryRepository.findById(id).orElse(null);
            if (!Objects.equals(null, coin)) {

                boolean hasChangeValue = false;

                if (low.compareTo(Utils.getBigDecimal(BigDecimal.ZERO)) > 0) {
                    if (low.compareTo(Utils.getBigDecimal(coin.getLow())) < 0) {
                        coin.setNote(note);
                        coin.setLow(low);
                        coin.setAvgLow(max_bid);
                        hasChangeValue = true;
                    }
                }

                if ((Utils.getBigDecimal(coin.getLow()).compareTo(BigDecimal.ZERO) < 1)
                        || (Utils.getBigDecimal(coin.getAvgLow()).compareTo(BigDecimal.ZERO) < 1)) {
                    coin.setNote(note);
                    coin.setLow(low);
                    coin.setAvgLow(max_bid);
                    hasChangeValue = true;
                }

                // ------------------------------

                if (high.compareTo(Utils.getBigDecimal(BigDecimal.ZERO)) > 0) {
                    if (high.compareTo(Utils.getBigDecimal(coin.getHigh())) > 0) {
                        coin.setNote(note);
                        coin.setHigh(high);
                        coin.setAvgHigh(max_ask);
                        hasChangeValue = true;
                    }
                }

                if ((Utils.getBigDecimal(coin.getHigh()).compareTo(BigDecimal.ZERO) < 1)
                        || (Utils.getBigDecimal(coin.getAvgHigh()).compareTo(BigDecimal.ZERO) < 1)) {
                    coin.setNote(note);
                    coin.setHigh(high);
                    coin.setAvgHigh(max_ask);
                    hasChangeValue = true;
                }

                // ------------------------------

                if (hasChangeValue) {
                    fundingHistoryRepository.save(coin);
                }

                low = coin.getLow();
                high = coin.getHigh();
            }
        }

        String result = Utils.createMsgLowHeight(Utils.getBinancePrice("BTC"), low, high);
        result = result.replace("L:", "Wall: ").replace("-H:", " ~ ").replace("$", "");

        return result;
    }
    // clearTrash

    @Override
    @Transactional
    public String getChartWD(String gecko_id, String symbol) {
        String result = symbol.toUpperCase() + " " + checkWDtrend(gecko_id, symbol.toUpperCase());

        return result;
    }

    private String sendMsgMonitorFibo(String gecko_id, String symbol, List<BtcFutures> list, String only_trend,
            int maIndex, boolean showDetail) {
        String msg = Utils.getMmDD_TimeHHmm() + symbol + ",";

        String result = Utils.checkMa3AndX(list, maIndex, showDetail, only_trend);

        if (Utils.isNotBlank(result)) {

            msg = (msg + result).replace(",", Utils.new_line_from_service);
            msg += Utils.new_line_from_service + "Currency:" + TREND_CURRENCY_TODAY;

            String EVENT_LONG_SHORT = EVENT_FIBO_LONG_SHORT + symbol + "_" + Utils.getCurrentYyyyMmDd_Blog2h();

            if (!fundingHistoryRepository.existsPumDump(gecko_id, EVENT_LONG_SHORT)) {
                fundingHistoryRepository.save(createPumpDumpEntity(EVENT_LONG_SHORT, gecko_id, symbol, "", true));

                Utils.sendToMyTelegram(msg.replace(" ", ""));

            }
        }

        return result;
    }

    private void sendMsgPerHour(String EVENT_ID, String msg_content) {
        String msg = Utils.getMmDD_TimeHHmm();
        msg += msg_content;

        if (!fundingHistoryRepository.existsPumDump("MSG_PER_HOUR", EVENT_ID)) {

            fundingHistoryRepository.save(createPumpDumpEntity(EVENT_ID, "MSG_PER_HOUR", "MSG_PER_HOUR", "", false));

            Utils.sendToMyTelegram(msg);
        }
    }

    private void sendMsgKillLongShort(String gecko_id, String symbol, List<BtcFutures> list_15m) {
        BtcFutures ido = list_15m.get(0);
        if (ido.isBtcKillLongCandle() || ido.isBtcKillShortCandle()) {
            String msg = Utils.getTimeHHmm() + " 💔 " + symbol + " 15m kill Long. "
                    + Utils.removeLastZero(ido.getCurrPrice());

            if (ido.isBtcKillShortCandle()) {
                msg = Utils.getTimeHHmm() + " 💔 " + symbol + " 15m kill Short. "
                        + Utils.removeLastZero(ido.getCurrPrice());
            }

            String EVENT_ID5 = EVENT_DANGER_CZ_KILL_LONG + "_" + symbol + "_" + Utils.getCurrentYyyyMmDdHH();

            if (!fundingHistoryRepository.existsPumDump(gecko_id, EVENT_ID5)) {
                fundingHistoryRepository.save(createPumpDumpEntity(EVENT_ID5, gecko_id, symbol, msg, true));

                Utils.sendToTelegram(msg);
            }
        }
    }

    // AUD_EUR_GBP_USDT
    private void checkCurrency() {
        if (pre_HH_CheckUSD == Utils.getCurrentHH()) {
            return;
        }

        if (!Objects.equals(pre_Blog4H_CheckUSD, Utils.getCurrentYyyyMmDd_Blog4h())) {
            List<BtcFutures> list_H4_AUD = Utils.loadData("AUD", TIME_4h, 60);
            List<BtcFutures> list_H4_EUR = Utils.loadData("EUR", TIME_4h, 60);
            List<BtcFutures> list_H4_GBP = Utils.loadData("GBP", TIME_4h, 60);

            String temp = "";
            temp = sendMsgMonitorFibo("AUD_USDT", "AUD_USDT", list_H4_AUD, "", 50, false);
            if (Utils.isBlank(temp)) {
                sendMsgMonitorFibo("AUD_USDT", "AUD_USDT", list_H4_AUD, "", 21, false);
            }

            temp = sendMsgMonitorFibo("EUR_USDT", "EUR_USDT", list_H4_EUR, "", 50, false);
            if (Utils.isBlank(temp)) {
                sendMsgMonitorFibo("EUR_USDT", "EUR_USDT", list_H4_EUR, "", 21, false);
            }

            temp = sendMsgMonitorFibo("GBP_USDT", "GBP_USDT", list_H4_GBP, "", 50, false);
            if (Utils.isBlank(temp)) {
                sendMsgMonitorFibo("GBP_USDT", "GBP_USDT", list_H4_GBP, "", 21, false);
            }

            boolean IsUpAUD_3 = Utils.maIsUptrend(list_H4_AUD, 3);
            boolean IsUpAUD_S = Utils.maIsUptrend(list_H4_AUD, Utils.MA_INDEX_CURRENCY);
            if (IsUpAUD_3 == IsUpAUD_S) {
                TREND_H4_AUD = IsUpAUD_S ? TREND_LONG : TREND_SHORT;
            } else {
                TREND_H4_AUD = TREND_OPPOSITE;
            }

            boolean IsUpEUR_3 = Utils.maIsUptrend(list_H4_EUR, 3);
            boolean IsUpEUR_S = Utils.maIsUptrend(list_H4_EUR, Utils.MA_INDEX_CURRENCY);
            if (IsUpEUR_3 == IsUpEUR_S) {
                TREND_H4_EUR = IsUpEUR_S ? TREND_LONG : TREND_SHORT;
            } else {
                TREND_H4_EUR = TREND_OPPOSITE;
            }

            boolean IsUpGBP_3 = Utils.maIsUptrend(list_H4_GBP, 3);
            boolean IsUpGBP_S = Utils.maIsUptrend(list_H4_GBP, Utils.MA_INDEX_CURRENCY);
            if (IsUpGBP_3 == IsUpGBP_S) {
                TREND_H4_GBP = IsUpGBP_S ? TREND_LONG : TREND_SHORT;
            } else {
                TREND_H4_GBP = TREND_OPPOSITE;
            }

            int count_usd_uptrend = 3;
            count_usd_uptrend -= IsUpAUD_S ? 1 : 0;
            count_usd_uptrend -= IsUpEUR_S ? 1 : 0;
            count_usd_uptrend -= IsUpGBP_S ? 1 : 0;
            usd_is_uptrend_today = (count_usd_uptrend > 1) ? true : false;
            if (usd_is_uptrend_today) {
                TREND_CURRENCY_TODAY = TREND_SHORT;
            } else {
                TREND_CURRENCY_TODAY = TREND_LONG;
            }
            pre_Blog4H_CheckUSD = Utils.getCurrentYyyyMmDd_Blog4h();
        }

        List<String> list_currency = new ArrayList<String>(Arrays.asList("AUD", "EUR", "GBP"));
        for (String CURR : list_currency) {
            String ID = CURR + "_USDT";
            String trend = TREND_LONG;
            if (Objects.equals("AUD", CURR)) {
                trend = TREND_H4_AUD;
            } else if (Objects.equals("EUR", CURR)) {
                trend = TREND_H4_EUR;
            } else if (Objects.equals("GBP", CURR)) {
                trend = TREND_H4_GBP;
            }

            if (Objects.equals(trend, TREND_OPPOSITE)) {
                continue;
            }

            String EVENT_LONG_SHORT_CURRENCY = EVENT_FIBO_LONG_SHORT + ID + Utils.getCurrentYyyyMmDd_Blog2h();
            if (!fundingHistoryRepository.existsPumDump(ID, EVENT_LONG_SHORT_CURRENCY)) {

                List<BtcFutures> list_cur = Utils.loadData(CURR, TIME_1h, 60);
                String cur_h1_result = Utils.checkMa3AndX(list_cur, 50, false, trend);

                if (Utils.isBlank(cur_h1_result)) {
                    cur_h1_result = Utils.checkMa3AndX(list_cur, 21, false, trend);
                }

                if (Utils.isBlank(cur_h1_result)) {
                    cur_h1_result = Utils.checkMa3AndX(list_cur, 13, false, trend);
                }

                if (Utils.isNotBlank(cur_h1_result)) {
                    String msg = Utils.getMmDD_TimeHHmm()
                            + list_cur.get(0).getId().replace("_00", "").replace("_", "_USDT_")
                            + Utils.new_line_from_service + cur_h1_result.replace(",", Utils.new_line_from_service);

                    fundingHistoryRepository.save(createPumpDumpEntity(EVENT_LONG_SHORT_CURRENCY, ID, ID, "", true));

                    Utils.sendToMyTelegram(msg);
                }
            }
        }
        pre_HH_CheckUSD = Utils.getCurrentHH();
    }

    @Transactional
    public String checkWDtrend(String gecko_id, String symbol) {
        // AUD_EUR_GBP_USDT
        if (Objects.equals("BTC", symbol)) {
            checkCurrency();
        }

        String EVENT_ID = EVENT_TREND_1W1D + "_" + symbol;
        String type = "";
        if (binanceFuturesRepository.existsById(gecko_id)) {
            type = " (Futures) ";
        } else {
            type = " (Spot) ";
        }
        List<BtcFutures> list_weeks = Utils.loadData(symbol, TIME_1w, 10);
        if (CollectionUtils.isEmpty(list_weeks)) {
            return "";
        }
        List<BtcFutures> list_days = Utils.loadData(symbol, TIME_1d, 30);
        List<BtcFutures> list_h4 = Utils.loadData(symbol, TIME_4h, 60);
        type = type + Utils.analysisVolume(list_h4);

        String scapLongOrShortH4 = Utils.getScapLong(list_h4, list_days, 10);

        String checkMa3AndX = "";
        String MAIN_TOKEN = "_BTC_ETH_BNB_";
        String SPOT_TOKEN = "_HOOK_HFT_APT_GMX_TWT_";
        if (MAIN_TOKEN.contains("_" + symbol + "_")) {
            List<BtcFutures> list_15m = Utils.loadData(symbol, "15m", 1);
            sendMsgKillLongShort(gecko_id, symbol, list_15m);

            scapLongOrShortH4 = Utils.getScapLongOrShort_BTC(list_h4, list_days, 10);

            if (Objects.equals("BTC", symbol)) {
                sendMsgMonitorFibo(gecko_id, symbol, list_h4, TREND_H4_BTC, Utils.MA_INDEX_STOP_LONG, false);

                TREND_H4_BTC_IS_LONG = Utils.maIsUptrend(list_h4, 21);
                TREND_H4_BTC = TREND_H4_BTC_IS_LONG ? TREND_LONG : TREND_SHORT;
            }

            if (Utils.isBlank(checkMa3AndX)) {
                checkMa3AndX = sendMsgMonitorFibo(gecko_id, symbol, list_h4, TREND_H4_BTC, 50, false);
                if (Utils.isBlank(checkMa3AndX)) {
                    checkMa3AndX = sendMsgMonitorFibo(gecko_id, symbol, list_h4, TREND_H4_BTC, 21, false);
                }
            }

            if (Utils.isBlank(checkMa3AndX)) {
                // H4: ma3 dong pha ma21, va ma21 dong pha ma21 cua BTC
                boolean IsUp_4h_ma21 = Utils.maIsUptrend(list_h4, 21);
                boolean IsUp_4h_ma3 = Utils.maIsUptrend(list_h4, 3);

                if ((TREND_H4_BTC_IS_LONG == IsUp_4h_ma21) && (IsUp_4h_ma21 == IsUp_4h_ma3)) {

                    List<BtcFutures> list_h1 = Utils.loadData(symbol, TIME_1h, 50);
                    checkMa3AndX = sendMsgMonitorFibo(gecko_id, symbol, list_h1, TREND_H4_BTC, 50, false);

                    if (Utils.isBlank(checkMa3AndX)) {
                        checkMa3AndX = sendMsgMonitorFibo(gecko_id, symbol, list_h1, TREND_H4_BTC, 21, false);
                    }
                }
            }
        } else if (type.contains("Futures") || SPOT_TOKEN.contains("_" + symbol + "_")) {
            if (TREND_H4_BTC_IS_LONG) {
                checkMa3AndX = sendMsgMonitorFibo(gecko_id, symbol, list_h4, TREND_LONG, 50, false);
                if (Utils.isBlank(checkMa3AndX)) {
                    checkMa3AndX = sendMsgMonitorFibo(gecko_id, symbol, list_h4, TREND_LONG, 21, false);
                }
            }
        }
        if (Utils.isStopLong(list_h4)) {
            scapLongOrShortH4 = TREND_STOP_LONG;
        }

        BigDecimal current_price = list_days.get(0).getCurrPrice();

        try {
            if (Utils.isNotBlank(checkMa3AndX)) {
                PriorityCoinHistory his = new PriorityCoinHistory();
                his.setGeckoid(gecko_id);
                his.setSymbol(Utils.getMmDD_TimeHHmm());
                if (checkMa3AndX.length() > 255) {
                    checkMa3AndX = checkMa3AndX.substring(0, 250) + "...";
                }
                his.setName(checkMa3AndX);

                priorityCoinHistoryRepository.save(his);
            }

            CandidateCoin entity = candidateCoinRepository.findById(gecko_id).orElse(null);
            if (!Objects.equals(null, entity)) {
                entity.setCurrentPrice(current_price);
                candidateCoinRepository.save(entity);
            }

        } catch (Exception e) {
        }

        List<BigDecimal> min_max_week = Utils.getLowHeightCandle(list_weeks);
        BigDecimal min_week = Utils.formatPrice(min_max_week.get(0).multiply(BigDecimal.valueOf(0.99)), 5);
        BigDecimal max_week = min_max_week.get(1);

        List<BigDecimal> min_max_day = Utils.getLowHeightCandle(list_days.subList(0, 10));
        BigDecimal min_days = min_max_day.get(0);
        BigDecimal max_days = min_max_day.get(1);

        String W1 = list_weeks.get(0).isUptrend() ? "W↑" : "W↓";
        String D1 = list_days.get(0).isUptrend() ? "D↑" : "D↓";

        String note = W1 + D1;
        note += ",L10d:" + Utils.getPercentToEntry(current_price, min_days, true);
        note += ",H10d:" + Utils.getPercentToEntry(current_price, max_days, false);
        note += ",L10w:" + Utils.getPercentToEntry(current_price, min_week, true) + ",";
        if (Utils.isStartingLong(list_h4)) {
            note += "_Position";
        }

        // ---------------------------------------------------------
        String curr_week_day_trending = W1 + D1;
        if (Objects.equals("BTC", symbol)) {
            btc_week_day_trending = curr_week_day_trending;
            btc_is_uptrend_today = list_days.get(0).isUptrend();
        }

        // ---------------------------------------------------------
        String mUpMa = "";
        boolean chartDUpMa10 = Utils.isAboveMALine(list_days, Utils.getSlowIndex(list_days), 0);
        mUpMa += chartDUpMa10 ? "↑D(ma" + Utils.getSlowIndex(list_days) + ") " : " ";
        if (Utils.isNotBlank(mUpMa.trim())) {
            mUpMa = " move" + mUpMa.trim();
        }

        String mDownMa = "";
        // boolean chartDTodayCutDown = Utils.isBelowMALine(list_days, 10, 0);
        mDownMa += !chartDUpMa10 ? "↓D(ma" + Utils.getSlowIndex(list_days) + ") " : "";

        if (Utils.isNotBlank(mDownMa)) {
            if (Utils.isNotBlank(mUpMa)) {
                mDownMa = " " + mDownMa.trim();
            } else {
                mDownMa = "move" + mDownMa.trim();
            }
        }

        String m2ma = " m2ma{" + (mUpMa.trim() + " " + mDownMa.trim()).trim() + "}m2ma";
        String checkMa50 = "_ma7(" + Utils.checkMa3And50(list_h4) + ")~";

        // H4 sl2ma
        String entry = "";
        if (Utils.isNotBlank(scapLongOrShortH4)) {
            scapLongOrShortH4 = scapLongOrShortH4.replace("_" + symbol.toUpperCase() + "_", "_");
            entry = " sl2ma{" + scapLongOrShortH4 + "}sl2ma";
        }
        // ---------------------------------------------------------

        String result = note + type + m2ma + checkMa50 + entry;
        if (result.length() > 255) {
            // result = result.substring(0, 250) + "...";
        }
        fundingHistoryRepository.save(createPumpDumpEntity(EVENT_ID, gecko_id, symbol, result, true));
        // -------------------------------------------------------------

        result = Utils.getTimeHHmm() + " " + symbol.toUpperCase() + " " + Utils.removeLastZero(current_price) + m2ma
                + entry;

        result += Utils.new_line_from_bot;
        result += W1 + D1 + Utils.new_line_from_bot;

        result += "L10d:" + Utils.getPercentToEntry(current_price, min_days, true);
        result += ", H10d:" + Utils.getPercentToEntry(current_price, max_days, false);

        result += Utils.new_line_from_bot;

        result += "L10w:" + Utils.getPercentToEntry(current_price, min_week, true);
        result += ", H10w:" + Utils.getPercentToEntry(current_price, max_week, false);
        result += checkMa3AndX.replace(",", Utils.new_line_from_bot);

        result = result.replaceAll("↑", "^").replaceAll("↓", "v");

        return result;
    }

    @Override
    @Transactional
    public void clearTrash() {
        List<FundingHistory> list = fundingHistoryRepository.clearTrash();
        if (!CollectionUtils.isEmpty(list)) {
            fundingHistoryRepository.deleteAll(list);
        }
    }

}
