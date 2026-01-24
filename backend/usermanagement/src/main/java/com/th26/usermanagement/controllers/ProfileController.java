package com.th26.usermanagement.controllers;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.bind.annotation.PathVariable;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.Pattern;

import com.th26.usermanagement.dtos.responses.ProfileResponse;
import com.th26.usermanagement.services.ProfileService;

@RestController
@Validated
@RequestMapping("/usermanagement/api/profile")
public class ProfileController {
    @Autowired
    private ProfileService profileService;

    @GetMapping("/{email}")
    public ResponseEntity<ProfileResponse> getProfileByEmail(@PathVariable("email") @Email(regexp = "^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Z]{2,}$", flags = Pattern.Flag.CASE_INSENSITIVE) String email) {
        return ResponseEntity.ok(profileService.getProfileByEmail(email));
    }
}
