package codervi.bsc_scan;

import java.util.Date;
import java.util.List;
import java.util.Objects;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.ApplicationContext;
import org.springframework.util.CollectionUtils;

import codervi.bsc_scan.entity.CandidateCoin;
import codervi.bsc_scan.service.BinanceService;
import codervi.bsc_scan.service.CoinGeckoService;
import codervi.bsc_scan.utils.Utils;
import lombok.extern.slf4j.Slf4j;

@Slf4j
@SpringBootApplication
public class BscScanApplication {

    public static void main(String[] args) {
        try {
            log.info("Start " + Utils.convertDateToString("yyyy-MM-dd HH:mm:ss", new Date()) + " ---->");

            ApplicationContext applicationContext = SpringApplication.run(BscScanApplication.class, args);
            CoinGeckoService gecko_service = applicationContext.getBean(CoinGeckoService.class);
            BinanceService binance_service = applicationContext.getBean(BinanceService.class);

            List<CandidateCoin> list = gecko_service.getList();
            if (CollectionUtils.isEmpty(list)) {
                gecko_service.initCandidateCoin();
            }

            int size = list.size();
            int idx = 0;
            while (idx < size) {
                CandidateCoin coin = list.get(idx);

                if (Objects.equals(null, coin.getCoinGeckoLink())) {
                    gecko_service.loadData(coin.getGeckoid(), true);
                } else {
                    gecko_service.loadData(coin.getGeckoid(), false);
                }

                binance_service.loadData(coin.getGeckoid(), coin.getSymbol());

                wait(2000);

                log.info("idx:" + String.valueOf(idx) + "/" + size + "; id:" + coin.getGeckoid() + "; Symbol:"
                        + coin.getSymbol());

                if (Objects.equals(idx, size - 1)) {
                    idx = 0;
                    list = gecko_service.getList();
                    size = list.size();
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
