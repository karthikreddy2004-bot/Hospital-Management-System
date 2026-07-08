package com.hms.hospital.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;
import java.util.Map;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class DashboardStatsDto {

    // Summary cards
    private long totalDoctors;
    private long totalPatients;
    private long totalAppointments;
    private long appointmentsToday;
    private long scheduledCount;
    private long completedCount;
    private long cancelledCount;

    // Chart data: appointments grouped by status -> { "SCHEDULED": 10, "COMPLETED": 5, ... }
    private Map<String, Long> appointmentsByStatus;

    // Chart data: appointments per day for last 7 days -> [{date, count}]
    private List<DayCount> appointmentsLast7Days;

    // Chart data: doctors grouped by specialization -> { "Cardiology": 3, ... }
    private Map<String, Long> doctorsBySpecialization;

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    public static class DayCount {
        private String date;
        private long count;
    }
}

