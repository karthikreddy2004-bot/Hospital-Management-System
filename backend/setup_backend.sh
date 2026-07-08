#!/bin/bash
set -e
echo "Creating backend folder structure..."
mkdir -p src/main/java/com/hms/hospital/{config,controller,dto,entity,exception,repository,security,service}
mkdir -p src/main/resources

echo 'Writing pom.xml...'
cat > 'pom.xml' << 'HMSEOF'
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 https://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>

    <parent>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-parent</artifactId>
        <version>3.2.5</version>
        <relativePath/>
    </parent>

    <groupId>com.hms</groupId>
    <artifactId>hospital-management-system</artifactId>
    <version>1.0.0</version>
    <name>hospital-management-system</name>
    <description>Hospital Management System - Spring Boot Backend</description>
    <packaging>jar</packaging>

    <properties>
        <java.version>17</java.version>
        <jjwt.version>0.12.5</jjwt.version>
    </properties>

    <dependencies>
        <!-- Web -->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-web</artifactId>
        </dependency>

        <!-- JPA / Hibernate -->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-data-jpa</artifactId>
        </dependency>

        <!-- Security -->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-security</artifactId>
        </dependency>

        <!-- Validation -->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-validation</artifactId>
        </dependency>

        <!-- MySQL Driver -->
        <dependency>
            <groupId>com.mysql</groupId>
            <artifactId>mysql-connector-j</artifactId>
            <scope>runtime</scope>
        </dependency>

        <!-- JWT -->
        <dependency>
            <groupId>io.jsonwebtoken</groupId>
            <artifactId>jjwt-api</artifactId>
            <version>${jjwt.version}</version>
        </dependency>
        <dependency>
            <groupId>io.jsonwebtoken</groupId>
            <artifactId>jjwt-impl</artifactId>
            <version>${jjwt.version}</version>
            <scope>runtime</scope>
        </dependency>
        <dependency>
            <groupId>io.jsonwebtoken</groupId>
            <artifactId>jjwt-jackson</artifactId>
            <version>${jjwt.version}</version>
            <scope>runtime</scope>
        </dependency>

        <!-- Lombok -->
        <dependency>
            <groupId>org.projectlombok</groupId>
            <artifactId>lombok</artifactId>
            <optional>true</optional>
        </dependency>

        <!-- Dev tools -->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-devtools</artifactId>
            <scope>runtime</scope>
            <optional>true</optional>
        </dependency>

        <!-- Test -->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-test</artifactId>
            <scope>test</scope>
        </dependency>
        <dependency>
            <groupId>org.springframework.security</groupId>
            <artifactId>spring-security-test</artifactId>
            <scope>test</scope>
        </dependency>
    </dependencies>

    <build>
        <plugins>
            <plugin>
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-maven-plugin</artifactId>
                <configuration>
                    <excludes>
                        <exclude>
                            <groupId>org.projectlombok</groupId>
                            <artifactId>lombok</artifactId>
                        </exclude>
                    </excludes>
                </configuration>
            </plugin>
        </plugins>
    </build>

</project>

HMSEOF

echo 'Writing src/main/java/com/hms/hospital/HospitalManagementApplication.java...'
cat > 'src/main/java/com/hms/hospital/HospitalManagementApplication.java' << 'HMSEOF'
package com.hms.hospital;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class HospitalManagementApplication {
    public static void main(String[] args) {
        SpringApplication.run(HospitalManagementApplication.class, args);
    }
}

HMSEOF

echo 'Writing src/main/java/com/hms/hospital/config/SecurityConfig.java...'
cat > 'src/main/java/com/hms/hospital/config/SecurityConfig.java' << 'HMSEOF'
package com.hms.hospital.config;

import com.hms.hospital.security.AuthEntryPointJwt;
import com.hms.hospital.security.AuthTokenFilter;
import com.hms.hospital.security.UserDetailsServiceImpl;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.dao.DaoAuthenticationProvider;
import org.springframework.security.config.annotation.authentication.configuration.AuthenticationConfiguration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;

import java.util.List;

@Configuration
@EnableWebSecurity
public class SecurityConfig {

    @Autowired
    private UserDetailsServiceImpl userDetailsService;

    @Autowired
    private AuthEntryPointJwt unauthorizedHandler;

    @Value("${app.cors.allowed-origins}")
    private String allowedOrigins;

    @Bean
    public AuthTokenFilter authenticationJwtTokenFilter() {
        return new AuthTokenFilter();
    }

    @Bean
    public DaoAuthenticationProvider authenticationProvider() {
        DaoAuthenticationProvider authProvider = new DaoAuthenticationProvider();
        authProvider.setUserDetailsService(userDetailsService);
        authProvider.setPasswordEncoder(passwordEncoder());
        return authProvider;
    }

    @Bean
    public AuthenticationManager authenticationManager(AuthenticationConfiguration config) throws Exception {
        return config.getAuthenticationManager();
    }

    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }

    @Bean
    public CorsConfigurationSource corsConfigurationSource() {
        CorsConfiguration configuration = new CorsConfiguration();
        configuration.setAllowedOrigins(List.of(allowedOrigins.split(",")));
        configuration.setAllowedMethods(List.of("GET", "POST", "PUT", "DELETE", "PATCH", "OPTIONS"));
        configuration.setAllowedHeaders(List.of("*"));
        configuration.setAllowCredentials(true);
        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", configuration);
        return source;
    }

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http.cors(cors -> cors.configurationSource(corsConfigurationSource()))
            .csrf(csrf -> csrf.disable())
            .exceptionHandling(exception -> exception.authenticationEntryPoint(unauthorizedHandler))
            .sessionManagement(session -> session.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
            .authorizeHttpRequests(auth -> auth
                .requestMatchers("/api/auth/**").permitAll()
                .requestMatchers("/api/test/**").permitAll()
                .requestMatchers("/error").permitAll()
                .anyRequest().authenticated()
            );

        http.authenticationProvider(authenticationProvider());
        http.addFilterBefore(authenticationJwtTokenFilter(), UsernamePasswordAuthenticationFilter.class);

        return http.build();
    }
}

HMSEOF

