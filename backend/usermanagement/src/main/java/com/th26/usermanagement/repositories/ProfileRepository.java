package com.th26.usermanagement.repositories;

import com.th26.usermanagement.entities.Profile;

import org.springframework.data.jpa.repository.JpaRepository;

import java.util.UUID;

public interface ProfileRepository extends JpaRepository<Profile, UUID> {}
