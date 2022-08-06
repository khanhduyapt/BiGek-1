package bsc_scan_token;

import java.util.Date;
import java.util.List;
import java.util.Objects;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.ApplicationContext;
import org.springframework.util.CollectionUtils;

import bsc_scan_token.entity.CandidateCoin;
import bsc_scan_token.service.CoinGeckoService;
import bsc_scan_token.service.TokenService;
import bsc_scan_token.utils.Constant;
import bsc_scan_token.utils.Utils;
import lombok.extern.slf4j.Slf4j;

@Slf4j
@SpringBootApplication
public class BscScanTokenApplication {

    public static void main(String[] args) {

        ApplicationContext applicationContext = SpringApplication.run(BscScanTokenApplication.class, args);
        TokenService token_service = applicationContext.getBean(TokenService.class);
        CoinGeckoService gecko_service = applicationContext.getBean(CoinGeckoService.class);

        // ((ConfigurableApplicationContext)applicationContext ).close();

        try {
            // gecko_service.loadData("arpa-chain");
            // for (int page = 1; page <= 3; page++) {
            // token_service.loadBscData("arpa-chain", page);
            // wait(10000);
            // }

            List<CandidateCoin> list = gecko_service.getList();

            if (CollectionUtils.isEmpty(list)) {
                list = gecko_service.initCandidateCoin();
            }

            int size = list.size();
            int idx = 0;
            while (idx < size) {

                CandidateCoin coin = list.get(idx);

                log.info("Token:" + idx + "/" + size + "; id:" + coin.getGeckoid() + "; Symbol:" + coin.getSymbol());

                try {
                    CandidateCoin entity = gecko_service.loadData(coin.getGeckoid());
                    boolean hasData = false;
                    if (entity.isVisible()) {
                        String blockchains = entity.getBlockchains();

                        if (blockchains.contains(Constant.CONST_BLOCKCHAIN_ETH)
                                || blockchains.contains(Constant.CONST_BLOCKCHAIN_ETH)) {
                            hasData = true;
                            for (int page = 1; page <= 3; page++) {
                                token_service.loadBscData(coin.getGeckoid(), page);

                                // log.info("loadData-> page:" + String.valueOf(page));
                            }
                        }
                    }

                    if (hasData) {
                        Utils.wait(Utils.wait_02_sec);
                    } else {
                        Utils.wait(Utils.wait_06_sec);
                    }

                } catch (Exception e) {
                    log.error("dkd error LoadData:[" + coin.getGeckoid() + "]" + e.getMessage());
                    if (e.getMessage().contains("Could not find coin with the given id")) {
                        gecko_service.hide(coin.getGeckoid(), "Could not find coin with the given id");
                    }
                }

                if (idx > 10) {
                    // break;
                }

                if (Objects.equals(idx, size - 1)) {
                    log.info("reload: " + Utils.convertDateToString("yyyy-MM-dd HH:mm:ss", new Date()));
                    idx = 0;
                    list.clear();
                    list = gecko_service.getList();
                    size = list.size();
                } else {
                    idx += 1;
                }
            }

            log.info("End " + Utils.convertDateToString("yyyy-MM-dd HH:mm:ss", new Date()) + " <----");
        } catch (

        Exception e) {
            log.error(e.getMessage());
        }

    }

}
