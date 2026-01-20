package com.th26.usermanagement.entities;

import jakarta.persistence.Entity;
import jakarta.persistence.Table;
import jakarta.persistence.Id;
import jakarta.persistence.OneToOne;
import jakarta.persistence.MapsId;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.Column;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Pattern;

import java.util.UUID;
import java.math.BigDecimal;

@Entity
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
    @NotBlank
    @Min(0)
    @Max(150)
    private short age;

    @Column(nullable = false)
    @NotBlank
    @Pattern(regexp = "^(male|female)$")
    private String sex;

    @Column(name = "gender_identity")
    private String genderIdentity;

    @Column(name = "height_in", nullable = false, precision = 4, scale = 2)
    @NotBlank
    private BigDecimal height;

    @Column(name = "weight_lbs", nullable = false, precision = 5, scale = 2)
    @NotBlank
    private BigDecimal weight;

    public Profile() {}

    public UUID getId() {
        return this.id;
    }

    public User getUser() {
        return this.user;
    }

    public void setUser(User user) {
        this.user = user;
    }

    public String getFirstName() {
        return this.firstName;
    }

    public void setFirstName(String firstName) {
        this.firstName = firstName;
    }

    public String getLastName() {
        return this.lastName;
    }

    public void setLastName(String lastName) {
        this.lastName = lastName;
    }

    public short getAge() {
        return this.age;
    }

    public void setAge(short age) throws IllegalArgumentException {
        if (age < 0 || age > 150) {
            throw new IllegalArgumentException("Age must be between 0 and 150");
        }
        this.age = age;
    }

    public String getSex() {
        return this.sex;
    }
    
    public void setSex(String sex) throws IllegalArgumentException {
        if (sex == null || !(sex.equals("male") || sex.equals("female")) ) {
            throw new IllegalArgumentException("Sex must be either 'male' or 'female'");
        }
        this.sex = sex;
    }

    public String getGenderIdentity() {
        return this.genderIdentity;
    }

    public void setGenderIdentity(String genderIdentity) {
        this.genderIdentity = genderIdentity;
    }

    public BigDecimal getHeight() {
        return this.height;
    }

    public void setHeight(BigDecimal height) throws IllegalArgumentException {
        if (height.compareTo(BigDecimal.ZERO) <= 0) {
            throw new IllegalArgumentException("Height must be a positive value");
        }
        this.height = height;
    }

    public BigDecimal getWeight() {
        return this.weight;
    }

    public void setWeight(BigDecimal weight) throws IllegalArgumentException {
        if (weight.compareTo(BigDecimal.ZERO) <= 0) {
            throw new IllegalArgumentException("Weight must be a positive value");
        }
        this.weight = weight;
    }
}
