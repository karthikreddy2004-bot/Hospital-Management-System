package com.hms.hospital.service;

import com.hms.hospital.dto.DashboardStatsDto;
import com.hms.hospital.entity.Appointment;
import com.hms.hospital.entity.Doctor;
import com.hms.hospital.repository.AppointmentRepository;
import com.hms.hospital.repository.DoctorRepository;
import com.hms.hospital.repository.PatientRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
public class DashboardService {

    @Autowired
    private DoctorRepository doctorRepository;

    @Autowired
    private PatientRepository patientRepository;

    @Autowired
    private AppointmentRepository appointmentRepository;

    public DashboardStatsDto getDashboardStats() {
        DashboardStatsDto stats = new DashboardStatsDto();

        long totalDoctors = doctorRepository.count();
        long totalPatients = patientRepository.count();
        long totalAppointments = appointmentRepository.count();
        long appointmentsToday = appointmentRepository.countByAppointmentDate(LocalDate.now());

        long scheduled = appointmentRepository.countByStatus(Appointment.AppointmentStatus.SCHEDULED);
        long completed = appointmentRepository.countByStatus(Appointment.AppointmentStatus.COMPLETED);
        long cancelled = appointmentRepository.countByStatus(Appointment.AppointmentStatus.CANCELLED);

        stats.setTotalDoctors(totalDoctors);
        stats.setTotalPatients(totalPatients);
        stats.setTotalAppointments(totalAppointments);
        stats.setAppointmentsToday(appointmentsToday);
        stats.setScheduledCount(scheduled);
        stats.setCompletedCount(completed);
        stats.setCancelledCount(cancelled);

        // Appointments by status (for pie chart)
        Map<String, Long> byStatus = new LinkedHashMap<>();
        byStatus.put("SCHEDULED", scheduled);
        byStatus.put("COMPLETED", completed);
        byStatus.put("CANCELLED", cancelled);
        stats.setAppointmentsByStatus(byStatus);

        // Appointments for last 7 days (for bar/line chart)
        LocalDate today = LocalDate.now();
        LocalDate sevenDaysAgo = today.minusDays(6);
        List<Appointment> recentAppointments = appointmentRepository.findBetweenDates(sevenDaysAgo, today);

        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("MMM dd");
        Map<LocalDate, Long> countsByDate = recentAppointments.stream()
                .collect(Collectors.groupingBy(Appointment::getAppointmentDate, Collectors.counting()));

        List<DashboardStatsDto.DayCount> last7Days = sevenDaysAgo.datesUntil(today.plusDays(1))
                .map(date -> new DashboardStatsDto.DayCount(date.format(formatter), countsByDate.getOrDefault(date, 0L)))
                .collect(Collectors.toList());
        stats.setAppointmentsLast7Days(last7Days);

        // Doctors by specialization (for bar/pie chart)
        Map<String, Long> bySpecialization = doctorRepository.findAll().stream()
                .collect(Collectors.groupingBy(Doctor::getSpecialization, Collectors.counting()));
        stats.setDoctorsBySpecialization(bySpecialization);

        return stats;
    }
}

