package bsc_scan_token.service.impl;

import java.math.BigDecimal;
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

import bsc_scan_token.entity.TokenAddressDay;
import bsc_scan_token.entity.TokenAddressDayKey;
import bsc_scan_token.repository.TokenAddressDayRepository;
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
    private TokenAddressDayRepository tokenAddressDayRepository;

    // @Override
//	@Transactional
//	public Response priority(CoinGeckoTokenRequest request) {
//		try {
//			log.info("Start priority  --->");
//
//			if (!Objects.equals("", Utils.getValue(request.getId()))) {
//				String sql = " Update candidate_coin set priority=:priority WHERE gecko_id=:gecko_id ;";
//				Query query = entityManager.createNativeQuery(sql);
//				query.setParameter("priority", request.getPriority());
//				query.setParameter("gecko_id", request.getId());
//				query.executeUpdate();
//
//				log.info(request.getId() + "=" + request.getNote());
//			}
//			log.info("End priority success <---");
//			return new Response("200", "Ok");
//		} catch (Exception e) {
//			log.info("Add note error --->");
//			log.error(e.getMessage());
//			return new Response("500", "Error", e.toString());
//		}
//	}

    @Override
    @Transactional
    public void loadBscData(String blockchain, String contract_address, String gecko_id, Integer page) {
        try {
            // https://openplanning.net/10399/jsoup-java-html-parser
            // 0x7837fd820ba38f95c54d6dac4ca3751b81511357

            String url = "";
            if (Objects.equals(blockchain, Constant.CONST_BLOCKCHAIN_BSC)) {
                url = "https://bscscan.com/token/generic-tokenholders2?a=";

            } else if (Objects.equals(blockchain, Constant.CONST_BLOCKCHAIN_ETH)) {
                url = "https://etherscan.io/token/generic-tokenholders2?a=";
            } else {
                return;
            }

            Document doc = Jsoup.connect(url + contract_address + "&p=" + page.toString()).get();

            Elements tables = doc.getElementsByClass("table table-md-text-normal table-hover");
            if (tables.size() > 0) {
                Elements rows = tables.get(0).select("tr");

                Calendar calendar = Calendar.getInstance();
                String dd = bsc_scan_token.utils.Utils.convertDateToString("dd", calendar.getTime());

                List<TokenAddressDay> list_day = new ArrayList<TokenAddressDay>();

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

                        TokenAddressDay day = new TokenAddressDay();
                        day.setId(new TokenAddressDayKey(blockchain, gecko_id, address, dd));
                        day.setQuantity(Utils.convertBigDecimal(quantity));
                        if (!Objects.equals(alias, address)) {
                            day.setAlias(alias);
                        }

                        list_day.add(day);
                    } catch (Exception e) {
                        continue;
                    }
                }

                tokenAddressDayRepository.saveAll(list_day);
                log.info("loadData->" + blockchain + ", " + gecko_id + ", page:" + page.toString());
            }
        } catch (Exception e) {
            log.info("TokenServiceImpl.loadData error --->");
            e.printStackTrace();
            log.error(e.getMessage());
        }
    }

}
