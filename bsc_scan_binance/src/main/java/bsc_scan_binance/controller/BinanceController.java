package bsc_scan_binance.controller;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.util.CollectionUtils;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;

import bsc_scan_binance.BscScanBinanceApplication;
import bsc_scan_binance.request.CoinGeckoTokenRequest;
import bsc_scan_binance.response.DepthResponse;
import bsc_scan_binance.response.EntryCssResponse;
import bsc_scan_binance.service.BinanceService;
import bsc_scan_binance.service.CoinGeckoService;
import bsc_scan_binance.utils.Response;
import bsc_scan_binance.utils.Utils;
import lombok.RequiredArgsConstructor;

@RequiredArgsConstructor
@Controller
public class BinanceController {
    @Autowired
    private final BinanceService service;

    @Autowired
    private final CoinGeckoService geckoService;

    @GetMapping
    public String list(Model model) {
        BscScanBinanceApplication.callFormBinance = "";

        model.addAttribute("data_list", service.getList(false));
        return "binance";
    }

    @GetMapping("/{symbol}")
    public String getListDepthData(@PathVariable("symbol") String symbol, Model model) {
        List<List<DepthResponse>> list = new ArrayList<List<DepthResponse>>();
        String SYMBOL = symbol.toUpperCase();
        list = service.getListDepthData(SYMBOL);
        List<DepthResponse> list_bids = new ArrayList<DepthResponse>();
        List<DepthResponse> list_asks = new ArrayList<DepthResponse>();

        if (!CollectionUtils.isEmpty(list)) {
            list_bids = list.get(0);
            list_asks = list.get(1);
        }
        model.addAttribute("data_list_1", list_bids);
        model.addAttribute("data_list_2", list_asks);
        model.addAttribute("symbol", SYMBOL);

        if (!SYMBOL.equals("BTC")) {
            String long_short = service.getLongShortIn48h(SYMBOL);

            List<String> headers = new ArrayList<String>(Arrays.asList(long_short.split(Utils.new_line_from_service)));
            model.addAttribute("token_48h", headers);

            return "detail_others";
        }

        model.addAttribute("sp500",
                service.loadPremarketSp500().replaceAll(Utils.new_line_from_bot, ", ").replaceAll("S&P 500", ""));

        String exchange = service.getBtcBalancesOnExchanges();
        exchange = exchange.replaceAll("BTC 24h: ", "").replaceAll(" 07d: ", "");
        List<String> exchanges = new ArrayList<String>(Arrays.asList(exchange.split(Utils.new_line_from_service)));
        if (CollectionUtils.isEmpty(exchanges) || exchanges.size() < 2) {
            model.addAttribute("exchanges_24h", "");
            model.addAttribute("exchanges_7d", "");
        } else {
            model.addAttribute("exchanges_24h", exchanges.get(0));
            model.addAttribute("exchanges_7d", exchanges.get(1));
        }

        List<String> long_short = service.monitorBtcPrice();
        if (CollectionUtils.isEmpty(long_short)) {
            model.addAttribute("long_short_header", "Btc sideway.");
            model.addAttribute("long_short_list_perfect", new ArrayList<String>());
            model.addAttribute("long_short_list_curr_price", new ArrayList<String>());

            model.addAttribute("long_list_perfect2", new ArrayList<String>());
            model.addAttribute("short_list_perfect2", new ArrayList<String>());

        } else {
            List<String> headers = new ArrayList<String>(
                    Arrays.asList(long_short.get(0).split(Utils.new_line_from_service)));

            model.addAttribute("long_short_header", headers.get(0));
            model.addAttribute("btc_48h", headers.subList(1, headers.size()));

            model.addAttribute("long_short_list_perfect",
                    new ArrayList<String>(Arrays.asList(long_short.get(1).split(Utils.new_line_from_service))));

            model.addAttribute("long_short_list_curr_price",
                    new ArrayList<String>(Arrays.asList(long_short.get(2).split(Utils.new_line_from_service))));

            model.addAttribute("long_list_perfect2",
                    new ArrayList<String>(Arrays.asList(long_short.get(3).split(Utils.new_line_from_service))));

            model.addAttribute("short_list_perfect2",
                    new ArrayList<String>(Arrays.asList(long_short.get(4).split(Utils.new_line_from_service))));
        }

        List<EntryCssResponse> scapling_list = service.findAllScalpingToday();
        model.addAttribute("scapling_list", scapling_list);

        return "detail"; // BTC
    }

    @GetMapping("/binance")
    public String listOrderByBinaceVolume(Model model) {
        BscScanBinanceApplication.callFormBinance = "binance";
        model.addAttribute("data_list", service.getList(true));
        return "binance";
    }

    @PostMapping("/add")
    public ResponseEntity<Response> add(@RequestBody CoinGeckoTokenRequest request) {
        return new ResponseEntity<>(geckoService.add(request), HttpStatus.OK);
    }

    @PostMapping("/del")
    public ResponseEntity<Response> delete(@RequestBody CoinGeckoTokenRequest request) {
        return new ResponseEntity<>(geckoService.delete(request), HttpStatus.OK);
    }

    @PostMapping("/note")
    public ResponseEntity<Response> note(@RequestBody CoinGeckoTokenRequest request) {
        return new ResponseEntity<>(geckoService.note(request), HttpStatus.OK);
    }

    @PostMapping("/priority")
    public ResponseEntity<Response> priority(@RequestBody CoinGeckoTokenRequest request) {
        return new ResponseEntity<>(geckoService.priority(request), HttpStatus.OK);
    }
}