echo 'Writing src/main/java/com/hms/hospital/controller/AppointmentController.java...'
cat > 'src/main/java/com/hms/hospital/controller/AppointmentController.java' << 'HMSEOF'
package com.hms.hospital.controller;

import com.hms.hospital.dto.AppointmentDto;
import com.hms.hospital.entity.Appointment;
import com.hms.hospital.service.AppointmentService;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/appointments")
public class AppointmentController {

    @Autowired
    private AppointmentService appointmentService;

    // GET /api/appointments?page=0&size=10&sortBy=appointmentDate&direction=desc&keyword=john
    @GetMapping
    public ResponseEntity<Page<AppointmentDto.Response>> getAllAppointments(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size,
            @RequestParam(defaultValue = "id") String sortBy,
            @RequestParam(defaultValue = "desc") String direction,
            @RequestParam(required = false) String keyword) {

        Sort sort = direction.equalsIgnoreCase("desc") ? Sort.by(sortBy).descending() : Sort.by(sortBy).ascending();
        Pageable pageable = PageRequest.of(page, size, sort);

        Page<Appointment> result = (keyword != null && !keyword.trim().isEmpty())
                ? appointmentService.searchAppointments(keyword, pageable)
                : appointmentService.getAllAppointments(pageable);

        Page<AppointmentDto.Response> response = result.map(appointmentService::mapToResponse);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/{id}")
    public ResponseEntity<AppointmentDto.Response> getAppointmentById(@PathVariable Long id) {
        Appointment appointment = appointmentService.getAppointmentById(id);
        return ResponseEntity.ok(appointmentService.mapToResponse(appointment));
    }

    @PostMapping
    public ResponseEntity<AppointmentDto.Response> createAppointment(@Valid @RequestBody AppointmentDto.Request request) {
        Appointment created = appointmentService.createAppointment(request);
        return ResponseEntity.status(HttpStatus.CREATED).body(appointmentService.mapToResponse(created));
    }

    @PutMapping("/{id}")
    public ResponseEntity<AppointmentDto.Response> updateAppointment(@PathVariable Long id, @Valid @RequestBody AppointmentDto.Request request) {
        Appointment updated = appointmentService.updateAppointment(id, request);
        return ResponseEntity.ok(appointmentService.mapToResponse(updated));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteAppointment(@PathVariable Long id) {
        appointmentService.deleteAppointment(id);
        return ResponseEntity.noContent().build();
    }
}

HMSEOF

echo 'Writing src/main/java/com/hms/hospital/controller/AuthController.java...'
cat > 'src/main/java/com/hms/hospital/controller/AuthController.java' << 'HMSEOF'
package com.hms.hospital.controller;

import com.hms.hospital.dto.AuthDtos.*;
import com.hms.hospital.entity.User;
import com.hms.hospital.service.AuthService;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/auth")
public class AuthController {

    @Autowired
    private AuthService authService;

    @PostMapping("/login")
    public ResponseEntity<JwtResponse> login(@Valid @RequestBody LoginRequest loginRequest) {
        JwtResponse response = authService.login(loginRequest);
        return ResponseEntity.ok(response);
    }

    @PostMapping("/register")
    public ResponseEntity<MessageResponse> register(@Valid @RequestBody RegisterRequest registerRequest) {
        User user = authService.register(registerRequest);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(new MessageResponse("User registered successfully with username: " + user.getUsername()));
    }
}

HMSEOF

echo 'Writing src/main/java/com/hms/hospital/controller/DashboardController.java...'
cat > 'src/main/java/com/hms/hospital/controller/DashboardController.java' << 'HMSEOF'
package com.hms.hospital.controller;

import com.hms.hospital.dto.DashboardStatsDto;
import com.hms.hospital.service.DashboardService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/dashboard")
public class DashboardController {

    @Autowired
    private DashboardService dashboardService;

    @GetMapping("/stats")
    public ResponseEntity<DashboardStatsDto> getDashboardStats() {
        return ResponseEntity.ok(dashboardService.getDashboardStats());
    }
}

HMSEOF

echo 'Writing src/main/java/com/hms/hospital/controller/DoctorController.java...'
cat > 'src/main/java/com/hms/hospital/controller/DoctorController.java' << 'HMSEOF'
package com.hms.hospital.controller;

import com.hms.hospital.dto.DoctorDto;
import com.hms.hospital.entity.Doctor;
import com.hms.hospital.service.DoctorService;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/doctors")
public class DoctorController {

    @Autowired
    private DoctorService doctorService;

    // GET /api/doctors?page=0&size=10&sortBy=name&direction=asc&keyword=cardio
    @GetMapping
    public ResponseEntity<Page<Doctor>> getAllDoctors(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size,
            @RequestParam(defaultValue = "id") String sortBy,
            @RequestParam(defaultValue = "asc") String direction,
            @RequestParam(required = false) String keyword) {

        Sort sort = direction.equalsIgnoreCase("desc") ? Sort.by(sortBy).descending() : Sort.by(sortBy).ascending();
        Pageable pageable = PageRequest.of(page, size, sort);

        Page<Doctor> result = (keyword != null && !keyword.trim().isEmpty())
                ? doctorService.searchDoctors(keyword, pageable)
                : doctorService.getAllDoctors(pageable);

        return ResponseEntity.ok(result);
    }

    @GetMapping("/{id}")
    public ResponseEntity<Doctor> getDoctorById(@PathVariable Long id) {
        return ResponseEntity.ok(doctorService.getDoctorById(id));
    }

    @PostMapping
    public ResponseEntity<Doctor> createDoctor(@Valid @RequestBody DoctorDto dto) {
        Doctor created = doctorService.createDoctor(dto);
        return ResponseEntity.status(HttpStatus.CREATED).body(created);
    }

    @PutMapping("/{id}")
    public ResponseEntity<Doctor> updateDoctor(@PathVariable Long id, @Valid @RequestBody DoctorDto dto) {
        Doctor updated = doctorService.updateDoctor(id, dto);
        return ResponseEntity.ok(updated);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteDoctor(@PathVariable Long id) {
        doctorService.deleteDoctor(id);
        return ResponseEntity.noContent().build();
    }
}

HMSEOF

echo 'Writing src/main/java/com/hms/hospital/controller/PatientController.java...'
cat > 'src/main/java/com/hms/hospital/controller/PatientController.java' << 'HMSEOF'
package com.hms.hospital.controller;

import com.hms.hospital.dto.PatientDto;
import com.hms.hospital.entity.Patient;
import com.hms.hospital.service.PatientService;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/patients")
public class PatientController {

    @Autowired
    private PatientService patientService;

    @GetMapping
    public ResponseEntity<Page<Patient>> getAllPatients(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size,
            @RequestParam(defaultValue = "id") String sortBy,
            @RequestParam(defaultValue = "asc") String direction,
            @RequestParam(required = false) String keyword) {

        Sort sort = direction.equalsIgnoreCase("desc") ? Sort.by(sortBy).descending() : Sort.by(sortBy).ascending();
        Pageable pageable = PageRequest.of(page, size, sort);

        Page<Patient> result = (keyword != null && !keyword.trim().isEmpty())
                ? patientService.searchPatients(keyword, pageable)
                : patientService.getAllPatients(pageable);

        return ResponseEntity.ok(result);
    }

    @GetMapping("/{id}")
    public ResponseEntity<Patient> getPatientById(@PathVariable Long id) {
        return ResponseEntity.ok(patientService.getPatientById(id));
    }

    @PostMapping
    public ResponseEntity<Patient> createPatient(@Valid @RequestBody PatientDto dto) {
        Patient created = patientService.createPatient(dto);
        return ResponseEntity.status(HttpStatus.CREATED).body(created);
    }

    @PutMapping("/{id}")
    public ResponseEntity<Patient> updatePatient(@PathVariable Long id, @Valid @RequestBody PatientDto dto) {
        Patient updated = patientService.updatePatient(id, dto);
        return ResponseEntity.ok(updated);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deletePatient(@PathVariable Long id) {
        patientService.deletePatient(id);
        return ResponseEntity.noContent().build();
    }
}

HMSEOF

echo 'Writing src/main/java/com/hms/hospital/controller/ReportController.java...'
cat > 'src/main/java/com/hms/hospital/controller/ReportController.java' << 'HMSEOF'
package com.hms.hospital.controller;

import com.hms.hospital.service.ReportService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.time.LocalDate;
import java.util.Map;

@RestController
@RequestMapping("/api/reports")
public class ReportController {

    @Autowired
    private ReportService reportService;

    // GET /api/reports/appointments?startDate=2026-06-01&endDate=2026-06-30
    @GetMapping("/appointments")
    public ResponseEntity<Map<String, Object>> getAppointmentReport(
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate) {

        Map<String, Object> report = reportService.generateAppointmentReport(startDate, endDate);
        return ResponseEntity.ok(report);
    }
}

HMSEOF

echo 'Writing src/main/java/com/hms/hospital/dto/AppointmentDto.java...'
cat > 'src/main/java/com/hms/hospital/dto/AppointmentDto.java' << 'HMSEOF'
package com.hms.hospital.dto;

import com.hms.hospital.entity.Appointment;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;

public class AppointmentDto {

    /** Used for create/update requests */
    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    public static class Request {
        @NotNull(message = "Patient id is required")
        private Long patientId;

        @NotNull(message = "Doctor id is required")
        private Long doctorId;

        @NotNull(message = "Appointment date is required")
        private LocalDate appointmentDate;

        @NotNull(message = "Appointment time is required")
        private LocalTime appointmentTime;

        private String reason;

        private Appointment.AppointmentStatus status;
    }

    /** Used for responses - flattened with patient/doctor names for easy display in React */
    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    public static class Response {
        private Long id;
        private Long patientId;
        private String patientName;
        private Long doctorId;
        private String doctorName;
        private String doctorSpecialization;
        private LocalDate appointmentDate;
        private LocalTime appointmentTime;
        private Appointment.AppointmentStatus status;
        private String reason;
        private LocalDateTime createdAt;
    }
}

HMSEOF

echo 'Writing src/main/java/com/hms/hospital/dto/AuthDtos.java...'
cat > 'src/main/java/com/hms/hospital/dto/AuthDtos.java' << 'HMSEOF'
package com.hms.hospital.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

public class AuthDtos {

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    public static class LoginRequest {
        @NotBlank(message = "Username is required")
        private String username;

        @NotBlank(message = "Password is required")
        private String password;
    }

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    public static class RegisterRequest {
        @NotBlank(message = "Username is required")
        @Size(min = 3, max = 50)
        private String username;

        @NotBlank(message = "Password is required")
        @Size(min = 6, message = "Password must be at least 6 characters")
        private String password;

        @NotBlank(message = "Email is required")
        @Email(message = "Email should be valid")
        private String email;

        private String role; // optional - defaults to ADMIN
    }

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    public static class JwtResponse {
        private String token;
        private String type = "Bearer";
        private Long id;
        private String username;
        private String email;
        private String role;

        public JwtResponse(String token, Long id, String username, String email, String role) {
            this.token = token;
            this.id = id;
            this.username = username;
            this.email = email;
            this.role = role;
        }
    }

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    public static class MessageResponse {
        private String message;
    }
}

HMSEOF

echo 'Writing src/main/java/com/hms/hospital/dto/DashboardStatsDto.java...'
cat > 'src/main/java/com/hms/hospital/dto/DashboardStatsDto.java' << 'HMSEOF'
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

HMSEOF

echo 'Writing src/main/java/com/hms/hospital/dto/DoctorDto.java...'
cat > 'src/main/java/com/hms/hospital/dto/DoctorDto.java' << 'HMSEOF'
package com.hms.hospital.dto;

import jakarta.validation.constraints.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class DoctorDto {

    private Long id;

    @NotBlank(message = "Name is required")
    private String name;

    @NotBlank(message = "Specialization is required")
    private String specialization;

    @NotBlank(message = "Email is required")
    @Email(message = "Email should be valid")
    private String email;

    @NotBlank(message = "Phone is required")
    @Pattern(regexp = "^[0-9]{10}$", message = "Phone must be 10 digits")
    private String phone;

    private String qualification;

    @Min(value = 0, message = "Experience cannot be negative")
    private Integer experienceYears;

    @DecimalMin(value = "0.0", message = "Fee cannot be negative")
    private BigDecimal consultationFee;

    private Boolean available;

    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}

HMSEOF

echo 'Writing src/main/java/com/hms/hospital/dto/PatientDto.java...'
cat > 'src/main/java/com/hms/hospital/dto/PatientDto.java' << 'HMSEOF'
package com.hms.hospital.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class PatientDto {
    private Long id;

    @NotBlank(message = "Name is required")
    private String name;

    private Integer age;
    private String gender;
    private String email;

    @NotBlank(message = "Phone is required")
    private String phone;

    private String address;
}

HMSEOF

echo 'Writing src/main/java/com/hms/hospital/entity/Appointment.java...'
cat > 'src/main/java/com/hms/hospital/entity/Appointment.java' << 'HMSEOF'
package com.hms.hospital.entity;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;

@Entity
@Table(name = "appointments")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Appointment {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @NotNull(message = "Patient is required")
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "patient_id", nullable = false)
    private Patient patient;

    @NotNull(message = "Doctor is required")
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "doctor_id", nullable = false)
    private Doctor doctor;

    @NotNull(message = "Appointment date is required")
    @Column(name = "appointment_date", nullable = false)
    private LocalDate appointmentDate;

    @NotNull(message = "Appointment time is required")
    @Column(name = "appointment_time", nullable = false)
    private LocalTime appointmentTime;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    private AppointmentStatus status = AppointmentStatus.SCHEDULED;

    @Column(length = 255)
    private String reason;

    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;

    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    @PrePersist
    protected void onCreate() {
        this.createdAt = LocalDateTime.now();
        this.updatedAt = LocalDateTime.now();
        if (this.status == null) this.status = AppointmentStatus.SCHEDULED;
    }

    @PreUpdate
    protected void onUpdate() {
        this.updatedAt = LocalDateTime.now();
    }

    public enum AppointmentStatus {
        SCHEDULED, COMPLETED, CANCELLED
    }
}

HMSEOF

echo 'Writing src/main/java/com/hms/hospital/entity/Doctor.java...'
cat > 'src/main/java/com/hms/hospital/entity/Doctor.java' << 'HMSEOF'
package com.hms.hospital.entity;

import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;
import jakarta.validation.constraints.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "doctors")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Doctor {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @NotBlank(message = "Name is required")
    @Column(nullable = false, length = 100)
    private String name;

    @NotBlank(message = "Specialization is required")
    @Column(nullable = false, length = 100)
    private String specialization;

    @NotBlank(message = "Email is required")
    @Email(message = "Email should be valid")
    @Column(nullable = false, unique = true, length = 100)
    private String email;

    @NotBlank(message = "Phone is required")
    @Pattern(regexp = "^[0-9]{10}$", message = "Phone must be 10 digits")
    @Column(nullable = false, length = 20)
    private String phone;

    @Column(length = 150)
    private String qualification;

    @Column(name = "experience_years")
    private Integer experienceYears = 0;

    @Column(name = "consultation_fee", precision = 10, scale = 2)
    private BigDecimal consultationFee = BigDecimal.ZERO;

    private Boolean available = true;

    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;

    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    @JsonIgnore
    @OneToMany(mappedBy = "doctor", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<Appointment> appointments = new ArrayList<>();

    @PrePersist
    protected void onCreate() {
        this.createdAt = LocalDateTime.now();
        this.updatedAt = LocalDateTime.now();
    }

    @PreUpdate
    protected void onUpdate() {
        this.updatedAt = LocalDateTime.now();
    }
}

HMSEOF

echo 'Writing src/main/java/com/hms/hospital/entity/Patient.java...'
cat > 'src/main/java/com/hms/hospital/entity/Patient.java' << 'HMSEOF'
package com.hms.hospital.entity;

import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;
import jakarta.validation.constraints.NotBlank;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "patients")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Patient {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @NotBlank(message = "Name is required")
    @Column(nullable = false, length = 100)
    private String name;

    private Integer age;

    @Column(length = 10)
    private String gender;

    @Column(length = 100)
    private String email;

    @NotBlank(message = "Phone is required")
    @Column(nullable = false, length = 20)
    private String phone;

    @Column(length = 255)
    private String address;

    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;

    @JsonIgnore
    @OneToMany(mappedBy = "patient", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<Appointment> appointments = new ArrayList<>();

    @PrePersist
    protected void onCreate() {
        this.createdAt = LocalDateTime.now();
    }
}

HMSEOF

echo 'Writing src/main/java/com/hms/hospital/entity/User.java...'
cat > 'src/main/java/com/hms/hospital/entity/User.java' << 'HMSEOF'
package com.hms.hospital.entity;

import jakarta.persistence.*;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Entity
@Table(name = "users")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class User {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @NotBlank
    @Column(unique = true, nullable = false, length = 50)
    private String username;

    @NotBlank
    @Column(nullable = false)
    private String password;

    @Email
    @NotBlank
    @Column(unique = true, nullable = false, length = 100)
    private String email;

    @Column(nullable = false, length = 20)
    private String role = "ADMIN";

    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;

    @PrePersist
    protected void onCreate() {
        this.createdAt = LocalDateTime.now();
        if (this.role == null) this.role = "ADMIN";
    }
}

HMSEOF

echo 'Writing src/main/java/com/hms/hospital/exception/DuplicateResourceException.java...'
cat > 'src/main/java/com/hms/hospital/exception/DuplicateResourceException.java' << 'HMSEOF'
package com.hms.hospital.exception;

import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.ResponseStatus;

@ResponseStatus(HttpStatus.CONFLICT)
public class DuplicateResourceException extends RuntimeException {
    public DuplicateResourceException(String message) {
        super(message);
    }
}

HMSEOF

echo 'Writing src/main/java/com/hms/hospital/exception/GlobalExceptionHandler.java...'
cat > 'src/main/java/com/hms/hospital/exception/GlobalExceptionHandler.java' << 'HMSEOF'
package com.hms.hospital.exception;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.validation.FieldError;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;
import org.springframework.web.context.request.WebRequest;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.Map;

@RestControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(ResourceNotFoundException.class)
    public ResponseEntity<Map<String, Object>> handleNotFound(ResourceNotFoundException ex, WebRequest request) {
        return buildResponse(HttpStatus.NOT_FOUND, ex.getMessage(), request);
    }

    @ExceptionHandler(DuplicateResourceException.class)
    public ResponseEntity<Map<String, Object>> handleDuplicate(DuplicateResourceException ex, WebRequest request) {
        return buildResponse(HttpStatus.CONFLICT, ex.getMessage(), request);
    }

    @ExceptionHandler(BadCredentialsException.class)
    public ResponseEntity<Map<String, Object>> handleBadCredentials(BadCredentialsException ex, WebRequest request) {
        return buildResponse(HttpStatus.UNAUTHORIZED, "Invalid username or password", request);
    }

    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<Map<String, Object>> handleValidation(MethodArgumentNotValidException ex, WebRequest request) {
        Map<String, String> fieldErrors = new LinkedHashMap<>();
        for (FieldError error : ex.getBindingResult().getFieldErrors()) {
            fieldErrors.put(error.getField(), error.getDefaultMessage());
        }
        Map<String, Object> body = new LinkedHashMap<>();
        body.put("timestamp", LocalDateTime.now());
        body.put("status", HttpStatus.BAD_REQUEST.value());
        body.put("error", "Validation Failed");
        body.put("fieldErrors", fieldErrors);
        body.put("path", request.getDescription(false).replace("uri=", ""));
        return new ResponseEntity<>(body, HttpStatus.BAD_REQUEST);
    }

    @ExceptionHandler(Exception.class)
    public ResponseEntity<Map<String, Object>> handleGenericException(Exception ex, WebRequest request) {
        return buildResponse(HttpStatus.INTERNAL_SERVER_ERROR, ex.getMessage(), request);
    }

    private ResponseEntity<Map<String, Object>> buildResponse(HttpStatus status, String message, WebRequest request) {
        Map<String, Object> body = new LinkedHashMap<>();
        body.put("timestamp", LocalDateTime.now());
        body.put("status", status.value());
        body.put("error", status.getReasonPhrase());
        body.put("message", message);
        body.put("path", request.getDescription(false).replace("uri=", ""));
        return new ResponseEntity<>(body, status);
    }
}

HMSEOF

echo 'Writing src/main/java/com/hms/hospital/exception/ResourceNotFoundException.java...'
cat > 'src/main/java/com/hms/hospital/exception/ResourceNotFoundException.java' << 'HMSEOF'
package com.hms.hospital.exception;

import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.ResponseStatus;

@ResponseStatus(HttpStatus.NOT_FOUND)
public class ResourceNotFoundException extends RuntimeException {
    public ResourceNotFoundException(String message) {
        super(message);
    }
}

HMSEOF

echo 'Writing src/main/java/com/hms/hospital/repository/AppointmentRepository.java...'
cat > 'src/main/java/com/hms/hospital/repository/AppointmentRepository.java' << 'HMSEOF'
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

HMSEOF

echo 'Writing src/main/java/com/hms/hospital/repository/DoctorRepository.java...'
cat > 'src/main/java/com/hms/hospital/repository/DoctorRepository.java' << 'HMSEOF'
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

HMSEOF

echo 'Writing src/main/java/com/hms/hospital/repository/PatientRepository.java...'
cat > 'src/main/java/com/hms/hospital/repository/PatientRepository.java' << 'HMSEOF'
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

HMSEOF

echo 'Writing src/main/java/com/hms/hospital/repository/UserRepository.java...'
cat > 'src/main/java/com/hms/hospital/repository/UserRepository.java' << 'HMSEOF'
package com.hms.hospital.repository;

import com.hms.hospital.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface UserRepository extends JpaRepository<User, Long> {
    Optional<User> findByUsername(String username);
    Boolean existsByUsername(String username);
    Boolean existsByEmail(String email);
}

HMSEOF

echo 'Writing src/main/java/com/hms/hospital/security/AuthEntryPointJwt.java...'
cat > 'src/main/java/com/hms/hospital/security/AuthEntryPointJwt.java' << 'HMSEOF'
package com.hms.hospital.security;

import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.security.core.AuthenticationException;
import org.springframework.security.web.AuthenticationEntryPoint;
import org.springframework.stereotype.Component;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

@Component
public class AuthEntryPointJwt implements AuthenticationEntryPoint {

