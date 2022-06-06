package bsc_scan_binance.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import bsc_scan_binance.entity.BinanceVolumnWeek;
import bsc_scan_binance.entity.BinanceVolumnWeekKey;

@Repository
public interface BinanceVolumnWeekRepository extends JpaRepository<BinanceVolumnWeek, BinanceVolumnWeekKey> {

}
