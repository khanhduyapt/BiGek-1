package bsc_scan_token.service.impl;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Calendar;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Objects;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.util.stream.Collectors;

import javax.persistence.EntityManager;
import javax.persistence.PersistenceContext;
import javax.persistence.Query;
import javax.transaction.Transactional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.util.CollectionUtils;
import org.springframework.web.client.RestTemplate;

import bsc_scan_token.entity.CandidateCoin;
import bsc_scan_token.entity.GeckoVolumeMonth;
import bsc_scan_token.entity.GeckoVolumeMonthKey;
import bsc_scan_token.repository.CandidateCoinRepository;
import bsc_scan_token.repository.GeckoVolumeMonthRepository;
import bsc_scan_token.service.CoinGeckoService;
import bsc_scan_token.utils.Utils;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Service
@Slf4j
@RequiredArgsConstructor
public class CoinGeckoServiceImpl implements CoinGeckoService {

    @PersistenceContext
    private EntityManager entityManager;

    @Autowired
    private CandidateCoinRepository candidateCoinRepository;

    @Autowired
    private GeckoVolumeMonthRepository geckoVolumeMonthRepository;

    @Override
    public List<CandidateCoin> getList() {
        return candidateCoinRepository.findCandidateCoinInBinanceFutures();
    }

    @Transactional
    public CandidateCoin loadData(String gecko_id) {
        final String url = "https://api.coingecko.com/api/v3/coins/" + gecko_id
                + "?localization=false&tickers=true&market_data=true&community_data=false&developer_data=false&sparkline=false";

        RestTemplate restTemplate = new RestTemplate();

        @SuppressWarnings("unchecked")
        LinkedHashMap<String, Object> result = restTemplate.getForObject(url, LinkedHashMap.class);

        CandidateCoin coin = new CandidateCoin();

        Object id = Utils.getLinkedHashMapValue(result, Arrays.asList("id"));
        Object symbol = Utils.getLinkedHashMapValue(result, Arrays.asList("symbol"));
        Object name = Utils.getLinkedHashMapValue(result, Arrays.asList("name"));

        coin.setGeckoid(String.valueOf(id).toLowerCase());
        coin.setSymbol(String.valueOf(symbol).toUpperCase());
        coin.setName(String.valueOf(name));

        BigDecimal market_cap = Utils
                .getBigDecimal(Utils.getLinkedHashMapValue(result, Arrays.asList("market_data", "market_cap", "usd")));
        BigDecimal total_volume = Utils.getBigDecimal(
                Utils.getLinkedHashMapValue(result, Arrays.asList("market_data", "total_volume", "usd")));
        Object current_price = Utils.getLinkedHashMapValue(result,
                Arrays.asList("market_data", "current_price", "usd"));
        Object priceChangePercentage24h = Utils.getLinkedHashMapValue(result,
                Arrays.asList("market_data", "price_change_percentage_24h"));
        Object priceChangePercentage7d = Utils.getLinkedHashMapValue(result,
                Arrays.asList("market_data", "price_change_percentage_7d"));
        Object priceChangePercentage14d = Utils.getLinkedHashMapValue(result,
                Arrays.asList("market_data", "price_change_percentage_14d"));
        Object priceChangePercentage30d = Utils.getLinkedHashMapValue(result,
                Arrays.asList("market_data", "price_change_percentage_30d"));

        Object ath_date = Utils.getLinkedHashMapValue(result,
                Arrays.asList("market_data", "ath_date"));

        @SuppressWarnings("unchecked")
        LinkedHashMap<String, Object> ath_date_map = (LinkedHashMap<String, Object>) ath_date;
        String min_year_month = "9999-12";
        if (!Objects.equals(null, ath_date_map) && !CollectionUtils.isEmpty(ath_date_map)) {
            for (Object key : ath_date_map.keySet()) {
                String value = String.valueOf(ath_date_map.get(key));
                if (value.length() > 7) {
                    String year_month = value.substring(0, 7);
                    if (min_year_month.compareTo(year_month) > 0 && Utils.isNotBlank(year_month)) {
                        min_year_month = year_month;
                    }
                }
            }
        }

        coin.setMarketCap(market_cap);
        coin.setTotalVolume(total_volume);
        coin.setCurrentPrice(Utils.getBigDecimal(current_price));
        coin.setPriceChangePercentage24H(Utils.getBigDecimal(priceChangePercentage24h));
        coin.setPriceChangePercentage7D(Utils.getBigDecimal(priceChangePercentage7d));
        coin.setPriceChangePercentage14D(Utils.getBigDecimal(priceChangePercentage14d));
        coin.setPriceChangePercentage30D(Utils.getBigDecimal(priceChangePercentage30d));

        if (Objects.equals(BigDecimal.ZERO, market_cap)) {
            coin.setVolumnDivMarketcap(BigDecimal.valueOf(0));

        } else {
            coin.setVolumnDivMarketcap(total_volume.divide(market_cap, 3, java.math.RoundingMode.CEILING));
        }

        GeckoVolumeMonth month = new GeckoVolumeMonth();
        month.setId(new GeckoVolumeMonthKey(String.valueOf(id).toLowerCase(), String.valueOf(symbol).toUpperCase(),
                Utils.convertDateToString("dd", Calendar.getInstance().getTime())));
        month.setTotalVolume(total_volume);
        month.setPrice(Utils.getBigDecimal(current_price));

        {
            Object total_supply = Utils.getLinkedHashMapValue(result, Arrays.asList("market_data", "total_supply"));
            Object max_supply = Utils.getLinkedHashMapValue(result, Arrays.asList("market_data", "max_supply"));
            Object circulating_supply = Utils.getLinkedHashMapValue(result,
                    Arrays.asList("market_data", "circulating_supply"));

            Object categories = Utils.getLinkedHashMapValue(result, Arrays.asList("categories"));
            String str_categories = "";
            if (categories instanceof List) {
                @SuppressWarnings("unchecked")
                List<Object> ct = (List<Object>) categories;
                for (Object obj : ct) {
                    String str_obj = String.valueOf(obj);

                    if (String.valueOf(str_obj).toLowerCase().indexOf("fungible") > 0) {
                        if (!Objects.equals("", str_categories)) {
                            str_categories += "; ";
                        }
                        str_categories += "NFT";
                    } else if (String.valueOf(str_obj).toLowerCase().indexOf("ecosystem") < 0
                            && !Objects.equals("null", str_obj)) {

                        if (!Objects.equals("", str_categories)) {
                            str_categories += "; ";
                        }
                        str_categories += str_obj;
                    }
                }
            }

            Object tickers = Utils.getLinkedHashMapValue(result, Arrays.asList("tickers"));
            String str_trade_url = "";
            List<String> marketList = new ArrayList<String>();

            if (tickers instanceof List) {
                @SuppressWarnings("unchecked")
                List<Object> tk = (List<Object>) tickers;
                for (Object obj : tk) {
                    Object trade_url = Utils.getLinkedHashMapValue(obj, Arrays.asList("trade_url"));
                    if (!Utils.isNotBlank(str_trade_url)
                            && String.valueOf(trade_url).toLowerCase().contains("binance.com/en")) {
                        str_trade_url = String.valueOf(trade_url);
                    }

                    Object market = Utils.getLinkedHashMapValue(obj, Arrays.asList("market", "name"));
                    if (!marketList.contains(String.valueOf(market))) {
                        marketList.add(String.valueOf(market));
                    }
                }
            }

            if (!CollectionUtils.isEmpty(marketList)) {
                String temp = marketList.stream().collect(Collectors.joining(", ")).trim();
                if (temp.length() > 500) {
                    temp = temp.substring(0, 450);
                }
                coin.setMarkets(temp);

                coin.setMarketsCount(marketList.size());
            }

            coin.setCategory(str_categories);

            // DeFi
            // Fan Token
            // L/B
            // Platform
            // Game
            // Web3
            String trend = "";
            if (String.valueOf(str_categories).toLowerCase().indexOf("gaming") > 0) {
                trend = "Game";
            } else if (String.valueOf(str_categories).toLowerCase().indexOf("earn") > 0) {
                trend = "Earn";
            } else if (String.valueOf(str_categories).toLowerCase().indexOf("nft") > 0) {
                trend = "NFT";
            } else if (String.valueOf(str_categories).toLowerCase().indexOf("fan") > 0) {
                trend = "Fan Token";
            } else if (String.valueOf(str_categories).toLowerCase().indexOf("lending") > 0) {
                trend = "L/B";
            } else if (String.valueOf(str_categories).toLowerCase().indexOf("borrowing") > 0) {
                trend = "L/B";
            } else if (String.valueOf(str_categories).toLowerCase().indexOf("defi") > 0) {
                trend = "DeFi";
            } else if (String.valueOf(str_categories).toLowerCase().indexOf("dex") > 0) {
                trend = "DeFi";
            } else if (String.valueOf(str_categories).toLowerCase().indexOf("finance") > 0) {
                trend = "DeFi";
            } else if (String.valueOf(str_categories).toLowerCase().indexOf("network") > 0) {
                trend = "Platform";
            } else if (String.valueOf(str_categories).toLowerCase().indexOf("platform") > 0) {
                trend = "Platform";
            } else if (String.valueOf(str_categories).toLowerCase().indexOf("infrastructure") > 0) {
                trend = "Platform";
            } else if (String.valueOf(str_categories).toLowerCase().indexOf("oracle") > 0) {
                trend = "Platform";
            } else if (String.valueOf(str_categories).toLowerCase().indexOf("storage") > 0) {
                trend = "Platform";
            } else if (String.valueOf(str_categories).toLowerCase().indexOf("protocol") > 0) {
                trend = "Platform";
            } else if (String.valueOf(str_categories).toLowerCase().indexOf("web3") > 0) {
                trend = "Web3";
            } else if (String.valueOf(str_categories).toLowerCase().indexOf("metaverse") > 0) {
                trend = "Metaverse";
            }

            String backer = "";
            String backer_id = Utils
                    .getStringValue(Utils.getLinkedHashMapValue(result, Arrays.asList("image", "thumb")));
            if (Utils.isNotBlank(backer_id)) {
                Pattern pattern = Pattern.compile("(.*images/)(\\d*)(/thumb.*)");
                Matcher m = pattern.matcher(backer_id);
                if (m.find()) {
                    backer = m.replaceAll("$2");
                }
            }

            coin.setTrend(trend + " (" + min_year_month + ")");
            coin.setUsdt(String.valueOf(symbol).toUpperCase() + "_USDT");
            coin.setBusd(String.valueOf(symbol).toUpperCase() + "_BUSD");
            coin.setTotalSupply(Utils.getBigDecimal(total_supply));
            coin.setMaxSupply(Utils.getBigDecimal(max_supply));
            coin.setCirculatingSupply(Utils.getBigDecimal(circulating_supply));
            coin.setBinanceTrade(str_trade_url);
            coin.setCoinGeckoLink("https://www.coingecko.com/en/coins/" + String.valueOf(id));

            //https://www.coingecko.com/en/coins/8506/markets_tab
            coin.setBacker(backer);
        }

        boolean allowUpdate = true;
        if (Utils.isNotBlank(min_year_month)) {
            int min_year = Utils.getIntValue(min_year_month.substring(0, 4));
            if ((!Utils.isNotBlank(coin.getBinanceTrade()))
                    && (min_year < Calendar.getInstance().get(Calendar.YEAR) - 1)) {

                allowUpdate = false;

                delete(gecko_id, "loadData: " + min_year_month);
            } else if (coin.getMarketsCount() < 3) {
                allowUpdate = false;

                delete(gecko_id, "loadData: MarketsCount");
            } else if (Objects.equals(coin.getTotalSupply(), BigDecimal.ZERO)
                    && Objects.equals(coin.getMaxSupply(), BigDecimal.ZERO)
                    && Objects.equals(coin.getCirculatingSupply(), BigDecimal.ZERO)) {
                allowUpdate = false;

                delete(gecko_id, "loadData: Supply=0");
            }
        }

        if (allowUpdate) {
            geckoVolumeMonthRepository.save(month);
            candidateCoinRepository.save(coin);
        } else {
            deleteTokenInMonth(gecko_id);
        }

        return coin;
    }

