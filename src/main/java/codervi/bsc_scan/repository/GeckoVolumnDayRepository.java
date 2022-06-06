package codervi.bsc_scan.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import codervi.bsc_scan.entity.GeckoVolumnDay;
import codervi.bsc_scan.entity.GeckoVolumnDayKey;

@Repository
public interface GeckoVolumnDayRepository extends JpaRepository<GeckoVolumnDay, GeckoVolumnDayKey> {

}