    private static final Logger logger = LoggerFactory.getLogger(AuthEntryPointJwt.class);

    @Override
    public void commence(HttpServletRequest request, HttpServletResponse response,
                          AuthenticationException authException) throws IOException, ServletException {
        logger.error("Unauthorized error: {}", authException.getMessage());

        response.setContentType("application/json");
        response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);

        Map<String, Object> body = new HashMap<>();
        body.put("status", HttpServletResponse.SC_UNAUTHORIZED);
        body.put("error", "Unauthorized");
        body.put("message", "Authentication required: " + authException.getMessage());
        body.put("path", request.getServletPath());

        new ObjectMapper().writeValue(response.getOutputStream(), body);
    }
}

HMSEOF

echo 'Writing src/main/java/com/hms/hospital/security/AuthTokenFilter.java...'
cat > 'src/main/java/com/hms/hospital/security/AuthTokenFilter.java' << 'HMSEOF'
package com.hms.hospital.security;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.web.authentication.WebAuthenticationDetailsSource;
import org.springframework.util.StringUtils;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;

public class AuthTokenFilter extends OncePerRequestFilter {

    @Autowired
    private JwtUtils jwtUtils;

    @Autowired
    private UserDetailsServiceImpl userDetailsService;

    private static final Logger logger = LoggerFactory.getLogger(AuthTokenFilter.class);

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain filterChain)
            throws ServletException, IOException {
        try {
            String jwt = parseJwt(request);
            if (jwt != null && jwtUtils.validateJwtToken(jwt)) {
                String username = jwtUtils.getUsernameFromJwtToken(jwt);

                UserDetails userDetails = userDetailsService.loadUserByUsername(username);
                UsernamePasswordAuthenticationToken authentication =
                        new UsernamePasswordAuthenticationToken(userDetails, null, userDetails.getAuthorities());
                authentication.setDetails(new WebAuthenticationDetailsSource().buildDetails(request));

                SecurityContextHolder.getContext().setAuthentication(authentication);
            }
        } catch (Exception e) {
            logger.error("Cannot set user authentication: {}", e.getMessage());
        }

        filterChain.doFilter(request, response);
    }

    private String parseJwt(HttpServletRequest request) {
        String headerAuth = request.getHeader("Authorization");
        if (StringUtils.hasText(headerAuth) && headerAuth.startsWith("Bearer ")) {
            return headerAuth.substring(7);
        }
        return null;
    }
}