    @Override
    @Transactional
    public void delete(String gecko_id, String note) {

        try {
            if (!java.util.Objects.equals(null, gecko_id)) {
                String sql = " UPDATE all_market_candidate_coin set visible=false, note=:note WHERE gecko_id=:gecko_id";

                Query query = entityManager.createNativeQuery(sql);
                query.setParameter("gecko_id", gecko_id);
                query.setParameter("note", note);
                query.executeUpdate();
            }

        } catch (Exception e) {
            log.info("delete all_market_candidate_coin error --->");
            e.printStackTrace();
        }
    }

    @Transactional
    public void deleteTokenInMonth(String gecko_id) {

        try {
            if (!java.util.Objects.equals(null, gecko_id)) {
                String sql = " DELETE FROM  all_market_volume_month WHERE gecko_id=:gecko_id";

                Query query = entityManager.createNativeQuery(sql);
                query.setParameter("gecko_id", gecko_id);
                query.executeUpdate();
            }
        } catch (Exception e) {
            log.info("deleteTokenInMonth error --->");
            e.printStackTrace();
        }
    }

    @Override
    public List<CandidateCoin> initCandidateCoin() {
        try {
            log.info("start CoinGeckoServiceImpl.initCandidateCoin   --->");

            List<CandidateCoin> list = new ArrayList<CandidateCoin>();

            // gecko_id symbol name
            String strUrl = "https://api.coingecko.com/api/v3/coins/list";
            RestTemplate restTemplate = new RestTemplate();

            Object result = restTemplate.getForObject(strUrl, Object.class);
            if (result instanceof List) {
                @SuppressWarnings("unchecked")
                List<Object> tk = (List<Object>) result;

                for (Object obj : tk) {
                    String id = Utils.getStringValue(Utils.getLinkedHashMapValue(obj, Arrays.asList("id")));
                    String symbol = Utils.getStringValue(Utils.getLinkedHashMapValue(obj, Arrays.asList("symbol")));
                    String name = Utils.getStringValue(Utils.getLinkedHashMapValue(obj, Arrays.asList("name")));

                    if (Utils.isNotBlank(id) && Utils.isNotBlank(symbol) && Utils.isNotBlank(name)) {
                        CandidateCoin entity = new CandidateCoin(id, symbol, name);
                        candidateCoinRepository.save(entity);
                        list.add(entity);
                    }
                }
            }

            log.info("end CoinGeckoServiceImpl.initCandidateCoin success -->");

            return list;
        } catch (Exception e) {
            e.printStackTrace();
        }

        return new ArrayList<CandidateCoin>();
    }

}
