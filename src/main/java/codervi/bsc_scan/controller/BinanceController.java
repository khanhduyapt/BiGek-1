package codervi.bsc_scan.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

import codervi.bsc_scan.service.BinanceService;
import lombok.RequiredArgsConstructor;

//@RestController
@RequiredArgsConstructor
//@RequestMapping("")
@Controller
public class BinanceController {
    @Autowired
    private final BinanceService service;

    @GetMapping
    public String list(Model model) {
        model.addAttribute("data_list", service.getList());
        return "binance";
    }
}
