package com.hms.hospital.service;

import com.hms.hospital.dto.AppointmentDto;
import com.hms.hospital.entity.Appointment;
import com.hms.hospital.repository.AppointmentRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
public class ReportService {

    @Autowired
    private AppointmentRepository appointmentRepository;

    @Autowired
    private AppointmentService appointmentService;

    public Map<String, Object> generateAppointmentReport(LocalDate startDate, LocalDate endDate) {
        if (startDate == null) startDate = LocalDate.now().minusDays(30);
        if (endDate == null) endDate = LocalDate.now();

        List<Appointment> appointments = appointmentRepository.findReportBetweenDates(startDate, endDate);

        List<AppointmentDto.Response> details = appointments.stream()
                .map(appointmentService::mapToResponse)
                .collect(Collectors.toList());

        Map<String, Long> statusBreakdown = appointments.stream()
                .collect(Collectors.groupingBy(a -> a.getStatus().name(), Collectors.counting()));

        Map<String, Long> doctorBreakdown = appointments.stream()
                .collect(Collectors.groupingBy(a -> a.getDoctor().getName(), Collectors.counting()));

        Map<String, Object> report = new LinkedHashMap<>();
        report.put("startDate", startDate);
        report.put("endDate", endDate);
        report.put("totalAppointments", appointments.size());
        report.put("statusBreakdown", statusBreakdown);
        report.put("doctorBreakdown", doctorBreakdown);
        report.put("appointments", details);

        return report;
    }
}

