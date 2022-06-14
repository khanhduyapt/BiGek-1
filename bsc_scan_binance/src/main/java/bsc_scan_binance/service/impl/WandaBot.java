package bsc_scan_binance.service.impl;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.util.CollectionUtils;
import org.telegram.telegrambots.bots.TelegramLongPollingBot;
import org.telegram.telegrambots.meta.api.methods.send.SendMessage;
import org.telegram.telegrambots.meta.api.objects.Update;
import org.telegram.telegrambots.meta.exceptions.TelegramApiException;

import bsc_scan_binance.entity.PriorityCoin;
import bsc_scan_binance.repository.PriorityCoinRepository;
import bsc_scan_binance.service.BinanceService;
import bsc_scan_binance.utils.Utils;
import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class WandaBot extends TelegramLongPollingBot {
    @Autowired
    private final BinanceService binance_service;

    @Autowired
    private PriorityCoinRepository priorityCoinRepository;

    @Override
    public void onUpdateReceived(Update update) {
        try {
            System.out.println(update.getMessage().getText());
            String command = update.getMessage().getText();
            SendMessage message = new SendMessage();

            if (command.equals("/web3")) {
                message.setChatId(update.getMessage().getChatId().toString());
                binance_service.getList(false);
                List<PriorityCoin> list = priorityCoinRepository.findAllByCandidateOrderByIndexAsc(true);
                for (PriorityCoin coin : list) {
                    if (Utils.getStringValue(coin.getNote()).toLowerCase().contains("web3")) {
                        message.setText(toString(coin));
                        execute(message);
                    }
                }
            } else if (command.equals("/defi")) {
                message.setChatId(update.getMessage().getChatId().toString());
                binance_service.getList(false);
                List<PriorityCoin> list = priorityCoinRepository.findAllByCandidateOrderByIndexAsc(true);
                for (PriorityCoin coin : list) {
                    if (Utils.getStringValue(coin.getNote()).toLowerCase().contains("defi")) {
                        message.setText(toString(coin));
                        execute(message);
                    }
                }
            } else if (command.equals("/fan")) {
                message.setChatId(update.getMessage().getChatId().toString());
                binance_service.getList(false);
                List<PriorityCoin> list = priorityCoinRepository.findAllByCandidateOrderByIndexAsc(true);
                for (PriorityCoin coin : list) {
                    if (Utils.getStringValue(coin.getName() + coin.getGeckoid()).toLowerCase().contains("fan")) {
                        message.setText(toString(coin));
                        execute(message);
                    }
                }
            } else if (command.equals("/game")) {
                message.setChatId(update.getMessage().getChatId().toString());
                binance_service.getList(false);
                List<PriorityCoin> list = priorityCoinRepository.findAllByCandidateOrderByIndexAsc(true);
                for (PriorityCoin coin : list) {
                    if (Utils.getStringValue(coin.getNote()).toLowerCase().contains("game")) {
                        message.setText(toString(coin));
                        execute(message);
                    }
                }
            } else if (command.equals("/other")) {
                message.setChatId(update.getMessage().getChatId().toString());
                binance_service.getList(false);
                List<PriorityCoin> list = priorityCoinRepository.findAllByCandidateOrderByIndexAsc(true);
                for (PriorityCoin coin : list) {
                    String text = (Utils.getStringValue(coin.getName() + coin.getGeckoid())
                            + Utils.getStringValue(coin.getNote())).toLowerCase();

                    if (!text.contains("game") && !text.contains("web3") && !text.contains("defi")
                            && !text.contains("fan")) {
                        message.setText(toString(coin));
                        execute(message);
                    }
                }
            } else if (command.equals("/all")) {
                message.setChatId(update.getMessage().getChatId().toString());
                binance_service.getList(false);
                List<PriorityCoin> list = priorityCoinRepository.findAllByCandidateOrderByIndexAsc(true);
                for (PriorityCoin coin : list) {
                    message.setText(toString(coin));
                    execute(message);
                }
            } else if (command.contains("/check")) {
                String[] arr = command.split(" ");

                message.setChatId(update.getMessage().getChatId().toString());
                binance_service.getList(false);
                List<PriorityCoin> list = priorityCoinRepository.searchBySymbolLike(arr[1].toUpperCase());
                if (!CollectionUtils.isEmpty(list)) {
                    for (PriorityCoin coin : list) {
                        message.setText(toString(coin));
                        execute(message);
                    }
                }
            }

        } catch (TelegramApiException e) {
            e.printStackTrace();
        }
    }

    private String toString(PriorityCoin coin) {
        return String.format("[%s]  [%s]  [Price: %s$]  [Target:%s$]  %s  %s", coin.getSymbol(), coin.getName(),
                coin.getCurrent_price(),
                coin.getTarget_price(), coin.getTarget_percent(), coin.getNote());
    }

    @Override
    public String getBotUsername() {
        return "wanda_bot";
    }

    @Override
    public String getBotToken() {
        return "5349894943:AAE_0-ZnbikN9m1aRoyCI2nkT2vgLnFBA-8";
    }

}
