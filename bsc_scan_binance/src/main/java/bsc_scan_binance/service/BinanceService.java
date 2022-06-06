package bsc_scan_binance.service;

import java.util.List;

import bsc_scan_binance.response.CandidateTokenCssResponse;

public interface BinanceService {

    List<CandidateTokenCssResponse> getList();

    public void loadData(String gecko_id, String symbol);

}
