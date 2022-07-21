package bsc_scan_geckko;

import java.util.Date;
import java.util.List;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.ApplicationContext;
import org.springframework.util.CollectionUtils;

import bsc_scan_geckko.entity.CandidateCoin;
import bsc_scan_geckko.service.CoinGeckoService;
import bsc_scan_geckko.utils.Utils;
import lombok.extern.slf4j.Slf4j;

@Slf4j
@SpringBootApplication
public class BscScanGeckkoApplication {

    public static void main(String[] args) {
        try {
            log.info("Start " + Utils.convertDateToString("yyyy-MM-dd HH:mm:ss", new Date()) + " ---->");

            ApplicationContext applicationContext = SpringApplication.run(BscScanGeckkoApplication.class, args);
            bsc_scan_geckko.service.CoinGeckoService gecko_service = applicationContext.getBean(CoinGeckoService.class);

            List<bsc_scan_geckko.entity.CandidateCoin> list = gecko_service.getList();
            if (CollectionUtils.isEmpty(list)) {
                gecko_service.initCandidateCoin();
            }

            int size = list.size();
            int idx = 0;
            while (idx < size) {
                CandidateCoin coin = list.get(idx);

                try {
                    gecko_service.loadData(coin.getGeckoid());
                } catch (Exception e) {
                    log.error("dkd error LoadData:[" + coin.getGeckoid() + "]" + e.getMessage());
                    //wait(600000);
                    //gecko_service.delete(coin.getGeckoid());
                }

                wait(2000);// 60000:2000ms=30 request/minus 1500=40


                log.info("Gecko:" + String.valueOf(idx) + "/" + size + "; id:" + coin.getGeckoid() + "; Symbol:"
                        + coin.getSymbol());

                if (java.util.Objects.equals(idx, size - 1)) {
                    log.info("reload: " + Utils.convertDateToString("yyyy-MM-dd HH:mm:ss", new Date()));
                    idx = 0;
                    list.clear();
                    list = gecko_service.getList();
                    size = list.size();

                    wait(900000); // 900000 = 15 minutes;
                } else {
                    idx += 1;
                }
            }

            log.info("End " + Utils.convertDateToString("yyyy-MM-dd HH:mm:ss", new Date()) + " <----");
        } catch (Exception e) {
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
