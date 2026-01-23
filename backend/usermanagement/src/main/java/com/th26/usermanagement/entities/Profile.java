package com.th26.usermanagement.entities;

import jakarta.persistence.Entity;
import jakarta.persistence.Table;
import jakarta.persistence.Id;
import jakarta.persistence.OneToOne;
import jakarta.persistence.MapsId;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.Column;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Pattern;

import lombok.Builder;
import lombok.Getter;
import lombok.Setter;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

import java.util.UUID;
import java.math.BigDecimal;

@Entity
@Builder
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Table(name = "profiles")
public class Profile {
    @Id
    private UUID id;

    @OneToOne
    @MapsId
    @JoinColumn(name = "id")
    private User user;

    @Column(name = "first_name", nullable = false)
    @NotBlank
    private String firstName;

    @Column(name = "last_name", nullable = false)
    @NotBlank
    private String lastName;

    @Column(nullable = false)
    @NotNull
    @Min(0)
    @Max(150)
    private Short age;

    @Column(nullable = false)
    @NotBlank
    @Pattern(regexp = "^(male|female)$")
    private String sex;

    @Column(name = "gender_identity")
    private String genderIdentity;

    @Column(name = "height_in", nullable = false, precision = 4, scale = 2)
    @NotNull
    private BigDecimal height;

    @Column(name = "weight_lbs", nullable = false, precision = 5, scale = 2)
    @NotNull
    private BigDecimal weight;
}
