package bsc_scan_token;

import java.io.IOException;
import java.util.Date;
import java.util.List;
import java.util.Objects;

import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;
import org.jsoup.select.Elements;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.ApplicationContext;
import org.springframework.context.ConfigurableApplicationContext;
import org.springframework.util.CollectionUtils;

import bsc_scan_token.service.TokenService;
import bsc_scan_token.utils.Constant;
import bsc_scan_token.utils.Utils;
import lombok.extern.slf4j.Slf4j;

@Slf4j
@SpringBootApplication
public class BscScanTokenApplication {

    public static void main(String[] args) {

        ApplicationContext applicationContext = SpringApplication.run(BscScanTokenApplication.class, args);
        TokenService gecko_service = applicationContext.getBean(TokenService.class);

        for (int page = 1; page <= 20; page++) {
            gecko_service.loadBscData(Constant.CONST_BLOCKCHAIN_BSC, "0x7837fd820ba38f95c54d6dac4ca3751b81511357",
                    "dose-token", page);

            gecko_service.loadBscData(Constant.CONST_BLOCKCHAIN_ETH, "0xb31ef9e52d94d4120eb44fe1ddfde5b4654a6515",
                    "dose-token", page);

            wait(10000);
        }
        ((ConfigurableApplicationContext)applicationContext ).close();
//        List<CandidateCoin> list = gecko_service.getList();
//        if (CollectionUtils.isEmpty(list)) {
//            gecko_service.initCandidateCoin();
//        }
//
//        int size = list.size();
//        int idx = 0;
//        while (idx < size) {
//            CandidateCoin coin = list.get(idx);
//
//            try {
//                //gecko_service.loadData(coin.getGeckoid());
//                binance_service.loadData(coin.getGeckoid(), coin.getSymbol());
//            } catch (Exception e) {
//                log.error("dkd error LoadData:" + e.getMessage());
//                wait(600000);
//            }
//
//            wait(300);//200ms=300 * 2 request/minus; 300ms=200 * 2 request/minus
//
//            log.info("idx:" + String.valueOf(idx) + "/" + size + "; id:" + coin.getGeckoid() + "; Symbol:"
//                    + coin.getSymbol());
//
//            if (Objects.equals(idx, size - 1)) {
//                log.info("reload: " + Utils.convertDateToString("yyyy-MM-dd HH:mm:ss", new Date()));
//                idx = 0;
//                list.clear();
//                list = gecko_service.getList();
//                size = list.size();
//            } else {
//                idx += 1;
//            }
//        }
//
//        log.info("End " + Utils.convertDateToString("yyyy-MM-dd HH:mm:ss", new Date()) + " <----");
//    }catch(
//
//    Exception e)
//    {
//        log.error(e.getMessage());
//    }

    }

    public static void wait(int ms) {
        try {
            java.lang.Thread.sleep(ms);
        } catch (InterruptedException ex) {
            java.lang.Thread.currentThread().interrupt();
        }
    }
}
