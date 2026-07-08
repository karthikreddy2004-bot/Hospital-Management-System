package com.hms.hospital.repository;

import com.hms.hospital.entity.Patient;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface PatientRepository extends JpaRepository<Patient, Long> {

    @Query("SELECT p FROM Patient p WHERE " +
           "LOWER(p.name) LIKE LOWER(CONCAT('%', :keyword, '%')) OR " +
           "p.phone LIKE CONCAT('%', :keyword, '%') OR " +
           "LOWER(p.email) LIKE LOWER(CONCAT('%', :keyword, '%'))")
    Page<Patient> search(@Param("keyword") String keyword, Pageable pageable);
}

