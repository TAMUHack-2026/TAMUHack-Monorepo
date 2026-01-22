package com.th26.usermanagement.services;

import com.th26.usermanagement.dtos.responses.ProfileResponse;

public interface UserService {
    ProfileResponse getProfileByEmail(String email);
}

