package bsc_scan_binance.service;

import java.util.List;

import bsc_scan_binance.response.CandidateTokenCssResponse;

public interface BinanceService {

    List<CandidateTokenCssResponse> getList(Boolean isOrderByBynaceVolume);

    public String checkBtcUpDown();

    public void loadData(String gecko_id, String symbol);

    public void loadDataBtcVolumeDay();

    public void monitorEma();

    public void monitorProfit();

    public void monitorToken();
}
