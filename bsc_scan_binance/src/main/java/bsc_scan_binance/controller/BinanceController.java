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

        model.addAttribute("data_list", service.getList(true));
        return "binance";
    }

    @GetMapping("/{symbol}")
    public String getListDepthData(@PathVariable("symbol") String symbol, Model model) {
        List<List<DepthResponse>> list = new ArrayList<List<DepthResponse>>();

        list = service.getListDepthData(symbol);
        if (symbol.toUpperCase().equals("BTC")) {
            // list = service.getListDepthData(symbol);
        }

        List<DepthResponse> list_bids = new ArrayList<DepthResponse>();
        List<DepthResponse> list_asks = new ArrayList<DepthResponse>();

        if (!CollectionUtils.isEmpty(list)) {
            list_bids = list.get(0);
            list_asks = list.get(1);
        }

        model.addAttribute("data_list_1", list_bids);
        model.addAttribute("data_list_2", list_asks);
        model.addAttribute("symbol", symbol);
        model.addAttribute("sp500", service.loadPremarketSp500().replaceAll(Utils.new_line_from_bot, ", "));
        model.addAttribute("exchanges",
                service.getBtcBalancesOnExchanges().replaceAll(Utils.new_line_from_service, ", "));

        List<String> long_short = service.monitorBtcPrice();
        if (CollectionUtils.isEmpty(long_short)) {
            model.addAttribute("long_short_header", "Btc sideway không rõ xu hướng.");
            model.addAttribute("long_short_list_perfect", new ArrayList<String>());
            model.addAttribute("long_short_list_curr_price", new ArrayList<String>());
        } else {

            model.addAttribute("long_short_header", long_short.get(0).replace(Utils.new_line_from_service, ""));

            model.addAttribute("long_short_list_perfect",
                    new ArrayList<String>(Arrays.asList(long_short.get(1).split(Utils.new_line_from_service))));

            model.addAttribute("long_short_list_curr_price",
                    new ArrayList<String>(Arrays.asList(long_short.get(2).split(Utils.new_line_from_service))));
        }

        return "detail";
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
