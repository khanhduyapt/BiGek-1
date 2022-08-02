package bsc_scan_binance.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import bsc_scan_binance.entity.BinanceVolumnDay;
import bsc_scan_binance.entity.BinanceVolumnDayKey;

@Repository
public interface BinanceVolumnDayRepository extends JpaRepository<BinanceVolumnDay, BinanceVolumnDayKey> {

    @Query("SELECT m FROM BinanceVolumnDay m WHERE m.id.hh = TO_CHAR(NOW(), 'HH24') and (m.id.symbol = :symbol or m.id.geckoid = :symbol) ")
    List<BinanceVolumnDay> searchBySymbol(@Param("symbol") String symbol);

}
