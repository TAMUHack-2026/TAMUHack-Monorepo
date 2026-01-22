package com.th26.usermanagement.controllers;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.th26.usermanagement.dtos.responses.ProfileResponse;
import com.th26.usermanagement.services.UserService;

@RestController
@RequestMapping("/usermanagement/api/profile")
public class ProfileController {
    @Autowired
    private UserService userService;

    @GetMapping("/{email}")
    public ResponseEntity<ProfileResponse> getProfileByEmail(String email) {
        return ResponseEntity.ok(userService.getProfileByEmail(email));
    }
}
