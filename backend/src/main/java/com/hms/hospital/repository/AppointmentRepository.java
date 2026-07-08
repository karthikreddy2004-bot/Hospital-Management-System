package com.hms.hospital.repository;

import com.hms.hospital.entity.Appointment;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.LocalDate;
import java.util.List;

public interface AppointmentRepository extends JpaRepository<Appointment, Long> {

    @Query("SELECT a FROM Appointment a WHERE " +
           "LOWER(a.patient.name) LIKE LOWER(CONCAT('%', :keyword, '%')) OR " +
           "LOWER(a.doctor.name) LIKE LOWER(CONCAT('%', :keyword, '%')) OR " +
           "LOWER(a.status) LIKE LOWER(CONCAT('%', :keyword, '%')) OR " +
           "LOWER(a.reason) LIKE LOWER(CONCAT('%', :keyword, '%'))")
    Page<Appointment> search(@Param("keyword") String keyword, Pageable pageable);

    long countByStatus(Appointment.AppointmentStatus status);

    long countByAppointmentDate(LocalDate date);

    @Query("SELECT a FROM Appointment a WHERE a.appointmentDate BETWEEN :start AND :end")
    List<Appointment> findBetweenDates(@Param("start") LocalDate start, @Param("end") LocalDate end);

    @Query("SELECT a FROM Appointment a WHERE a.doctor.id = :doctorId")
    Page<Appointment> findByDoctorId(@Param("doctorId") Long doctorId, Pageable pageable);

    @Query("SELECT a FROM Appointment a WHERE a.patient.id = :patientId")
    Page<Appointment> findByPatientId(@Param("patientId") Long patientId, Pageable pageable);

    @Query("SELECT a FROM Appointment a WHERE a.appointmentDate BETWEEN :start AND :end ORDER BY a.appointmentDate ASC, a.appointmentTime ASC")
    List<Appointment> findReportBetweenDates(@Param("start") LocalDate start, @Param("end") LocalDate end);
}

