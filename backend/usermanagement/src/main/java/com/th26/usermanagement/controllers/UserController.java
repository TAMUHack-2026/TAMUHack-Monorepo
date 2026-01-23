package com.th26.usermanagement.controllers;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.th26.usermanagement.services.LoginService;
import com.th26.usermanagement.dtos.requests.CreateValidation;
import com.th26.usermanagement.dtos.requests.UserRequest;

@RestController
@RequestMapping("/usermanagement/api/user")
public class UserController {
    @Autowired
    private LoginService loginService;

    @PostMapping
    public ResponseEntity<String> createUser(@Validated(CreateValidation.class) @RequestBody UserRequest request) {
        loginService.createUser(request);
        return ResponseEntity.ok("User created successfully");
    }

    @PatchMapping
    public ResponseEntity<String> updateUser(@RequestBody UserRequest request) {
        loginService.updateUser(request);
        return ResponseEntity.ok("User updated successfully");
    }
    
    @DeleteMapping("/{email}")
    public ResponseEntity<String> deleteUser(@PathVariable String email) {
        loginService.deleteUserByEmail(email);
        return ResponseEntity.ok("User deleted successfully");
    }
}
