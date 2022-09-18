package bsc_scan_binance.utils;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Calendar;
import java.util.Collection;
import java.util.LinkedHashMap;
import java.util.List;

import org.springframework.web.client.RestTemplate;

import bsc_scan_binance.entity.BitcoinBalancesOnExchanges;
import bsc_scan_binance.entity.BitcoinBalancesOnExchangesKey;

public class GoinglassUtils {

    @SuppressWarnings({ "rawtypes", "unchecked" })
    public static List<BitcoinBalancesOnExchanges> getBtcExchangeBalance() throws Exception {
        List<BitcoinBalancesOnExchanges> entities = new ArrayList<BitcoinBalancesOnExchanges>();

        String url = "https://fapi.coinglass.com/api/exchange/chain/balance/list";

        RestTemplate restTemplate = new RestTemplate();
        Object result = restTemplate.getForObject(url, Object.class);
        Object dataList = Utils.getLinkedHashMapValue(result, Arrays.asList("data"));

        if (dataList instanceof Collection) {
            List<LinkedHashMap> exchangeList = new ArrayList<>((Collection<LinkedHashMap>) dataList);

            String yyyyMMdd = Utils.convertDateToString("yyyyMMdd", Calendar.getInstance().getTime());

            for (LinkedHashMap exchange : exchangeList) {

                Object exchangeName = Utils.getLinkedHashMapValue(exchange, Arrays.asList("exchangeName"));
                Object symbol = Utils.getLinkedHashMapValue(exchange, Arrays.asList("symbol"));
                Object balance = Utils.getLinkedHashMapValue(exchange, Arrays.asList("balance"));

                Object balanceChange = Utils.getLinkedHashMapValue(exchange, Arrays.asList("balanceChange"));
                Object balanceChangePercent = Utils.getLinkedHashMapValue(exchange,
                        Arrays.asList("balanceChangePercent"));

                Object d7BalanceChange = Utils.getLinkedHashMapValue(exchange, Arrays.asList("d7BalanceChange"));
                Object d7BalanceChangePercent = Utils.getLinkedHashMapValue(exchange,
                        Arrays.asList("d7BalanceChangePercent"));

                Object d30BalanceChange = Utils.getLinkedHashMapValue(exchange, Arrays.asList("d30BalanceChange"));
                Object d30BalanceChangePercent = Utils.getLinkedHashMapValue(exchange,
                        Arrays.asList("d30BalanceChangePercent"));
                Object exLogo = Utils.getLinkedHashMapValue(exchange, Arrays.asList("exLogo"));

                BitcoinBalancesOnExchanges entity = new BitcoinBalancesOnExchanges();
                BitcoinBalancesOnExchangesKey id = new BitcoinBalancesOnExchangesKey();
                id.setYyyymmdd(yyyyMMdd);
                id.setExchangeName(Utils.getStringValue(exchangeName));
                id.setSymbol(Utils.getStringValue(symbol));

                entity.setId(id);
                entity.setBalance(Utils.getBigDecimal(balance));
                entity.setBalanceChange(Utils.getBigDecimal(balanceChange));
                entity.setBalanceChangePercent(Utils.getBigDecimal(balanceChangePercent));
                entity.setD7BalanceChange(Utils.getBigDecimal(d7BalanceChange));
                entity.setD7BalanceChangePercent(Utils.getBigDecimal(d7BalanceChangePercent));
                entity.setD30BalanceChange(Utils.getBigDecimal(d30BalanceChange));
                entity.setD30BalanceChangePercent(Utils.getBigDecimal(d30BalanceChangePercent));
                entity.setExLogo(Utils.getStringValue(exLogo));

                entities.add(entity);
            }
        }

        return entities;
    }
}
