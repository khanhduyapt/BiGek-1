package bsc_scan_binance.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import bsc_scan_binance.entity.BinanceVolumeDateTime;
import bsc_scan_binance.entity.BinanceVolumeDateTimeKey;

@Repository
public interface BinanceVolumeDateTimeRepository
        extends JpaRepository<BinanceVolumeDateTime, BinanceVolumeDateTimeKey> {

}