HMSEOF

echo 'Writing src/main/java/com/hms/hospital/security/JwtUtils.java...'
cat > 'src/main/java/com/hms/hospital/security/JwtUtils.java' << 'HMSEOF'
package com.hms.hospital.security;

import io.jsonwebtoken.*;
import io.jsonwebtoken.security.Keys;
import jakarta.annotation.PostConstruct;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Component;

import javax.crypto.SecretKey;
import java.nio.charset.StandardCharsets;
import java.util.Date;

@Component
public class JwtUtils {

    private static final Logger logger = LoggerFactory.getLogger(JwtUtils.class);

    @Value("${jwt.secret}")
    private String jwtSecret;

    @Value("${jwt.expiration}")
    private long jwtExpirationMs;

    private SecretKey signingKey;

    @PostConstruct
    public void init() {
        // Ensure key is long enough for HS256 (32+ bytes)
        byte[] keyBytes = jwtSecret.getBytes(StandardCharsets.UTF_8);
        this.signingKey = Keys.hmacShaKeyFor(keyBytes);
    }

    public String generateJwtToken(Authentication authentication) {
        UserDetailsImpl userPrincipal = (UserDetailsImpl) authentication.getPrincipal();
        return generateTokenFromUsername(userPrincipal.getUsername());
    }

