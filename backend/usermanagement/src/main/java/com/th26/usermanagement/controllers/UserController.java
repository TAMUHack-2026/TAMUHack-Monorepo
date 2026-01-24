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
import org.springframework.web.servlet.support.ServletUriComponentsBuilder;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.Pattern;

import com.th26.usermanagement.services.LoginService;
import com.th26.usermanagement.dtos.requests.CreateValidation;
import com.th26.usermanagement.dtos.requests.UpdateValidation;
import com.th26.usermanagement.dtos.requests.UserRequest;

import java.util.UUID;
import java.net.URI;

@RestController
@Validated
@RequestMapping("/usermanagement/api/user")
public class UserController {
    @Autowired
    private LoginService loginService;

    @PostMapping
    public ResponseEntity<String> createUser(@Validated(CreateValidation.class) @RequestBody UserRequest request) {
        UUID id = loginService.createUser(request);
        URI location = ServletUriComponentsBuilder.fromCurrentRequest()
                .path("/{id}")
                .buildAndExpand(id)
                .toUri();
        return ResponseEntity.created(location).body(id.toString());
    }

    @PatchMapping
    public ResponseEntity<String> updateUser(@Validated(UpdateValidation.class) @RequestBody UserRequest request) {
        loginService.updateUser(request);
        return ResponseEntity.ok("User updated successfully");
    }
    
    @DeleteMapping("/{email}")
    public ResponseEntity<String> deleteUser(@PathVariable("email") @Email(regexp = "^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Z]{2,}$", flags = Pattern.Flag.CASE_INSENSITIVE) String email) {
        loginService.deleteUserByEmail(email);
        return ResponseEntity.ok("User deleted successfully");
    }
}
