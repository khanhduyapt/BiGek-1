package codervi.bsc_scan.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import codervi.bsc_scan.entity.BinanceVolumnWeek;
import codervi.bsc_scan.entity.BinanceVolumnWeekKey;

@Repository
public interface BinanceVolumnWeekRepository extends JpaRepository<BinanceVolumnWeek, BinanceVolumnWeekKey> {

}