    public String generateTokenFromUsername(String username) {
        Date now = new Date();
        Date expiryDate = new Date(now.getTime() + jwtExpirationMs);

        return Jwts.builder()
                .subject(username)
                .issuedAt(now)
                .expiration(expiryDate)
                .signWith(signingKey)
                .compact();
    }

    public String getUsernameFromJwtToken(String token) {
        return Jwts.parser()
                .verifyWith(signingKey)
                .build()
                .parseSignedClaims(token)
                .getPayload()
                .getSubject();
    }

    public boolean validateJwtToken(String authToken) {
        try {
            Jwts.parser().verifyWith(signingKey).build().parseSignedClaims(authToken);
            return true;
        } catch (MalformedJwtException e) {
            logger.error("Invalid JWT token: {}", e.getMessage());
        } catch (ExpiredJwtException e) {
            logger.error("JWT token is expired: {}", e.getMessage());
        } catch (UnsupportedJwtException e) {
            logger.error("JWT token is unsupported: {}", e.getMessage());
        } catch (IllegalArgumentException e) {
            logger.error("JWT claims string is empty: {}", e.getMessage());
        } catch (io.jsonwebtoken.security.SignatureException e) {
            logger.error("JWT signature validation failed: {}", e.getMessage());
        }
        return false;
    }
}

