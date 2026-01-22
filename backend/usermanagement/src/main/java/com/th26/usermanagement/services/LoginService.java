package com.th26.usermanagement.services;

import com.th26.usermanagement.dtos.requests.UserRequest;
import com.th26.usermanagement.dtos.requests.LoginRequest;

public interface LoginService {
    void createUser(UserRequest request);
    void updateUser(UserRequest request);
    void deleteUserByEmail(String email);
    boolean validateCredentials(LoginRequest request);
}
