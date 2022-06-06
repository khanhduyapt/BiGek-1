package bsc_scan_binance.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import bsc_scan_binance.entity.GeckoVolumnDay;
import bsc_scan_binance.entity.GeckoVolumnDayKey;

@Repository
public interface GeckoVolumnDayRepository extends JpaRepository<GeckoVolumnDay, GeckoVolumnDayKey> {

}