HMSEOF

echo 'Writing src/main/java/com/hms/hospital/security/UserDetailsImpl.java...'
cat > 'src/main/java/com/hms/hospital/security/UserDetailsImpl.java' << 'HMSEOF'
package com.hms.hospital.security;

import com.hms.hospital.entity.User;
import com.fasterxml.jackson.annotation.JsonIgnore;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;

import java.util.Collection;
import java.util.Collections;
import java.util.Objects;

public class UserDetailsImpl implements UserDetails {

    private final Long id;
    private final String username;
    private final String email;

    @JsonIgnore
    private final String password;

    private final Collection<? extends GrantedAuthority> authorities;

    public UserDetailsImpl(Long id, String username, String email, String password,
                            Collection<? extends GrantedAuthority> authorities) {
        this.id = id;
        this.username = username;
        this.email = email;
        this.password = password;
        this.authorities = authorities;
    }

    public static UserDetailsImpl build(User user) {
        return new UserDetailsImpl(
                user.getId(),
                user.getUsername(),
                user.getEmail(),
                user.getPassword(),
                Collections.singletonList(new SimpleGrantedAuthority("ROLE_" + user.getRole()))
        );
    }

    public Long getId() {
        return id;
    }

    public String getEmail() {
        return email;
    }

    @Override
    public Collection<? extends GrantedAuthority> getAuthorities() {
        return authorities;
    }

    @Override
    public String getPassword() {
        return password;
    }

    @Override
    public String getUsername() {
        return username;
    }

    @Override
    public boolean isAccountNonExpired() {
        return true;
    }

    @Override
    public boolean isAccountNonLocked() {
        return true;
    }

    @Override
    public boolean isCredentialsNonExpired() {
        return true;
    }

    @Override
    public boolean isEnabled() {
        return true;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        UserDetailsImpl user = (UserDetailsImpl) o;
        return Objects.equals(id, user.id);
    }
}

HMSEOF

echo 'Writing src/main/java/com/hms/hospital/security/UserDetailsServiceImpl.java...'
cat > 'src/main/java/com/hms/hospital/security/UserDetailsServiceImpl.java' << 'HMSEOF'
package com.hms.hospital.security;

import com.hms.hospital.entity.User;
import com.hms.hospital.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class UserDetailsServiceImpl implements UserDetailsService {

    @Autowired
    private UserRepository userRepository;

    @Override
    @Transactional
    public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {
        User user = userRepository.findByUsername(username)
                .orElseThrow(() -> new UsernameNotFoundException("User not found with username: " + username));
        return UserDetailsImpl.build(user);
    }
}

HMSEOF

echo 'Writing src/main/java/com/hms/hospital/service/AppointmentService.java...'
cat > 'src/main/java/com/hms/hospital/service/AppointmentService.java' << 'HMSEOF'
package com.hms.hospital.service;

