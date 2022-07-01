package bsc_scan_binance.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import bsc_scan_binance.entity.ViewOpportunity;

@Repository
public interface ViewOpportunityRepository extends JpaRepository<ViewOpportunity, String> {

}
