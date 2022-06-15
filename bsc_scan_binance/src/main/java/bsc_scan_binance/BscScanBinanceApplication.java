package bsc_scan_binance;

import java.util.Date;
import java.util.List;
import java.util.Objects;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.ApplicationContext;
import org.springframework.util.CollectionUtils;
import org.telegram.telegrambots.meta.TelegramBotsApi;
import org.telegram.telegrambots.meta.exceptions.TelegramApiException;
import org.telegram.telegrambots.updatesreceivers.DefaultBotSession;

import bsc_scan_binance.entity.CandidateCoin;
import bsc_scan_binance.service.BinanceService;
import bsc_scan_binance.service.CoinGeckoService;
import bsc_scan_binance.service.impl.WandaBot;
import bsc_scan_binance.utils.Utils;
import lombok.extern.slf4j.Slf4j;

@Slf4j
@SpringBootApplication
public class BscScanBinanceApplication {

    public static void main(String[] args) {
        try {
            log.info("Start " + Utils.convertDateToString("yyyy-MM-dd HH:mm:ss", new Date()) + " ---->");

            ApplicationContext applicationContext = SpringApplication.run(BscScanBinanceApplication.class, args);
            CoinGeckoService gecko_service = applicationContext.getBean(CoinGeckoService.class);
            BinanceService binance_service = applicationContext.getBean(BinanceService.class);
            WandaBot wandaBot = applicationContext.getBean(WandaBot.class);

            try {
                TelegramBotsApi telegramBotsApi = new TelegramBotsApi(DefaultBotSession.class);
                telegramBotsApi.registerBot(wandaBot);
            } catch (TelegramApiException e) {
                e.printStackTrace();
            }

            List<CandidateCoin> list = gecko_service.getList();
            if (CollectionUtils.isEmpty(list)) {
                gecko_service.initCandidateCoin();
            }

            int size = list.size();
            int idx = 0;
            while (idx < size) {
                CandidateCoin coin = list.get(idx);

                try {
                    binance_service.loadData(coin.getGeckoid(), coin.getSymbol());
                } catch (Exception e) {
                    log.error("dkd error LoadData:" + e.getMessage());
                    wait(600000);
                }

                wait(300);// 200ms=300 * 2 request/minus; 300ms=200 * 2 request/minus

                log.info("Binance " + String.valueOf(idx) + "/" + size + "; id:" + coin.getGeckoid() + "; Symbol:"
                        + coin.getSymbol());

                if (Objects.equals(idx, size - 1)) {
                    binance_service.getList(false); //~3p 1 lan

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
