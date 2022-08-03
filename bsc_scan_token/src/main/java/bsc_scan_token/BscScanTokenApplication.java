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
import bsc_scan_token.utils.Utils;
import lombok.extern.slf4j.Slf4j;

@Slf4j
@SpringBootApplication
public class BscScanTokenApplication {

    public static void main(String[] args) {

        ApplicationContext applicationContext = SpringApplication.run(BscScanTokenApplication.class, args);
        TokenService token_service = applicationContext.getBean(TokenService.class);
        CoinGeckoService gecko_service = applicationContext.getBean(CoinGeckoService.class);

        //for (int page = 1; page <= 20; page++) {
        //    token_service.loadBscData(Constant.CONST_BLOCKCHAIN_BSC, "0x7837fd820ba38f95c54d6dac4ca3751b81511357",
        //            "dose-token", page);
        //
        //    token_service.loadBscData(Constant.CONST_BLOCKCHAIN_ETH, "0xb31ef9e52d94d4120eb44fe1ddfde5b4654a6515",
        //            "dose-token", page);
        //
        //    wait(10000);
        //}
        //((ConfigurableApplicationContext)applicationContext ).close();

        try {
            //gecko_service.loadData("arpa-chain");

            List<CandidateCoin> list = gecko_service.getList();

            if (CollectionUtils.isEmpty(list)) {
                list = gecko_service.initCandidateCoin();
            }

            int size = list.size();
            int idx = 0;
            while (idx < size) {
                CandidateCoin coin = list.get(idx);

                try {
                    gecko_service.loadData(coin.getGeckoid());
                } catch (Exception e) {
                    log.error("dkd error LoadData:[" + coin.getGeckoid() + "]" + e.getMessage());
                }

                log.info("idx:" + String.valueOf(idx) + "/" + size + "; id:" + coin.getGeckoid() + "; Symbol:"
                        + coin.getSymbol());

                wait(12000);//200ms=300 * 2 request/minus; 300ms=200 * 2 request/minus

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

    public static void wait(int ms) {
        try {
            java.lang.Thread.sleep(ms);
        } catch (InterruptedException ex) {
            java.lang.Thread.currentThread().interrupt();
        }
    }
}
