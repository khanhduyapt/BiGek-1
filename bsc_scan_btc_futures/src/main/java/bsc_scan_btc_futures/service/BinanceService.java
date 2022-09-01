package bsc_scan_btc_futures.service;

import java.util.List;

import response.DepthResponse;

public interface BinanceService {
    public String doProcess();

    public List<List<DepthResponse>> getListDepthData();
}
