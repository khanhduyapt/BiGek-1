package bsc_scan_binance.service.impl;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.List;

import javax.persistence.EntityManager;
import javax.persistence.PersistenceContext;
import javax.persistence.Query;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.util.CollectionUtils;
import org.telegram.telegrambots.bots.TelegramLongPollingBot;
import org.telegram.telegrambots.meta.api.methods.send.SendMessage;
import org.telegram.telegrambots.meta.api.objects.Update;
import org.telegram.telegrambots.meta.exceptions.TelegramApiException;

import com.google.common.base.Objects;

import bsc_scan_binance.entity.BinanceVolumnDay;
import bsc_scan_binance.entity.Orders;
import bsc_scan_binance.entity.PriorityCoin;
import bsc_scan_binance.entity.TakeProfit;
import bsc_scan_binance.repository.BinanceVolumnDayRepository;
import bsc_scan_binance.repository.OrdersRepository;
import bsc_scan_binance.repository.PriorityCoinRepository;
import bsc_scan_binance.repository.TakeProfitRepository;
import bsc_scan_binance.response.OrdersProfitResponse;
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

    @Autowired
    private BinanceVolumnDayRepository binanceVolumnDayRepository;

    @Autowired
    private OrdersRepository ordersRepository;

    @Autowired
    private TakeProfitRepository takeProfitRepository;

    @PersistenceContext
    private final EntityManager entityManager;

    @Override
    public void onUpdateReceived(Update update) {
        try {
            if (!Objects.equal("khanhduyapt", update.getMessage().getChat().getUserName())) {
                return;
            }

            System.out.println(update.getMessage().getText());
            String command = update.getMessage().getText();
            SendMessage message = new SendMessage();
            message.setChatId(update.getMessage().getChatId().toString());

            if (command.equals("/web3")) {
                binance_service.getList(false);
                List<PriorityCoin> list = priorityCoinRepository.searchCandidate();
                for (PriorityCoin coin : list) {
                    if (Utils.getStringValue(coin.getNote()).toLowerCase().contains("web3")) {
                        message.setText(toString(coin));
                        execute(message);
                    }
                }
            } else if (command.equals("/defi")) {
                binance_service.getList(false);
                List<PriorityCoin> list = priorityCoinRepository.searchCandidate();
                for (PriorityCoin coin : list) {
                    if (Utils.getStringValue(coin.getNote()).toLowerCase().contains("defi")) {
                        message.setText(toString(coin));
                        execute(message);
                    }
                }
            } else if (command.equals("/fan")) {
                binance_service.getList(false);
                List<PriorityCoin> list = priorityCoinRepository.searchCandidate();
                for (PriorityCoin coin : list) {
                    if (Utils.getStringValue(coin.getName() + coin.getGeckoid()).toLowerCase().contains("fan")) {
                        message.setText(toString(coin));
                        execute(message);
                    }
                }
            } else if (command.equals("/game")) {
                binance_service.getList(false);
                List<PriorityCoin> list = priorityCoinRepository.searchCandidate();
                for (PriorityCoin coin : list) {
                    if (Utils.getStringValue(coin.getNote()).toLowerCase().contains("game")) {
                        message.setText(toString(coin));
                        execute(message);
                    }
                }
            } else if (command.equals("/other")) {
                binance_service.getList(false);
                List<PriorityCoin> list = priorityCoinRepository.searchCandidate();
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
                binance_service.getList(false);
                List<PriorityCoin> list = priorityCoinRepository.searchCandidate();
                for (PriorityCoin coin : list) {
                    if (coin.getEma().compareTo(BigDecimal.ZERO) > 0) {
                        message.setText(toString(coin));
                        execute(message);
                    }
                }
            } else if (command.contains("/check")) {
                String[] arr = command.split(" ");

                binance_service.getList(false);
                List<PriorityCoin> list = priorityCoinRepository.searchBySymbolLike(arr[1].toUpperCase());
                if (!CollectionUtils.isEmpty(list)) {
                    for (PriorityCoin coin : list) {
                        message.setText(toString(coin));
                        execute(message);
                    }
                }
            } else if (command.contains("/buy")) {
                // /buy LIT 600$
                // /buy WING 600$
                String[] arr = command.split(" ");

                if (arr.length != 3) {
                    message.setText("format: /buy TOKEN USD");
                    execute(message);
                    return;
                }

                List<BinanceVolumnDay> list = binanceVolumnDayRepository.searchBySymbol(arr[1].toUpperCase());
                if (CollectionUtils.isEmpty(list)) {
                    message.setText("Not found:" + arr[1].toUpperCase());
                    execute(message);
                    return;
                }

                for (BinanceVolumnDay dto : list) {
                    Orders entity = ordersRepository.findById(dto.getId().getGeckoid()).orElse(null);
                    if (Objects.equal(null, entity)) {
                        entity = new Orders();
                        entity.setGeckoid(dto.getId().getGeckoid());
                        entity.setSymbol(dto.getId().getSymbol());
                        entity.setName(dto.getId().getGeckoid());
                    }

                    BigDecimal amount1 = Utils.getBigDecimal(entity.getAmount());
                    BigDecimal qty1 = Utils.getBigDecimal(entity.getQty());

                    BigDecimal order_price2 = Utils.getBigDecimal(dto.getPriceAtBinance());
                    BigDecimal amount2 = Utils.getBigDecimal(arr[2].replace("$", ""));
                    BigDecimal qty2 = amount2.divide(order_price2, 5, RoundingMode.CEILING);

                    BigDecimal amount = amount1.add(amount2);
                    BigDecimal qty = qty1.add(qty2);
                    BigDecimal avg_price = amount.divide(qty, 5, RoundingMode.CEILING);

                    entity.setOrder_price(avg_price);
                    entity.setAmount(amount);
                    entity.setQty(qty);

                    ordersRepository.save(entity);

                    message.setText(String.format("Added:[%s] [%s] [Qty:%s(+%s)]_[P:%s$]_[Amount:%s$].",
                            entity.getSymbol(), entity.getName(), entity.getQty(), qty2, entity.getOrder_price(),
                            entity.getAmount()));
                    execute(message);
                }
            } else if (command.contains("/sell")) {
                // /sell UNFI
                // /sell UNFI 100$
                String[] arr = command.split(" ");

                if (arr.length < 2) {
                    message.setText("format: /sell TOKEN USD or /sell TOKEN");
                    execute(message);
                    return;
                }

                List<BinanceVolumnDay> list = binanceVolumnDayRepository.searchBySymbol(arr[1].toUpperCase());
                if (CollectionUtils.isEmpty(list)) {
                    message.setText("Not found:" + arr[1].toUpperCase());
                    execute(message);
                    return;
                }

                for (BinanceVolumnDay dto : list) {
                    Orders order = ordersRepository.findById(dto.getId().getGeckoid()).orElse(null);
                    if (Objects.equal(null, order)) {
                        message.setText("[Orders] Not found:" + arr[1].toUpperCase());
                        execute(message);
                        return;
                    }

                    BigDecimal order_price1 = Utils.getBigDecimal(order.getOrder_price());
                    BigDecimal amount1 = Utils.getBigDecimal(order.getAmount());
                    BigDecimal qty1 = Utils.getBigDecimal(order.getQty());

                    BigDecimal order_price2 = Utils.getBigDecimal(dto.getPriceAtBinance());
                    BigDecimal qty2 = qty1;
                    BigDecimal amount2 = order_price2.multiply(qty2);

                    boolean is_sell_all = true;
                    if (arr.length == 3) {
                        is_sell_all = false;
                        BigDecimal amount = Utils.getBigDecimal(arr[2].replace("$", ""));
                        BigDecimal curr_amount = qty1.multiply(order_price2).multiply(BigDecimal.valueOf(0.95));

                        if (amount.compareTo(curr_amount) > 0) {
                            message.setText(
                                    String.format("Not enough to sell: [%s]_[%s]", arr[1].toUpperCase(), arr[2]));
                            execute(message);
                            return;
                        }
                    }

                    TakeProfit profit = new TakeProfit();
                    profit.setGeckoid(dto.getId().getGeckoid());
                    profit.setSymbol(dto.getId().getSymbol());
                    profit.setName(dto.getId().getGeckoid());
                    profit.setOrder_price(order_price1);

                    if (is_sell_all) {
                        ordersRepository.delete(order);
                        profit.setQty(qty1);
                        profit.setAmount(amount1);
                        profit.setSale_price(order_price2);
                        profit.setProfit(amount2.subtract(amount1));

                    } else {
                        amount2 = Utils.getBigDecimal(arr[2].replace("$", ""));
                        qty2 = amount2.divide(order_price2, 5, RoundingMode.CEILING);

                        BigDecimal qty_remain = qty1.subtract(qty2);
                        BigDecimal amount_remain = qty_remain.multiply(order_price1);

                        order.setQty(qty_remain);
                        order.setAmount(amount_remain);
                        ordersRepository.save(order);

                        message.setText(String.format("Remain:[%s] [%s] [Qty:%s]_[P:%s$]_[Amount:%s$].",
                                order.getSymbol(), order.getName(), order.getQty(), order_price1, order.getAmount()));
                        execute(message);
                        // ------------------------
                        profit.setQty(qty2);
                        profit.setAmount(amount2);
                        profit.setSale_price(order_price2);
                        profit.setProfit((order_price2.subtract(order_price1)).multiply(qty2));
                    }

                    takeProfitRepository.save(profit);
                    message.setText(
                            String.format("Sell:[%s] [%s] [Qty:-%s]_[P:%s$]_[Amount:%s$]_[PT:%s$].", profit.getSymbol(),
                                    profit.getName(), profit.getQty(), order_price2, amount2, profit.getProfit()));
                    execute(message);

                }

            } else if (command.contains("/balance")) {
                String sql = ""
                        + " SELECT * from (                                                                             \n"
                        + "    SELECT                                                                                   \n"
                        + "      od.gecko_id,                                                                           \n"
                        + "      od.symbol,                                                                             \n"
                        + "      od.name,                                                                               \n"
                        + "      od.order_price,                                                                        \n"
                        + "      od.qty,                                                                                \n"
                        + "      od.amount,                                                                             \n"
                        + "      cur.price_at_binance,                                                                  \n"
                        + "      ROUND(((cur.price_at_binance - od.order_price)/od.order_price)*100, 1) as tp_percent,  \n"
                        + "      ROUND((cur.price_at_binance - od.order_price)*od.qty, 1)               as tp_amount,   \n"
                        + "      (select concat(cast(target_price as varchar), ' ', target_percent) from priority_coin pc where pc.gecko_id = od.gecko_id) as target "
                        + "    FROM                                                                                     \n"
                        + "        orders od,                                                                           \n"
                        + "        binance_volumn_day cur                                                               \n"
                        + "    WHERE                                                                                    \n"
                        + "            cur.hh      = TO_CHAR(NOW(), 'HH24')                                             \n"
                        + "        and od.gecko_id = cur.gecko_id                                                       \n"
                        + "        and od.symbol   = cur.symbol                                                         \n"
                        + " ) odr ORDER BY odr.tp_percent desc ";

                Query query = entityManager.createNativeQuery(sql, "OrdersProfitResponse");

                @SuppressWarnings("unchecked")
                List<OrdersProfitResponse> results = query.getResultList();

                if (!CollectionUtils.isEmpty(results)) {
                    for (OrdersProfitResponse dto : results) {
                        if (dto.getTp_percent().compareTo(BigDecimal.valueOf(0)) >= 0) {
                            Utils.sendToTelegram(String.format(
                                    "PROFIT: [%s]_[%s] [Qty:%s]x[%s$] [%s$], Now:[P:%s][TP:%s$] %s percents, Target:%s.",
                                    dto.getSymbol(), dto.getName(), Utils.removeLastZero(dto.getQty().toString()),
                                    Utils.removeLastZero(dto.getOrder_price().toString()),
                                    Utils.removeLastZero(dto.getAmount().toString()),

                                    Utils.removeLastZero(dto.getPrice_at_binance().toString()),
                                    Utils.removeLastZero(dto.getTp_amount().toString()), dto.getTp_percent(),
                                    dto.getTarget()));
                        } else {
                            Utils.sendToTelegram(String.format(
                                    "LOST: [%s]_[%s] [Qty:%s]x[%s$] [%s$], Now:[P:%s][TP:%s$] %s percents, Target:%s.",
                                    dto.getSymbol(), dto.getName(), Utils.removeLastZero(dto.getQty().toString()),
                                    Utils.removeLastZero(dto.getOrder_price().toString()),
                                    Utils.removeLastZero(dto.getAmount().toString()),

                                    Utils.removeLastZero(dto.getPrice_at_binance().toString()),
                                    Utils.removeLastZero(dto.getTp_amount().toString()), dto.getTp_percent(),
                                    dto.getTarget()));
                        }
                    }
                }
            }

        } catch (TelegramApiException e) {
            e.printStackTrace();
        }
    }

    private String toString(PriorityCoin coin) {
        return String.format("[%s]  [%s]  [Price: %s$]  [Target:%s$=%s]  %s", coin.getSymbol(), coin.getName(),
                coin.getCurrent_price(), coin.getTarget_price(), coin.getTarget_percent(), coin.getNote());
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
