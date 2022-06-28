package bsc_scan_binance.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import bsc_scan_binance.entity.GeckoVolumeMonth;
import bsc_scan_binance.entity.GeckoVolumeMonthKey;

@Repository
public interface GeckoVolumeMonthRepository extends JpaRepository<GeckoVolumeMonth, GeckoVolumeMonthKey> {

}