import com.hms.hospital.dto.AppointmentDto;
import com.hms.hospital.entity.Appointment;
import com.hms.hospital.entity.Doctor;
import com.hms.hospital.entity.Patient;
import com.hms.hospital.exception.ResourceNotFoundException;
import com.hms.hospital.repository.AppointmentRepository;
import com.hms.hospital.repository.DoctorRepository;
import com.hms.hospital.repository.PatientRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class AppointmentService {

    @Autowired
    private AppointmentRepository appointmentRepository;

    @Autowired
    private PatientRepository patientRepository;

    @Autowired
    private DoctorRepository doctorRepository;

    public Page<Appointment> getAllAppointments(Pageable pageable) {
        return appointmentRepository.findAll(pageable);
    }

    public Page<Appointment> searchAppointments(String keyword, Pageable pageable) {
        if (keyword == null || keyword.trim().isEmpty()) {
            return appointmentRepository.findAll(pageable);
        }
        return appointmentRepository.search(keyword.trim(), pageable);
    }

    public Appointment getAppointmentById(Long id) {
        return appointmentRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Appointment not found with id: " + id));
    }

    @Transactional
    public Appointment createAppointment(AppointmentDto.Request request) {
        Patient patient = patientRepository.findById(request.getPatientId())
                .orElseThrow(() -> new ResourceNotFoundException("Patient not found with id: " + request.getPatientId()));
        Doctor doctor = doctorRepository.findById(request.getDoctorId())
                .orElseThrow(() -> new ResourceNotFoundException("Doctor not found with id: " + request.getDoctorId()));

        Appointment appointment = new Appointment();
        appointment.setPatient(patient);
        appointment.setDoctor(doctor);
        appointment.setAppointmentDate(request.getAppointmentDate());
        appointment.setAppointmentTime(request.getAppointmentTime());
        appointment.setReason(request.getReason());
        appointment.setStatus(request.getStatus() != null ? request.getStatus() : Appointment.AppointmentStatus.SCHEDULED);

        return appointmentRepository.save(appointment);
    }

    @Transactional
    public Appointment updateAppointment(Long id, AppointmentDto.Request request) {
        Appointment existing = getAppointmentById(id);

        if (request.getPatientId() != null && !request.getPatientId().equals(existing.getPatient().getId())) {
            Patient patient = patientRepository.findById(request.getPatientId())
                    .orElseThrow(() -> new ResourceNotFoundException("Patient not found with id: " + request.getPatientId()));
            existing.setPatient(patient);
        }

        if (request.getDoctorId() != null && !request.getDoctorId().equals(existing.getDoctor().getId())) {
            Doctor doctor = doctorRepository.findById(request.getDoctorId())
                    .orElseThrow(() -> new ResourceNotFoundException("Doctor not found with id: " + request.getDoctorId()));
            existing.setDoctor(doctor);
        }

        existing.setAppointmentDate(request.getAppointmentDate());
        existing.setAppointmentTime(request.getAppointmentTime());
        existing.setReason(request.getReason());
        if (request.getStatus() != null) {
            existing.setStatus(request.getStatus());
        }

        return appointmentRepository.save(existing);
    }

    @Transactional
    public void deleteAppointment(Long id) {
        Appointment appointment = getAppointmentById(id);
        appointmentRepository.delete(appointment);
    }

    /** Maps entity -> flattened response DTO for clean React consumption */
    public AppointmentDto.Response mapToResponse(Appointment a) {
        AppointmentDto.Response dto = new AppointmentDto.Response();
        dto.setId(a.getId());
        dto.setPatientId(a.getPatient().getId());
        dto.setPatientName(a.getPatient().getName());
        dto.setDoctorId(a.getDoctor().getId());
        dto.setDoctorName(a.getDoctor().getName());
        dto.setDoctorSpecialization(a.getDoctor().getSpecialization());
        dto.setAppointmentDate(a.getAppointmentDate());
        dto.setAppointmentTime(a.getAppointmentTime());
        dto.setStatus(a.getStatus());
        dto.setReason(a.getReason());
        dto.setCreatedAt(a.getCreatedAt());
        return dto;
    }
}

HMSEOF

echo 'Writing src/main/java/com/hms/hospital/service/AuthService.java...'
cat > 'src/main/java/com/hms/hospital/service/AuthService.java' << 'HMSEOF'
package com.hms.hospital.service;

import com.hms.hospital.dto.AuthDtos.JwtResponse;
import com.hms.hospital.dto.AuthDtos.LoginRequest;
import com.hms.hospital.dto.AuthDtos.RegisterRequest;
import com.hms.hospital.entity.User;
import com.hms.hospital.exception.DuplicateResourceException;
import com.hms.hospital.repository.UserRepository;
import com.hms.hospital.security.JwtUtils;
import com.hms.hospital.security.UserDetailsImpl;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

@Service
public class AuthService {

    @Autowired
    private AuthenticationManager authenticationManager;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @Autowired
    private JwtUtils jwtUtils;

    public JwtResponse login(LoginRequest loginRequest) {
        Authentication authentication = authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(loginRequest.getUsername(), loginRequest.getPassword())
        );

        SecurityContextHolder.getContext().setAuthentication(authentication);

        String jwt = jwtUtils.generateJwtToken(authentication);
        UserDetailsImpl userDetails = (UserDetailsImpl) authentication.getPrincipal();
        String role = userDetails.getAuthorities().iterator().next().getAuthority().replace("ROLE_", "");

        return new JwtResponse(jwt, userDetails.getId(), userDetails.getUsername(), userDetails.getEmail(), role);
    }

    public User register(RegisterRequest registerRequest) {
        if (userRepository.existsByUsername(registerRequest.getUsername())) {
            throw new DuplicateResourceException("Username is already taken");
        }
        if (userRepository.existsByEmail(registerRequest.getEmail())) {
            throw new DuplicateResourceException("Email is already in use");
        }

        User user = new User();
        user.setUsername(registerRequest.getUsername());
        user.setEmail(registerRequest.getEmail());
        user.setPassword(passwordEncoder.encode(registerRequest.getPassword()));
        user.setRole(registerRequest.getRole() != null ? registerRequest.getRole().toUpperCase() : "ADMIN");

        return userRepository.save(user);
    }
}

HMSEOF

echo 'Writing src/main/java/com/hms/hospital/service/DashboardService.java...'
cat > 'src/main/java/com/hms/hospital/service/DashboardService.java' << 'HMSEOF'
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

HMSEOF

echo 'Writing src/main/java/com/hms/hospital/service/DoctorService.java...'
cat > 'src/main/java/com/hms/hospital/service/DoctorService.java' << 'HMSEOF'
package com.hms.hospital.service;

