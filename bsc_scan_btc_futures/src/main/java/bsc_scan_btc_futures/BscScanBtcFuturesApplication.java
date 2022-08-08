package bsc_scan_btc_futures;

import java.util.Calendar;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.ApplicationContext;

import bsc_scan_btc_futures.service.BinanceService;
import bsc_scan_btc_futures.utils.Utils;
import lombok.extern.slf4j.Slf4j;

@Slf4j
@SpringBootApplication
public class BscScanBtcFuturesApplication {

    public static void main(String[] args) {
        try {
            log.info("Start " + Utils.convertDateToString("yyyy-MM-dd HH:mm:ss", Calendar.getInstance().getTime()));

            // --------------------Init--------------------
            ApplicationContext applicationContext = SpringApplication.run(BscScanBtcFuturesApplication.class, args);
            BinanceService binance_service = applicationContext.getBean(BinanceService.class);

            while (true) {

                try {
                    binance_service.getList();
                    wait(10000); // 1m=60000ms
                } catch (Exception e) {
                    log.error("dkd error LoadData:" + e.getMessage());
                }
            }
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
