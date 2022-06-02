package codervi.bsc_scan.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import codervi.bsc_scan.entity.BinanceVolumnDay;
import codervi.bsc_scan.entity.BinanceVolumnDayKey;

@Repository
public interface BinanceVolumnDayRepository extends JpaRepository<BinanceVolumnDay, BinanceVolumnDayKey> {

}
