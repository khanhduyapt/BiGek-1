package bsc_scan_binance.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import bsc_scan_binance.entity.BinancePumpingHistory;
import bsc_scan_binance.entity.BinanceVolumnDayKey;

@Repository
public interface BinancePumpingHistoryRepository extends JpaRepository<BinancePumpingHistory, BinanceVolumnDayKey> {

}
