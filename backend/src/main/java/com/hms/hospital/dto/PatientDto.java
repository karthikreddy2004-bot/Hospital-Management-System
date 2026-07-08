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

