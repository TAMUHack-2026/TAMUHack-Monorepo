package com.th26.usermanagement.controllers;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.bind.annotation.PathVariable;

import com.th26.usermanagement.dtos.responses.ProfileResponse;
import com.th26.usermanagement.services.UserService;

@RestController
@RequestMapping("/usermanagement/api/profile")
public class ProfileController {
    @Autowired
    private UserService userService;

    @GetMapping("/{email}")
    public ResponseEntity<ProfileResponse> getProfileByEmail(@PathVariable("email") String email) {
        return ResponseEntity.ok(userService.getProfileByEmail(email));
    }
}
