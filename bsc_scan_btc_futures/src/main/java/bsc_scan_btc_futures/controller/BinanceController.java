package bsc_scan_btc_futures.controller;

import java.util.ArrayList;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.util.CollectionUtils;
import org.springframework.web.bind.annotation.GetMapping;

import bsc_scan_btc_futures.service.BinanceService;
import lombok.RequiredArgsConstructor;
import response.DepthResponse;

@RequiredArgsConstructor
@Controller
public class BinanceController {
    @Autowired
    private final BinanceService service;

    @GetMapping()
    public String getListDepthData(Model model) {
        List<List<DepthResponse>> list = service.getListDepthData();

        List<DepthResponse> list_bids = new ArrayList<DepthResponse>();
        List<DepthResponse> list_asks = new ArrayList<DepthResponse>();

        if (!CollectionUtils.isEmpty(list)) {
            list_bids = list.get(0);
            list_asks = list.get(1);
        }

        model.addAttribute("data_list_1", list_bids);
        model.addAttribute("data_list_2", list_asks);
        model.addAttribute("symbol", "BTC");

        return "detail";
    }
}
