package com.th26.usermanagement.services;

import com.th26.usermanagement.entities.User;
import com.th26.usermanagement.entities.Profile;
import com.th26.usermanagement.repositories.UserRepository;
import com.th26.usermanagement.repositories.ProfileRepository;

import org.springframework.stereotype.Service;

interface UserService {
    // TODO: Fix create and update methods to use DTOs
    void createUser(User user, Profile profile);
    void updateUser(User user, Profile profile);
    User getUserByEmail(String email);
    boolean deleteUserByEmail(String email);
    Profile getProfileByEmail(String email);
}

@Service
public class UserServiceImpl implements UserService {
    private final UserRepository userRepository;
    private final ProfileRepository profileRepository;

    public UserServiceImpl(UserRepository userRepository, ProfileRepository profileRepository) {
        this.userRepository = userRepository;
        this.profileRepository = profileRepository;
    }

    @Override
    public void createUser(User user, Profile profile) {
        // Implementation here
    }

    @Override
    public void updateUser(User user, Profile profile) {
        // Implementation here
    }

    @Override
    public User getUserByEmail(String email) {
        return userRepository.findByEmail(email).orElse(null);
    }

    @Override
    public boolean deleteUserByEmail(String email) {
        User toDelete = userRepository.findByEmail(email).orElse(null);
        if (toDelete != null) {
            userRepository.delete(toDelete);
            return true;
        }
        return false;
    }

    @Override
    public Profile getProfileByEmail(String email) {
        User user = userRepository.findByEmail(email).orElse(null);
        if (user != null) {
            return user.getProfile();
        } else {
            return null;
        }
    }
}
