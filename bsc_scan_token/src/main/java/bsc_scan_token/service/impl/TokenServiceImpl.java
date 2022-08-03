package bsc_scan_token.service.impl;

import java.util.ArrayList;
import java.util.Calendar;
import java.util.List;
import java.util.Objects;

import javax.persistence.EntityManager;
import javax.persistence.PersistenceContext;
import javax.transaction.Transactional;

import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;
import org.jsoup.select.Elements;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.util.CollectionUtils;

import bsc_scan_token.entity.AddressQuantity;
import bsc_scan_token.entity.AddressQuantityKey;
import bsc_scan_token.entity.Wallet;
import bsc_scan_token.repository.AddressQuantityRepository;
import bsc_scan_token.repository.WalletRepository;
import bsc_scan_token.service.TokenService;
import bsc_scan_token.utils.Constant;
import bsc_scan_token.utils.Utils;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Service
@Slf4j
@RequiredArgsConstructor
public class TokenServiceImpl implements TokenService {

    @PersistenceContext
    private EntityManager entityManager;

    @Autowired
    private WalletRepository walletRepository;

    @Autowired
    private AddressQuantityRepository addressQuantityRepository;

    @Override
    @Transactional
    public boolean loadBscData(String gecko_id, Integer page) {
        boolean val = false;
        List<Wallet> wallets = walletRepository.findAllByIdGeckoid(gecko_id);
        for (Wallet entity : wallets) {
            String blokchain = entity.getId().getBlockchain().toLowerCase();
            if (blokchain.contains("eth") || blokchain.contains("binance")) {
                val = val || loadBscData(entity.getId().getBlockchain(), entity.getId().getAddress(), gecko_id, page);

            }
        }

        return val;
    }

    @Transactional
    private boolean loadBscData(String blockchain, String contract_address, String gecko_id, Integer page) {
        try {
            // https://openplanning.net/10399/jsoup-java-html-parser
            // 0x7837fd820ba38f95c54d6dac4ca3751b81511357

            String url = "";
            if (Objects.equals(blockchain, Constant.CONST_BLOCKCHAIN_BSC)) {
                url = "https://bscscan.com/token/generic-tokenholders2?a=";

            } else if (Objects.equals(blockchain, Constant.CONST_BLOCKCHAIN_ETH)) {
                url = "https://etherscan.io/token/generic-tokenholders2?a=";
            } else {
                return false;
            }

            Utils.wait(Utils.wait_06_sec);

            Document doc = Jsoup.connect(url + contract_address + "&p=" + page.toString()).get();

            Elements tables = doc.getElementsByClass("table table-md-text-normal table-hover");
            if (tables.size() > 0) {
                Elements rows = tables.get(0).select("tr");

                Calendar calendar = Calendar.getInstance();
                String yyyyMMdd = Utils.convertDateToString("yyyyMMdd", calendar.getTime());

                List<AddressQuantity> list_day = new ArrayList<AddressQuantity>();

                for (int i = 1; i < rows.size(); i++) {
                    try {
                        Elements values = rows.get(i).select("td");

                        String alias = Utils.getValue(values.get(1).text());
                        String address = alias;
                        Elements links = values.get(1).getElementsByTag("a");
                        if (!CollectionUtils.isEmpty(links)) {
                            String href = links.get(0).attr("href");
                            address = href.substring(href.indexOf("a=") + 2, href.length());
                        }

                        String quantity = Utils.replaceComma(values.get(2).text());

                        AddressQuantity day = new AddressQuantity();
                        day.setId(new AddressQuantityKey(blockchain, gecko_id, address, yyyyMMdd));
                        day.setQuantity(Utils.convertBigDecimal(quantity));
                        if (!Objects.equals(alias, address)) {
                            day.setWalletName(alias);
                        }

                        list_day.add(day);
                    } catch (Exception e) {
                        continue;
                    }
                }

                addressQuantityRepository.saveAll(list_day);
                log.info("loadData->" + blockchain + ", " + gecko_id + ", page:" + page.toString());
            }
        } catch (Exception e) {
            log.info("TokenServiceImpl.loadData error --->");
            e.printStackTrace();
            log.error(e.getMessage());
            return false;
        }
        return true;
    }

}
