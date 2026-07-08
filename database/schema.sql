CREATE DATABASE IF NOT EXISTS hospital_db;
USE hospital_db;

CREATE TABLE IF NOT EXISTS users (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    role VARCHAR(20) NOT NULL DEFAULT 'ADMIN',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS doctors (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    specialization VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(20) NOT NULL,
    qualification VARCHAR(150),
    experience_years INT DEFAULT 0,
    consultation_fee DECIMAL(10,2) DEFAULT 0.00,
    available BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS patients (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    age INT,
    gender VARCHAR(10),
    email VARCHAR(100),
    phone VARCHAR(20) NOT NULL,
    address VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS appointments (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    patient_id BIGINT NOT NULL,
    doctor_id BIGINT NOT NULL,
    appointment_date DATE NOT NULL,
    appointment_time TIME NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'SCHEDULED',
    reason VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_appt_patient FOREIGN KEY (patient_id) REFERENCES patients(id) ON DELETE CASCADE,
    CONSTRAINT fk_appt_doctor FOREIGN KEY (doctor_id) REFERENCES doctors(id) ON DELETE CASCADE
);

INSERT INTO doctors (name, specialization, email, phone, qualification, experience_years, consultation_fee, available) VALUES
('Dr. Ananya Rao', 'Cardiology', 'ananya.rao@hospital.com', '9876543210', 'MBBS, MD (Cardiology)', 12, 800.00, TRUE),
('Dr. Vikram Shah', 'Orthopedics', 'vikram.shah@hospital.com', '9876543211', 'MBBS, MS (Ortho)', 9, 600.00, TRUE),
('Dr. Priya Menon', 'Pediatrics', 'priya.menon@hospital.com', '9876543212', 'MBBS, MD (Pediatrics)', 7, 500.00, TRUE),
('Dr. Arjun Verma', 'Dermatology', 'arjun.verma@hospital.com', '9876543213', 'MBBS, MD (Derma)', 5, 450.00, TRUE),
('Dr. Kavita Iyer', 'Neurology', 'kavita.iyer@hospital.com', '9876543214', 'MBBS, DM (Neuro)', 15, 1000.00, FALSE);

INSERT INTO patients (name, age, gender, email, phone, address) VALUES
('Rahul Sharma', 34, 'Male', 'rahul.sharma@mail.com', '9000000001', 'Pune, MH'),
('Sneha Patil', 28, 'Female', 'sneha.patil@mail.com', '9000000002', 'Mumbai, MH'),
('Karan Mehta', 45, 'Male', 'karan.mehta@mail.com', '9000000003', 'Ahmedabad, GJ'),
('Divya Nair', 31, 'Female', 'divya.nair@mail.com', '9000000004', 'Kochi, KL');

INSERT INTO appointments (patient_id, doctor_id, appointment_date, appointment_time, status, reason) VALUES
(1, 1, CURDATE(), '10:00:00', 'SCHEDULED', 'Chest pain follow-up'),
(2, 3, CURDATE(), '11:30:00', 'SCHEDULED', 'Child vaccination'),
(3, 2, CURDATE() - INTERVAL 1 DAY, '09:00:00', 'COMPLETED', 'Knee pain'),
(4, 4, CURDATE() - INTERVAL 2 DAY, '15:00:00', 'CANCELLED', 'Skin rash'),
(1, 1, CURDATE() + INTERVAL 3 DAY, '10:30:00', 'SCHEDULED', 'Routine checkup');