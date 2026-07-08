package com.hms.hospital.repository;

import com.hms.hospital.entity.Doctor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface DoctorRepository extends JpaRepository<Doctor, Long> {

    Boolean existsByEmail(String email);

    @Query("SELECT d FROM Doctor d WHERE " +
           "LOWER(d.name) LIKE LOWER(CONCAT('%', :keyword, '%')) OR " +
           "LOWER(d.specialization) LIKE LOWER(CONCAT('%', :keyword, '%')) OR " +
           "LOWER(d.email) LIKE LOWER(CONCAT('%', :keyword, '%')) OR " +
           "d.phone LIKE CONCAT('%', :keyword, '%')")
    Page<Doctor> search(@Param("keyword") String keyword, Pageable pageable);

    long countByAvailable(boolean available);
}