import com.hms.hospital.dto.DoctorDto;
import com.hms.hospital.entity.Doctor;
import com.hms.hospital.exception.DuplicateResourceException;
import com.hms.hospital.exception.ResourceNotFoundException;
import com.hms.hospital.repository.DoctorRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class DoctorService {

    @Autowired
    private DoctorRepository doctorRepository;

    public Page<Doctor> getAllDoctors(Pageable pageable) {
        return doctorRepository.findAll(pageable);
    }

    public Page<Doctor> searchDoctors(String keyword, Pageable pageable) {
        if (keyword == null || keyword.trim().isEmpty()) {
            return doctorRepository.findAll(pageable);
        }
        return doctorRepository.search(keyword.trim(), pageable);
    }

    public Doctor getDoctorById(Long id) {
        return doctorRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Doctor not found with id: " + id));
    }

    @Transactional
    public Doctor createDoctor(DoctorDto dto) {
        if (doctorRepository.existsByEmail(dto.getEmail())) {
            throw new DuplicateResourceException("A doctor with this email already exists");
        }
        Doctor doctor = mapToEntity(dto);
        return doctorRepository.save(doctor);
    }

    @Transactional
    public Doctor updateDoctor(Long id, DoctorDto dto) {
        Doctor existing = getDoctorById(id);

        // If email changed, ensure uniqueness
        if (!existing.getEmail().equalsIgnoreCase(dto.getEmail()) && doctorRepository.existsByEmail(dto.getEmail())) {
            throw new DuplicateResourceException("A doctor with this email already exists");
        }

        existing.setName(dto.getName());
        existing.setSpecialization(dto.getSpecialization());
        existing.setEmail(dto.getEmail());
        existing.setPhone(dto.getPhone());
        existing.setQualification(dto.getQualification());
        existing.setExperienceYears(dto.getExperienceYears() != null ? dto.getExperienceYears() : 0);
        existing.setConsultationFee(dto.getConsultationFee());
        existing.setAvailable(dto.getAvailable() != null ? dto.getAvailable() : existing.getAvailable());

        return doctorRepository.save(existing);
    }

    @Transactional
    public void deleteDoctor(Long id) {
        Doctor doctor = getDoctorById(id);
        doctorRepository.delete(doctor);
    }

    private Doctor mapToEntity(DoctorDto dto) {
        Doctor doctor = new Doctor();
        doctor.setName(dto.getName());
        doctor.setSpecialization(dto.getSpecialization());
        doctor.setEmail(dto.getEmail());
        doctor.setPhone(dto.getPhone());
        doctor.setQualification(dto.getQualification());
        doctor.setExperienceYears(dto.getExperienceYears() != null ? dto.getExperienceYears() : 0);
        doctor.setConsultationFee(dto.getConsultationFee());
        doctor.setAvailable(dto.getAvailable() != null ? dto.getAvailable() : true);
        return doctor;
    }
}

HMSEOF

echo 'Writing src/main/java/com/hms/hospital/service/PatientService.java...'
cat > 'src/main/java/com/hms/hospital/service/PatientService.java' << 'HMSEOF'
package com.hms.hospital.service;

import com.hms.hospital.dto.PatientDto;
import com.hms.hospital.entity.Patient;
import com.hms.hospital.exception.ResourceNotFoundException;
import com.hms.hospital.repository.PatientRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class PatientService {

    @Autowired
    private PatientRepository patientRepository;

    public Page<Patient> getAllPatients(Pageable pageable) {
        return patientRepository.findAll(pageable);
    }

    public Page<Patient> searchPatients(String keyword, Pageable pageable) {
        if (keyword == null || keyword.trim().isEmpty()) {
            return patientRepository.findAll(pageable);
        }
        return patientRepository.search(keyword.trim(), pageable);
    }

    public Patient getPatientById(Long id) {
        return patientRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Patient not found with id: " + id));
    }

    @Transactional
    public Patient createPatient(PatientDto dto) {
        Patient patient = new Patient();
        mapDtoToEntity(dto, patient);
        return patientRepository.save(patient);
    }

    @Transactional
    public Patient updatePatient(Long id, PatientDto dto) {
        Patient existing = getPatientById(id);
        mapDtoToEntity(dto, existing);
        return patientRepository.save(existing);
    }

    @Transactional
    public void deletePatient(Long id) {
        Patient patient = getPatientById(id);
        patientRepository.delete(patient);
    }

    private void mapDtoToEntity(PatientDto dto, Patient patient) {
        patient.setName(dto.getName());
        patient.setAge(dto.getAge());
        patient.setGender(dto.getGender());
        patient.setEmail(dto.getEmail());
        patient.setPhone(dto.getPhone());
        patient.setAddress(dto.getAddress());
    }
}

HMSEOF

echo 'Writing src/main/java/com/hms/hospital/service/ReportService.java...'
cat > 'src/main/java/com/hms/hospital/service/ReportService.java' << 'HMSEOF'
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

HMSEOF

echo 'Writing src/main/resources/application.properties...'
cat > 'src/main/resources/application.properties' << 'HMSEOF'
# ============================================================
# Hospital Management System - application.properties
# ============================================================

# Server
server.port=8080

# ---- MySQL Database ----
spring.datasource.url=jdbc:mysql://localhost:3306/hospital_db?useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true
spring.datasource.username=root
spring.datasource.password=YOUR_MYSQL_PASSWORD
spring.datasource.driver-class-name=com.mysql.cj.jdbc.Driver

# ---- JPA / Hibernate ----
spring.jpa.hibernate.ddl-auto=update
spring.jpa.show-sql=true
spring.jpa.properties.hibernate.format_sql=true
spring.jpa.database-platform=org.hibernate.dialect.MySQLDialect
spring.jpa.open-in-view=false

# ---- JWT ----
# 256-bit (32+ char) secret used to sign tokens - change this in production
jwt.secret=hms_super_secret_key_change_this_in_production_1234567890
# Token validity in milliseconds (24 hours)
jwt.expiration=86400000

# ---- CORS ----
app.cors.allowed-origins=http://localhost:3000

# ---- Logging ----
logging.level.org.springframework.security=INFO
logging.level.com.hms.hospital=DEBUG

HMSEOF

echo "Backend files created successfully."
echo "Now run: cd backend && mvn clean install -DskipTests"
