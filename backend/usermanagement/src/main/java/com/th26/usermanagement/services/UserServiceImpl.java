package com.th26.usermanagement.services;

import com.th26.usermanagement.entities.User;
import com.th26.usermanagement.entities.Profile;
import com.th26.usermanagement.repositories.UserRepository;

import org.springframework.stereotype.Service;

interface UserService {
    User getUserByEmail(String email);
    Profile getProfileByEmail(String email);
}

@Service
public class UserServiceImpl implements UserService {
    private final UserRepository userRepository;

    public UserServiceImpl(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    @Override
    public User getUserByEmail(String email) {
        User user = userRepository.findByEmail(email).orElse(null);

        if (user == null) {
            // TODO: Throw with proper exception
            return null;
        }
        return user;
    }

    @Override
    public Profile getProfileByEmail(String email) {
        User user = userRepository.findByEmail(email).orElse(null);
        if (user == null) {
            // TODO: Throw with proper exception
            return null;
        }
        return user.getProfile();
    }
}
