package bsc_scan_binance.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import bsc_scan_binance.entity.FundingHistory;
import bsc_scan_binance.entity.FundingHistoryKey;

@Repository
public interface FundingHistoryRepository extends JpaRepository<FundingHistory, FundingHistoryKey> {
    // @Query(value = "SELECT m.* FROM binance_futures m WHERE scalping_today",
    // nativeQuery = true)
    // public List<BinanceFutures> findAllByScalpingToday();

    public List<FundingHistory> findAllByPumpdump(boolean pumpdump);
}