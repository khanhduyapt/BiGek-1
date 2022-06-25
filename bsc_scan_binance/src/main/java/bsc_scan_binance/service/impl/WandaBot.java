package bsc_scan_binance.service.impl;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.ArrayList;
import java.util.Calendar;
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
import bsc_scan_binance.entity.BinanceVolumnDayKey;
import bsc_scan_binance.entity.BinanceVolumnWeek;
import bsc_scan_binance.entity.BinanceVolumnWeekKey;
import bsc_scan_binance.entity.Orders;
import bsc_scan_binance.entity.PriorityCoin;
import bsc_scan_binance.entity.TakeProfit;
import bsc_scan_binance.repository.BinanceVolumnDayRepository;
import bsc_scan_binance.repository.BinanceVolumnWeekRepository;
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
    private BinanceVolumnWeekRepository binanceVolumnWeekRepository;

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
            SendMessage message = new SendMessage();
            message.setChatId(update.getMessage().getChatId().toString());

            if ((!Objects.equal("khanhduyapt", update.getMessage().getChat().getUserName()))
                    || (!Utils.chatId.equals(update.getMessage().getChatId().toString()))) {
                message.setText("You are not my master.");
                execute(message);
                return;
            }

            // int minus = Utils.getIntValue(Utils.convertDateToString("mm",
            // Calendar.getInstance().getTime()));
            // if ((minus > 59) || (minus < 3)) {
            // message.setText("59...3 minutes is the time to get data.");
            // execute(message);
            // return;
            // }

            System.out.println(update.getMessage().getText());
            String command = update.getMessage().getText();

            if (command.equals("/all")) {
                binance_service.getList(false);
                List<PriorityCoin> list = searchCandidate();
                if (CollectionUtils.isEmpty(list)) {
                    message.setText("Empty");
                    execute(message);
                    return;
                }

                for (PriorityCoin coin : list) {
                    message.setText(Utils.createMsgPriorityToken(coin, Utils.new_line_from_bot));
                    execute(message);
                }

            } else if (command.contains("/btc")) {
                binance_service.getList(false);
                List<PriorityCoin> list = priorityCoinRepository.searchBySymbol("BTC");
                if (CollectionUtils.isEmpty(list)) {
                    message.setText("Empty");
                    execute(message);
                    return;
                }

                message.setText(
                        Utils.createMsgPriorityToken(list.get(0), Utils.new_line_from_bot) + Utils.new_line_from_bot);
                execute(message);

            } else if (command.contains("/buy")) {
                Calendar calendar = Calendar.getInstance();
                BinanceVolumnWeek btc = binanceVolumnWeekRepository.findById(new BinanceVolumnWeekKey("bitcoin", "BTC",
                        Utils.convertDateToString("yyyyMMdd", calendar.getTime()))).orElse(null);

                BinanceVolumnDay btc_now = binanceVolumnDayRepository.findById(
                        new BinanceVolumnDayKey("bitcoin", "BTC", Utils.convertDateToString("HH", calendar.getTime())))
                        .orElse(null);

                if (Objects.equal(null, btc) || Objects.equal(null, btc_now)) {
                    message.setText("Failed to check the price of BTC.\nPlease buy another time.");
                    execute(message);
                    return;
                }

                message.setText("BTC: " + Utils.createMsgSimple(btc_now.getPriceAtBinance(), btc.getMin_price(),
                        btc_now.getPriceAtBinance()));
                execute(message);

                Boolean allowNext = true;
                if (!Utils.isGoodPrice(btc_now.getPriceAtBinance(), btc.getMin_price(), btc.getMax_price())) {
                    BigDecimal good_price = Utils.getGoodPrice(btc_now.getPriceAtBinance(), btc.getMin_price(),
                            btc.getMax_price());

                    message.setText("The current price is unfavorable.\nWaiting for BTC correct to "
                            + Utils.removeLastZero(good_price.toString()) + "("
                            + Utils.toPercent(btc_now.getPriceAtBinance(), good_price, 1) + "%).");
                    execute(message);

                    if (!command.contains("/buynow")) {
                        allowNext = false;
                    }
                }

                // /buy LIT 600$
                // /buy WING 600$
                String[] arr = command.split(" ");

                List<BinanceVolumnDay> list = binanceVolumnDayRepository.searchBySymbol(arr[1].toUpperCase());
                if (CollectionUtils.isEmpty(list)) {
                    message.setText("(BinanceVolumnDay) Not found:" + arr[1].toUpperCase());
                    execute(message);
                    return;
                }

                BinanceVolumnDay dto = list.get(0);

                BinanceVolumnWeek temp = binanceVolumnWeekRepository
                        .findById(new BinanceVolumnWeekKey(dto.getId().getGeckoid(), dto.getId().getSymbol(),
                                Utils.convertDateToString("yyyyMMdd", calendar.getTime())))
                        .orElse(null);

                message.setText(dto.getId().getSymbol() + ": "
                        + Utils.createMsgSimple(dto.getPriceAtBinance(), temp.getMin_price(), temp.getMax_price()));
                execute(message);

                if (!Utils.isGoodPrice(dto.getPriceAtBinance(), temp.getMin_price(), temp.getMax_price())) {
                    BigDecimal good_price = Utils.getGoodPrice(dto.getPriceAtBinance(), temp.getMin_price(),
                            temp.getMax_price());

                    message.setText("Waiting for " + dto.getId().getSymbol() + " correct to "
                            + Utils.removeLastZero(good_price.toString()) + "("
                            + Utils.toPercent(dto.getPriceAtBinance(), good_price, 1) + "%).");
                    execute(message);

                    if (!command.contains("/buynow")) {
                        allowNext = false;
                    }
                }

                if (arr.length != 3) {
                    message.setText("format: /buy TOKEN USD");
                    execute(message);
                    return;
                }

                if (!allowNext) {
                    return;
                }

                BinanceVolumnWeek dtoweek = binanceVolumnWeekRepository
                        .findById(new BinanceVolumnWeekKey(dto.getId().getGeckoid(), dto.getId().getSymbol(),
                                Utils.convertDateToString("yyyyMMdd", Calendar.getInstance().getTime())))
                        .orElse(null);
                BigDecimal low_price = BigDecimal.ZERO;
                BigDecimal height_price = BigDecimal.ZERO;
                if (!Objects.equal(null, dtoweek)) {
                    low_price = Utils.getBigDecimal(dtoweek.getMin_price());
                    height_price = Utils.getBigDecimal(dtoweek.getMax_price());
                }

                String note = "";
                Orders entity = ordersRepository.findById(dto.getId().getGeckoid()).orElse(null);
                if (Objects.equal(null, entity)) {
                    entity = new Orders();
                    entity.setGeckoid(dto.getId().getGeckoid());
                    entity.setSymbol(dto.getId().getSymbol());
                    entity.setName(dto.getId().getGeckoid());

                    PriorityCoin pc = priorityCoinRepository.findById(dto.getId().getGeckoid()).orElse(null);
                    if (!Objects.equal(null, pc)) {
                        note = pc.getNote();
                    }
                    entity.setNote(note);
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
                entity.setLow_price(low_price);
                entity.setHeight_price(height_price);

                ordersRepository.save(entity);

                message.setText(
                        String.format("Added:[%s] [%s]" + Utils.new_line_from_bot + "[Qty:%s(+%s)]_[P:%s$] [T:%s$].",
                                entity.getSymbol(), entity.getName(), entity.getQty(), qty2, entity.getOrder_price(),
                                entity.getAmount()) + Utils.new_line_from_bot
                                + note.replace("~", Utils.new_line_from_bot));
                execute(message);

            } else if (command.contains("/sel")) {
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
                    message.setText("(BinanceVolumnDay) Not found:" + arr[1].toUpperCase());
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
                    profit.setProfit_id(take_profit_id_seq());
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

                        message.setText(String.format("Remain:[%s] [%s] [Qty:%s]_[P:%s$] [T:%s$].", order.getSymbol(),
                                order.getName(), order.getQty(), order_price1, order.getAmount()));
                        execute(message);
                        // ------------------------
                        profit.setQty(qty2);
                        profit.setAmount(amount2);
                        profit.setSale_price(order_price2);
                        profit.setProfit((order_price2.subtract(order_price1)).multiply(qty2));
                    }

                    takeProfitRepository.save(profit);
                    message.setText(
                            String.format("Sell:[%s] [%s] [Qty:-%s]_[P:%s$]_[T:%s$] [PT:%s$].", profit.getSymbol(),
                                    profit.getName(), profit.getQty(), order_price2, amount2, profit.getProfit()));
                    execute(message);

                }

            } else if (command.contains("/balance")) {
                Query query = entityManager.createNativeQuery(Utils.sql_OrdersProfitResponse, "OrdersProfitResponse");

                @SuppressWarnings("unchecked")
                List<OrdersProfitResponse> list = query.getResultList();
                if (CollectionUtils.isEmpty(list)) {
                    message.setText("Empty");
                    execute(message);
                    return;
                }

                int index = 1;
                String msg = "";
                for (OrdersProfitResponse dto : list) {
                    if (dto.getTp_percent().compareTo(BigDecimal.valueOf(0)) >= 0) {
                        msg += "PROFIT: ";
                    } else {
                        msg += "LOSS  : ";
                    }

                    msg += Utils.createMsgBalance(dto, Utils.new_line_from_bot) + Utils.new_line_from_bot
                            + Utils.new_line_from_bot;

                    if (index == 5) {
                        message.setText(msg);
                        execute(message);

                        msg = "";
                        index = 1;
                    }
                    index += 1;
                }

                if (Utils.isNotBlank(msg)) {
                    message.setText(msg);
                    execute(message);

                    msg = "";
                }

            } else if (command.contains("/mute")) {
                List<PriorityCoin> list = priorityCoinRepository.findAllByMute(true);
                if (!CollectionUtils.isEmpty(list)) {
                    String msg = "Muting: ";
                    for (PriorityCoin dto : list) {
                        msg += dto.getSymbol() + ", ";
                    }
                    message.setText(msg);
                    execute(message);
                } else {
                    message.setText("Muting list is empty");
                    execute(message);
                }

                String[] arr = command.split(" ");
                if (arr.length < 2) {
                    return;
                }
                binance_service.getList(false);
                list = priorityCoinRepository.searchBySymbol(arr[1].toUpperCase());
                if (CollectionUtils.isEmpty(list)) {
                    message.setText("Empty");
                    execute(message);
                    return;
                }

                PriorityCoin coin = list.get(0);
                coin.setMute(!coin.getMute());
                priorityCoinRepository.save(coin);

                message.setText(String.format("Muting: [%s]_[%s] = [%s]", list.get(0).getSymbol(),
                        list.get(0).getGeckoid(), coin.getMute()));
                execute(message);
            } else {
                if (Utils.isNotBlank(command)) {
                    checkCommand(message, command);
                }
            }
        } catch (TelegramApiException e) {
            e.printStackTrace();
        }
    }

    @Override
    public String getBotUsername() {
        return "wanda_bot";
    }

    @Override
    public String getBotToken() {
        return "5349894943:AAE_0-ZnbikN9m1aRoyCI2nkT2vgLnFBA-8";
    }

    private Long take_profit_id_seq() {
        String sql = "SELECT nextval('take_profit_id_seq')";
        return Long.parseLong(entityManager.createNativeQuery(sql).getSingleResult().toString());
    }

    private List<PriorityCoin> searchCandidate() {
        try {
            List<PriorityCoin> results = priorityCoinRepository.findAllByCandidateOrderByVmcDesc(true);
            return results;
        } catch (Exception e) {
            e.printStackTrace();
            return new ArrayList<PriorityCoin>();
        }
    }

    private void checkCommand(SendMessage message, String token) throws TelegramApiException {
        binance_service.getList(false);
        List<PriorityCoin> list = priorityCoinRepository.searchBySymbol(token.toUpperCase());
        if (CollectionUtils.isEmpty(list)) {
            message.setText("Empty");
            execute(message);
            return;
        }

        message.setText(Utils.createMsgPriorityToken(list.get(0), Utils.new_line_from_bot));
        execute(message);

    }
}
